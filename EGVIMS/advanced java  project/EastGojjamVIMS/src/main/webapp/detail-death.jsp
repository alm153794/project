<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String recordId = request.getParameter("id");
    if (recordId == null) {
        response.sendRedirect("view-death.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Death Record Details - East Gojjam VIMS</title>
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
            <h2> Death Record Details</h2>
            <p>Complete death registration information</p>
        </div>
        
        <div class="form-section">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "SELECT d.*, u.full_name as registered_by_name " +
                                "FROM death_records d " +
                                "LEFT JOIN users u ON d.registered_by = u.user_id " +
                                "WHERE d.record_id = ?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, recordId);
                    ResultSet rs = stmt.executeQuery();
                    
                    if (rs.next()) {
            %>
            
            <div class="user-details-card">
                <div class="detail-header">
                    <div>
                        <h3> <%= rs.getString("deceased_first_name") + " " + 
                                  (rs.getString("deceased_middle_name") != null ? rs.getString("deceased_middle_name") + " " : "") +
                                  rs.getString("deceased_last_name") %></h3>
                        <span class="role-badge role-data-entry">Death Record</span>
                    </div>
                    <% if (rs.getString("photo_path") != null && !rs.getString("photo_path").isEmpty()) { %>
                    <div class="record-photo">
                        <img src="<%= rs.getString("photo_path") %>" alt="Deceased Photo" style="width: 120px; height: 150px; object-fit: cover; border-radius: 10px; border: 3px solid #dc3545; box-shadow: 0 5px 15px rgba(0,0,0,0.2);">
                    </div>
                    <% } %>
                </div>
                
                <div class="detail-grid">
                    <div class="detail-item">
                        <label>Record ID:</label>
                        <span><%= rs.getString("record_id") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Deceased Full Name:</label>
                        <span><%= rs.getString("deceased_first_name") + " " + 
                                  (rs.getString("deceased_middle_name") != null ? rs.getString("deceased_middle_name") + " " : "") +
                                  rs.getString("deceased_last_name") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Gender:</label>
                        <span><%= rs.getString("gender") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Date of Death:</label>
                        <span><%= rs.getDate("date_of_death") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Age at Death:</label>
                        <span><%= rs.getInt("age_at_death") %> years</span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Place of Death:</label>
                        <span><%= rs.getString("place_of_death") %></span>
                    </div>
                    
                    <div class="detail-item">
                        <label>Cause of Death:</label>
                        <span><%= rs.getString("cause_of_death") != null ? rs.getString("cause_of_death") : "Not specified" %></span>
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
                <a href="edit-death.jsp?id=<%= recordId %>" class="btn btn-primary"> Edit Record</a>
                <% } %>
                <a href="view-death.jsp" class="btn btn-secondary"> Back to Records</a>
            </div>
            
            <%
                    } else {
                        out.println("<div class='error-message'>Death record not found!</div>");
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