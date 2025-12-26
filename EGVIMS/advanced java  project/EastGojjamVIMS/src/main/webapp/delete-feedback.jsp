<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int feedbackId = Integer.parseInt(request.getParameter("id"));
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        PreparedStatement stmt = conn.prepareStatement("DELETE FROM feedback WHERE feedback_id = ?");
        stmt.setInt(1, feedbackId);
        
        int result = stmt.executeUpdate();
        conn.close();
        
        if (result > 0) {
            session.setAttribute("message", "Feedback deleted successfully!");
        } else {
            session.setAttribute("error", "Failed to delete feedback.");
        }
    } catch (Exception e) {
        session.setAttribute("error", "Error: " + e.getMessage());
    }
    
    response.sendRedirect("manage-feedback.jsp");
%>