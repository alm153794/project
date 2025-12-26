import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import java.io.InputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/sendFeedbackReply")
public class EmailSenderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private Properties emailConfig;
    
    @Override
    public void init() throws ServletException {
        super.init();
        emailConfig = new Properties();
        try {
            InputStream is = getServletContext().getResourceAsStream("/WEB-INF/email-config.properties");
            if (is != null) {
                emailConfig.load(is);
            }
        } catch (Exception e) {
            log("Failed to load email configuration: " + e.getMessage());
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Check authentication
        if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            int feedbackId = Integer.parseInt(request.getParameter("feedbackId"));
            String replyMessage = request.getParameter("replyMessage");
            
            // Get feedback details from database
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
            
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT name, email, subject, message FROM feedback WHERE feedback_id = ?");
            stmt.setInt(1, feedbackId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String customerName = rs.getString("name");
                String customerEmail = rs.getString("email");
                String originalSubject = rs.getString("subject");
                String originalMessage = rs.getString("message");
                
                // For now, just save the reply to database and show success
                // Email functionality can be enabled when JavaMail API is added
                PreparedStatement updateStmt = conn.prepareStatement(
                    "UPDATE feedback SET admin_reply = ?, status = 'resolved', " +
                    "updated_date = CURRENT_TIMESTAMP WHERE feedback_id = ?");
                updateStmt.setString(1, replyMessage);
                updateStmt.setInt(2, feedbackId);
                int result = updateStmt.executeUpdate();
                
                if (result > 0) {
                    // Create email content for manual sending or future automation
                    String emailContent = createEmailContent(customerName, originalSubject, 
                                                            originalMessage, replyMessage);
                    
                    // Log the email content for manual sending
                    log("Email to be sent to " + customerEmail + ":\n" + emailContent);
                    
                    session.setAttribute("message", 
                        "Reply saved successfully! Email content logged for manual sending to: " + customerEmail);
                } else {
                    session.setAttribute("error", "Failed to save reply. Please try again.");
                }
            }
            
            conn.close();
            
        } catch (Exception e) {
            session.setAttribute("error", "Error: " + e.getMessage());
        }
        
        response.sendRedirect("reply-feedback.jsp?id=" + request.getParameter("feedbackId"));
    }
    
    private String createEmailContent(String customerName, String originalSubject, 
                                     String originalMessage, String replyMessage) {
        return String.format(
            "To: %s\n" +
            "Subject: Re: %s\n\n" +
            "Dear %s,\n\n" +
            "Thank you for your feedback regarding: \"%s\"\n\n" +
            "Your original message:\n" +
            "\"%s\"\n\n" +
            "Our response:\n" +
            "%s\n\n" +
            "Best regards,\n" +
            "East Gojjam VIMS Administration Team\n" +
            "Email: %s\n" +
            "Phone: %s\n" +
            "Address: %s",
            customerName, originalSubject, customerName, originalSubject, 
            originalMessage, replyMessage,
            emailConfig.getProperty("email.username", "eastgojjamvims@gmail.com"),
            emailConfig.getProperty("system.phone", "+251-11-XXX-XXXX"),
            emailConfig.getProperty("system.address", "Debre Markos, East Gojjam Zone")
        );
    }
}