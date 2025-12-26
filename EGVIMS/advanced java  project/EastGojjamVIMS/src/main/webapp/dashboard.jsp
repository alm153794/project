<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    String fullName = (String) session.getAttribute("fullName");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .dashboard-header { text-align: center; margin-bottom: 3rem; }
        .dashboard-header h1 { color: #2c3e50; font-size: 2.5rem; margin-bottom: 0.5rem; }
        .dashboard-header p { color: #7f8c8d; font-size: 1.2rem; }
        .dashboard-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; margin: 3rem 0; }
        .stat-card { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; padding: 2rem; border-radius: 15px; text-align: center; box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3); transition: all 0.3s ease; }
        .stat-card:hover { transform: translateY(-10px); box-shadow: 0 20px 40px rgba(79, 172, 254, 0.4); }
        .stat-card h3 { margin: 0 0 1rem; font-size: 1.2rem; opacity: 0.9; }
        .stat-number { font-size: 3rem; font-weight: bold; margin: 1rem 0; text-shadow: 2px 2px 4px rgba(0,0,0,0.2); }
        .stat-card a { color: white; text-decoration: none; background: rgba(255,255,255,0.2); padding: 0.5rem 1rem; border-radius: 25px; display: inline-block; margin-top: 1rem; transition: all 0.3s ease; }
        .stat-card a:hover { background: rgba(255,255,255,0.3); transform: translateY(-2px); }
        .quick-actions { background: white; padding: 2rem; border-radius: 15px; margin: 2rem 0; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .quick-actions h2 { color: #2c3e50; text-align: center; margin-bottom: 2rem; }
        .action-buttons { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }
        .action-btn { background: linear-gradient(135deg, #ff6b6b, #ee5a24); color: white; padding: 1rem 2rem; text-decoration: none; border-radius: 10px; text-align: center; font-weight: bold; transition: all 0.3s ease; box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3); }
        .action-btn:hover { background: linear-gradient(135deg, #ee5a24, #ff3838); transform: translateY(-3px); box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4); }
        .error { background: #ff6b6b; color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="dashboard-header">
            <h1>Welcome, <%= fullName %>!</h1>
            <p>Role: <strong><%= role.toUpperCase() %></strong></p>
        </div>
        
        <% if (!"admin".equals(role)) { %>
        <div class="dashboard-stats">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    // Get statistics
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM birth_records");
                    rs.next();
                    int birthCount = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM death_records");
                    rs.next();
                    int deathCount = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM marriage_records");
                    rs.next();
                    int marriageCount = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM divorce_records");
                    rs.next();
                    int divorceCount = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM immigration_records");
                    rs.next();
                    int immigrationCount = rs.getInt("count");
                    
                    conn.close();
            %>
            
            <div class="stat-card">
                <h3>Birth Records</h3>
                <div class="stat-number"><%= birthCount %></div>
                <a href="view-birth.jsp">View All</a>
            </div>
            
            <div class="stat-card">
                <h3>Death Records</h3>
                <div class="stat-number"><%= deathCount %></div>
                <a href="view-death.jsp">View All</a>
            </div>
            
            <div class="stat-card">
                <h3>Marriage Records</h3>
                <div class="stat-number"><%= marriageCount %></div>
                <a href="view-marriage.jsp">View All</a>
            </div>
            
            <div class="stat-card">
                <h3>Divorce Records</h3>
                <div class="stat-number"><%= divorceCount %></div>
                <a href="view-divorce.jsp">View All</a>
            </div>
            
            <div class="stat-card">
                <h3>Immigration Records</h3>
                <div class="stat-number"><%= immigrationCount %></div>
                <a href="view-immigration.jsp">View All</a>
            </div>
            
            <%
                } catch (Exception e) {
                    out.println("<div class='error'>Error loading statistics: " + e.getMessage() + "</div>");
                }
            %>
        </div>
        <% } %>
        
        <div class="quick-actions">
            <h2>Quick Actions</h2>
            <div class="action-buttons">
                <% if ("data_entry".equals(role)) { %>
                    <a href="add-birth.jsp" class="action-btn">Add Birth Record</a>
                    <a href="add-death.jsp" class="action-btn">Add Death Record</a>
                    <a href="add-marriage.jsp" class="action-btn">Add Marriage Record</a>
                    <a href="add-divorce.jsp" class="action-btn">Add Divorce Record</a>
                    <a href="add-immigration.jsp" class="action-btn">Add Immigration Record</a>
                <% } %>
                <% if ("admin".equals(role)) { %>
                    <a href="user-management.jsp" class="action-btn" style="background: linear-gradient(135deg, #dc3545, #c82333);">Manage Users</a>
                    <a href="manage-feedback.jsp" class="action-btn" style="background: linear-gradient(135deg, #6f42c1, #5a2d91);">Manage Feedback</a>
                    <a href="reports.jsp" class="action-btn">Generate Reports</a>
                <% } else { %>
                    <a href="reports.jsp" class="action-btn">Generate Reports</a>
                <% } %>
            </div>
        </div>
    </div>
    
    <%@ include file="feedback-modal.jsp" %>
    <%@ include file="footer.jsp" %>
</body>
</html>