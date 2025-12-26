<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String recordId = request.getParameter("id");
    if (recordId == null) {
        response.sendRedirect("view-immigration.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Immigration Record Details - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        .detail-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 2rem; }
        .record-photo { flex-shrink: 0; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="user-management-header">
            <h2> Immigration Record Details</h2>
            <p>Complete immigration/emigration information</p>
        </div>
        
        <div class="form-section">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "SELECT i.*, u.full_name as registered_by_name " +
                                "FROM immigration_records i " +
                                "LEFT JOIN users u ON i.registered_by = u.user_id " +
                                "WHERE i.record_id = ?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, recordId);
                    ResultSet rs = stmt.executeQuery();
                    
                    if (rs.next()) {
            %>
            
            <div class="user-details-card">
                <div class="detail-header">
                    <div>
                        <h3> <%= rs.getString("person_first_name") + " " + 
                                  (rs.getString("person_middle_name") != null ? rs.getString("person_middle_name") + " " : "") +
                                  rs.getString("person_last_name") %></h3>
                        <span class="role-badge role-public"><%= rs.getString("immigration_type") %> Record</span>
                    </div>
                    <% if (rs.getString("photo_path") != null && !rs.getString("photo_path").isEmpty()) { %>
                    <div class="record-photo">
                        <img src="<%= rs.getString("photo_path") %>" alt="Person Photo" style="width: 120px; height: 150px; object-fit: cover; border-radius: 10px; border: 3px solid #17a2b8; box-shadow: 0 5px 15px rgba(0,0,0,0.2);">
                    </div>
                    <% } %>
                </div>
                
                <div class="detail-grid">
                    <div class="detail-item">
                        <label>Record ID:</label>
                        <span><%= rs.getString("record_id") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Person's Full Name:</label>
                        <span><%= rs.getString("person_first_name") + " " + 
                                  (rs.getString("person_middle_name") != null ? rs.getString("person_middle_name") + " " : "") +
                                  rs.getString("person_last_name") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Gender:</label>
                        <span><%= rs.getString("gender") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Date of Birth:</label>
                        <span><%= rs.getDate("date_of_birth") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Birth Record ID:</label>
                        <span><%= rs.getString("birth_record_id") != null ? rs.getString("birth_record_id") : "Not linked" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Nationality:</label>
                        <span><%= rs.getString("nationality") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Passport Number:</label>
                        <span><%= rs.getString("passport_number") != null ? rs.getString("passport_number") : "Not provided" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Immigration Type:</label>
                        <span><%= rs.getString("immigration_type") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>From Country:</label>
                        <span><%= rs.getString("from_country") != null ? rs.getString("from_country") : "Not specified" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>To Country:</label>
                        <span><%= rs.getString("to_country") != null ? rs.getString("to_country") : "Not specified" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>From Location:</label>
                        <span><%= rs.getString("from_location") != null ? rs.getString("from_location") : "Not specified" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>To Location:</label>
                        <span><%= rs.getString("to_location") != null ? rs.getString("to_location") : "Not specified" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Immigration Date:</label>
                        <span><%= rs.getDate("immigration_date") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Purpose:</label>
                        <span><%= rs.getString("purpose") != null ? rs.getString("purpose") : "Not specified" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Duration (Days):</label>
                        <span><%= rs.getInt("duration_days") > 0 ? rs.getInt("duration_days") + " days" : "Not specified" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Location:</label>
                        <span><%= (rs.getString("wereda") != null ? rs.getString("wereda") + ", " : "") +
                                  (rs.getString("kebele") != null ? rs.getString("kebele") : "Not specified") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Registration Date:</label>
                        <span><%= rs.getDate("registration_date") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Registered By:</label>
                        <span><%= rs.getString("registered_by_name") != null ? rs.getString("registered_by_name") : "Unknown" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Record Created:</label>
                        <span><%= rs.getTimestamp("created_date") %></span>
                    </div>
                </div>
            </div>
            
            <div class="form-actions">
                <% if ("data_entry".equals(session.getAttribute("role"))) { %>
                <a href="edit-immigration.jsp?id=<%= recordId %>" class="btn btn-primary"> Edit Record</a>
                <% } %>
                <a href="view-immigration.jsp" class="btn btn-secondary"> Back to Records</a>
            </div>
            
            <%
                    } else {
                        out.println("<div class='error-message'>Immigration record not found!</div>");
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error loading record details: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>