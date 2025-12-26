<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Birth Certificate Generator - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%@ include file="header.jsp" %>
    <%@ include file="nav.jsp" %>
    
    <div class="main-content">
        <div class="user-management-header">
            <h2> Birth Certificate Generator</h2>
            <p>Generate official birth certificates with PDF export</p>
        </div>
        
        <div class="form-section">
            <h3 class="section-title">Search & Select Birth Record</h3>
            <form method="get" class="record-form">
                <div class="form-row">
                    <div class="form-group">
                        <label for="search">Search by Name or ID:</label>
                        <input type="text" id="search" name="search" placeholder="Enter child name or record ID" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                    </div>
                    <button type="submit" class="btn btn-primary"> Search</button>
                </div>
                
                <%
                    String searchTerm = request.getParameter("search");
                    if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                %>
                <div class="search-results">
                    <h4>Search Results:</h4>
                    <div class="records-list">
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                                
                                String sql = "SELECT record_id, child_first_name, child_middle_name, child_last_name, date_of_birth FROM birth_records WHERE CONCAT(child_first_name, ' ', IFNULL(child_middle_name, ''), ' ', child_last_name) LIKE ? OR record_id = ? ORDER BY created_date DESC";
                                PreparedStatement stmt = conn.prepareStatement(sql);
                                stmt.setString(1, "%" + searchTerm + "%");
                                stmt.setString(2, searchTerm);
                                
                                ResultSet rs = stmt.executeQuery();
                                boolean hasResults = false;
                                
                                while (rs.next()) {
                                    hasResults = true;
                                    String fullName = rs.getString("child_first_name") + " " + 
                                                    (rs.getString("child_middle_name") != null ? rs.getString("child_middle_name") + " " : "") +
                                                    rs.getString("child_last_name");
                        %>
                        <div class="record-item" onclick="selectRecord('<%= rs.getString("record_id") %>')">
                            <strong>ID: <%= rs.getString("record_id") %></strong> - <%= fullName %><br>
                            <small>Birth Date: <%= rs.getDate("date_of_birth") %></small>
                        </div>
                        <%
                                }
                                
                                if (!hasResults) {
                                    out.println("<div class='no-results'>No records found matching your search.</div>");
                                }
                                
                                rs.close();
                                stmt.close();
                                conn.close();
                            } catch (Exception e) {
                                out.println("<div class='error-message'>Error searching records: " + e.getMessage() + "</div>");
                            }
                        %>
                    </div>
                </div>
                <%
                    }
                %>
            </form>
        </div>
        
        <%
            String selectedId = request.getParameter("id");
            if (selectedId == null) selectedId = request.getParameter("record_id");
            String certParam = request.getParameter("cert");
            String printMode = request.getParameter("print");
            String exportMode = request.getParameter("export");
            
            if (selectedId != null && !selectedId.isEmpty()) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    String sql = "SELECT * FROM birth_records WHERE record_id = ?";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, selectedId);
                    ResultSet rs = stmt.executeQuery();
                    
                    if (rs.next()) {
                        // Use provided certificate number or generate new one
                        String certNumber = certParam != null ? certParam : "BC-" + selectedId + "-" + java.time.Year.now().getValue();
                        String recordName = rs.getString("child_first_name") + " " + 
                                          (rs.getString("child_middle_name") != null ? rs.getString("child_middle_name") + " " : "") +
                                          rs.getString("child_last_name");
                        
                        // Save certificate record only if not using existing cert number
                        if (certParam == null) {
                            try {
                                String insertSql = "INSERT INTO certificates (cert_number, cert_type, record_id, record_name, generated_by) VALUES (?, 'birth', ?, ?, ?) ON DUPLICATE KEY UPDATE generated_date = CURRENT_TIMESTAMP";
                                PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                                insertStmt.setString(1, certNumber);
                                insertStmt.setString(2, selectedId);
                                insertStmt.setString(3, recordName);
                                insertStmt.setInt(4, (Integer) session.getAttribute("userId"));
                                insertStmt.executeUpdate();
                                insertStmt.close();
                            } catch (Exception e) {
                                // Handle silently
                            }
                        }
        %>
        
        <div class="form-section" id="certificate">
            <div class="certificate-container">
                <div class="certificate-header">
                    <h1>🇪🇹 FEDERAL DEMOCRATIC REPUBLIC OF ETHIOPIA</h1>
                    <h2>EAST GOJJAM ZONE ADMINISTRATION</h2>
                    <h3>BIRTH CERTIFICATE</h3>
                    <div class="cert-number">Certificate No: <%= certNumber %></div>
                </div>
                
                <div class="certificate-body">
                    <p class="cert-intro">This is to certify that the following particulars have been compiled from the official vital records maintained by this office in accordance with the laws of the Federal Democratic Republic of Ethiopia:</p>
                    
                    <div class="cert-details">
                        <div class="cert-row">
                            <span class="cert-label">Photo:</span>
                            <span class="cert-value">
                                <% 
                                    String photoPath = rs.getString("photo_path");
                                    if (photoPath != null && !photoPath.trim().isEmpty()) {
                                %>
                                    <img src="<%= photoPath %>" alt="Child Photo" class="child-photo">
                                <% } else { %>
                                    <div class="photo-placeholder">
                                        <div>NO PHOTO</div>
                                        <div>UPLOADED</div>
                                    </div>
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Full Name of Child:</span>
                            <span class="cert-value"><%= rs.getString("child_first_name") + " " + 
                                                      (rs.getString("child_middle_name") != null ? rs.getString("child_middle_name") + " " : "") +
                                                      rs.getString("child_last_name") %></span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Gender:</span>
                            <span class="cert-value"><%= rs.getString("gender") %></span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Date of Birth:</span>
                            <span class="cert-value"><%= rs.getDate("date_of_birth") %></span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Place of Birth:</span>
                            <span class="cert-value"><%= rs.getString("place_of_birth") %></span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Father's Name:</span>
                            <span class="cert-value"><%= rs.getString("father_full_name") %></span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Mother's Name:</span>
                            <span class="cert-value"><%= rs.getString("mother_full_name") %></span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Registration Date:</span>
                            <span class="cert-value"><%= rs.getDate("registration_date") %></span>
                        </div>
                        
                        <div class="cert-row">
                            <span class="cert-label">Location:</span>
                            <span class="cert-value"><%= (rs.getString("wereda") != null ? rs.getString("wereda") + ", " : "") +
                                                      (rs.getString("kebele") != null ? rs.getString("kebele") : "") %></span>
                        </div>
                    </div>
                    
                    <div class="cert-footer">
                        <div class="cert-signature">
                            <div class="signature-line">
                                <div class="signature-space"></div>
                                <div class="signature-label">Registrar General</div>
                                <div class="signature-label">East Gojjam Zone</div>
                            </div>
                            
                            <div class="cert-seal">
                                <div class="seal-circle">
                                    <div>OFFICIAL</div>
                                    <div>SEAL</div>
                                </div>
                            </div>
                            
                            <div class="signature-line">
                                <div class="signature-space"></div>
                                <div class="signature-label">Zone Administrator</div>
                                <div class="signature-label">Date: <%= new java.util.Date() %></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="form-actions">
                <button onclick="window.print()" class="btn btn-primary"> Print Certificate</button>
                <a href="certification.jsp" class="btn btn-secondary">← Back to Certificates</a>
            </div>
        </div>
        
        <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error loading record: " + e.getMessage() + "</div>");
                }
            }
        %>
    </div>
    
    <script>
        function selectRecord(recordId) {
            window.location.href = 'cert-birth.jsp?record_id=' + encodeURIComponent(recordId) + '&search=' + encodeURIComponent(document.getElementById('search').value);
        }
    </script>
    
    <style>
        .certificate-container {
            background: white;
            padding: 3rem;
            border: 3px solid #2c3e50;
            margin: 2rem 0;
            font-family: 'Times New Roman', serif;
            position: relative;
        }
        
        .certificate-header {
            text-align: center;
            border-bottom: 2px solid #2c3e50;
            padding-bottom: 2rem;
            margin-bottom: 2rem;
        }
        
        .certificate-header h1 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
            color: #2c3e50;
        }
        
        .certificate-header h2 {
            font-size: 1.4rem;
            margin-bottom: 0.5rem;
            color: #34495e;
        }
        
        .certificate-header h3 {
            font-size: 2rem;
            margin: 1rem 0;
            color: #e74c3c;
            text-decoration: underline;
        }
        
        .cert-number {
            font-weight: bold;
            color: #2c3e50;
            margin-top: 1rem;
        }
        
        .cert-intro {
            text-align: center;
            font-style: italic;
            margin-bottom: 2rem;
            color: #2c3e50;
        }
        
        .cert-details {
            margin: 2rem 0;
        }
        
        .cert-row {
            display: flex;
            margin-bottom: 1rem;
            padding: 0.5rem 0;
            border-bottom: 1px dotted #bdc3c7;
        }
        
        .cert-label {
            font-weight: bold;
            width: 200px;
            color: #2c3e50;
        }
        
        .cert-value {
            flex: 1;
            color: #34495e;
            text-transform: uppercase;
        }
        
        .cert-footer {
            margin-top: 3rem;
            border-top: 2px solid #2c3e50;
            padding-top: 2rem;
        }
        
        .cert-signature {
            display: flex;
            justify-content: space-between;
            align-items: end;
        }
        
        .signature-line {
            text-align: center;
        }
        
        .signature-space {
            width: 150px;
            height: 60px;
            border-bottom: 2px solid #2c3e50;
            margin-bottom: 0.5rem;
        }
        
        .signature-label {
            font-size: 0.9rem;
            color: #2c3e50;
            margin-bottom: 0.2rem;
        }
        
        .cert-seal {
            text-align: center;
        }
        
        .seal-circle {
            width: 100px;
            height: 100px;
            border: 3px solid #e74c3c;
            border-radius: 50%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            font-weight: bold;
            color: #e74c3c;
            font-size: 0.8rem;
        }
        

        
        .search-results {
            margin: 1rem 0;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 5px;
        }
        
        .records-list {
            max-height: 300px;
            overflow-y: auto;
        }
        
        .record-item {
            padding: 0.8rem;
            margin: 0.5rem 0;
            background: white;
            border: 1px solid #ddd;
            border-radius: 3px;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .record-item:hover {
            background: #e3f2fd;
            border-color: #2196f3;
        }
        
        .no-results {
            text-align: center;
            color: #666;
            padding: 1rem;
            font-style: italic;
        }
        
        .child-photo {
            width: 80px;
            height: 100px;
            object-fit: cover;
            border: 1px solid #2c3e50;
            display: block;
        }
        
        .photo-placeholder {
            width: 80px;
            height: 100px;
            border: 2px solid #2c3e50;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #f8f9fa;
            font-size: 0.8rem;
            font-weight: bold;
            color: #2c3e50;
            flex-direction: column;
        }
        
        @media print {
            .main-content { margin: 0; }
            .form-actions, .user-management-header, nav, header, footer, .search-results, .form-section:not(#certificate) { display: none !important; }
            .certificate-container { border: 2px solid #000; margin: 0; }
            .child-photo {
                width: 80px !important;
                height: 100px !important;
                object-fit: cover !important;
                border: 1px solid #000 !important;
                display: block !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .photo-placeholder {
                width: 80px !important;
                height: 100px !important;
                border: 2px solid #000 !important;
                display: flex !important;
                align-items: center !important;
                justify-content: center !important;
                background: #f8f9fa !important;
                font-size: 0.8rem !important;
                font-weight: bold !important;
                color: #000 !important;
                flex-direction: column !important;
            }
        }
        
        <% if ("true".equals(printMode) || "pdf".equals(exportMode)) { %>
        .form-section:not(#certificate), .form-actions, .user-management-header {
            display: none !important;
        }
        .child-photo {
            width: 80px !important;
            height: 100px !important;
            object-fit: cover !important;
            border: 1px solid #000 !important;
            display: block !important;
        }
        <% } %>
        
        <% if ("pdf".equals(exportMode)) { %>
        <script>
            window.onload = function() {
                setTimeout(() => {
                    window.print();
                }, 500);
            };
        </script>
        <% } %>
    </style>
    
    <%@ include file="footer.jsp" %>
</body>
</html>