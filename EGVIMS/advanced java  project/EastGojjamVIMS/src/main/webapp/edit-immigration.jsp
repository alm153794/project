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
    if (recordId == null) {
        response.sendRedirect("view-immigration.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Immigration Record - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            min-height: 100vh; 
            font-family: 'Inter', 'Segoe UI', sans-serif; 
            overflow-x: hidden;
        }
        .main-content { 
            background: rgba(255,255,255,0.98); 
            margin: 1.5rem; 
            border-radius: 25px; 
            padding: 0; 
            backdrop-filter: blur(20px); 
            box-shadow: 0 25px 50px rgba(0,0,0,0.15); 
            border: 1px solid rgba(255,255,255,0.3);
        }
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2.5rem 2rem;
            border-radius: 25px 25px 0 0;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .page-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="20" cy="20" r="2" fill="white" opacity="0.1"/><circle cx="80" cy="80" r="2" fill="white" opacity="0.1"/><circle cx="40" cy="60" r="1" fill="white" opacity="0.1"/></svg>');
        }
        .page-header h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
            position: relative;
            z-index: 1;
        }
        .page-header p {
            font-size: 1.2rem;
            opacity: 0.9;
            position: relative;
            z-index: 1;
        }
        .form-container { 
            max-width: 1400px; 
            margin: 0 auto; 
            padding: 3rem 2rem;
        }
        .record-id-banner {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 25px;
            text-align: center;
            font-size: 1.4rem;
            font-weight: 800;
            margin-bottom: 3rem;
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.3);
            border: 3px solid rgba(255,255,255,0.2);
            position: relative;
            overflow: hidden;
        }
        .record-id-banner::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: shimmer 3s ease-in-out infinite;
        }
        @keyframes shimmer {
            0%, 100% { transform: rotate(0deg); }
            50% { transform: rotate(180deg); }
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 3rem;
            margin-bottom: 3rem;
        }
        .form-section {
            background: linear-gradient(145deg, #ffffff, #f8fafc);
            padding: 3rem;
            border-radius: 25px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.08), 0 6px 20px rgba(0,0,0,0.04);
            border: 2px solid rgba(255,255,255,0.8);
            position: relative;
            overflow: hidden;
            backdrop-filter: blur(10px);
        }
        .form-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2);
        }
        .section-title {
            font-size: 1.6rem;
            font-weight: 800;
            color: #2c3e50;
            margin-bottom: 2.5rem;
            display: flex;
            align-items: center;
            gap: 0.8rem;
            padding-bottom: 1rem;
            border-bottom: 3px solid #f1f5f9;
            position: relative;
        }
        .section-title::after {
            content: '';
            position: absolute;
            bottom: -3px;
            left: 0;
            width: 60px;
            height: 3px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 2px;
        }
        .form-row { 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 1.5rem; 
            margin-bottom: 1.5rem; 
        }
        .form-group { 
            position: relative; 
        }
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        .form-group label { 
            display: block; 
            color: #2c3e50; 
            font-weight: 700; 
            margin-bottom: 0.8rem; 
            font-size: 0.95rem;
            letter-spacing: 0.3px;
            position: relative;
            padding-left: 0.5rem;
        }
        .form-group label::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 3px;
            height: 60%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 2px;
        }
        .form-group input, .form-group select, .form-group textarea { 
            width: 100%; 
            padding: 1.1rem 1.3rem; 
            border: 2px solid #e2e8f0; 
            border-radius: 15px; 
            font-size: 1rem; 
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
            background: linear-gradient(145deg, #ffffff, #f8fafc);
            font-family: inherit;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            position: relative;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { 
            outline: none; 
            border-color: #667eea; 
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.12), 0 8px 25px rgba(102, 126, 234, 0.15); 
            transform: translateY(-2px);
            background: #ffffff;
        }
        .form-group input:hover, .form-group select:hover, .form-group textarea:hover { 
            border-color: #cbd5e0; 
        }
        .form-group input[readonly] { 
            background: linear-gradient(135deg, #f7fafc, #edf2f7); 
            color: #718096; 
            cursor: not-allowed;
        }
        .form-group textarea {
            min-height: 120px;
            resize: vertical;
        }
        .form-actions { 
            display: flex; 
            gap: 1.5rem; 
            justify-content: center; 
            margin-top: 3rem; 
            padding-top: 2rem;
            border-top: 2px solid #f1f5f9;
        }
        .btn { 
            padding: 1.2rem 2.5rem; 
            border: none; 
            border-radius: 50px; 
            font-size: 1rem; 
            font-weight: 700; 
            text-decoration: none; 
            cursor: pointer; 
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); 
            display: inline-flex;
            align-items: center;
            gap: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            min-width: 180px;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.6s;
        }
        .btn:hover::before {
            left: 100%;
        }
        .btn-primary { 
            background: linear-gradient(135deg, #667eea, #764ba2); 
            color: white; 
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            border: 2px solid rgba(255,255,255,0.1);
        }
        .btn-primary:hover { 
            transform: translateY(-3px) scale(1.02); 
            box-shadow: 0 15px 45px rgba(102, 126, 234, 0.5);
            background: linear-gradient(135deg, #5a67d8, #6b46c1);
        }
        .btn-secondary { 
            background: linear-gradient(135deg, #718096, #4a5568); 
            color: white; 
            box-shadow: 0 10px 30px rgba(113, 128, 150, 0.4);
            border: 2px solid rgba(255,255,255,0.1);
        }
        .btn-secondary:hover { 
            transform: translateY(-3px) scale(1.02); 
            box-shadow: 0 15px 45px rgba(113, 128, 150, 0.5);
            background: linear-gradient(135deg, #4a5568, #2d3748);
        }
        .btn-danger { 
            background: linear-gradient(135deg, #e53e3e, #c53030); 
            color: white; 
            box-shadow: 0 10px 30px rgba(229, 62, 62, 0.4);
            border: 2px solid rgba(255,255,255,0.1);
        }
        .btn-danger:hover { 
            transform: translateY(-3px) scale(1.02); 
            box-shadow: 0 15px 45px rgba(229, 62, 62, 0.5);
            background: linear-gradient(135deg, #c53030, #9c2626);
        }
        .success-message, .error-message { 
            padding: 1.5rem; 
            border-radius: 15px; 
            margin: 2rem 0; 
            text-align: center; 
            font-weight: 600;
            font-size: 1.1rem;
        }
        .success-message { 
            background: linear-gradient(135deg, #48bb78, #38a169); 
            color: white; 
            box-shadow: 0 8px 25px rgba(72, 187, 120, 0.3);
        }
        .error-message { 
            background: linear-gradient(135deg, #e53e3e, #c53030); 
            color: white; 
            box-shadow: 0 8px 25px rgba(229, 62, 62, 0.3);
        }
        @media (max-width: 768px) {
            .form-grid { grid-template-columns: 1fr; gap: 2rem; }
            .form-row { grid-template-columns: 1fr; }
            .main-content { margin: 1rem; }
            .page-header h1 { font-size: 2rem; }
            .form-actions { flex-direction: column; align-items: center; }
        }
        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(40px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        @keyframes fadeInScale {
            from { opacity: 0; transform: scale(0.9); }
            to { opacity: 1; transform: scale(1); }
        }
        .form-section { 
            animation: slideInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1); 
        }
        .form-section:nth-child(even) { 
            animation-delay: 0.2s; 
        }
        .record-id-banner {
            animation: fadeInScale 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .form-group {
            animation: slideInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .form-group:nth-child(odd) { animation-delay: 0.1s; }
        .form-group:nth-child(even) { animation-delay: 0.2s; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="page-header">
            <h1> Edit Immigration Record</h1>
            <p>Update immigration/emigration information and travel details</p>
        </div>
        <div class="form-container">
            
            <% if (request.getMethod().equals("POST")) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "UPDATE immigration_records SET person_first_name=?, person_middle_name=?, person_last_name=?, gender=?, date_of_birth=?, nationality=?, passport_number=?, immigration_type=?, from_country=?, to_country=?, from_location=?, to_location=?, wereda=?, kebele=?, immigration_date=?, purpose=?, duration_days=?, registration_date=?, birth_record_id=? WHERE record_id=?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    
                    stmt.setString(1, request.getParameter("person_first_name"));
                    stmt.setString(2, request.getParameter("person_middle_name"));
                    stmt.setString(3, request.getParameter("person_last_name"));
                    stmt.setString(4, request.getParameter("gender"));
                    stmt.setString(5, request.getParameter("date_of_birth"));
                    stmt.setString(6, request.getParameter("nationality"));
                    stmt.setString(7, request.getParameter("passport_number"));
                    stmt.setString(8, request.getParameter("immigration_type"));
                    stmt.setString(9, request.getParameter("from_country"));
                    stmt.setString(10, request.getParameter("to_country"));
                    stmt.setString(11, request.getParameter("from_location"));
                    stmt.setString(12, request.getParameter("to_location"));
                    stmt.setString(13, request.getParameter("wereda"));
                    stmt.setString(14, request.getParameter("kebele"));
                    stmt.setString(15, request.getParameter("immigration_date"));
                    stmt.setString(16, request.getParameter("purpose"));
                    stmt.setInt(17, request.getParameter("duration_days") != null && !request.getParameter("duration_days").isEmpty() ? Integer.parseInt(request.getParameter("duration_days")) : 0);
                    stmt.setString(18, request.getParameter("registration_date"));
                    String birthRecordId = request.getParameter("birth_record_id");
                    stmt.setString(19, (birthRecordId != null && !birthRecordId.trim().isEmpty()) ? birthRecordId.trim() : null);
                    stmt.setString(20, recordId);
                    
                    int result = stmt.executeUpdate();
                    if (result > 0) {
                        out.println("<div class='success-message'>Immigration record updated successfully!</div>");
                    }
                    
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                }
            } %>
            
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "SELECT * FROM immigration_records WHERE record_id = ?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, recordId);
                    ResultSet rs = stmt.executeQuery();
                    
                    if (rs.next()) {
            %>
            
            <form method="post" class="record-form">
                <div class="record-id-banner">
                     Record ID: <%= rs.getString("record_id") %>
                </div>
                
                <div class="form-grid">
                    <div class="form-section">
                        <div class="section-title"> Personal Information</div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="birth_record_id"> Birth Record ID:</label>
                                <input type="text" id="birth_record_id" name="birth_record_id" value="<%= rs.getString("birth_record_id") != null ? rs.getString("birth_record_id") : "" %>" placeholder="e.g., ETH2020001234567">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="person_first_name"> First Name:</label>
                                <input type="text" id="person_first_name" name="person_first_name" value="<%= rs.getString("person_first_name") %>" required placeholder="Enter first name">
                            </div>
                            <div class="form-group">
                                <label for="person_middle_name"> Middle Name:</label>
                                <input type="text" id="person_middle_name" name="person_middle_name" value="<%= rs.getString("person_middle_name") != null ? rs.getString("person_middle_name") : "" %>" placeholder="Enter middle name">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="person_last_name"> Last Name:</label>
                                <input type="text" id="person_last_name" name="person_last_name" value="<%= rs.getString("person_last_name") %>" required placeholder="Enter last name">
                            </div>
                            <div class="form-group">
                                <label for="gender"> Gender:</label>
                                <select id="gender" name="gender" required>
                                    <option value="">Select Gender</option>
                                    <option value="Male" <%= "Male".equals(rs.getString("gender")) ? "selected" : "" %>> Male</option>
                                    <option value="Female" <%= "Female".equals(rs.getString("gender")) ? "selected" : "" %>> Female</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="date_of_birth"> Date of Birth:</label>
                                <input type="date" id="date_of_birth" name="date_of_birth" value="<%= rs.getDate("date_of_birth") %>" required>
                            </div>
                            <div class="form-group">
                                <label for="nationality"> Nationality:</label>
                                <input type="text" id="nationality" name="nationality" value="<%= rs.getString("nationality") %>" required placeholder="e.g., Ethiopian">
                            </div>
                        </div>
                
                        <div class="form-row">
                            <div class="form-group">
                                <label for="passport_number"> Passport Number:</label>
                                <input type="text" id="passport_number" name="passport_number" value="<%= rs.getString("passport_number") != null ? rs.getString("passport_number") : "" %>" placeholder="Enter passport number">
                            </div>
                            <div class="form-group">
                                <label for="immigration_type"> Immigration Type:</label>
                                <select id="immigration_type" name="immigration_type" required>
                                    <option value="">Select Type</option>
                                    <option value="Immigration" <%= "Immigration".equals(rs.getString("immigration_type")) ? "selected" : "" %>>📥 Immigration</option>
                                    <option value="Emigration" <%= "Emigration".equals(rs.getString("immigration_type")) ? "selected" : "" %>>📤 Emigration</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="immigration_date"> Immigration Date:</label>
                                <input type="date" id="immigration_date" name="immigration_date" value="<%= rs.getDate("immigration_date") %>" required>
                            </div>
                        </div>
                
                    </div>
                    
                    <div class="form-section">
                        <div class="section-title"> Travel & Location Details</div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="from_country"> From Country:</label>
                                <input type="text" id="from_country" name="from_country" value="<%= rs.getString("from_country") != null ? rs.getString("from_country") : "" %>" placeholder="Origin country">
                            </div>
                            <div class="form-group">
                                <label for="to_country"> To Country:</label>
                                <input type="text" id="to_country" name="to_country" value="<%= rs.getString("to_country") != null ? rs.getString("to_country") : "" %>" placeholder="Destination country">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="from_location"> From Location:</label>
                                <input type="text" id="from_location" name="from_location" value="<%= rs.getString("from_location") != null ? rs.getString("from_location") : "" %>" placeholder="Specific origin location">
                            </div>
                            <div class="form-group">
                                <label for="to_location"> To Location:</label>
                                <input type="text" id="to_location" name="to_location" value="<%= rs.getString("to_location") != null ? rs.getString("to_location") : "" %>" placeholder="Specific destination">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="duration_days"> Duration (Days):</label>
                                <input type="number" id="duration_days" name="duration_days" value="<%= rs.getInt("duration_days") %>" placeholder="Number of days" min="0">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="wereda"> Wereda:</label>
                                <input type="text" id="wereda" name="wereda" value="<%= rs.getString("wereda") %>" required placeholder="Administrative district">
                            </div>
                            <div class="form-group">
                                <label for="kebele"> Kebele:</label>
                                <input type="text" id="kebele" name="kebele" value="<%= rs.getString("kebele") %>" required placeholder="Local administrative unit">
                            </div>
                        </div>
                
                        <div class="form-row">
                            <div class="form-group full-width">
                                <label for="purpose"> Purpose of Travel:</label>
                                <textarea id="purpose" name="purpose" placeholder="Describe the purpose of immigration/emigration (e.g., work, study, family reunion, tourism)"><%= rs.getString("purpose") != null ? rs.getString("purpose") : "" %></textarea>
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="registration_date"> Registration Date:</label>
                                <input type="date" id="registration_date" name="registration_date" value="<%= rs.getDate("registration_date") %>" required>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                         Update Record
                    </button>
                    <a href="view-immigration.jsp" class="btn btn-secondary">
                         Back to List
                    </a>
                    <% if ("admin".equals(role)) { %>
                    <a href="delete-immigration.jsp?id=<%= recordId %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this record?')">
                         Delete Record
                    </a>
                    <% } %>
                </div>
            </form>
            
            <%
                    } else {
                        out.println("<div class='error-message'>Immigration record not found!</div>");
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error loading record: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
    
    <%@ include file="footer.jsp" %>
</body>
</html>