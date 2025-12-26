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
        
        // Delete related divorce records first
        String deleteDivorcesSql = "DELETE FROM divorce_records WHERE marriage_record_id = ?";
        PreparedStatement stmt1 = conn.prepareStatement(deleteDivorcesSql);
        stmt1.setString(1, recordId);
        stmt1.executeUpdate();
        stmt1.close();
        
        // Delete marriage record
        String sql = "DELETE FROM marriage_records WHERE record_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, recordId);
        
        int result = stmt.executeUpdate();
        
        stmt.close();
        conn.close();
        
        if (result > 0) {
            response.sendRedirect("view-marriage.jsp?deleted=true");
        } else {
            response.sendRedirect("view-marriage.jsp?error=delete_failed");
        }
    } catch (Exception e) {
        response.sendRedirect("view-marriage.jsp?error=" + e.getMessage());
    }
%>