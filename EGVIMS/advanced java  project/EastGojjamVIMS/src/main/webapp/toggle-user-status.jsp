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
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        String sql = "UPDATE users SET status = CASE WHEN status = 'active' THEN 'deactive' ELSE 'active' END WHERE user_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, Integer.parseInt(userId));
        
        int result = stmt.executeUpdate();
        
        stmt.close();
        conn.close();
        
        if (result > 0) {
            session.setAttribute("success", "User status updated successfully!");
        } else {
            session.setAttribute("error", "Failed to update user status!");
        }
    } catch (Exception e) {
        session.setAttribute("error", "Error updating status: " + e.getMessage());
    }
    
    response.sendRedirect("user-management.jsp");
%>