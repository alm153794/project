<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Immigration Records - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .table-container h2 { color: #2c3e50; text-align: center; font-size: 2.5rem; margin-bottom: 2rem; }
        .table-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem; }
        .btn { padding: 0.75rem 1.5rem; border: none; border-radius: 25px; font-size: 0.9rem; font-weight: bold; text-decoration: none; cursor: pointer; transition: all 0.3s ease; display: inline-block; text-align: center; }
        .btn-primary { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; box-shadow: 0 5px 15px rgba(79, 172, 254, 0.3); }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(79, 172, 254, 0.4); }
        .btn-success { background: linear-gradient(135deg, #28a745, #20c997); color: white; box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3); }
        .btn-success:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(40, 167, 69, 0.4); }
        .btn-secondary { background: linear-gradient(135deg, #6c757d, #495057); color: white; box-shadow: 0 3px 10px rgba(108, 117, 125, 0.3); }
        .btn-secondary:hover { transform: translateY(-2px); }
        .btn-danger { background: linear-gradient(135deg, #dc3545, #c82333); color: white; box-shadow: 0 3px 10px rgba(220, 53, 69, 0.3); }
        .btn-danger:hover { transform: translateY(-2px); }
        #searchInput { padding: 1rem; border: 2px solid #e0e6ed; border-radius: 25px; font-size: 1rem; width: 300px; transition: all 0.3s ease; }
        #searchInput:focus { outline: none; border-color: #4facfe; box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.1); }
        .table-wrapper { overflow-x: auto; margin: 1rem 0; }
        .data-table { width: 100%; min-width: 800px; border-collapse: collapse; background: white; border-radius: 15px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .data-table th { background: linear-gradient(135deg, #4facfe, #00f2fe); color: white; padding: 0.8rem; text-align: left; font-weight: 600; font-size: 0.9rem; white-space: nowrap; }
        .data-table td { padding: 0.8rem; border-bottom: 1px solid #eee; font-size: 0.9rem; }
        .data-table tr:hover { background: #f8f9fa; }
        .data-table tr:last-child td { border-bottom: none; }
        .action-buttons { display: flex; gap: 0.3rem; align-items: center; white-space: nowrap; }
        .action-buttons .btn { padding: 0.4rem 0.8rem; font-size: 0.75rem; min-width: auto; }
        @media (max-width: 768px) {
            .main-content { margin: 1rem; padding: 1rem; }
            .table-actions { flex-direction: column; align-items: stretch; gap: 1rem; }
            .table-actions > div { display: flex; flex-wrap: wrap; gap: 0.5rem; justify-content: center; }
            .data-table th, .data-table td { padding: 0.5rem; font-size: 0.8rem; }
            .btn { padding: 0.5rem 1rem; font-size: 0.8rem; }
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="table-container">
            <h2> Immigration Records</h2>
            <div class="table-actions">
                <div>
                    <% if ("data_entry".equals(session.getAttribute("role"))) { %>
                    <a href="add-immigration.jsp" class="btn btn-primary"> Add New Record</a>
                    <% } %>
                    <a href="export-immigration.jsp" class="btn btn-success"> Export CSV</a>
                </div>
                <form method="get" style="display: flex; gap: 0.5rem; align-items: center;">
                    <input type="text" name="search" placeholder=" Search by ID or Name..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" style="padding: 0.75rem; border: 2px solid #e0e6ed; border-radius: 25px; font-size: 1rem; width: 300px;">
                    <button type="submit" class="btn btn-primary">Search</button>
                    <% if (request.getParameter("search") != null) { %>
                    <a href="view-immigration.jsp" class="btn btn-secondary">Clear</a>
                    <% } %>
                </form>
            </div>
            
            <div class="table-wrapper">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Photo</th>
                        <th>Person Name</th>
                        <th>Gender</th>
                        <th>Nationality</th>
                        <th>Type</th>
                        <th>Immigration Date</th>
                        <th>From Country</th>
                        <th>To Country</th>
                        <th>Registration Date</th>
                        <% if (!"guest".equals(session.getAttribute("role"))) { %>
                        <th>Actions</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                            
                            String searchTerm = request.getParameter("search");
                            String sql = "SELECT i.* FROM immigration_records i";
                            
                            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                                sql += " WHERE i.record_id LIKE ? OR CONCAT(i.person_first_name, ' ', IFNULL(i.person_middle_name, ''), ' ', i.person_last_name) LIKE ?";
                            }
                            sql += " ORDER BY i.created_date DESC";
                            
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            
                            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                                stmt.setString(1, "%" + searchTerm + "%");
                                stmt.setString(2, "%" + searchTerm + "%");
                            }
                            
                            ResultSet rs = stmt.executeQuery();
                            
                            while (rs.next()) {
                                String fullName = rs.getString("person_first_name") + " " + 
                                                (rs.getString("person_middle_name") != null ? rs.getString("person_middle_name") + " " : "") +
                                                rs.getString("person_last_name");
                    %>
                    <tr>
                        <td><%= rs.getString("record_id") %></td>
                        <td>
                            <% if (rs.getString("photo_path") != null && !rs.getString("photo_path").isEmpty()) { %>
                                <img src="<%= rs.getString("photo_path") %>" alt="Person Photo" style="width: 40px; height: 50px; object-fit: cover; border-radius: 5px; border: 1px solid #ddd;">
                            <% } else { %>
                                <span style="color: #999; font-size: 0.8rem;">No Photo</span>
                            <% } %>
                        </td>
                        <td><%= fullName %></td>
                        <td><%= rs.getString("gender") %></td>
                        <td><%= rs.getString("nationality") %></td>
                        <td><%= rs.getString("immigration_type") %></td>
                        <td><%= rs.getDate("immigration_date") %></td>
                        <td><%= rs.getString("from_country") != null ? rs.getString("from_country") : "N/A" %></td>
                        <td><%= rs.getString("to_country") != null ? rs.getString("to_country") : "N/A" %></td>
                        <td><%= rs.getDate("registration_date") %></td>
                        <% if (!"guest".equals(session.getAttribute("role"))) { %>
                        <td>
                            <div class="action-buttons">
                                <a href="detail-immigration.jsp?id=<%= rs.getString("record_id") %>" class="btn btn-success"> View</a>
                                <% if ("data_entry".equals(session.getAttribute("role"))) { %>
                                <a href="edit-immigration.jsp?id=<%= rs.getString("record_id") %>" class="btn btn-secondary"> Edit</a>
                                <% } %>
                                <% if (!"guest".equals(session.getAttribute("role"))) { %>
                                <a href="certified-document.jsp?type=immigration&id=<%= rs.getString("record_id") %>" class="btn btn-primary"> Certificate</a>
                                <% } %>
                                <% if ("data_entry".equals(session.getAttribute("role"))) { %>
                                <a href="delete-immigration.jsp?id=<%= rs.getString("record_id") %>" class="btn btn-danger" onclick="return confirm('Are you sure?')">Delete</a>
                                <% } %>
                            </div>
                        </td>
                        <% } %>
                    </tr>
                    <%
                            }
                            rs.close();
                            stmt.close();
                            conn.close();
                        } catch (Exception e) {
                            String colspan = "guest".equals(session.getAttribute("role")) ? "9" : "10";
                            out.println("<tr><td colspan='" + colspan + "'>Error loading records: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
            </div>
        </div>
    </div>
    
    <script>
        document.getElementById('searchInput').addEventListener('keyup', function() {
            const filter = this.value.toLowerCase();
            const rows = document.querySelectorAll('.data-table tbody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(filter) ? '' : 'none';
            });
        });
    </script>
    
    <%@ include file="footer.jsp" %>
</body>
</html>