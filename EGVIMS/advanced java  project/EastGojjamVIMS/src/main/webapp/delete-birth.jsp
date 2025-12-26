<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role) && !"data_entry".equals(role)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    String recordId = request.getParameter("id");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        // Delete related records first to avoid foreign key constraint errors
        String[] deleteSqls = {
            "DELETE FROM divorce_records WHERE husband_record_id = ? OR wife_record_id = ?",
            "DELETE FROM marriage_records WHERE groom_record_id = ? OR bride_record_id = ?",
            "DELETE FROM death_records WHERE birth_record_id = ?",
            "DELETE FROM immigration_records WHERE birth_record_id = ?",
            "DELETE FROM birth_records WHERE record_id = ?"
        };
        
        int totalDeleted = 0;
        for (String sql : deleteSqls) {
            PreparedStatement stmt = conn.prepareStatement(sql);
            if (sql.contains("husband_record_id") || sql.contains("groom_record_id")) {
                stmt.setString(1, recordId);
                stmt.setString(2, recordId);
            } else {
                stmt.setString(1, recordId);
            }
            totalDeleted += stmt.executeUpdate();
            stmt.close();
        }
        
        conn.close();
        int result = totalDeleted;
        
        if (result > 0) {
            response.sendRedirect("view-birth.jsp?deleted=true");
        } else {
            response.sendRedirect("view-birth.jsp?error=delete_failed");
        }
    } catch (Exception e) {
        response.sendRedirect("view-birth.jsp?error=" + e.getMessage());
    }
%>