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
    <title>Add Marriage Record - East Gojjam VIMS</title>
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
            <h2> Add New Marriage Record</h2>
            
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
                            
                            String uploadPath = application.getRealPath("/uploads/marriage/");
                            File uploadDir = new File(uploadPath);
                            if (!uploadDir.exists()) uploadDir.mkdirs();
                            
                            String filePath = uploadPath + File.separator + newFileName;
                            filePart.write(filePath);
                            photoPath = "uploads/marriage/" + newFileName;
                        }
                    }
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "INSERT INTO marriage_records (record_id, groom_first_name, groom_middle_name, groom_last_name, groom_age, groom_record_id, bride_first_name, bride_middle_name, bride_last_name, bride_age, bride_record_id, marriage_date, marriage_place, wereda, kebele, photo_path, registration_date, registered_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    stmt.setString(1, recordId.trim());
                    stmt.setString(2, getFormValue.apply("groom_first_name"));
                    stmt.setString(3, getFormValue.apply("groom_middle_name"));
                    stmt.setString(4, getFormValue.apply("groom_last_name"));
                    String groomAgeStr = getFormValue.apply("groom_age");
                    stmt.setInt(5, (groomAgeStr != null && !groomAgeStr.isEmpty()) ? Integer.parseInt(groomAgeStr) : 0);
                    String groomBirthId = getFormValue.apply("groom_record_id");
                    stmt.setString(6, (groomBirthId != null && !groomBirthId.trim().isEmpty()) ? groomBirthId.trim() : null);
                    stmt.setString(7, getFormValue.apply("bride_first_name"));
                    stmt.setString(8, getFormValue.apply("bride_middle_name"));
                    stmt.setString(9, getFormValue.apply("bride_last_name"));
                    String brideAgeStr = getFormValue.apply("bride_age");
                    stmt.setInt(10, (brideAgeStr != null && !brideAgeStr.isEmpty()) ? Integer.parseInt(brideAgeStr) : 0);
                    String brideBirthId = getFormValue.apply("bride_record_id");
                    stmt.setString(11, (brideBirthId != null && !brideBirthId.trim().isEmpty()) ? brideBirthId.trim() : null);
                    stmt.setString(12, getFormValue.apply("marriage_date"));
                    stmt.setString(13, getFormValue.apply("marriage_place"));
                    stmt.setString(14, getFormValue.apply("wereda"));
                    stmt.setString(15, getFormValue.apply("kebele"));
                    stmt.setString(16, photoPath);
                    stmt.setString(17, getFormValue.apply("registration_date"));
                    stmt.setInt(18, (Integer) session.getAttribute("userId"));
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Marriage record added successfully!" + (photoPath != null ? " Photo uploaded." : "") + "</div>");
                    }
                    
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                }
            } %>
            
            <form method="post" class="record-form" enctype="multipart/form-data" onsubmit="return validateMarriage()">
                <div class="form-row">
                    <div class="form-group">
                        <label for="record_id">Marriage Certificate ID:</label>
                        <input type="text" id="record_id" name="record_id" required placeholder="MAR2023001234567">
                    </div>
                    <div class="form-group">
                        <label for="groom_record_id">Groom Birth Record ID (if available):</label>
                        <input type="text" id="groom_record_id" name="groom_record_id" placeholder="ETH1995001234567" onblur="fetchGroomRecord()">
                        <small style="color: #666; font-size: 0.9em;">Link to groom's birth record if available</small>
                    </div>
                    <div class="form-group">
                        <label for="bride_record_id">Bride Birth Record ID (if available):</label>
                        <input type="text" id="bride_record_id" name="bride_record_id" placeholder="ETH1998001234567" onblur="fetchBrideRecord()">
                        <small style="color: #666; font-size: 0.9em;">Link to bride's birth record if available</small>
                    </div>
                </div>
                
                <h3>Groom Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="groom_first_name">Groom First Name:</label>
                        <input type="text" id="groom_first_name" name="groom_first_name" required>
                    </div>
                    <div class="form-group">
                        <label for="groom_middle_name">Groom Middle Name:</label>
                        <input type="text" id="groom_middle_name" name="groom_middle_name">
                    </div>
                    <div class="form-group">
                        <label for="groom_last_name">Groom Last Name:</label>
                        <input type="text" id="groom_last_name" name="groom_last_name" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="groom_age">Groom Age:</label>
                        <input type="number" id="groom_age" name="groom_age" required min="18" readonly>
                    </div>
                </div>
                <input type="hidden" id="groom_birth_date" name="groom_birth_date">
                
                <h3>Bride Information</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="bride_first_name">Bride First Name:</label>
                        <input type="text" id="bride_first_name" name="bride_first_name" required>
                    </div>
                    <div class="form-group">
                        <label for="bride_middle_name">Bride Middle Name:</label>
                        <input type="text" id="bride_middle_name" name="bride_middle_name">
                    </div>
                    <div class="form-group">
                        <label for="bride_last_name">Bride Last Name:</label>
                        <input type="text" id="bride_last_name" name="bride_last_name" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="bride_age">Bride Age:</label>
                        <input type="number" id="bride_age" name="bride_age" required min="18" readonly>
                    </div>
                </div>
                <input type="hidden" id="bride_birth_date" name="bride_birth_date">
                
                <h3>Marriage Details</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="marriage_date">Marriage Date:</label>
                        <input type="date" id="marriage_date" name="marriage_date" required onchange="calculateAges()">
                    </div>
                    <div class="form-group">
                        <label for="marriage_place">Marriage Place:</label>
                        <input type="text" id="marriage_place" name="marriage_place" required>
                    </div>
                    <div class="form-group">
                        <label for="wereda">Wereda:</label>
                        <input type="text" id="wereda" name="wereda" required>
                    </div>
                    <div class="form-group">
                        <label for="kebele">Kebele:</label>
                        <input type="text" id="kebele" name="kebele" required>
                    </div>
                    <div class="form-group">
                        <label for="couple_photo">Couple Photo (Optional):</label>
                        <input type="file" id="couple_photo" name="couple_photo" accept="image/jpeg,image/jpg,image/png,image/gif" onchange="previewPhoto(this)">
                        <small style="color: #666; font-size: 0.8rem;">Max size: 2MB. Formats: JPG, PNG, GIF</small>
                        <div id="photo-preview" style="margin-top: 10px; display: none;">
                            <img id="preview-img" style="width: 120px; height: 80px; object-fit: cover; border: 1px solid #ccc;">
                        </div>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="registration_date">Registration Date:</label>
                        <input type="date" id="registration_date" name="registration_date" required>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Marriage Record</button>
                    <a href="view-marriage.jsp" class="btn btn-secondary">View Records</a>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
    
    <script>
    function fetchGroomRecord() {
        const birthRecordId = document.getElementById('groom_record_id').value.trim();
        if (birthRecordId) {
            fetch('fetch-birth-record.jsp?record_id=' + encodeURIComponent(birthRecordId))
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        document.getElementById('groom_first_name').value = data.child_first_name || '';
                        document.getElementById('groom_middle_name').value = data.child_middle_name || '';
                        document.getElementById('groom_last_name').value = data.child_last_name || '';
                        document.getElementById('groom_birth_date').value = data.date_of_birth || '';
                        calculateAges();
                    }
                })
                .catch(error => console.error('Error:', error));
        }
    }
    
    function fetchBrideRecord() {
        const birthRecordId = document.getElementById('bride_record_id').value.trim();
        if (birthRecordId) {
            fetch('fetch-birth-record.jsp?record_id=' + encodeURIComponent(birthRecordId))
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        document.getElementById('bride_first_name').value = data.child_first_name || '';
                        document.getElementById('bride_middle_name').value = data.child_middle_name || '';
                        document.getElementById('bride_last_name').value = data.child_last_name || '';
                        document.getElementById('bride_birth_date').value = data.date_of_birth || '';
                        calculateAges();
                    }
                })
                .catch(error => console.error('Error:', error));
        }
    }
    
    function calculateAges() {
        const marriageDate = document.getElementById('marriage_date').value;
        const groomBirthDate = document.getElementById('groom_birth_date').value;
        const brideBirthDate = document.getElementById('bride_birth_date').value;
        
        let groomAge = 0;
        let brideAge = 0;
        let validAges = true;
        
        if (marriageDate && groomBirthDate) {
            groomAge = calculateAge(groomBirthDate, marriageDate);
            document.getElementById('groom_age').value = groomAge;
        }
        
        if (marriageDate && brideBirthDate) {
            brideAge = calculateAge(brideBirthDate, marriageDate);
            document.getElementById('bride_age').value = brideAge;
        }
        
        // Check both ages together
        if (marriageDate && (groomBirthDate || brideBirthDate)) {
            if (groomBirthDate && groomAge < 18) {
                alert('Groom must be at least 18 years old to marry (Current age: ' + groomAge + ')');
                validAges = false;
            }
            if (brideBirthDate && brideAge < 18) {
                alert('Bride must be at least 18 years old to marry (Current age: ' + brideAge + ')');
                validAges = false;
            }
            
            if (!validAges) {
                document.getElementById('marriage_date').value = '';
                document.getElementById('groom_age').value = '';
                document.getElementById('bride_age').value = '';
                return false;
            }
        }
        return true;
    }
    
    function calculateAge(birthDate, eventDate) {
        const birth = new Date(birthDate);
        const event = new Date(eventDate);
        
        if (event >= birth) {
            let age = event.getFullYear() - birth.getFullYear();
            const monthDiff = event.getMonth() - birth.getMonth();
            
            if (monthDiff < 0 || (monthDiff === 0 && event.getDate() < birth.getDate())) {
                age--;
            }
            
            return age;
        }
        return 0;
    }
    
    function validateMarriage() {
        const groomAge = parseInt(document.getElementById('groom_age').value) || 0;
        const brideAge = parseInt(document.getElementById('bride_age').value) || 0;
        
        if (groomAge > 0 && groomAge < 18) {
            alert('Cannot register marriage: Groom is only ' + groomAge + ' years old. Minimum age is 18.');
            return false;
        }
        
        if (brideAge > 0 && brideAge < 18) {
            alert('Cannot register marriage: Bride is only ' + brideAge + ' years old. Minimum age is 18.');
            return false;
        }
        
        return true;
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