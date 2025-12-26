import java.io.IOException;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            return password;
        }
    }
    
    private boolean verifyPassword(String inputPassword, String storedPassword) {
        // Try plain text first
        if (inputPassword.equals(storedPassword)) {
            return true;
        }
        
        // Try SHA-256 hash
        String hashedInput = hashPassword(inputPassword);
        if (hashedInput.equals(storedPassword)) {
            return true;
        }
        
        // Try user-management.jsp hashing method (salt:hash with 10000 iterations)
        if (storedPassword.contains(":")) {
            try {
                String[] parts = storedPassword.split(":");
                String saltBase64 = parts[0];
                String expectedHash = parts[1];
                
                byte[] salt = Base64.getDecoder().decode(saltBase64);
                
                // Match the exact method from user-management.jsp
                MessageDigest md = MessageDigest.getInstance("SHA-256");
                md.update(salt);
                byte[] hashedPassword = md.digest(inputPassword.getBytes("UTF-8"));
                
                // Apply 10000 iterations like in user-management.jsp
                for (int i = 0; i < 10000; i++) {
                    md.reset();
                    hashedPassword = md.digest(hashedPassword);
                }
                
                String computedHash = Base64.getEncoder().encodeToString(hashedPassword);
                return computedHash.equals(expectedHash);
                
            } catch (Exception e) {
                return false;
            }
        }
        
        return false;
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect("index.jsp");
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
            
            // First check if user exists
            String checkSql = "SELECT user_id, username, full_name, role, status, password FROM users WHERE username = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            
            ResultSet checkRs = checkStmt.executeQuery();
            
            if (checkRs.next()) {
                String userStatus = checkRs.getString("status");
                String storedPassword = checkRs.getString("password");
                
                // Check if password matches first
                if (verifyPassword(password, storedPassword)) {
                    // Password is correct, now check status
                    if ("active".equals(userStatus)) {
                        HttpSession session = request.getSession();
                        session.setAttribute("userId", checkRs.getInt("user_id"));
                        session.setAttribute("username", checkRs.getString("username"));
                        session.setAttribute("fullName", checkRs.getString("full_name"));
                        session.setAttribute("role", checkRs.getString("role"));
                        
                        response.sendRedirect("dashboard.jsp");
                    } else {
                        request.setAttribute("error", "Access denied: Your account has been deactivated. Please contact administrator.");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "Invalid username or password");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Invalid username or password");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            
            conn.close();
            
        } catch (Exception e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}