<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setContentType("application/json");
    
    String recordId = request.getParameter("record_id");
    StringBuilder json = new StringBuilder();
    
    if (recordId != null && !recordId.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
            
            String sql = "SELECT child_first_name, child_middle_name, child_last_name, gender, date_of_birth, father_full_name, mother_full_name, place_of_birth, wereda, kebele FROM birth_records WHERE record_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, recordId.trim());
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                json.append("{");
                json.append("\"success\": true,");
                json.append("\"child_first_name\": \"").append(rs.getString("child_first_name") != null ? rs.getString("child_first_name") : "").append("\",");
                json.append("\"child_middle_name\": \"").append(rs.getString("child_middle_name") != null ? rs.getString("child_middle_name") : "").append("\",");
                json.append("\"child_last_name\": \"").append(rs.getString("child_last_name") != null ? rs.getString("child_last_name") : "").append("\",");
                json.append("\"gender\": \"").append(rs.getString("gender") != null ? rs.getString("gender") : "").append("\",");
                json.append("\"date_of_birth\": \"").append(rs.getString("date_of_birth") != null ? rs.getString("date_of_birth") : "").append("\",");
                json.append("\"father_full_name\": \"").append(rs.getString("father_full_name") != null ? rs.getString("father_full_name") : "").append("\",");
                json.append("\"mother_full_name\": \"").append(rs.getString("mother_full_name") != null ? rs.getString("mother_full_name") : "").append("\",");
                json.append("\"place_of_birth\": \"").append(rs.getString("place_of_birth") != null ? rs.getString("place_of_birth") : "").append("\",");
                json.append("\"wereda\": \"").append(rs.getString("wereda") != null ? rs.getString("wereda") : "").append("\",");
                json.append("\"kebele\": \"").append(rs.getString("kebele") != null ? rs.getString("kebele") : "").append("\"");
                json.append("}");
            } else {
                json.append("{\"success\": false, \"message\": \"Birth record not found\"}");
            }
            
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (Exception e) {
            json.append("{\"success\": false, \"message\": \"Error: ").append(e.getMessage()).append("\"}");
        }
    } else {
        json.append("{\"success\": false, \"message\": \"Record ID is required\"}");
    }
    
    out.print(json.toString());
%>