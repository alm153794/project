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
    <title>Reply to Feedback - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .reply-form { background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 1rem; }
        .form-group label { display: block; color: #2c3e50; font-weight: 600; margin-bottom: 0.5rem; }
        .form-group input, .form-group textarea { width: 100%; padding: 1rem; border: 2px solid #e0e6ed; border-radius: 10px; font-size: 1rem; box-sizing: border-box; }
        .form-group textarea { min-height: 120px; resize: vertical; }
        .btn { padding: 1rem 2rem; border: none; border-radius: 25px; cursor: pointer; font-weight: bold; text-decoration: none; display: inline-block; margin: 0.5rem; }
        .btn-primary { background: linear-gradient(135deg, #4facfe, #00f2fe); color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .original-feedback { background: #f8f9fa; padding: 1rem; border-radius: 10px; margin-bottom: 1.5rem; }
        .success-message { background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; }
        .error-message { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <h2>↩️ Reply to Feedback</h2>
        
        <% 
            if (session.getAttribute("message") != null) {
                out.println("<div class='success-message'>" + session.getAttribute("message") + "</div>");
                session.removeAttribute("message");
            }
            if (session.getAttribute("error") != null) {
                out.println("<div class='error-message'>" + session.getAttribute("error") + "</div>");
                session.removeAttribute("error");
            }
        %>
        
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM feedback WHERE feedback_id = ?");
                stmt.setInt(1, feedbackId);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
        %>
        
        <div class="original-feedback">
            <h4>Original Feedback:</h4>
            <strong>From:</strong> <%= rs.getString("name") %> (<%= rs.getString("email") %>)<br>
            <strong>Subject:</strong> <%= rs.getString("subject") %><br>
            <strong>Message:</strong> <%= rs.getString("message") %>
        </div>
        
        <div class="reply-form">
            <form action="sendFeedbackReply" method="post">
                <input type="hidden" name="feedbackId" value="<%= feedbackId %>">
                <div class="form-group">
                    <label for="replyMessage">Your Response:</label>
                    <textarea name="replyMessage" id="replyMessage" placeholder="Type your response here..." required><%= rs.getString("admin_reply") != null ? rs.getString("admin_reply") : "" %></textarea>
                </div>
                
                <div>
                    <button type="submit" class="btn btn-primary"> Save Reply</button>
                    <% if (rs.getString("admin_reply") != null && !rs.getString("admin_reply").trim().isEmpty()) { %>
                        <a href="email-template.jsp?id=<%= feedbackId %>" class="btn" style="background: #17a2b8; color: white;"> Get Email Template</a>
                    <% } %>
                    <a href="manage-feedback.jsp" class="btn btn-secondary">← Back to List</a>
                </div>
            </form>
        </div>
        
        <%
                }
                conn.close();
            } catch (Exception e) {
                out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
            }
        %>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>