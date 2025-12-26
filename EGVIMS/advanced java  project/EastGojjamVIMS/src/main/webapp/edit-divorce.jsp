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
    <title>Edit Divorce Record - East Gojjam VIMS</title>
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
            <h2> Edit Divorce Record</h2>
            
            <% if (request.getMethod().equals("POST")) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "UPDATE divorce_records SET husband_first_name=?, husband_middle_name=?, husband_last_name=?, wife_first_name=?, wife_middle_name=?, wife_last_name=?, marriage_date=?, divorce_date=?, divorce_place=?, divorce_reason=?, wereda=?, kebele=?, registration_date=?, husband_age=?, wife_age=? WHERE record_id=?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    stmt.setString(1, request.getParameter("husband_first_name"));
                    stmt.setString(2, request.getParameter("husband_middle_name"));
                    stmt.setString(3, request.getParameter("husband_last_name"));
                    stmt.setString(4, request.getParameter("wife_first_name"));
                    stmt.setString(5, request.getParameter("wife_middle_name"));
                    stmt.setString(6, request.getParameter("wife_last_name"));
                    stmt.setString(7, request.getParameter("marriage_date"));
                    stmt.setString(8, request.getParameter("divorce_date"));
                    stmt.setString(9, request.getParameter("divorce_place"));
                    stmt.setString(10, request.getParameter("divorce_reason"));
                    stmt.setString(11, request.getParameter("wereda"));
                    stmt.setString(12, request.getParameter("kebele"));
                    stmt.setString(13, request.getParameter("registration_date"));
                    stmt.setInt(14, Integer.parseInt(request.getParameter("husband_age")));
                    stmt.setInt(15, Integer.parseInt(request.getParameter("wife_age")));
                    stmt.setString(16, recordId);
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Divorce record updated successfully!</div>");
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
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM divorce_records WHERE record_id = ?");
                stmt.setString(1, recordId);
                record = stmt.executeQuery();
                record.next();
            } catch (Exception e) {
                out.println("<div class='error-message'>Error loading record: " + e.getMessage() + "</div>");
            }
            %>
            
            <form method="post" class="record-form">
                <h3>Husband Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="husband_first_name">Husband First Name:</label>
                        <input type="text" id="husband_first_name" name="husband_first_name" value="<%= record.getString("husband_first_name") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="husband_middle_name">Husband Middle Name:</label>
                        <input type="text" id="husband_middle_name" name="husband_middle_name" value="<%= record.getString("husband_middle_name") != null ? record.getString("husband_middle_name") : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="husband_last_name">Husband Last Name:</label>
                        <input type="text" id="husband_last_name" name="husband_last_name" value="<%= record.getString("husband_last_name") %>" required>
                    </div>
                </div>
                
                <h3>Wife Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="wife_first_name">Wife First Name:</label>
                        <input type="text" id="wife_first_name" name="wife_first_name" value="<%= record.getString("wife_first_name") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="wife_middle_name">Wife Middle Name:</label>
                        <input type="text" id="wife_middle_name" name="wife_middle_name" value="<%= record.getString("wife_middle_name") != null ? record.getString("wife_middle_name") : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="wife_last_name">Wife Last Name:</label>
                        <input type="text" id="wife_last_name" name="wife_last_name" value="<%= record.getString("wife_last_name") %>" required>
                    </div>
                </div>
                
                <h3>Divorce Details</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="marriage_date">Marriage Date:</label>
                        <input type="date" id="marriage_date" name="marriage_date" value="<%= record.getDate("marriage_date") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="divorce_date">Divorce Date:</label>
                        <input type="date" id="divorce_date" name="divorce_date" value="<%= record.getDate("divorce_date") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="divorce_place">Divorce Place:</label>
                        <input type="text" id="divorce_place" name="divorce_place" value="<%= record.getString("divorce_place") %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="wereda">Wereda:</label>
                        <input type="text" id="wereda" name="wereda" value="<%= record.getString("wereda") != null ? record.getString("wereda") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label for="kebele">Kebele:</label>
                        <input type="text" id="kebele" name="kebele" value="<%= record.getString("kebele") != null ? record.getString("kebele") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label for="registration_date">Registration Date:</label>
                        <input type="date" id="registration_date" name="registration_date" value="<%= record.getDate("registration_date") %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="husband_age">Husband Age:</label>
                        <input type="number" id="husband_age" name="husband_age" value="<%= record.getInt("husband_age") %>" min="18" required>
                    </div>
                    <div class="form-group">
                        <label for="wife_age">Wife Age:</label>
                        <input type="number" id="wife_age" name="wife_age" value="<%= record.getInt("wife_age") %>" min="18" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="divorce_reason">Divorce Reason:</label>
                        <textarea id="divorce_reason" name="divorce_reason"><%= record.getString("divorce_reason") != null ? record.getString("divorce_reason") : "" %></textarea>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Update Record</button>
                    <a href="view-divorce.jsp" class="btn btn-secondary">Back to List</a>
                    <% if ("admin".equals(role)) { %>
                    <a href="delete-divorce.jsp?id=<%= recordId %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this record?')">Delete Record</a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>