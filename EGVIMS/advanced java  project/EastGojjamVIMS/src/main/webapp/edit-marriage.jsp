<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    if (!"data_entry".equals(role)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    String recordId = request.getParameter("id");
    ResultSet record = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Marriage Record - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; }
        .form-container { max-width: 1000px; margin: 0 auto; }
        .form-container h2 { color: #2c3e50; text-align: center; font-size: 2.5rem; margin-bottom: 2rem; }
        .record-form { background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin-bottom: 1.5rem; }
        .form-group label { display: block; color: #2c3e50; font-weight: 600; margin-bottom: 0.5rem; }
        .form-group input, .form-group select { width: 100%; padding: 1rem; border: 2px solid #e0e6ed; border-radius: 10px; font-size: 1rem; box-sizing: border-box; }
        .form-actions { display: flex; gap: 1rem; justify-content: center; margin-top: 2rem; }
        .btn { padding: 1rem 2rem; border: none; border-radius: 25px; font-size: 1rem; font-weight: bold; text-decoration: none; cursor: pointer; display: inline-block; text-align: center; }
        .btn-primary { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; }
        .btn-secondary { background: linear-gradient(135deg, #6c757d, #495057); color: white; }
        .btn-danger { background: linear-gradient(135deg, #dc3545, #c82333); color: white; }
        .success-message { background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; }
        .error-message { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="form-container">
            <h2> Edit Marriage Record</h2>
            
            <% if (request.getMethod().equals("POST")) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "UPDATE marriage_records SET groom_first_name=?, groom_middle_name=?, groom_last_name=?, groom_age=?, bride_first_name=?, bride_middle_name=?, bride_last_name=?, bride_age=?, marriage_date=?, marriage_place=?, wereda=?, kebele=?, registration_date=? WHERE record_id=?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    stmt.setString(1, request.getParameter("groom_first_name"));
                    stmt.setString(2, request.getParameter("groom_middle_name"));
                    stmt.setString(3, request.getParameter("groom_last_name"));
                    stmt.setInt(4, Integer.parseInt(request.getParameter("groom_age")));
                    stmt.setString(5, request.getParameter("bride_first_name"));
                    stmt.setString(6, request.getParameter("bride_middle_name"));
                    stmt.setString(7, request.getParameter("bride_last_name"));
                    stmt.setInt(8, Integer.parseInt(request.getParameter("bride_age")));
                    stmt.setString(9, request.getParameter("marriage_date"));
                    stmt.setString(10, request.getParameter("marriage_place"));
                    stmt.setString(11, request.getParameter("wereda"));
                    stmt.setString(12, request.getParameter("kebele"));
                    stmt.setString(13, request.getParameter("registration_date"));
                    stmt.setString(14, recordId);
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Marriage record updated successfully!</div>");
                    }
                    
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                }
            }
            
            // Load existing record
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM marriage_records WHERE record_id = ?");
                stmt.setString(1, recordId);
                record = stmt.executeQuery();
                record.next();
            } catch (Exception e) {
                out.println("<div class='error-message'>Error loading record: " + e.getMessage() + "</div>");
            }
            %>
            
            <form method="post" class="record-form">
                <h3>Groom Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="groom_first_name">Groom First Name:</label>
                        <input type="text" id="groom_first_name" name="groom_first_name" value="<%= record.getString("groom_first_name") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="groom_middle_name">Groom Middle Name:</label>
                        <input type="text" id="groom_middle_name" name="groom_middle_name" value="<%= record.getString("groom_middle_name") != null ? record.getString("groom_middle_name") : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="groom_last_name">Groom Last Name:</label>
                        <input type="text" id="groom_last_name" name="groom_last_name" value="<%= record.getString("groom_last_name") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="groom_age">Groom Age:</label>
                        <input type="number" id="groom_age" name="groom_age" value="<%= record.getInt("groom_age") %>" required>
                    </div>
                </div>
                
                <h3>Bride Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="bride_first_name">Bride First Name:</label>
                        <input type="text" id="bride_first_name" name="bride_first_name" value="<%= record.getString("bride_first_name") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="bride_middle_name">Bride Middle Name:</label>
                        <input type="text" id="bride_middle_name" name="bride_middle_name" value="<%= record.getString("bride_middle_name") != null ? record.getString("bride_middle_name") : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="bride_last_name">Bride Last Name:</label>
                        <input type="text" id="bride_last_name" name="bride_last_name" value="<%= record.getString("bride_last_name") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="bride_age">Bride Age:</label>
                        <input type="number" id="bride_age" name="bride_age" value="<%= record.getInt("bride_age") %>" required>
                    </div>
                </div>
                
                <h3>Marriage Details</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="marriage_date">Marriage Date:</label>
                        <input type="date" id="marriage_date" name="marriage_date" value="<%= record.getDate("marriage_date") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="marriage_place">Marriage Place:</label>
                        <input type="text" id="marriage_place" name="marriage_place" value="<%= record.getString("marriage_place") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="wereda">Wereda:</label>
                        <input type="text" id="wereda" name="wereda" value="<%= record.getString("wereda") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="kebele">Kebele:</label>
                        <input type="text" id="kebele" name="kebele" value="<%= record.getString("kebele") %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="registration_date">Registration Date:</label>
                        <input type="date" id="registration_date" name="registration_date" value="<%= record.getDate("registration_date") %>" required>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Update Record</button>
                    <a href="view-marriage.jsp" class="btn btn-secondary">Back to List</a>
                    <% if ("admin".equals(role)) { %>
                    <a href="delete-marriage.jsp?id=<%= recordId %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this record?')">Delete Record</a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>