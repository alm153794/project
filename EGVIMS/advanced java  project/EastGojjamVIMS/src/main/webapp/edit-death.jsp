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
    <title>Edit Death Record - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <script src="assets/js/validation.js"></script>
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .form-container { max-width: 1000px; margin: 0 auto; }
        .form-container h2 { color: #2c3e50; text-align: center; font-size: 2.5rem; margin-bottom: 2rem; }
        .record-form { background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin-bottom: 1.5rem; }
        .form-group label { display: block; color: #2c3e50; font-weight: 600; margin-bottom: 0.5rem; }
        .form-group input, .form-group select { width: 100%; padding: 1rem; border: 2px solid #e0e6ed; border-radius: 10px; font-size: 1rem; transition: all 0.3s ease; box-sizing: border-box; }
        .form-group input:focus, .form-group select:focus { outline: none; border-color: #4facfe; box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.1); }
        .form-actions { display: flex; gap: 1rem; justify-content: center; margin-top: 2rem; flex-wrap: wrap; }
        .btn { padding: 1rem 2rem; border: none; border-radius: 25px; font-size: 1rem; font-weight: bold; text-decoration: none; cursor: pointer; transition: all 0.3s ease; display: inline-block; text-align: center; }
        .btn-primary { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3); }
        .btn-primary:hover { background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); transform: translateY(-3px); box-shadow: 0 15px 35px rgba(79, 172, 254, 0.4); }
        .btn-secondary { background: linear-gradient(135deg, #6c757d, #495057); color: white; box-shadow: 0 5px 15px rgba(108, 117, 125, 0.3); }
        .btn-secondary:hover { background: linear-gradient(135deg, #495057, #343a40); transform: translateY(-3px); }
        .btn-danger { background: linear-gradient(135deg, #dc3545, #c82333); color: white; box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3); }
        .btn-danger:hover { background: linear-gradient(135deg, #c82333, #bd2130); transform: translateY(-3px); }
        .success-message { background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3); }
        .error-message { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3); }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="form-container">
            <h2> Edit Death Record</h2>
            
            <% if (request.getMethod().equals("POST")) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "UPDATE death_records SET deceased_first_name=?, deceased_middle_name=?, deceased_last_name=?, gender=?, date_of_death=?, place_of_death=?, wereda=?, kebele=?, cause_of_death=?, age_at_death=?, registration_date=? WHERE record_id=?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    stmt.setString(1, request.getParameter("deceased_first_name"));
                    stmt.setString(2, request.getParameter("deceased_middle_name"));
                    stmt.setString(3, request.getParameter("deceased_last_name"));
                    stmt.setString(4, request.getParameter("gender"));
                    stmt.setString(5, request.getParameter("date_of_death"));
                    stmt.setString(6, request.getParameter("place_of_death"));
                    stmt.setString(7, request.getParameter("wereda"));
                    stmt.setString(8, request.getParameter("kebele"));
                    stmt.setString(9, request.getParameter("cause_of_death"));
                    stmt.setInt(10, Integer.parseInt(request.getParameter("age_at_death")));
                    stmt.setString(11, request.getParameter("registration_date"));
                    stmt.setString(12, recordId);
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Death record updated successfully!</div>");
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
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM death_records WHERE record_id = ?");
                stmt.setString(1, recordId);
                record = stmt.executeQuery();
                record.next();
            } catch (Exception e) {
                out.println("<div class='error-message'>Error loading record: " + e.getMessage() + "</div>");
            }
            %>
            
            <form method="post" class="record-form">
                <div class="form-row">
                    <div class="form-group">
                        <label for="deceased_first_name">Deceased First Name:</label>
                        <input type="text" id="deceased_first_name" name="deceased_first_name" value="<%= record.getString("deceased_first_name") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="deceased_middle_name">Deceased Middle Name:</label>
                        <input type="text" id="deceased_middle_name" name="deceased_middle_name" value="<%= record.getString("deceased_middle_name") != null ? record.getString("deceased_middle_name") : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="deceased_last_name">Deceased Last Name:</label>
                        <input type="text" id="deceased_last_name" name="deceased_last_name" value="<%= record.getString("deceased_last_name") %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="gender">Gender:</label>
                        <select id="gender" name="gender" required>
                            <option value="Male" <%= "Male".equals(record.getString("gender")) ? "selected" : "" %>>Male</option>
                            <option value="Female" <%= "Female".equals(record.getString("gender")) ? "selected" : "" %>>Female</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="date_of_death">Date of Death:</label>
                        <input type="date" id="date_of_death" name="date_of_death" value="<%= record.getDate("date_of_death") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="age_at_death">Age at Death:</label>
                        <input type="number" id="age_at_death" name="age_at_death" value="<%= record.getInt("age_at_death") %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="place_of_death">Place of Death:</label>
                        <input type="text" id="place_of_death" name="place_of_death" value="<%= record.getString("place_of_death") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="wereda">Wereda:</label>
                        <input type="text" id="wereda" name="wereda" value="<%= record.getString("wereda") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="kebele">Kebele:</label>
                        <input type="text" id="kebele" name="kebele" value="<%= record.getString("kebele") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="registration_date">Registration Date:</label>
                        <input type="date" id="registration_date" name="registration_date" value="<%= record.getDate("registration_date") %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="cause_of_death">Cause of Death:</label>
                        <textarea id="cause_of_death" name="cause_of_death"><%= record.getString("cause_of_death") != null ? record.getString("cause_of_death") : "" %></textarea>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Update Record</button>
                    <a href="view-death.jsp" class="btn btn-secondary">Back to List</a>
                    <% if ("admin".equals(role)) { %>
                    <a href="delete-death.jsp?id=<%= recordId %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this record?')">Delete Record</a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>