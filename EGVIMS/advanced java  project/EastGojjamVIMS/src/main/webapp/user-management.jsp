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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Management - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .user-management-header { text-align: center; margin-bottom: 3rem; }
        .user-management-header h2 { color: #2c3e50; font-size: 3rem; margin-bottom: 1rem; background: linear-gradient(135deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .user-management-header p { color: #6c757d; font-size: 1.2rem; }
        .form-section { background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); margin-bottom: 2rem; }
        .section-title { color: #2c3e50; font-size: 1.8rem; margin-bottom: 1.5rem; text-align: center; }
        .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin-bottom: 1.5rem; }
        .form-group label { display: block; color: #2c3e50; font-weight: 600; margin-bottom: 0.5rem; }
        .form-group input, .form-group select { width: 100%; padding: 1rem; border: 2px solid #e0e6ed; border-radius: 10px; font-size: 1rem; transition: all 0.3s ease; box-sizing: border-box; }
        .form-group input:focus, .form-group select:focus { outline: none; border-color: #4facfe; box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.1); }
        .form-actions { display: flex; gap: 1rem; justify-content: center; margin-top: 2rem; }
        .btn { padding: 1rem 2rem; border: none; border-radius: 25px; font-size: 1rem; font-weight: bold; text-decoration: none; cursor: pointer; transition: all 0.3s ease; display: inline-block; text-align: center; }
        .btn-primary { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3); }
        .btn-primary:hover { background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); transform: translateY(-3px); box-shadow: 0 15px 35px rgba(79, 172, 254, 0.4); }
        .export-section { background: linear-gradient(135deg, #28a745, #20c997); padding: 2rem; border-radius: 15px; margin-bottom: 2rem; color: white; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 10px 30px rgba(40, 167, 69, 0.3); }
        .export-info h4 { margin: 0 0 0.5rem 0; font-size: 1.5rem; }
        .export-info p { margin: 0; opacity: 0.9; }
        .btn-export { background: rgba(255,255,255,0.2); color: white; padding: 1rem 2rem; border-radius: 25px; text-decoration: none; font-weight: bold; transition: all 0.3s ease; backdrop-filter: blur(10px); }
        .btn-export:hover { background: rgba(255,255,255,0.3); transform: translateY(-3px); }
        .users-table-container { background: white; border-radius: 15px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .table-header { background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 1.5rem; text-align: center; }
        .table-header h3 { margin: 0; font-size: 1.8rem; }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th { background: #f8f9fa; color: #2c3e50; padding: 1rem; text-align: left; font-weight: 600; border-bottom: 2px solid #e0e6ed; }
        .data-table td { padding: 1rem; border-bottom: 1px solid #e0e6ed; }
        .data-table tr:hover { background: #f8f9fa; }
        .role-badge { padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.8rem; font-weight: bold; text-transform: uppercase; }
        .role-admin { background: linear-gradient(135deg, #dc3545, #c82333); color: white; }
        .role-data-entry { background: linear-gradient(135deg, #007bff, #0056b3); color: white; }
        .role-guest { background: linear-gradient(135deg, #6c757d, #495057); color: white; }
        .status-badge { padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.8rem; font-weight: bold; text-transform: uppercase; }
        .status-active { background: linear-gradient(135deg, #28a745, #20c997); color: white; }
        .status-deactive { background: linear-gradient(135deg, #ffc107, #e0a800); color: white; }
        .action-buttons { display: flex; gap: 0.5rem; }
        .btn-small { padding: 0.5rem 1rem; border-radius: 15px; text-decoration: none; font-size: 0.8rem; font-weight: bold; transition: all 0.3s ease; }
        .btn-success { background: linear-gradient(135deg, #28a745, #20c997); color: white; }
        .btn-success:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3); }
        .btn-primary.btn-small { background: linear-gradient(135deg, #007bff, #0056b3); color: white; }
        .btn-primary.btn-small:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 123, 255, 0.3); }
        .btn-danger { background: linear-gradient(135deg, #dc3545, #c82333); color: white; }
        .btn-danger:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3); }
        .btn-warning { background: linear-gradient(135deg, #ffc107, #e0a800); color: white; }
        .btn-warning:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255, 193, 7, 0.3); }
        .btn-info { background: linear-gradient(135deg, #17a2b8, #138496); color: white; }
        .btn-info:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(23, 162, 184, 0.3); }
        .success-message { background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3); }
        .error-message { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3); }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="user-management-header">
            <h2>User Management</h2>
            <p>Manage system users, roles, and permissions</p>
        </div>
            
        <% 
            String successMsg = (String) session.getAttribute("success");
            String errorMsg = (String) session.getAttribute("error");
            if (successMsg != null) {
                out.println("<div class='success-message'>" + successMsg + "</div>");
                session.removeAttribute("success");
            }
            if (errorMsg != null) {
                out.println("<div class='error-message'>" + errorMsg + "</div>");
                session.removeAttribute("error");
            }
        %>
        
        <% if (request.getMethod().equals("POST")) {
            String action = request.getParameter("action");
            if ("add".equals(action)) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "INSERT INTO users (username, password, full_name, email, role) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    String hashedPassword = hashPassword(request.getParameter("password"));
                    
                    stmt.setString(1, request.getParameter("username"));
                    stmt.setString(2, hashedPassword);
                    stmt.setString(3, request.getParameter("full_name"));
                    stmt.setString(4, request.getParameter("email"));
                    stmt.setString(5, request.getParameter("user_role"));
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Success: User added successfully!</div>");
                    } else {
                        out.println("<div class='error-message'>Error: Failed to add user!</div>");
                    }
                    
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: Failed to add user - " + e.getMessage() + "</div>");
                }
            }
        } %>
        
        <div class="form-section">
            <h3 class="section-title"> Add New User</h3>
            <form method="post">
                <input type="hidden" name="action" value="add">
                <div class="form-row">
                    <div class="form-group">
                        <label for="username">Username:</label>
                        <input type="text" id="username" name="username" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Password:</label>
                        <input type="password" id="password" name="password" required>
                    </div>
                    <div class="form-group">
                        <label for="full_name">Full Name:</label>
                        <input type="text" id="full_name" name="full_name" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email">
                    </div>
                    <div class="form-group">
                        <label for="user_role">Role:</label>
                        <select id="user_role" name="user_role" required>
                            <option value="">Select Role</option>
                            <option value="admin">Admin</option>
                            <option value="data_entry">Data Entry</option>
                            <option value="guest">Guest</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add User</button>
                </div>
            </form>
        </div>
        
        <div class="export-section">
            <div class="export-info">
                <h4>Export User Data</h4>
                <p>Download complete user information as Excel file</p>
            </div>
            <a href="export-users.jsp" class="btn-export"> Export</a>
        </div>
        
        <div class="users-table-container">
            <div class="table-header">
                <h3>System Users</h3>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Created Date</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                            
                            String sql = "SELECT * FROM users ORDER BY created_date DESC";
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("user_id") %></td>
                        <td><%= rs.getString("username") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") != null ? rs.getString("email") : "N/A" %></td>
                        <td><span class="role-badge role-<%= rs.getString("role").replace("_", "-") %>"><%= rs.getString("role").toUpperCase().replace("_", " ") %></span></td>
                        <td><%= rs.getTimestamp("created_date") %></td>
                        <td><span class="status-badge status-<%= rs.getString("status") %>"><%= rs.getString("status").toUpperCase() %></span></td>
                        <td>
                            <div class="action-buttons">
                                <a href="view-user.jsp?id=<%= rs.getInt("user_id") %>" class="btn-small btn-success"> View</a>
                                <a href="edit-user.jsp?id=<%= rs.getInt("user_id") %>" class="btn-small btn-primary"> Edit</a>
                                <a href="toggle-user-status.jsp?id=<%= rs.getInt("user_id") %>" class="btn-small <%= "active".equals(rs.getString("status")) ? "btn-warning" : "btn-info" %>" onclick="return confirm('Change user status?')"><%= "active".equals(rs.getString("status")) ? " Deactivate" : " Activate" %></a>
                                <a href="delete-user.jsp?id=<%= rs.getInt("user_id") %>" class="btn-small btn-danger" onclick="return confirm('Are you sure you want to delete this user?')"> Delete</a>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                            rs.close();
                            stmt.close();
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='8'>Error loading users: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>