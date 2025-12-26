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
            
            String sql = "SELECT groom_first_name, groom_middle_name, groom_last_name, groom_age, bride_first_name, bride_middle_name, bride_last_name, bride_age, marriage_date, marriage_place, wereda, kebele FROM marriage_records WHERE record_id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, recordId.trim());
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                json.append("{");
                json.append("\"success\": true,");
                json.append("\"groom_first_name\": \"").append(rs.getString("groom_first_name") != null ? rs.getString("groom_first_name") : "").append("\",");
                json.append("\"groom_middle_name\": \"").append(rs.getString("groom_middle_name") != null ? rs.getString("groom_middle_name") : "").append("\",");
                json.append("\"groom_last_name\": \"").append(rs.getString("groom_last_name") != null ? rs.getString("groom_last_name") : "").append("\",");
                json.append("\"groom_age\": \"").append(rs.getInt("groom_age")).append("\",");
                json.append("\"bride_first_name\": \"").append(rs.getString("bride_first_name") != null ? rs.getString("bride_first_name") : "").append("\",");
                json.append("\"bride_middle_name\": \"").append(rs.getString("bride_middle_name") != null ? rs.getString("bride_middle_name") : "").append("\",");
                json.append("\"bride_last_name\": \"").append(rs.getString("bride_last_name") != null ? rs.getString("bride_last_name") : "").append("\",");
                json.append("\"bride_age\": \"").append(rs.getInt("bride_age")).append("\",");
                json.append("\"marriage_date\": \"").append(rs.getString("marriage_date") != null ? rs.getString("marriage_date") : "").append("\",");
                json.append("\"marriage_place\": \"").append(rs.getString("marriage_place") != null ? rs.getString("marriage_place") : "").append("\",");
                json.append("\"wereda\": \"").append(rs.getString("wereda") != null ? rs.getString("wereda") : "").append("\",");
                json.append("\"kebele\": \"").append(rs.getString("kebele") != null ? rs.getString("kebele") : "").append("\"");
                json.append("}");
            } else {
                json.append("{\"success\": false, \"message\": \"Marriage record not found\"}");
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