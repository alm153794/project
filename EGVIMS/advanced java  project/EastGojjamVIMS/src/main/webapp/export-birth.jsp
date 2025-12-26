<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    response.setHeader("Content-Disposition", "attachment; filename=birth_records.csv");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        String sql = "SELECT * FROM birth_records ORDER BY created_date DESC";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        
        // CSV Header
        out.println("ID,Child First Name,Child Middle Name,Child Last Name,Gender,Date of Birth,Place of Birth,Father Name,Mother Name,Wereda,Kebele,Registration Date,Created Date");
        
        while (rs.next()) {
            out.println(rs.getString("record_id") + "," +
                       "\"" + rs.getString("child_first_name") + "\"," +
                       "\"" + (rs.getString("child_middle_name") != null ? rs.getString("child_middle_name") : "") + "\"," +
                       "\"" + rs.getString("child_last_name") + "\"," +
                       "\"" + rs.getString("gender") + "\"," +
                       "\"" + rs.getDate("date_of_birth") + "\"," +
                       "\"" + rs.getString("place_of_birth") + "\"," +
                       "\"" + rs.getString("father_full_name") + "\"," +
                       "\"" + rs.getString("mother_full_name") + "\"," +
                       "\"" + (rs.getString("wereda") != null ? rs.getString("wereda") : "") + "\"," +
                       "\"" + (rs.getString("kebele") != null ? rs.getString("kebele") : "") + "\"," +
                       "\"" + rs.getDate("registration_date") + "\"," +
                       "\"" + rs.getTimestamp("created_date") + "\"");
        }
        
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>