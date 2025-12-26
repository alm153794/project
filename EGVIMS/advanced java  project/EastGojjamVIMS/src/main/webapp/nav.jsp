<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userRole = (String) session.getAttribute("role");
%>
<style>
    .main-nav { background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%); box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .nav-menu { list-style: none; margin: 0; padding: 0; display: flex; justify-content: center; }
    .nav-menu > li { position: relative; }
    .nav-menu > li > a { display: block; color: white; padding: 1rem 1.5rem; text-decoration: none; transition: all 0.3s ease; font-weight: 500; }
    .nav-menu > li > a:hover { background: rgba(255,255,255,0.1); }
    .dropdown-menu { position: absolute; top: 100%; left: 0; background: white; min-width: 200px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); border-radius: 8px; opacity: 0; visibility: hidden; transform: translateY(-10px); transition: all 0.3s ease; z-index: 1000; }
    .dropdown:hover .dropdown-menu { opacity: 1; visibility: visible; transform: translateY(0); }
    .dropdown-menu li a { display: block; color: #2c3e50; padding: 0.75rem 1rem; text-decoration: none; transition: all 0.3s ease; }
    .dropdown-menu li a:hover { background: #f8f9fa; color: #4facfe; }
</style>
<nav class="main-nav">
    <ul class="nav-menu">
        <li><a href="dashboard.jsp">Dashboard</a></li>
        <% if (!"admin".equals(userRole)) { %>
        <li><a href="verify-record.jsp">Verify Record</a></li>
        
        <li class="dropdown">
            <a href="#" class="dropdown-toggle">Birth Records</a>
            <ul class="dropdown-menu">
                <% if ("data_entry".equals(userRole)) { %>
                <li><a href="add-birth.jsp">Add Birth Record</a></li>
                <% } %>
                <li><a href="view-birth.jsp">View Records</a></li>
            </ul>
        </li>
        
        <li class="dropdown">
            <a href="#" class="dropdown-toggle">Death Records</a>
            <ul class="dropdown-menu">
                <% if ("data_entry".equals(userRole)) { %>
                <li><a href="add-death.jsp">Add Death Record</a></li>
                <% } %>
                <li><a href="view-death.jsp">View Records</a></li>
            </ul>
        </li>
        
        <li class="dropdown">
            <a href="#" class="dropdown-toggle">Marriage Records</a>
            <ul class="dropdown-menu">
                <% if ("data_entry".equals(userRole)) { %>
                <li><a href="add-marriage.jsp">Add Marriage Record</a></li>
                <% } %>
                <li><a href="view-marriage.jsp">View Records</a></li>
            </ul>
        </li>
        
        <li class="dropdown">
            <a href="#" class="dropdown-toggle">Divorce Records</a>
            <ul class="dropdown-menu">
                <% if ("data_entry".equals(userRole)) { %>
                <li><a href="add-divorce.jsp">Add Divorce Record</a></li>
                <% } %>
                <li><a href="view-divorce.jsp">View Records</a></li>
            </ul>
        </li>
        
        <li class="dropdown">
            <a href="#" class="dropdown-toggle">Immigration Records</a>
            <ul class="dropdown-menu">
                <% if ("data_entry".equals(userRole)) { %>
                <li><a href="add-immigration.jsp">Add Immigration Record</a></li>
                <% } %>
                <li><a href="view-immigration.jsp">View Records</a></li>
            </ul>
        </li>
        <% } %>
        
        <li class="dropdown">
            <a href="#" class="dropdown-toggle">Reports</a>
            <ul class="dropdown-menu">
                <li><a href="reports.jsp">Statistical Reports</a></li>
            </ul>
        </li>
        
        <% if ("admin".equals(userRole)) { %>
        <li class="dropdown">
            <a href="#" class="dropdown-toggle">Administration</a>
            <ul class="dropdown-menu">
                <li><a href="user-management.jsp">Manage Users</a></li>
                <li><a href="manage-feedback.jsp">Manage Feedback</a></li>
            </ul>
        </li>
        <% } %>
    </ul>
</nav>