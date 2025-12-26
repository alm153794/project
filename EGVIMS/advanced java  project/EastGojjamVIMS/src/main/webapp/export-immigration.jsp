<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    response.setHeader("Content-Disposition", "attachment; filename=immigration_records.csv");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        String sql = "SELECT * FROM immigration_records ORDER BY created_date DESC";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        
        // CSV Header
        out.println("ID,Person First Name,Person Middle Name,Person Last Name,Gender,Date of Birth,Nationality,Passport Number,Immigration Type,From Country,To Country,From Location,To Location,Immigration Date,Purpose,Duration Days,Wereda,Kebele,Registration Date,Created Date");
        
        while (rs.next()) {
            out.println(rs.getString("record_id") + "," +
                       "\"" + rs.getString("person_first_name") + "\"," +
                       "\"" + (rs.getString("person_middle_name") != null ? rs.getString("person_middle_name") : "") + "\"," +
                       "\"" + rs.getString("person_last_name") + "\"," +
                       "\"" + rs.getString("gender") + "\"," +
                       "\"" + rs.getDate("date_of_birth") + "\"," +
                       "\"" + rs.getString("nationality") + "\"," +
                       "\"" + (rs.getString("passport_number") != null ? rs.getString("passport_number") : "") + "\"," +
                       "\"" + rs.getString("immigration_type") + "\"," +
                       "\"" + (rs.getString("from_country") != null ? rs.getString("from_country") : "") + "\"," +
                       "\"" + (rs.getString("to_country") != null ? rs.getString("to_country") : "") + "\"," +
                       "\"" + (rs.getString("from_location") != null ? rs.getString("from_location") : "") + "\"," +
                       "\"" + (rs.getString("to_location") != null ? rs.getString("to_location") : "") + "\"," +
                       "\"" + rs.getDate("immigration_date") + "\"," +
                       "\"" + (rs.getString("purpose") != null ? rs.getString("purpose") : "") + "\"," +
                       (rs.getObject("duration_days") != null ? rs.getInt("duration_days") : 0) + "," +
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