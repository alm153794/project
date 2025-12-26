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
    <title>Add Immigration Record - East Gojjam VIMS</title>
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
            <h2> Add New Immigration Record</h2>
            
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
                    Part filePart = request.getPart("person_photo");
                    if (filePart != null && filePart.getSize() > 0) {
                        String fileName = filePart.getSubmittedFileName();
                        if (fileName != null && !fileName.isEmpty()) {
                            String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                            String newFileName = recordId + fileExtension;
                            
                            String uploadPath = application.getRealPath("/uploads/immigration/");
                            File uploadDir = new File(uploadPath);
                            if (!uploadDir.exists()) uploadDir.mkdirs();
                            
                            String filePath = uploadPath + File.separator + newFileName;
                            filePart.write(filePath);
                            photoPath = "uploads/immigration/" + newFileName;
                        }
                    }
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "INSERT INTO immigration_records (record_id, person_first_name, person_middle_name, person_last_name, gender, date_of_birth, nationality, passport_number, immigration_type, from_country, to_country, from_location, to_location, wereda, kebele, immigration_date, purpose, duration_days, birth_record_id, photo_path, registration_date, registered_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    stmt.setString(1, recordId.trim());
                    stmt.setString(2, getFormValue.apply("person_first_name"));
                    stmt.setString(3, getFormValue.apply("person_middle_name"));
                    stmt.setString(4, getFormValue.apply("person_last_name"));
                    stmt.setString(5, getFormValue.apply("gender"));
                    stmt.setString(6, getFormValue.apply("date_of_birth"));
                    stmt.setString(7, getFormValue.apply("nationality"));
                    stmt.setString(8, getFormValue.apply("passport_number"));
                    stmt.setString(9, getFormValue.apply("immigration_type"));
                    stmt.setString(10, getFormValue.apply("from_country"));
                    stmt.setString(11, getFormValue.apply("to_country"));
                    stmt.setString(12, getFormValue.apply("from_location"));
                    stmt.setString(13, getFormValue.apply("to_location"));
                    stmt.setString(14, getFormValue.apply("wereda"));
                    stmt.setString(15, getFormValue.apply("kebele"));
                    stmt.setString(16, getFormValue.apply("immigration_date"));
                    stmt.setString(17, getFormValue.apply("purpose"));
                    String durationStr = getFormValue.apply("duration_days");
                    stmt.setInt(18, (durationStr != null && !durationStr.isEmpty()) ? Integer.parseInt(durationStr) : 0);
                    String birthRecordId = getFormValue.apply("birth_record_id");
                    stmt.setString(19, (birthRecordId != null && !birthRecordId.trim().isEmpty()) ? birthRecordId.trim() : null);
                    stmt.setString(20, photoPath);
                    stmt.setString(21, getFormValue.apply("registration_date"));
                    stmt.setInt(22, (Integer) session.getAttribute("userId"));
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Immigration record added successfully!" + (photoPath != null ? " Photo uploaded." : "") + "</div>");
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
                        <label for="record_id">Immigration Record ID:</label>
                        <input type="text" id="record_id" name="record_id" required placeholder="IMM2024001234567">
                    </div>
                    <div class="form-group">
                        <label for="birth_record_id">Birth Record ID (if available):</label>
                        <input type="text" id="birth_record_id" name="birth_record_id" placeholder="ETH1985001234567" onblur="fetchBirthRecordForImmigration()">
                        <small style="color: #666; font-size: 0.9em;">Link to person's birth record if available</small>
                    </div>
                </div>
                
                <h3>Personal Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="person_first_name">First Name:</label>
                        <input type="text" id="person_first_name" name="person_first_name" required>
                    </div>
                    <div class="form-group">
                        <label for="person_middle_name">Middle Name:</label>
                        <input type="text" id="person_middle_name" name="person_middle_name">
                    </div>
                    <div class="form-group">
                        <label for="person_last_name">Last Name:</label>
                        <input type="text" id="person_last_name" name="person_last_name" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="gender">Gender:</label>
                        <select id="gender" name="gender" required>
                            <option value="">Select Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="date_of_birth">Date of Birth:</label>
                        <input type="date" id="date_of_birth" name="date_of_birth" required>
                    </div>
                    <input type="hidden" id="person_birth_date" name="person_birth_date">
                    <div class="form-group">
                        <label for="nationality">Nationality:</label>
                        <input type="text" id="nationality" name="nationality" required>
                    </div>
                    <div class="form-group">
                        <label for="person_photo">Person Photo (Optional):</label>
                        <input type="file" id="person_photo" name="person_photo" accept="image/jpeg,image/jpg,image/png,image/gif" onchange="previewPhoto(this)">
                        <small style="color: #666; font-size: 0.8rem;">Max size: 2MB. Formats: JPG, PNG, GIF</small>
                        <div id="photo-preview" style="margin-top: 10px; display: none;">
                            <img id="preview-img" style="width: 80px; height: 100px; object-fit: cover; border: 1px solid #ccc;">
                        </div>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="passport_number">Passport Number:</label>
                        <input type="text" id="passport_number" name="passport_number">
                    </div>
                    <div class="form-group">
                        <label for="immigration_type">Immigration Type:</label>
                        <select id="immigration_type" name="immigration_type" required>
                            <option value="">Select Type</option>
                            <option value="Immigration">Immigration</option>
                            <option value="Emigration">Emigration</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="immigration_date">Immigration Date:</label>
                        <input type="date" id="immigration_date" name="immigration_date" required onchange="calculateImmigrationAge()">
                    </div>
                </div>
                
                <h3>Location Details</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="from_country">From Country:</label>
                        <input type="text" id="from_country" name="from_country">
                    </div>
                    <div class="form-group">
                        <label for="to_country">To Country:</label>
                        <input type="text" id="to_country" name="to_country">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="from_location">From Location:</label>
                        <input type="text" id="from_location" name="from_location">
                    </div>
                    <div class="form-group">
                        <label for="to_location">To Location:</label>
                        <input type="text" id="to_location" name="to_location">
                    </div>
                    <div class="form-group">
                        <label for="duration_days">Duration (Days):</label>
                        <input type="number" id="duration_days" name="duration_days">
                    </div>
                </div>
                
                <div class="form-row">
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
                        <label for="purpose">Purpose:</label>
                        <textarea id="purpose" name="purpose" style="width: 100%; padding: 1rem; border: 2px solid #e0e6ed; border-radius: 10px; font-size: 1rem; resize: vertical; min-height: 100px;"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="registration_date">Registration Date:</label>
                        <input type="date" id="registration_date" name="registration_date" required>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Immigration Record</button>
                    <a href="view-immigration.jsp" class="btn btn-secondary">View Records</a>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
    
    <script>
    function fetchBirthRecordForImmigration() {
        const birthRecordId = document.getElementById('birth_record_id').value.trim();
        if (birthRecordId) {
            fetch('fetch-birth-record.jsp?record_id=' + encodeURIComponent(birthRecordId))
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        document.getElementById('person_first_name').value = data.child_first_name || '';
                        document.getElementById('person_middle_name').value = data.child_middle_name || '';
                        document.getElementById('person_last_name').value = data.child_last_name || '';
                        document.getElementById('gender').value = data.gender || '';
                        document.getElementById('date_of_birth').value = data.date_of_birth || '';
                        document.getElementById('person_birth_date').value = data.date_of_birth || '';
                        document.getElementById('wereda').value = data.wereda || '';
                        document.getElementById('kebele').value = data.kebele || '';
                        calculateImmigrationAge();
                    }
                })
                .catch(error => console.error('Error:', error));
        }
    }
    
    function calculateImmigrationAge() {
        const birthDate = document.getElementById('person_birth_date').value;
        const immigrationDate = document.getElementById('immigration_date').value;
        
        if (birthDate && immigrationDate) {
            const birth = new Date(birthDate);
            const immigration = new Date(immigrationDate);
            
            if (immigration >= birth) {
                let age = immigration.getFullYear() - birth.getFullYear();
                const monthDiff = immigration.getMonth() - birth.getMonth();
                
                if (monthDiff < 0 || (monthDiff === 0 && immigration.getDate() < birth.getDate())) {
                    age--;
                }
                

            } else {

                alert('Immigration date cannot be before birth date');
            }
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