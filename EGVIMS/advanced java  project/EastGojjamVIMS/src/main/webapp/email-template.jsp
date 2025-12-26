<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    int feedbackId = Integer.parseInt(request.getParameter("id"));
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Email Template - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .email-template { background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); font-family: 'Courier New', monospace; }
        .copy-btn { background: #28a745; color: white; padding: 0.5rem 1rem; border: none; border-radius: 5px; cursor: pointer; margin: 1rem 0; }
        .email-content { background: #f8f9fa; padding: 1rem; border-radius: 5px; border: 1px solid #dee2e6; white-space: pre-wrap; }
        .btn { padding: 1rem 2rem; border: none; border-radius: 25px; cursor: pointer; font-weight: bold; text-decoration: none; display: inline-block; margin: 0.5rem; }
        .btn-secondary { background: #6c757d; color: white; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <h2> Email Template</h2>
        
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM feedback WHERE feedback_id = ?");
                stmt.setInt(1, feedbackId);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    String customerName = rs.getString("name");
                    String customerEmail = rs.getString("email");
                    String originalSubject = rs.getString("subject");
                    String originalMessage = rs.getString("message");
                    String adminReply = rs.getString("admin_reply");
                    
                    if (adminReply != null && !adminReply.trim().isEmpty()) {
        %>
        
        <div class="email-template">
            <h4>Copy this email content and send manually:</h4>
            <button class="copy-btn" onclick="copyToClipboard()"> Copy Email Content</button>
            
            <div class="email-content" id="emailContent"><img src="uploads/images/logo.jpg" alt="East Gojjam VIMS Logo" style="max-width: 200px; height: auto; margin-bottom: 20px;">

To: <%= customerEmail %>
Subject: Re: <%= originalSubject %>

Dear <%= customerName %>,

Thank you for your feedback regarding: "<%= originalSubject %>"

Your original message:
"<%= originalMessage %>"

Our response:
<%= adminReply %>

Best regards,
East Gojjam VIMS Administration Team
Email: eastgojjamvims@gmail.com
Phone: +251-11-XXX-XXXX
Address: Debre Markos, East Gojjam Zone, Amhara Region, Ethiopia</div>
            
            <div style="margin-top: 1rem;">
                <strong>Customer Email:</strong> <a href="mailto:<%= customerEmail %>?subject=Re: <%= originalSubject %>&body=<%= java.net.URLEncoder.encode("Dear " + customerName + ",\n\nThank you for your feedback regarding: \"" + originalSubject + "\"\n\nYour original message:\n\"" + originalMessage + "\"\n\nOur response:\n" + adminReply + "\n\nBest regards,\nEast Gojjam VIMS Administration Team", "UTF-8") %>"><%= customerEmail %></a>
            </div>
        </div>
        
        <%
                    } else {
                        out.println("<div class='error'>No reply found for this feedback. Please add a reply first.</div>");
                    }
                }
                conn.close();
            } catch (Exception e) {
                out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
            }
        %>
        
        <div>
            <a href="reply-feedback.jsp?id=<%= feedbackId %>" class="btn btn-secondary">← Back to Reply</a>
            <a href="manage-feedback.jsp" class="btn btn-secondary">← Back to Feedback List</a>
        </div>
    </div>
    
    <script>
        function copyToClipboard() {
            const emailContent = document.getElementById('emailContent');
            const textArea = document.createElement('textarea');
            textArea.value = emailContent.textContent;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            
            const btn = document.querySelector('.copy-btn');
            const originalText = btn.textContent;
            btn.textContent = '✅ Copied!';
            btn.style.background = '#28a745';
            
            setTimeout(() => {
                btn.textContent = originalText;
                btn.style.background = '#28a745';
            }, 2000);
        }
    </script>
    
    <%@ include file="footer.jsp" %>
</body>
</html>