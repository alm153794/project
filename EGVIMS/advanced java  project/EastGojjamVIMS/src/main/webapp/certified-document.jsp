<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String recordType = request.getParameter("type");
    String recordId = request.getParameter("id");
    String exportMode = request.getParameter("export");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Certified Document - East Gojjam VIMS</title>
    <style>
        @media print {
            .no-print { display: none !important; }
            .child-photo { width: 80px !important; height: 100px !important; object-fit: cover !important; border: 1px solid #000 !important; display: block !important; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
            .couple-photo { width: 120px !important; height: 80px !important; object-fit: cover !important; border: 1px solid #000 !important; display: block !important; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
            .photo-placeholder { width: 80px !important; height: 100px !important; border: 2px solid #000 !important; display: flex !important; align-items: center !important; justify-content: center !important; background: #f8f9fa !important; font-size: 0.7rem !important; font-weight: bold !important; color: #000 !important; flex-direction: column !important; }
            .couple-placeholder { width: 120px !important; height: 80px !important; border: 2px solid #000 !important; display: flex !important; align-items: center !important; justify-content: center !important; background: #f8f9fa !important; font-size: 0.7rem !important; font-weight: bold !important; color: #000 !important; flex-direction: column !important; }
        }
        
        body { font-family: 'Times New Roman', serif; margin: 0; padding: 20px; background: #f8f9fa; }
        .certificate-container { background: white; padding: 2rem; border: 4px double #1e3a8a; margin: 1rem auto; max-width: 800px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        .certificate-header { text-align: center; border-bottom: 3px double #1e3a8a; padding-bottom: 1.5rem; margin-bottom: 2rem; }
        .certificate-header h1 { font-size: 1.6rem; margin: 0.3rem 0; color: #1e3a8a; font-weight: bold; }
        .certificate-header h2 { font-size: 1.2rem; margin: 0.3rem 0; color: #3b82f6; }
        .certificate-header h3 { font-size: 1.8rem; margin: 1.5rem 0; color: #dc2626; text-decoration: underline; font-weight: bold; }
        .cert-number { font-weight: bold; color: #1e3a8a; margin-top: 1rem; font-size: 1.1rem; }
        .cert-intro { text-align: justify; font-style: italic; margin: 2rem 0; color: #2c3e50; line-height: 1.6; }
        .cert-details { margin: 2rem 0; }
        .cert-row { display: flex; margin-bottom: 0.8rem; padding: 0.4rem 0; border-bottom: 1px solid #ddd; }
        .cert-label { font-weight: bold; width: 220px; color: #1e3a8a; font-size: 0.95rem; }
        .cert-value { flex: 1; color: #2c3e50; font-weight: 500; }
        .cert-footer { margin-top: 3rem; border-top: 3px double #1e3a8a; padding-top: 2rem; }
        .cert-signature { display: flex; justify-content: space-between; align-items: end; }
        .signature-line { text-align: center; }
        .signature-space { width: 160px; height: 50px; border-bottom: 2px solid #1e3a8a; margin-bottom: 0.5rem; }
        .signature-label { font-size: 0.85rem; color: #1e3a8a; margin-bottom: 0.2rem; font-weight: bold; }
        .cert-seal { text-align: center; }
        .seal-circle { width: 120px; height: 120px; border: 4px solid #dc2626; border-radius: 50%; display: flex; flex-direction: column; justify-content: center; align-items: center; font-weight: bold; color: #dc2626; font-size: 0.75rem; background: radial-gradient(circle, rgba(220,38,38,0.1) 0%, rgba(220,38,38,0.05) 100%); }
        .action-buttons { text-align: center; margin: 2rem 0; }
        .btn { padding: 0.8rem 1.5rem; margin: 0 0.5rem; border: none; border-radius: 4px; font-size: 0.9rem; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .ethiopian-header { background: linear-gradient(135deg, #1e3a8a, #3b82f6); color: white; padding: 1.5rem; text-align: center; margin-bottom: 0; border-bottom: 4px solid #dc2626; }
        .header-symbols { display: flex; justify-content: center; align-items: center; margin-bottom: 1rem; }
        .flag-emblem { font-size: 3rem; margin: 0 2rem; }
        .federal-logo { width: 80px; height: 80px; border: 3px solid #FFD700; border-radius: 50%; display: flex; flex-direction: column; align-items: center; justify-content: center; background: radial-gradient(circle, #FFD700 0%, #FFA500 100%); color: #8B4513; font-size: 0.7rem; font-weight: bold; text-align: center; position: relative; }
        .coat-of-arms { background: linear-gradient(45deg, #228B22, #32CD32); border: 2px solid #FFD700; color: #FFD700; }
        .coat-text { line-height: 1.1; }
        .amharic-text { font-family: 'Nyala', 'Ebrima', 'Abyssinica SIL', serif; font-size: 1.1rem; margin: 0.3rem 0; font-weight: 500; }
        .child-photo { width: 80px; height: 100px; object-fit: cover; border: 1px solid #1e3a8a; display: block; }
        .couple-photo { width: 120px; height: 80px; object-fit: cover; border: 1px solid #1e3a8a; display: block; }
        .photo-placeholder { width: 80px; height: 100px; border: 2px solid #1e3a8a; display: inline-flex; align-items: center; justify-content: center; background: #f8f9fa; font-size: 0.7rem; font-weight: bold; color: #1e3a8a; flex-direction: column; }
        .couple-placeholder { width: 120px; height: 80px; border: 2px solid #1e3a8a; display: inline-flex; align-items: center; justify-content: center; background: #f8f9fa; font-size: 0.7rem; font-weight: bold; color: #1e3a8a; flex-direction: column; }
    </style>
</head>
<body>
    <div class="no-print action-buttons">
        <button onclick="window.print()" class="btn btn-primary">🖨️ Print Certificate</button>
        <a href="certified-document.jsp?type=<%= recordType %>&id=<%= recordId %>&export=pdf" class="btn btn-success">📄 Export PDF</a>
        <a href="view-<%= recordType %>.jsp" class="btn btn-secondary">← Back to Records</a>
    </div>
    
    <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
            
            String tableName = recordType + "_records";
            String sql = "SELECT r.* FROM " + tableName + " r WHERE r.record_id = ?";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, recordId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String certNumber = "EG/" + recordType.toUpperCase().substring(0,3) + "/" + recordId + "/" + java.time.Year.now().getValue();
                String certTitle = "CERTIFICATE OF " + recordType.toUpperCase();
    %>
    
    <div class="certificate-container">
        <div class="ethiopian-header">
            <div class="header-symbols">
                <div class="flag-emblem">🇪🇹</div>
            </div>
            <div class="amharic-text">የኢትዮጵያ ፌዴራላዊ ዲሞክራሲያዊ ሪፐብሊክ</div>
            <h1>FEDERAL DEMOCRATIC REPUBLIC OF ETHIOPIA</h1>
            <div class="amharic-text">አማራ ክልላዊ መንግስት</div>
            <h2>AMHARA REGIONAL STATE</h2>
            <div class="amharic-text">የምስራቅ ጎጃም ዞን አስተዳደር</div>
            <h2>EAST GOJJAM ZONE ADMINISTRATION</h2>
            <div class="amharic-text">የሕይወት ወሳኝ መረጃዎች ምዝገባ ቢሮ</div>
            <h2>VITAL RECORDS REGISTRATION OFFICE</h2>
        </div>
        
        <div class="certificate-header">
            <h3><%= certTitle %></h3>
            <div class="cert-number">Certificate No: <%= certNumber %></div>
        </div>
        
        <div class="certificate-body">

            <p class="cert-intro">This is to certify that the following particulars have been compiled from the official vital records maintained by this office in accordance with the laws of the Federal Democratic Republic of Ethiopia:</p>
            
            <div class="cert-details">
                <%
                    if ("birth".equals(recordType)) {
                        String photoPath = rs.getString("photo_path");
                %>
                <div class="cert-row">
                    <span class="cert-label">Photo:</span>
                    <span class="cert-value">
                        <% if (photoPath != null && !photoPath.trim().isEmpty()) { %>
                            <img src="<%= photoPath %>" alt="Child Photo" class="child-photo">
                        <% } else { %>
                            <div class="photo-placeholder">
                                <div>NO PHOTO</div>
                                <div>AVAILABLE</div>
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
                <%
                    } else if ("marriage".equals(recordType)) {
                        String marriagePhotoPath = rs.getString("photo_path");
                %>
                <div class="cert-row">
                    <span class="cert-label">Couple Photo:</span>
                    <span class="cert-value">
                        <% if (marriagePhotoPath != null && !marriagePhotoPath.trim().isEmpty()) { %>
                            <img src="<%= marriagePhotoPath %>" alt="Couple Photo" class="couple-photo">
                        <% } else { %>
                            <div class="couple-placeholder">
                                <div>NO PHOTO</div>
                                <div>AVAILABLE</div>
                            </div>
                        <% } %>
                    </span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Groom's Full Name:</span>
                    <span class="cert-value"><%= rs.getString("groom_first_name") + " " + 
                                              (rs.getString("groom_middle_name") != null ? rs.getString("groom_middle_name") + " " : "") +
                                              rs.getString("groom_last_name") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Bride's Full Name:</span>
                    <span class="cert-value"><%= rs.getString("bride_first_name") + " " + 
                                              (rs.getString("bride_middle_name") != null ? rs.getString("bride_middle_name") + " " : "") +
                                              rs.getString("bride_last_name") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Date of Marriage:</span>
                    <span class="cert-value"><%= rs.getDate("marriage_date") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Place of Marriage:</span>
                    <span class="cert-value"><%= rs.getString("marriage_place") %></span>
                </div>
                <%
                    } else if ("death".equals(recordType)) {
                        String deathPhotoPath = rs.getString("photo_path");
                %>
                <div class="cert-row">
                    <span class="cert-label">Photo:</span>
                    <span class="cert-value">
                        <% if (deathPhotoPath != null && !deathPhotoPath.trim().isEmpty()) { %>
                            <img src="<%= deathPhotoPath %>" alt="Deceased Photo" class="child-photo">
                        <% } else { %>
                            <div class="photo-placeholder">
                                <div>NO PHOTO</div>
                                <div>AVAILABLE</div>
                            </div>
                        <% } %>
                    </span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Full Name of Deceased:</span>
                    <span class="cert-value"><%= rs.getString("deceased_first_name") + " " + 
                                              (rs.getString("deceased_middle_name") != null ? rs.getString("deceased_middle_name") + " " : "") +
                                              rs.getString("deceased_last_name") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Gender:</span>
                    <span class="cert-value"><%= rs.getString("gender") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Date of Death:</span>
                    <span class="cert-value"><%= rs.getDate("date_of_death") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Place of Death:</span>
                    <span class="cert-value"><%= rs.getString("place_of_death") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Cause of Death:</span>
                    <span class="cert-value"><%= rs.getString("cause_of_death") %></span>
                </div>
                <%
                    } else if ("divorce".equals(recordType)) {
                        String divorcePhotoPath = rs.getString("photo_path");
                %>
                <div class="cert-row">
                    <span class="cert-label">Couple Photo:</span>
                    <span class="cert-value">
                        <% if (divorcePhotoPath != null && !divorcePhotoPath.trim().isEmpty()) { %>
                            <img src="<%= divorcePhotoPath %>" alt="Couple Photo" class="couple-photo">
                        <% } else { %>
                            <div class="couple-placeholder">
                                <div>NO PHOTO</div>
                                <div>AVAILABLE</div>
                            </div>
                        <% } %>
                    </span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Husband's Full Name:</span>
                    <span class="cert-value"><%= rs.getString("husband_first_name") + " " + 
                                              (rs.getString("husband_middle_name") != null ? rs.getString("husband_middle_name") + " " : "") +
                                              rs.getString("husband_last_name") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Wife's Full Name:</span>
                    <span class="cert-value"><%= rs.getString("wife_first_name") + " " + 
                                              (rs.getString("wife_middle_name") != null ? rs.getString("wife_middle_name") + " " : "") +
                                              rs.getString("wife_last_name") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Date of Divorce:</span>
                    <span class="cert-value"><%= rs.getDate("divorce_date") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Place of Divorce:</span>
                    <span class="cert-value"><%= rs.getString("divorce_place") %></span>
                </div>
                <%
                    } else if ("immigration".equals(recordType)) {
                        String immigrationPhotoPath = rs.getString("photo_path");
                %>
                <div class="cert-row">
                    <span class="cert-label">Photo:</span>
                    <span class="cert-value">
                        <% if (immigrationPhotoPath != null && !immigrationPhotoPath.trim().isEmpty()) { %>
                            <img src="<%= immigrationPhotoPath %>" alt="Person Photo" class="child-photo">
                        <% } else { %>
                            <div class="photo-placeholder">
                                <div>NO PHOTO</div>
                                <div>AVAILABLE</div>
                            </div>
                        <% } %>
                    </span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Full Name:</span>
                    <span class="cert-value"><%= rs.getString("person_first_name") + " " + 
                                              (rs.getString("person_middle_name") != null ? rs.getString("person_middle_name") + " " : "") +
                                              rs.getString("person_last_name") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Nationality:</span>
                    <span class="cert-value"><%= rs.getString("nationality") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Immigration Type:</span>
                    <span class="cert-value"><%= rs.getString("immigration_type") %></span>
                </div>
                <div class="cert-row">
                    <span class="cert-label">Immigration Date:</span>
                    <span class="cert-value"><%= rs.getDate("immigration_date") %></span>
                </div>
                <%
                    }
                %>
                
                <div class="cert-row">
                    <span class="cert-label">Registration Date:</span>
                    <span class="cert-value"><%= rs.getDate("registration_date") %></span>
                </div>
                
                <div class="cert-row">
                    <span class="cert-label">Location:</span>
                    <span class="cert-value"><%= (rs.getString("wereda") != null ? rs.getString("wereda") + ", " : "") +
                                              (rs.getString("kebele") != null ? rs.getString("kebele") : "") %></span>
                </div>
                
                <div class="cert-row">
                    <span class="cert-label">Certified By:</span>
                    <span class="cert-value"><%= session.getAttribute("fullName") %></span>
                </div>
                
                <div class="cert-row">
                    <span class="cert-label">Certification Date:</span>
                    <span class="cert-value"><%= new java.util.Date() %></span>
                </div>
            </div>
            
            <div class="cert-footer">
                <div class="cert-signature">
                    <div class="signature-line">
                        <div class="signature-space"></div>
                        <div class="signature-label">Civil Registration Officer</div>
                        <div class="signature-label">East Gojjam Zone</div>
                    </div>
                    
                    <div class="cert-seal">
                        <div class="seal-circle">
                            <div style="font-size: 0.7rem;">EAST GOJJAM</div>
                            <div style="font-size: 0.6rem;">ZONE</div>
                            <div style="font-size: 0.7rem;">OFFICIAL</div>
                            <div style="font-size: 0.6rem;">SEAL</div>
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
    
    <%
            } else {
                out.println("<div style='text-align: center; padding: 2rem;'>");
                out.println("<h2>Certificate Not Available</h2>");
                out.println("<p>This record is not certified or does not exist.</p>");
                out.println("<a href='view-" + recordType + ".jsp' class='btn btn-secondary'>← Back to Records</a>");
                out.println("</div>");
            }
            
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (Exception e) {
            out.println("<div style='text-align: center; padding: 2rem;'>");
            out.println("<h2>Error Loading Certificate</h2>");
            out.println("<p>Error: " + e.getMessage() + "</p>");
            out.println("<a href='dashboard.jsp' class='btn btn-secondary'>← Back to Dashboard</a>");
            out.println("</div>");
        }
    %>
    
    <% if ("pdf".equals(exportMode)) { %>
    <script>
        window.onload = function() {
            setTimeout(() => {
                window.print();
            }, 500);
        };
    </script>
    <% } %>
</body>
</html>