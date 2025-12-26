<%@ page language="java" contentType="application/vnd.ms-excel; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
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
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
    String timestamp = sdf.format(new Date());
    
    response.setHeader("Content-Disposition", "attachment; filename=users_export_" + timestamp + ".xls");
%>
<html>
<head>
    <meta charset="UTF-8">
    <title>Users Export</title>
</head>
<body>
    <table border="1">
        <tr>
            <th>User ID</th>
            <th>Username</th>
            <th>Full Name</th>
            <th>Email</th>
            <th>Role</th>
            <th>Created Date</th>
            <th>Last Login</th>
            <th>Status</th>
        </tr>
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
            <td><%= rs.getString("role").toUpperCase() %></td>
            <td><%= rs.getTimestamp("created_date") %></td>
            <td><%= rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login") : "Never" %></td>
            <td><%= "active".equals(rs.getString("status")) ? "Active" : "Inactive" %></td>
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
    </table>
</body>
</html>