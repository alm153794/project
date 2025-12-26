<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    response.setHeader("Content-Disposition", "attachment; filename=marriage_records.csv");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        String sql = "SELECT * FROM marriage_records ORDER BY created_date DESC";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        
        // CSV Header
        out.println("ID,Groom First Name,Groom Middle Name,Groom Last Name,Bride First Name,Bride Middle Name,Bride Last Name,Marriage Date,Marriage Place,Wereda,Kebele,Registration Date,Created Date");
        
        while (rs.next()) {
            out.println(rs.getString("record_id") + "," +
                       "\"" + rs.getString("groom_first_name") + "\"," +
                       "\"" + (rs.getString("groom_middle_name") != null ? rs.getString("groom_middle_name") : "") + "\"," +
                       "\"" + rs.getString("groom_last_name") + "\"," +
                       "\"" + rs.getString("bride_first_name") + "\"," +
                       "\"" + (rs.getString("bride_middle_name") != null ? rs.getString("bride_middle_name") : "") + "\"," +
                       "\"" + rs.getString("bride_last_name") + "\"," +
                       "\"" + rs.getDate("marriage_date") + "\"," +
                       "\"" + rs.getString("marriage_place") + "\"," +
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