# East Gojjam VIMS - Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Database Design](#database-design)
4. [User Roles](#user-roles)
5. [Core Features](#core-features)
6. [Installation Guide](#installation-guide)
7. [User Manual](#user-manual)
8. [Security Features](#security-features)

---

## Project Overview

### Purpose
East Gojjam Vital Information Management System (VIMS) manages vital records for East Gojjam Zone, Ethiopia including birth, death, marriage, divorce, and immigration records with certificate generation.

### Technology Stack
- **Backend**: Java Servlets, JSP
- **Database**: MySQL 8.0+
- **Frontend**: HTML5, CSS3, JavaScript
- **Server**: Apache Tomcat 9.0+
- **Security**: SHA-256 password hashing
- **Email**: Template-based email system (EmailSenderServlet)
- **Architecture**: Organized folder structure with MVC pattern

### Key Features
- Role-based access control
- Complete vital records management
- Certificate generation with PDF export
- Statistical reporting
- Public record verification
- User management system
- Feedback system with email replies
- Organized folder structure for maintainability
- Backward compatibility with legacy URLs

---

## System Architecture

### Architecture Pattern
- Model-View-Controller (MVC)
- Three-tier Architecture
- Responsive Design

### Components
1. Authentication System
2. Record Management (CRUD)
3. Certificate Generation
4. Reporting System
5. User Management
6. Audit System

---

## Database Design

### Tables Overview
- **users**: System user accounts
- **locations**: Geographic locations (woreda, kebele, village)
- **birth_records**: Birth registrations
- **death_records**: Death registrations
- **marriage_records**: Marriage registrations
- **divorce_records**: Divorce registrations
- **immigration_records**: Immigration/emigration records
- **certificates**: Generated certificates tracking
- **audit_log**: System activity logging
- **feedback**: User feedback system

### Key Relationships
- All records linked to users (registered_by)
- All records linked to locations
- Certificates linked to records and users
- Audit logs track all user activities

---

## User Roles

### Admin Role (System Administrator)
- **User Management**: Create, edit, delete, activate/deactivate users
- **Role Assignment**: Assign roles (admin, data_entry, guest) to users
- **Feedback Management**: View, reply to, and delete user feedback
- **Email System**: Send feedback replies via email templates
- **User Data Export**: Export user information to Excel
- **Certificate Generation**: Generate and export certificates (shared capability)
- **Reports Access**: View statistical reports
- **System Oversight**: Monitor system usage and user activities
- **Navigation**: Administrative menu only (no direct record management)

### Data Entry Role (Operational Staff)
- **Record Management**: Create, edit, view all vital records (birth, death, marriage, divorce, immigration)
- **Record Operations**: Full CRUD operations on all record types
- **Certificate Generation**: Generate and export certificates (shared capability)
- **Reports Access**: View and generate statistical reports
- **Record Verification**: Access record verification features
- **Navigation**: Full record management menus
- **Limitations**: Cannot manage users or access administrative functions

### Guest Role (Public Access)
- **Record Verification**: Verify existing records
- **Limited Search**: Basic search functionality
- **Public Records**: View publicly available information
- **No Administrative Access**: Cannot create, edit, or manage any data

---

## Core Features

### 1. Record Management
**Birth Records**
- Child information (name, gender, birth date/place)
- Parent information (father/mother names)
- Location and registration details

**Death Records**
- Deceased information (name, gender, death date/place)
- Cause of death and age at death
- Location and registration details

**Marriage Records**
- Groom and bride information
- Marriage date and place
- Location and registration details

**Divorce Records**
- Husband and wife information
- Marriage and divorce dates
- Divorce reason and place

**Immigration Records**
- Person information and nationality
- Immigration type (Immigration/Emigration)
- Countries, dates, and purpose

### 2. Certificate Generation
- Official government-format certificates
- Unique certificate numbering
- PDF export functionality
- Certificate history tracking
- Professional Ethiopian government design

### 3. User Management (Admin Only)
- **Create Users**: Add new system users with username, password, full name, email, and role
- **Edit Users**: Modify user information and role assignments
- **User Status Control**: Activate/deactivate user accounts
- **Delete Users**: Remove users from the system
- **Role Assignment**: Assign roles (admin, data_entry, guest)
- **User Data Export**: Export complete user list to Excel format
- **Password Security**: Automatic SHA-256 hashing with salt and 10,000 iterations

### 4. Reporting System
- Statistical reports by date range
- Wereda and kebele analysis
- Record type summaries
- Export capabilities (Excel/PDF)

### 5. Search & Verification
- Multi-field search across records
- Public record verification
- Real-time search results
- Type-specific searches

---

## Installation Guide

### Prerequisites
1. Java JDK 8+
2. Apache Tomcat 9.0+
3. MySQL Server 8.0+
4. MySQL Connector/J JAR
5. IDE (Eclipse/IntelliJ/NetBeans)

### Setup Steps
1. **Database Setup**
   ```sql
   mysql -u root -p
   source database.sql
   ```

2. **Project Configuration**
   - Import as Dynamic Web Project
   - Add MySQL Connector JAR to WEB-INF/lib/
   - Configure database connection in LoginServlet.java

3. **Server Deployment**
   - Configure Tomcat server
   - Deploy project to Tomcat
   - Access at http://localhost:8080/EastGojjamVIMS

4. **Initial Login**
   - Username: admin
   - Password: password123

---

## User Manual

### Getting Started
1. Navigate to system URL
2. Login with credentials
3. Access dashboard based on role

### Adding Records
1. Select record type from navigation
2. Click "Add [Record Type] Record"
3. Fill required fields
4. Select location
5. Save record

### Generating Certificates
1. Navigate to any record view page
2. Select record to certify
3. Click certificate generation link
4. View official government-format certificate
5. Print or export as PDF
**Note**: Available to both Admin and Data Entry roles

### Managing Users (Admin)
1. Navigate to "Manage Users"
2. Add/edit/delete users as needed
3. Assign appropriate roles
4. Export user data

### Running Reports
1. Go to Reports section
2. Select date range
3. View statistical summaries
4. Export as needed

---

## Security Features

### Authentication
- SHA-256 password hashing with salt
- 10,000 iteration password strengthening
- Secure session management
- Role-based access control

### Data Protection
- SQL injection prevention (prepared statements)
- Input validation and sanitization
- XSS protection
- CSRF protection

### Access Control
- Page-level authentication checks
- Function-level permissions
- Complete audit trail
- Foreign key constraints

---

## File Structure

```
EastGojjamVIMS/
├── src/main/
│   ├── java/
│   │   ├── LoginServlet.java
│   │   └── EmailSenderServlet.java
│   └── webapp/
│       ├── WEB-INF/
│       ├── assets/
│       │   ├── css/global.css
│       │   └── js/
│       ├── pages/
│       │   ├── auth/
│       │   │   ├── index.jsp
│       │   │   └── login.jsp
│       │   ├── common/
│       │   │   ├── header.jsp
│       │   │   ├── nav.jsp
│       │   │   ├── footer.jsp
│       │   │   └── dashboard.jsp
│       │   ├── records/
│       │   │   ├── birth/
│       │   │   │   ├── add-birth.jsp
│       │   │   │   ├── view-birth.jsp
│       │   │   │   ├── edit-birth.jsp
│       │   │   │   ├── detail-birth.jsp
│       │   │   │   └── fetch-birth-record.jsp
│       │   │   ├── marriage/
│       │   │   │   ├── add-marriage.jsp
│       │   │   │   ├── view-marriage.jsp
│       │   │   │   ├── edit-marriage.jsp
│       │   │   │   ├── detail-marriage.jsp
│       │   │   │   └── fetch-marriage-record.jsp
│       │   │   ├── death/
│       │   │   │   ├── add-death.jsp
│       │   │   │   ├── view-death.jsp
│       │   │   │   ├── edit-death.jsp
│       │   │   │   └── detail-death.jsp
│       │   │   ├── divorce/
│       │   │   │   ├── add-divorce.jsp
│       │   │   │   ├── view-divorce.jsp
│       │   │   │   ├── edit-divorce.jsp
│       │   │   │   └── detail-divorce.jsp
│       │   │   └── immigration/
│       │   │       ├── add-immigration.jsp
│       │   │       ├── view-immigration.jsp
│       │   │       ├── edit-immigration.jsp
│       │   │       └── detail-immigration.jsp
│       │   ├── certificates/
│       │   │   ├── certification.jsp
│       │   │   ├── certified-document.jsp
│       │   │   ├── cert-birth.jsp
│       │   │   ├── cert-death.jsp
│       │   │   ├── cert-marriage.jsp
│       │   │   ├── cert-divorce.jsp
│       │   │   ├── cert-immigration.jsp
│       │   │   └── cert-list.jsp
│       │   ├── feedback/
│       │   │   ├── manage-feedback.jsp
│       │   │   ├── reply-feedback.jsp
│       │   │   └── email-template.jsp
│       │   └── management/
│       │       ├── user-management.jsp
│       │       ├── add-user.jsp
│       │       ├── edit-user.jsp
│       │       ├── reports.jsp
│       │       ├── verify-record.jsp
│       │       ├── our-addresses.jsp
│       │       ├── export-all-certificates.jsp
│       │       └── export-certified-records.jsp
│       └── Root Redirects (for backward compatibility):
│           ├── index.jsp → pages/auth/index.jsp
│           ├── login.jsp → pages/auth/login.jsp
│           ├── dashboard.jsp → pages/common/dashboard.jsp
│           └── [all other legacy paths]
├── database.sql
└── docs/
    └── PROJECT_DOCUMENTATION.md
```

---

## System Requirements

### Server Requirements
- OS: Windows/Linux/macOS
- Java: JRE 8+
- Memory: 2GB RAM minimum
- Storage: 1GB free space
- Database: MySQL 8.0+

### Client Requirements
- Modern web browser (Chrome, Firefox, Safari, Edge)
- JavaScript enabled
- Screen resolution: 1024x768 minimum
- Internet connection required

---

## Maintenance

### Regular Tasks
- Weekly database backups
- Monitor audit logs
- Review user accounts
- Apply security updates
- System performance monitoring

### Troubleshooting
- **Login Issues**: Check database connection and credentials
- **Certificate Problems**: Verify record exists and user permissions
- **Export Issues**: Check browser settings and popup blockers
- **Database Errors**: Verify MySQL service status

---

## Support Information

### Default Credentials
- **Username**: admin
- **Password**: password123

### Contact Information
- **System Admin**: admin@eastgojjam.gov.et
- **Technical Support**: Local IT Department

### Documentation Version
- **Version**: 1.0
- **Last Updated**: December 2024
- **Classification**: Internal Use

---

This documentation provides comprehensive information for installation, usage, and maintenance of the East Gojjam VIMS system.