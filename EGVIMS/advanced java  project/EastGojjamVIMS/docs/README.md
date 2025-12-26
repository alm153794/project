# East Gojjam VIMS (Vital Information Management System)

A comprehensive web-based system for managing vital records including births, deaths, marriages, divorces, and immigration records for East Gojjam Zone, Ethiopia.

## Features

- **User Authentication**: Role-based access control (Admin, Data Entry, Public)
- **Birth Records Management**: Add, view, edit, and search birth records
- **Death Records Management**: Complete death record management
- **Marriage Records Management**: Marriage registration and tracking
- **Divorce Records Management**: Divorce record management
- **Immigration Records Management**: Immigration/emigration tracking
- **Location Management**: Woreda, Kebele, and Village management
- **Reporting System**: Statistical reports and data export
- **Audit Trail**: Complete activity logging

## Technology Stack

- **Backend**: Java Servlets, JSP
- **Database**: MySQL
- **Frontend**: HTML5, CSS3, JavaScript
- **Server**: Apache Tomcat

## Database Setup

1. Install MySQL Server
2. Run the database.sql script to create the database and tables
3. Default admin credentials:
   - Username: admin
   - Password: admin123

## Installation

1. Clone the project
2. Import into Eclipse/IntelliJ as a Dynamic Web Project
3. Add MySQL Connector JAR to WEB-INF/lib/
4. Configure database connection in LoginServlet.java
5. Deploy to Tomcat server

## Project Structure

```
EastGojjamVIMS/
├── src/main/
│   ├── java/
│   │   └── LoginServlet.java
│   └── webapp/
│       ├── WEB-INF/
│       │   ├── web.xml
│       │   └── lib/
│       ├── login.jsp
│       ├── dashboard.jsp
│       ├── header.jsp
│       ├── nav.jsp
│       ├── footer.jsp
│       └── style.css
└── database.sql
```

## User Roles

- **Admin**: Full system access, user management, all CRUD operations
- **Data Entry**: Add and edit records, view reports
- **Public**: View-only access to public records

## Default Locations

- Debre Markos - Kebele 01 - Center
- Debre Markos - Kebele 02 - Arada
- Bichena - Kebele 01 - Town Center
- Machakel - Kebele 01 - Rural Area

## License

© 2024 East Gojjam Zone Administration. All rights reserved.