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
    <title>Divorce Records - East Gojjam VIMS</title>
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
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 15px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .data-table th { background: linear-gradient(135deg, #4facfe, #00f2fe); color: white; padding: 1rem; text-align: left; font-weight: 600; }
        .data-table td { padding: 1rem; border-bottom: 1px solid #eee; }
        .data-table tr:hover { background: #f8f9fa; }
        .data-table tr:last-child td { border-bottom: none; }
        .action-buttons { display: flex; gap: 0.5rem; align-items: center; white-space: nowrap; }
        .action-buttons .btn { padding: 0.5rem 1rem; font-size: 0.8rem; min-width: auto; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="table-container">
            <h2> Divorce Records</h2>
            <div class="table-actions">
                <div>
                    <% if ("data_entry".equals(session.getAttribute("role"))) { %>
                    <a href="add-divorce.jsp" class="btn btn-primary"> Add New Record</a>
                    <% } %>
                    <a href="export-divorce.jsp" class="btn btn-success"> Export CSV</a>
                </div>
                <form method="get" style="display: flex; gap: 0.5rem; align-items: center;">
                    <input type="text" name="search" placeholder=" Search by ID or Name..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" style="padding: 0.75rem; border: 2px solid #e0e6ed; border-radius: 25px; font-size: 1rem; width: 300px;">
                    <button type="submit" class="btn btn-primary">Search</button>
                    <% if (request.getParameter("search") != null) { %>
                    <a href="view-divorce.jsp" class="btn btn-secondary">Clear</a>
                    <% } %>
                </form>
            </div>
            
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Photo</th>
                        <th>Husband Name</th>
                        <th>Wife Name</th>
                        <th>Marriage Date</th>
                        <th>Divorce Date</th>
                        <th>Divorce Place</th>
                        <th>Registration Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                            
                            String searchTerm = request.getParameter("search");
                            String sql = "SELECT d.* FROM divorce_records d";
                            
                            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                                sql += " WHERE d.record_id LIKE ? OR CONCAT(d.husband_first_name, ' ', d.husband_last_name) LIKE ? OR CONCAT(d.wife_first_name, ' ', d.wife_last_name) LIKE ?";
                            }
                            sql += " ORDER BY d.created_date DESC";
                            
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            
                            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                                stmt.setString(1, "%" + searchTerm + "%");
                                stmt.setString(2, "%" + searchTerm + "%");
                                stmt.setString(3, "%" + searchTerm + "%");
                            }
                            
                            ResultSet rs = stmt.executeQuery();
                            
                            while (rs.next()) {
                                String husbandName = rs.getString("husband_first_name") + " " + 
                                                   (rs.getString("husband_middle_name") != null ? rs.getString("husband_middle_name") + " " : "") +
                                                   rs.getString("husband_last_name");
                                String wifeName = rs.getString("wife_first_name") + " " + 
                                                (rs.getString("wife_middle_name") != null ? rs.getString("wife_middle_name") + " " : "") +
                                                rs.getString("wife_last_name");
                    %>
                    <tr>
                        <td><%= rs.getString("record_id") %></td>
                        <td>
                            <% if (rs.getString("photo_path") != null && !rs.getString("photo_path").isEmpty()) { %>
                                <img src="<%= rs.getString("photo_path") %>" alt="Couple Photo" style="width: 60px; height: 40px; object-fit: cover; border-radius: 5px; border: 1px solid #ddd;">
                            <% } else { %>
                                <span style="color: #999; font-size: 0.8rem;">No Photo</span>
                            <% } %>
                        </td>
                        <td><%= husbandName %></td>
                        <td><%= wifeName %></td>
                        <td><%= rs.getDate("marriage_date") %></td>
                        <td><%= rs.getDate("divorce_date") %></td>
                        <td><%= rs.getString("divorce_place") %></td>
                        <td><%= rs.getDate("registration_date") %></td>
                        <td>
                            <div class="action-buttons">
                                <a href="detail-divorce.jsp?id=<%= rs.getString("record_id") %>" class="btn btn-success"> View</a>
                                <% if ("data_entry".equals(session.getAttribute("role"))) { %>
                                <a href="edit-divorce.jsp?id=<%= rs.getString("record_id") %>" class="btn btn-secondary"> Edit</a>
                                <% } %>
                                <% if (!"guest".equals(session.getAttribute("role"))) { %>
                                <a href="certified-document.jsp?type=divorce&id=<%= rs.getString("record_id") %>" class="btn btn-primary"> Certificate</a>
                                <% } %>
                                <% if ("data_entry".equals(session.getAttribute("role"))) { %>
                                <a href="delete-divorce.jsp?id=<%= rs.getString("record_id") %>" class="btn btn-danger" onclick="return confirm('Are you sure?')">Delete</a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                            rs.close();
                            stmt.close();
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='8'>Error loading records: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
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