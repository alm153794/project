<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
    <title>View User Details - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .user-management-header { text-align: center; margin-bottom: 3rem; }
        .user-management-header h2 { color: #2c3e50; font-size: 3rem; margin-bottom: 1rem; background: linear-gradient(135deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .user-management-header p { color: #6c757d; font-size: 1.2rem; }
        .user-details-card { background: white; border-radius: 20px; padding: 2rem; margin-bottom: 2rem; box-shadow: 0 15px 35px rgba(0,0,0,0.1); }
        .detail-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 2px solid #f8f9fa; }
        .detail-header h3 { color: #2c3e50; font-size: 2rem; margin: 0; }
        .detail-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem; }
        .detail-item { background: #f8f9fa; padding: 1.5rem; border-radius: 15px; border-left: 4px solid #667eea; }
        .detail-item label { display: block; color: #6c757d; font-weight: 600; margin-bottom: 0.5rem; font-size: 0.9rem; text-transform: uppercase; }
        .detail-item span { color: #2c3e50; font-size: 1.1rem; font-weight: 500; }
        .activity-section { background: white; border-radius: 20px; padding: 2rem; margin-bottom: 2rem; box-shadow: 0 15px 35px rgba(0,0,0,0.1); }
        .activity-section h3 { color: #2c3e50; font-size: 1.8rem; margin-bottom: 2rem; text-align: center; }
        .activity-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; }
        .activity-card { background: linear-gradient(135deg, #f8f9fa, #e9ecef); padding: 2rem; border-radius: 15px; text-align: center; transition: all 0.3s ease; border: 2px solid transparent; }
        .activity-card:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(0,0,0,0.15); border-color: #667eea; }
        .activity-icon { font-size: 3rem; margin-bottom: 1rem; }
        .activity-count { font-size: 2.5rem; font-weight: bold; color: #667eea; margin-bottom: 0.5rem; }
        .activity-label { color: #6c757d; font-weight: 600; text-transform: uppercase; font-size: 0.9rem; }
        .role-badge { padding: 0.5rem 1rem; border-radius: 25px; font-size: 0.9rem; font-weight: bold; text-transform: uppercase; }
        .role-admin { background: linear-gradient(135deg, #dc3545, #c82333); color: white; }
        .role-data-entry { background: linear-gradient(135deg, #007bff, #0056b3); color: white; }
        .role-guest { background: linear-gradient(135deg, #6c757d, #495057); color: white; }
        .status-badge { padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.8rem; font-weight: bold; text-transform: uppercase; }
        .status-active { background: linear-gradient(135deg, #28a745, #20c997); color: white; }
        .status-deactive { background: linear-gradient(135deg, #ffc107, #e0a800); color: white; }
        .form-actions { display: flex; gap: 1rem; justify-content: center; margin-top: 2rem; }
        .btn { padding: 1rem 2rem; border: none; border-radius: 25px; font-size: 1rem; font-weight: bold; text-decoration: none; cursor: pointer; transition: all 0.3s ease; display: inline-block; text-align: center; }
        .btn-primary { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3); }
        .btn-primary:hover { background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); transform: translateY(-3px); box-shadow: 0 15px 35px rgba(79, 172, 254, 0.4); }
        .btn-secondary { background: linear-gradient(135deg, #6c757d, #495057); color: white; box-shadow: 0 5px 15px rgba(108, 117, 125, 0.3); }
        .btn-secondary:hover { background: linear-gradient(135deg, #495057, #343a40); transform: translateY(-3px); }
        .error-message { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3); }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="user-management-header">
            <h2>User Details</h2>
            <p>Complete user information and activity summary</p>
        </div>
        
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
            
            <div class="user-details-card">
                <div class="detail-header">
                    <h3> <%= rs.getString("full_name") %></h3>
                    <span class="role-badge role-<%= rs.getString("role").replace("_", "-") %>"><%= rs.getString("role").toUpperCase().replace("_", " ") %></span>
                </div>
                
                <div class="detail-grid">
                    <div class="detail-item">
                        <label>User ID:</label>
                        <span><%= rs.getInt("user_id") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Username:</label>
                        <span><%= rs.getString("username") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Full Name:</label>
                        <span><%= rs.getString("full_name") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Email:</label>
                        <span><%= rs.getString("email") != null ? rs.getString("email") : "Not provided" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Role:</label>
                        <span><%= rs.getString("role").toUpperCase().replace("_", " ") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Account Status:</label>
                        <span class="status-badge status-<%= rs.getString("status") %>">
                            <%= rs.getString("status").toUpperCase() %>
                        </span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Account Created:</label>
                        <span><%= rs.getTimestamp("created_date") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Last Login:</label>
                        <span><%= rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login") : "Never logged in" %></span>
                    </div>
                </div>
            </div>
            
            <%
                // Get user activity statistics
                String activitySql = "SELECT " +
                    "(SELECT COUNT(*) FROM birth_records WHERE registered_by = ?) as birth_count, " +
                    "(SELECT COUNT(*) FROM death_records WHERE registered_by = ?) as death_count, " +
                    "(SELECT COUNT(*) FROM marriage_records WHERE registered_by = ?) as marriage_count, " +
                    "(SELECT COUNT(*) FROM divorce_records WHERE registered_by = ?) as divorce_count, " +
                    "(SELECT COUNT(*) FROM immigration_records WHERE registered_by = ?) as immigration_count";
                
                PreparedStatement activityStmt = conn.prepareStatement(activitySql);
                for (int i = 1; i <= 5; i++) {
                    activityStmt.setInt(i, Integer.parseInt(userId));
                }
                ResultSet activityRs = activityStmt.executeQuery();
                
                if (activityRs.next()) {
            %>
            
            <div class="activity-section">
                <h3> User Activity Summary</h3>
                <div class="activity-grid">
                    <div class="activity-card">
                        <div class="activity-icon"></div>
                        <div class="activity-count"><%= activityRs.getInt("birth_count") %></div>
                        <div class="activity-label">Birth Records</div>
                    </div>
                    
                    <div class="activity-card">
                        <div class="activity-icon"></div>
                        <div class="activity-count"><%= activityRs.getInt("death_count") %></div>
                        <div class="activity-label">Death Records</div>
                    </div>
                    
                    <div class="activity-card">
                        <div class="activity-icon"></div>
                        <div class="activity-count"><%= activityRs.getInt("marriage_count") %></div>
                        <div class="activity-label">Marriage Records</div>
                    </div>
                    
                    <div class="activity-card">
                        <div class="activity-icon"></div>
                        <div class="activity-count"><%= activityRs.getInt("divorce_count") %></div>
                        <div class="activity-label">Divorce Records</div>
                    </div>
                    
                    <div class="activity-card">
                        <div class="activity-icon"></div>
                        <div class="activity-count"><%= activityRs.getInt("immigration_count") %></div>
                        <div class="activity-label">Immigration Records</div>
                    </div>
                </div>
            </div>
            
            <%
                }
                activityRs.close();
                activityStmt.close();
            %>
            
            <div class="form-actions">
                <a href="edit-user.jsp?id=<%= userId %>" class="btn btn-primary"> Edit User</a>
                <a href="user-management.jsp" class="btn btn-secondary">← Back to Users</a>
            </div>
            
            <%
                    } else {
                        out.println("<div class='error-message'>User not found!</div>");
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error loading user details: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>