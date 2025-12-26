<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.util.Base64" %>
<%!
    // Hash password with salt
    private String hashPassword(String password) {
        try {
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);
            String saltStr = Base64.getEncoder().encodeToString(salt);
            
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes("UTF-8"));
            
            for (int i = 0; i < 10000; i++) {
                md.reset();
                hashedPassword = md.digest(hashedPassword);
            }
            
            String hash = Base64.getEncoder().encodeToString(hashedPassword);
            return saltStr + ":" + hash;
        } catch (Exception e) {
            return null;
        }
    }
%>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    String userId = request.getParameter("id");
    if (userId == null) {
        response.sendRedirect("user-management.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit User - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="user-management-header">
            <h2>Edit User Account</h2>
            <p>Update user information and permissions</p>
        </div>
        
        <% if (request.getMethod().equals("POST")) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                
                String newPassword = request.getParameter("new_password");
                String sql;
                PreparedStatement stmt;
                
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    sql = "UPDATE users SET username=?, password=?, full_name=?, email=?, role=?, status=? WHERE user_id=?";
                    stmt = conn.prepareStatement(sql);
                    String hashedPassword = hashPassword(newPassword);
                    stmt.setString(1, request.getParameter("username"));
                    stmt.setString(2, hashedPassword);
                    stmt.setString(3, request.getParameter("full_name"));
                    stmt.setString(4, request.getParameter("email"));
                    stmt.setString(5, request.getParameter("user_role"));
                    stmt.setString(6, "on".equals(request.getParameter("is_active")) ? "active" : "deactive");
                    stmt.setInt(7, Integer.parseInt(userId));
                } else {
                    sql = "UPDATE users SET username=?, full_name=?, email=?, role=?, status=? WHERE user_id=?";
                    stmt = conn.prepareStatement(sql);
                    stmt.setString(1, request.getParameter("username"));
                    stmt.setString(2, request.getParameter("full_name"));
                    stmt.setString(3, request.getParameter("email"));
                    stmt.setString(4, request.getParameter("user_role"));
                    stmt.setString(5, "on".equals(request.getParameter("is_active")) ? "active" : "deactive");
                    stmt.setInt(6, Integer.parseInt(userId));
                }
                
                int result = stmt.executeUpdate();
                if (result > 0) {
                    out.println("<div class='success-message'>User updated successfully!</div>");
                }
                
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
            }
        } %>
        
        <div class="form-section">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "SELECT * FROM users WHERE user_id = ?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setInt(1, Integer.parseInt(userId));
                    ResultSet rs = stmt.executeQuery();
                    
                    if (rs.next()) {
            %>
            
            <form method="post" class="record-form">
                <div class="form-row">
                    <div class="form-group">
                        <label for="username">Username:</label>
                        <input type="text" id="username" name="username" value="<%= rs.getString("username") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="full_name">Full Name:</label>
                        <input type="text" id="full_name" name="full_name" value="<%= rs.getString("full_name") %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="new_password">New Password (leave blank to keep current):</label>
                        <input type="password" id="new_password" name="new_password" placeholder="Enter new password">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" value="<%= rs.getString("email") != null ? rs.getString("email") : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="user_role">Role:</label>
                        <select id="user_role" name="user_role" required>
                            <option value="admin" <%= "admin".equals(rs.getString("role")) ? "selected" : "" %>>Admin</option>
                            <option value="data_entry" <%= "data_entry".equals(rs.getString("role")) ? "selected" : "" %>>Data Entry</option>
                            <option value="public" <%= "public".equals(rs.getString("role")) ? "selected" : "" %>>Public</option>
                        </select>
                    </div>
                </div>
                
                <div class="checkbox-group">
                    <input type="checkbox" id="is_active" name="is_active" <%= "active".equals(rs.getString("status")) ? "checked" : "" %>>
                    <label for="is_active">Active User</label>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">✓ Update User</button>
                    <a href="user-management.jsp" class="btn btn-secondary">← Cancel</a>
                </div>
            </form>
            
            <%
                    } else {
                        out.println("<div class='error-message'>User not found!</div>");
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error loading user: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>