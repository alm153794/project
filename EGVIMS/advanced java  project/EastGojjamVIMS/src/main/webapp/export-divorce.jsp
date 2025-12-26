<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    response.setHeader("Content-Disposition", "attachment; filename=divorce_records.csv");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
        
        String sql = "SELECT * FROM divorce_records ORDER BY created_date DESC";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        
        // CSV Header
        out.println("ID,Husband First Name,Husband Middle Name,Husband Last Name,Wife First Name,Wife Middle Name,Wife Last Name,Marriage Date,Divorce Date,Divorce Place,Divorce Reason,Wereda,Kebele,Registration Date,Created Date");
        
        while (rs.next()) {
            out.println(rs.getString("record_id") + "," +
                       "\"" + rs.getString("husband_first_name") + "\"," +
                       "\"" + (rs.getString("husband_middle_name") != null ? rs.getString("husband_middle_name") : "") + "\"," +
                       "\"" + rs.getString("husband_last_name") + "\"," +
                       "\"" + rs.getString("wife_first_name") + "\"," +
                       "\"" + (rs.getString("wife_middle_name") != null ? rs.getString("wife_middle_name") : "") + "\"," +
                       "\"" + rs.getString("wife_last_name") + "\"," +
                       "\"" + rs.getDate("marriage_date") + "\"," +
                       "\"" + rs.getDate("divorce_date") + "\"," +
                       "\"" + rs.getString("divorce_place") + "\"," +
                       "\"" + (rs.getString("divorce_reason") != null ? rs.getString("divorce_reason") : "") + "\"," +
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