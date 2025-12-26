<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Feedback - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .feedback-card { background: white; padding: 1.5rem; border-radius: 10px; margin: 1rem 0; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .feedback-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
        .feedback-meta { color: #666; font-size: 0.9rem; }
        .feedback-actions { display: flex; gap: 0.5rem; }
        .btn { padding: 0.5rem 1rem; border: none; border-radius: 20px; cursor: pointer; font-size: 0.8rem; text-decoration: none; display: inline-block; }
        .btn-reply { background: #4facfe; color: white; }
        .btn-delete { background: #dc3545; color: white; }
        .btn-view { background: #28a745; color: white; }
        .success-message { background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; }
        .error-message { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <h2> Feedback Management</h2>
        
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
                
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM feedback ORDER BY created_date DESC");
                
                while (rs.next()) {
        %>
        <div class="feedback-card">
            <div class="feedback-header">
                <div>
                    <strong><%= rs.getString("name") %></strong>
                    <div class="feedback-meta">
                         <%= rs.getString("email") %> |  <%= rs.getTimestamp("created_date") %>
                    </div>
                </div>
                <div class="feedback-actions">
                    <a href="view-feedback.jsp?id=<%= rs.getInt("feedback_id") %>" class="btn btn-view"> View</a>
                    <a href="reply-feedback.jsp?id=<%= rs.getInt("feedback_id") %>" class="btn btn-reply"> Reply</a>
                    <% if ("resolved".equals(rs.getString("status")) && rs.getString("admin_reply") != null) { %>
                        <a href="email-template.jsp?id=<%= rs.getInt("feedback_id") %>" class="btn" style="background: #17a2b8; color: white; font-size: 0.8rem;"> Email</a>
                    <% } %>
                    <a href="delete-feedback.jsp?id=<%= rs.getInt("feedback_id") %>" class="btn btn-delete" onclick="return confirm('Delete this feedback?')"> Delete</a>
                </div>
            </div>
            <h4><%= rs.getString("subject") %></h4>
            <p><%= rs.getString("message").length() > 100 ? rs.getString("message").substring(0, 100) + "..." : rs.getString("message") %></p>
        </div>
        <%
                }
                conn.close();
            } catch (Exception e) {
                out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
            }
        %>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>