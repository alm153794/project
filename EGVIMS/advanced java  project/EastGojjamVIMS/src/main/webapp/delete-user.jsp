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
    
    String currentUserId = session.getAttribute("userId").toString();
    if (userId.equals(currentUserId)) {
        session.setAttribute("error", "You cannot delete your own account!");
        response.sendRedirect("user-management.jsp");
        return;
    }
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        // First, update all records to set registered_by to NULL
        String[] updateQueries = {
            "UPDATE birth_records SET registered_by = NULL WHERE registered_by = ?",
            "UPDATE death_records SET registered_by = NULL WHERE registered_by = ?",
            "UPDATE marriage_records SET registered_by = NULL WHERE registered_by = ?",
            "UPDATE divorce_records SET registered_by = NULL WHERE registered_by = ?",
            "UPDATE immigration_records SET registered_by = NULL WHERE registered_by = ?"
        };
        
        for (String updateSql : updateQueries) {
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setInt(1, Integer.parseInt(userId));
            updateStmt.executeUpdate();
            updateStmt.close();
        }
        
        // Now delete the user
        String sql = "DELETE FROM users WHERE user_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, Integer.parseInt(userId));
        
        int result = stmt.executeUpdate();
        
        stmt.close();
        conn.close();
        
        if (result > 0) {
            session.setAttribute("success", "Success: User deleted successfully!");
        } else {
            session.setAttribute("error", "Error: Failed to delete user!");
        }
    } catch (Exception e) {
        session.setAttribute("error", "Error: Failed to delete user - " + e.getMessage());
    }
    
    response.sendRedirect("user-management.jsp");
%>