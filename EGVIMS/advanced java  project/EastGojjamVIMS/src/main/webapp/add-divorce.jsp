<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, javax.servlet.http.*, javax.servlet.*" %>
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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Divorce Record - East Gojjam VIMS</title>
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
        .form-actions { display: flex; gap: 1rem; justify-content: center; margin-top: 2rem; }
        .btn { padding: 1rem 2rem; border: none; border-radius: 25px; font-size: 1rem; font-weight: bold; text-decoration: none; cursor: pointer; transition: all 0.3s ease; display: inline-block; text-align: center; }
        .btn-primary { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3); }
        .btn-primary:hover { background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); transform: translateY(-3px); box-shadow: 0 15px 35px rgba(79, 172, 254, 0.4); }
        .btn-secondary { background: linear-gradient(135deg, #6c757d, #495057); color: white; box-shadow: 0 5px 15px rgba(108, 117, 125, 0.3); }
        .btn-secondary:hover { background: linear-gradient(135deg, #495057, #343a40); transform: translateY(-3px); }
        .success-message { background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3); }
        .error-message { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3); }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="form-container">
            <h2> Add New Divorce Record</h2>
            
            <% if (request.getMethod().equals("POST")) {
                try {
                    // Helper method to get form field value
                    java.util.function.Function<String, String> getFormValue = (fieldName) -> {
                        try {
                            Part part = request.getPart(fieldName);
                            if (part != null) {
                                java.io.InputStream is = part.getInputStream();
                                java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
                                return s.hasNext() ? s.next() : "";
                            }
                        } catch (Exception e) {}
                        return "";
                    };
                    
                    String recordId = getFormValue.apply("record_id");
                    if (recordId == null || recordId.trim().isEmpty()) {
                        throw new Exception("Record ID is required");
                    }
                    
                    // Handle file upload
                    String photoPath = null;
                    Part filePart = request.getPart("couple_photo");
                    if (filePart != null && filePart.getSize() > 0) {
                        String fileName = filePart.getSubmittedFileName();
                        if (fileName != null && !fileName.isEmpty()) {
                            String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                            String newFileName = recordId + fileExtension;
                            
                            String uploadPath = application.getRealPath("/uploads/divorce/");
                            File uploadDir = new File(uploadPath);
                            if (!uploadDir.exists()) uploadDir.mkdirs();
                            
                            String filePath = uploadPath + File.separator + newFileName;
                            filePart.write(filePath);
                            photoPath = "uploads/divorce/" + newFileName;
                        }
                    }
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "INSERT INTO divorce_records (record_id, husband_first_name, husband_middle_name, husband_last_name, husband_age, wife_first_name, wife_middle_name, wife_last_name, wife_age, marriage_record_id, marriage_date, divorce_date, divorce_place, wereda, kebele, photo_path, divorce_reason, registration_date, registered_by, husband_record_id, wife_record_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL)";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    stmt.setString(1, recordId.trim());
                    stmt.setString(2, getFormValue.apply("husband_first_name"));
                    stmt.setString(3, getFormValue.apply("husband_middle_name"));
                    stmt.setString(4, getFormValue.apply("husband_last_name"));
                    String husbandAgeStr = getFormValue.apply("husband_age");
                    stmt.setInt(5, (husbandAgeStr != null && !husbandAgeStr.isEmpty()) ? Integer.parseInt(husbandAgeStr) : 0);
                    stmt.setString(6, getFormValue.apply("wife_first_name"));
                    stmt.setString(7, getFormValue.apply("wife_middle_name"));
                    stmt.setString(8, getFormValue.apply("wife_last_name"));
                    String wifeAgeStr = getFormValue.apply("wife_age");
                    stmt.setInt(9, (wifeAgeStr != null && !wifeAgeStr.isEmpty()) ? Integer.parseInt(wifeAgeStr) : 0);
                    String marriageRecordId = getFormValue.apply("marriage_record_id");
                    stmt.setString(10, (marriageRecordId != null && !marriageRecordId.trim().isEmpty()) ? marriageRecordId.trim() : null);
                    stmt.setString(11, getFormValue.apply("marriage_date"));
                    stmt.setString(12, getFormValue.apply("divorce_date"));
                    stmt.setString(13, getFormValue.apply("divorce_place"));
                    stmt.setString(14, getFormValue.apply("wereda"));
                    stmt.setString(15, getFormValue.apply("kebele"));
                    stmt.setString(16, photoPath);
                    stmt.setString(17, getFormValue.apply("divorce_reason"));
                    stmt.setString(18, getFormValue.apply("registration_date"));
                    stmt.setInt(19, (Integer) session.getAttribute("userId"));
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Divorce record added successfully!" + (photoPath != null ? " Photo uploaded." : "") + "</div>");
                    }
                    
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                }
            } %>
            
            <form method="post" class="record-form" enctype="multipart/form-data">
                <div class="form-row">
                    <div class="form-group">
                        <label for="record_id">Divorce Certificate ID:</label>
                        <input type="text" id="record_id" name="record_id" required placeholder="DIV2024001234567">
                    </div>
                    <div class="form-group">
                        <label for="marriage_record_id">Marriage Record ID (if available):</label>
                        <input type="text" id="marriage_record_id" name="marriage_record_id" placeholder="MAR2023001234567" onblur="fetchMarriageRecord()">
                        <small style="color: #666; font-size: 0.9em;">Link to existing marriage record if marriage was registered in this system</small>
                    </div>
                </div>
                
                <h3>Husband Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="husband_first_name">Husband First Name:</label>
                        <input type="text" id="husband_first_name" name="husband_first_name" required>
                    </div>
                    <div class="form-group">
                        <label for="husband_middle_name">Husband Middle Name:</label>
                        <input type="text" id="husband_middle_name" name="husband_middle_name">
                    </div>
                    <div class="form-group">
                        <label for="husband_last_name">Husband Last Name:</label>
                        <input type="text" id="husband_last_name" name="husband_last_name" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="husband_age">Husband Age at Divorce:</label>
                        <input type="number" id="husband_age" name="husband_age" required min="18" readonly>
                    </div>
                    <input type="hidden" id="marriage_date_hidden" name="marriage_date_hidden">
                    <div class="form-group">
                        <label for="couple_photo">Couple Photo (Optional):</label>
                        <input type="file" id="couple_photo" name="couple_photo" accept="image/jpeg,image/jpg,image/png,image/gif" onchange="previewPhoto(this)">
                        <small style="color: #666; font-size: 0.8rem;">Max size: 2MB. Formats: JPG, PNG, GIF</small>
                        <div id="photo-preview" style="margin-top: 10px; display: none;">
                            <img id="preview-img" style="width: 120px; height: 80px; object-fit: cover; border: 1px solid #ccc;">
                        </div>
                    </div>
                </div>
                
                <h3>Wife Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="wife_first_name">Wife First Name:</label>
                        <input type="text" id="wife_first_name" name="wife_first_name" required>
                    </div>
                    <div class="form-group">
                        <label for="wife_middle_name">Wife Middle Name:</label>
                        <input type="text" id="wife_middle_name" name="wife_middle_name">
                    </div>
                    <div class="form-group">
                        <label for="wife_last_name">Wife Last Name:</label>
                        <input type="text" id="wife_last_name" name="wife_last_name" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="wife_age">Wife Age at Divorce:</label>
                        <input type="number" id="wife_age" name="wife_age" required min="18" readonly>
                    </div>

                </div>
                
                <h3>Divorce Details</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="marriage_date">Marriage Date:</label>
                        <input type="date" id="marriage_date" name="marriage_date" required readonly>
                    </div>
                    <div class="form-group">
                        <label for="divorce_date">Divorce Date:</label>
                        <input type="date" id="divorce_date" name="divorce_date" required onchange="calculateDivorceAges()">
                    </div>
                    <div class="form-group">
                        <label for="divorce_place">Divorce Place:</label>
                        <input type="text" id="divorce_place" name="divorce_place" required>
                    </div>
                    <div class="form-group">
                        <label for="wereda">Wereda:</label>
                        <input type="text" id="wereda" name="wereda" required>
                    </div>
                    <div class="form-group">
                        <label for="kebele">Kebele:</label>
                        <input type="text" id="kebele" name="kebele" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="registration_date">Registration Date:</label>
                        <input type="date" id="registration_date" name="registration_date" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="divorce_reason">Divorce Reason:</label>
                        <textarea id="divorce_reason" name="divorce_reason" style="width: 100%; padding: 1rem; border: 2px solid #e0e6ed; border-radius: 10px; font-size: 1rem; resize: vertical; min-height: 100px;"></textarea>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Divorce Record</button>
                    <a href="view-divorce.jsp" class="btn btn-secondary">View Records</a>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
    
    <script>
    function fetchMarriageRecord() {
        const marriageRecordId = document.getElementById('marriage_record_id').value.trim();
        if (marriageRecordId) {
            fetch('fetch-marriage-record.jsp?record_id=' + encodeURIComponent(marriageRecordId))
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        document.getElementById('husband_first_name').value = data.groom_first_name || '';
                        document.getElementById('husband_middle_name').value = data.groom_middle_name || '';
                        document.getElementById('husband_last_name').value = data.groom_last_name || '';
                        document.getElementById('wife_first_name').value = data.bride_first_name || '';
                        document.getElementById('wife_middle_name').value = data.bride_middle_name || '';
                        document.getElementById('wife_last_name').value = data.bride_last_name || '';
                        document.getElementById('marriage_date').value = data.marriage_date || '';
                        document.getElementById('marriage_date_hidden').value = data.marriage_date || '';
                        document.getElementById('divorce_place').value = data.marriage_place || '';
                        document.getElementById('wereda').value = data.wereda || '';
                        document.getElementById('kebele').value = data.kebele || '';
                        calculateDivorceAges();
                    }
                })
                .catch(error => console.error('Error:', error));
        }
    }
    
    function calculateDivorceAges() {
        const marriageDate = document.getElementById('marriage_date').value;
        const divorceDate = document.getElementById('divorce_date').value;
        const marriageRecordId = document.getElementById('marriage_record_id').value.trim();
        
        if (marriageDate && divorceDate && marriageRecordId) {
            const marriage = new Date(marriageDate);
            const divorce = new Date(divorceDate);
            
            if (divorce < marriage) {
                alert('Divorce date cannot be before marriage date');
                document.getElementById('divorce_date').value = '';
                return;
            }
            
            // Fetch marriage ages and calculate current ages at divorce
            fetch('fetch-marriage-record.jsp?record_id=' + encodeURIComponent(marriageRecordId))
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const marriageYear = marriage.getFullYear();
                        const divorceYear = divorce.getFullYear();
                        const yearsDiff = divorceYear - marriageYear;
                        
                        const husbandAgeAtMarriage = parseInt(data.groom_age);
                        const wifeAgeAtMarriage = parseInt(data.bride_age);
                        
                        document.getElementById('husband_age').value = husbandAgeAtMarriage + yearsDiff;
                        document.getElementById('wife_age').value = wifeAgeAtMarriage + yearsDiff;
                    }
                })
                .catch(error => console.error('Error:', error));
        }
    }
    
    function previewPhoto(input) {
        const preview = document.getElementById('photo-preview');
        const previewImg = document.getElementById('preview-img');
        
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                previewImg.src = e.target.result;
                preview.style.display = 'block';
            };
            reader.readAsDataURL(input.files[0]);
        } else {
            preview.style.display = 'none';
        }
    }
    </script>
</body>
</html>