<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verify Your Record - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .page-header { text-align: center; color: white; margin-bottom: 2rem; }
        .page-header h2 { font-size: 2.5rem; margin-bottom: 0.5rem; }
        .search-form { background: white; padding: 2rem; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .results-section { margin-top: 2rem; }
    </style>
    <script>
        function validateForm() {
            var recordId = document.getElementsByName('recordId')[0].value.trim();
            var recordType = document.getElementsByName('recordType')[0].value;
            
            if (!recordId || !recordType) {
                alert('Please fill in all required fields.');
                return false;
            }
            
            if (recordId.length < 3) {
                alert('Record ID must be at least 3 characters long.');
                return false;
            }
            
            return true;
        }
    </script>
</head>
<body>

    
    <div class="container">
        <div class="page-header">
            <a href="index.jsp" style="color: #4facfe; text-decoration: none; font-size: 1rem; margin-bottom: 1rem; display: inline-block;">← Back to Home</a>
            <h2> Verify Your Record</h2>
            <p>Check if your vital records are registered in our system</p>
        </div>
        
        <div class="search-form">
            <form method="post" action="">
                <div class="form-row">
                    <div class="form-group">
                        <label>Record ID:</label>
                        <input type="text" name="recordId" value="<%= request.getParameter("recordId") != null ? request.getParameter("recordId") : "" %>" required placeholder="ETH2020001234567">
                    </div>
                    <div class="form-group">
                        <label>Record Type:</label>
                        <select name="recordType" required>
                            <option value="" <%= "".equals(request.getParameter("recordType")) ? "selected" : "" %>>Select Record Type</option>
                            <option value="birth" <%= "birth".equals(request.getParameter("recordType")) ? "selected" : "" %>>Birth Records</option>
                            <option value="marriage" <%= "marriage".equals(request.getParameter("recordType")) ? "selected" : "" %>>Marriage Records</option>
                            <option value="death" <%= "death".equals(request.getParameter("recordType")) ? "selected" : "" %>>Death Records</option>
                            <option value="divorce" <%= "divorce".equals(request.getParameter("recordType")) ? "selected" : "" %>>Divorce Records</option>
                            <option value="immigration" <%= "immigration".equals(request.getParameter("recordType")) ? "selected" : "" %>>Immigration Records</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary" onclick="return validateForm()"> Search Records</button>
            </form>
        </div>
        
        <%
        String recordId = request.getParameter("recordId");
        String recordType = request.getParameter("recordType");
        
        if (recordType != null && !recordType.isEmpty() && recordId != null && !recordId.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                
                boolean foundRecords = false;
        %>
        
        <div class="results-section">
            <% if (foundRecords) { %>
            <div style="background: #d4edda; border: 1px solid #c3e6cb; border-radius: 8px; padding: 1rem; margin-bottom: 1rem; text-align: center;">
                <h3 style="color: #155724; margin: 0;">✅ You Are Registered!</h3>
                <p style="color: #155724; margin: 0.5rem 0 0 0;">Your record has been found in our system.</p>
            </div>
            <% } %>
            <h3>Search Results</h3>
            
            <%
            // Search Birth Records
            if ("birth".equals(recordType)) {
                String birthQuery = "SELECT b.*, u.full_name as registered_by_name FROM birth_records b LEFT JOIN users u ON b.registered_by = u.user_id WHERE b.record_id = ?";
                
                PreparedStatement birthStmt = conn.prepareStatement(birthQuery);
                birthStmt.setString(1, recordId);
                
                ResultSet birthRs = birthStmt.executeQuery();
                while (birthRs.next()) {
                    foundRecords = true;
            %>
            <div class="record-found">
                <h4>✅ Birth Record Found</h4>
                <p><strong>Record ID:</strong> <%= birthRs.getString("record_id") %></p>
                <p><strong>Full Name:</strong> <%= birthRs.getString("child_first_name") %> <%= birthRs.getString("child_middle_name") != null ? birthRs.getString("child_middle_name") : "" %> <%= birthRs.getString("child_last_name") %></p>
                <p><strong>Gender:</strong> <%= birthRs.getString("gender") %></p>
                <p><strong>Date of Birth:</strong> <%= birthRs.getDate("date_of_birth") %></p>
                <p><strong>Place of Birth:</strong> <%= birthRs.getString("place_of_birth") %></p>
                <p><strong>Father's Name:</strong> <%= birthRs.getString("father_full_name") %></p>
                <p><strong>Mother's Name:</strong> <%= birthRs.getString("mother_full_name") %></p>
                <p><strong>Location:</strong> <%= birthRs.getString("wereda") != null ? birthRs.getString("wereda") + ", " + birthRs.getString("kebele") : "Not specified" %></p>
                <p><strong>Registration Date:</strong> <%= birthRs.getDate("registration_date") %></p>

                <p><strong>Created Date:</strong> <%= birthRs.getTimestamp("created_date") %></p>
            </div>
            <%
                }
                birthRs.close();
                birthStmt.close();
            }
            
            // Search Marriage Records
            if ("marriage".equals(recordType)) {
                String marriageQuery = "SELECT m.*, u.full_name as registered_by_name FROM marriage_records m LEFT JOIN users u ON m.registered_by = u.user_id WHERE m.record_id = ?";
                
                PreparedStatement marriageStmt = conn.prepareStatement(marriageQuery);
                marriageStmt.setString(1, recordId);
                
                ResultSet marriageRs = marriageStmt.executeQuery();
                while (marriageRs.next()) {
                    foundRecords = true;
            %>
            <div class="record-found">
                <h4>✅ Marriage Record Found</h4>
                <p><strong>Record ID:</strong> <%= marriageRs.getString("record_id") %></p>
                <p><strong>Groom:</strong> <%= marriageRs.getString("groom_first_name") %> <%= marriageRs.getString("groom_middle_name") != null ? marriageRs.getString("groom_middle_name") : "" %> <%= marriageRs.getString("groom_last_name") %></p>
                <p><strong>Bride:</strong> <%= marriageRs.getString("bride_first_name") %> <%= marriageRs.getString("bride_middle_name") != null ? marriageRs.getString("bride_middle_name") : "" %> <%= marriageRs.getString("bride_last_name") %></p>
                <p><strong>Marriage Date:</strong> <%= marriageRs.getDate("marriage_date") %></p>
                <p><strong>Marriage Place:</strong> <%= marriageRs.getString("marriage_place") %></p>
                <p><strong>Location:</strong> <%= marriageRs.getString("wereda") != null ? marriageRs.getString("wereda") + ", " + marriageRs.getString("kebele") : "Not specified" %></p>
                <p><strong>Registration Date:</strong> <%= marriageRs.getDate("registration_date") %></p>

                <p><strong>Created Date:</strong> <%= marriageRs.getTimestamp("created_date") %></p>
            </div>
            <%
                }
                marriageRs.close();
                marriageStmt.close();
            }
            
            // Search Death Records
            if ("death".equals(recordType)) {
                String deathQuery = "SELECT d.*, u.full_name as registered_by_name FROM death_records d LEFT JOIN users u ON d.registered_by = u.user_id WHERE d.record_id = ?";
                
                PreparedStatement deathStmt = conn.prepareStatement(deathQuery);
                deathStmt.setString(1, recordId);
                
                ResultSet deathRs = deathStmt.executeQuery();
                while (deathRs.next()) {
                    foundRecords = true;
            %>
            <div class="record-found">
                <h4>✅ Death Record Found</h4>
                <p><strong>Record ID:</strong> <%= deathRs.getString("record_id") %></p>
                <p><strong>Deceased Name:</strong> <%= deathRs.getString("deceased_first_name") %> <%= deathRs.getString("deceased_middle_name") != null ? deathRs.getString("deceased_middle_name") : "" %> <%= deathRs.getString("deceased_last_name") %></p>
                <p><strong>Gender:</strong> <%= deathRs.getString("gender") %></p>
                <p><strong>Date of Death:</strong> <%= deathRs.getDate("date_of_death") %></p>
                <p><strong>Place of Death:</strong> <%= deathRs.getString("place_of_death") %></p>
                <p><strong>Cause of Death:</strong> <%= deathRs.getString("cause_of_death") != null ? deathRs.getString("cause_of_death") : "Not specified" %></p>
                <p><strong>Age at Death:</strong> <%= deathRs.getInt("age_at_death") %> years</p>
                <p><strong>Location:</strong> <%= deathRs.getString("wereda") != null ? deathRs.getString("wereda") + ", " + deathRs.getString("kebele") : "Not specified" %></p>
                <p><strong>Registration Date:</strong> <%= deathRs.getDate("registration_date") %></p>

                <p><strong>Created Date:</strong> <%= deathRs.getTimestamp("created_date") %></p>
            </div>
            <%
                }
                deathRs.close();
                deathStmt.close();
            }
            
            // Search Divorce Records
            if ("divorce".equals(recordType)) {
                String divorceQuery = "SELECT d.*, u.full_name as registered_by_name FROM divorce_records d LEFT JOIN users u ON d.registered_by = u.user_id WHERE d.record_id = ?";
                
                PreparedStatement divorceStmt = conn.prepareStatement(divorceQuery);
                divorceStmt.setString(1, recordId);
                
                ResultSet divorceRs = divorceStmt.executeQuery();
                while (divorceRs.next()) {
                    foundRecords = true;
            %>
            <div class="record-found">
                <h4>✅ Divorce Record Found</h4>
                <p><strong>Record ID:</strong> <%= divorceRs.getString("record_id") %></p>
                <p><strong>Husband:</strong> <%= divorceRs.getString("husband_first_name") %> <%= divorceRs.getString("husband_middle_name") != null ? divorceRs.getString("husband_middle_name") : "" %> <%= divorceRs.getString("husband_last_name") %></p>
                <p><strong>Wife:</strong> <%= divorceRs.getString("wife_first_name") %> <%= divorceRs.getString("wife_middle_name") != null ? divorceRs.getString("wife_middle_name") : "" %> <%= divorceRs.getString("wife_last_name") %></p>
                <p><strong>Marriage Date:</strong> <%= divorceRs.getDate("marriage_date") %></p>
                <p><strong>Divorce Date:</strong> <%= divorceRs.getDate("divorce_date") %></p>
                <p><strong>Divorce Place:</strong> <%= divorceRs.getString("divorce_place") %></p>
                <p><strong>Divorce Reason:</strong> <%= divorceRs.getString("divorce_reason") != null ? divorceRs.getString("divorce_reason") : "Not specified" %></p>
                <p><strong>Location:</strong> <%= divorceRs.getString("wereda") != null ? divorceRs.getString("wereda") + ", " + divorceRs.getString("kebele") : "Not specified" %></p>
                <p><strong>Registration Date:</strong> <%= divorceRs.getDate("registration_date") %></p>

                <p><strong>Created Date:</strong> <%= divorceRs.getTimestamp("created_date") %></p>
            </div>
            <%
                }
                divorceRs.close();
                divorceStmt.close();
            }
            
            // Search Immigration Records
            if ("immigration".equals(recordType)) {
                String immigrationQuery = "SELECT i.*, u.full_name as registered_by_name FROM immigration_records i LEFT JOIN users u ON i.registered_by = u.user_id WHERE i.record_id = ?";
                
                PreparedStatement immigrationStmt = conn.prepareStatement(immigrationQuery);
                immigrationStmt.setString(1, recordId);
                
                ResultSet immigrationRs = immigrationStmt.executeQuery();
                while (immigrationRs.next()) {
                    foundRecords = true;
            %>
            <div class="record-found">
                <h4>✅ Immigration Record Found</h4>
                <p><strong>Record ID:</strong> <%= immigrationRs.getString("record_id") %></p>
                <p><strong>Full Name:</strong> <%= immigrationRs.getString("person_first_name") %> <%= immigrationRs.getString("person_middle_name") != null ? immigrationRs.getString("person_middle_name") : "" %> <%= immigrationRs.getString("person_last_name") %></p>
                <p><strong>Gender:</strong> <%= immigrationRs.getString("gender") %></p>
                <p><strong>Date of Birth:</strong> <%= immigrationRs.getDate("date_of_birth") %></p>
                <p><strong>Nationality:</strong> <%= immigrationRs.getString("nationality") %></p>
                <p><strong>Passport Number:</strong> <%= immigrationRs.getString("passport_number") != null ? immigrationRs.getString("passport_number") : "Not specified" %></p>
                <p><strong>Immigration Type:</strong> <%= immigrationRs.getString("immigration_type") %></p>
                <p><strong>From Country:</strong> <%= immigrationRs.getString("from_country") != null ? immigrationRs.getString("from_country") : "Not specified" %></p>
                <p><strong>To Country:</strong> <%= immigrationRs.getString("to_country") != null ? immigrationRs.getString("to_country") : "Not specified" %></p>
                <p><strong>From Location:</strong> <%= immigrationRs.getString("from_location") != null ? immigrationRs.getString("from_location") : "Not specified" %></p>
                <p><strong>To Location:</strong> <%= immigrationRs.getString("to_location") != null ? immigrationRs.getString("to_location") : "Not specified" %></p>
                <p><strong>Immigration Date:</strong> <%= immigrationRs.getDate("immigration_date") %></p>
                <p><strong>Purpose:</strong> <%= immigrationRs.getString("purpose") != null ? immigrationRs.getString("purpose") : "Not specified" %></p>
                <p><strong>Duration (Days):</strong> <%= immigrationRs.getInt("duration_days") > 0 ? immigrationRs.getInt("duration_days") : "Not specified" %></p>
                <p><strong>Location:</strong> <%= immigrationRs.getString("wereda") != null ? immigrationRs.getString("wereda") + ", " + immigrationRs.getString("kebele") : "Not specified" %></p>
                <p><strong>Registration Date:</strong> <%= immigrationRs.getDate("registration_date") %></p>

                <p><strong>Created Date:</strong> <%= immigrationRs.getTimestamp("created_date") %></p>
            </div>
            <%
                }
                immigrationRs.close();
                immigrationStmt.close();
            }
            
            if (!foundRecords) {
            %>
            <div class="no-records">
                <h4>❌ You Have Not Registered</h4>
                <p>You are not registered in our <%= recordType %> records system.</p>
                <p>Please visit the registration office to register your vital information.</p>
            </div>
            <%
            }
            %>
        </div>
        
        <%
                conn.close();
            } catch (Exception e) {
                out.println("<div class='error'>Error: " + e.getMessage() + "</div>");
            }
        }
        %>
    </div>
    
    <jsp:include page="footer.jsp" />
</body>
</html>