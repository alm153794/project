<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    .main-footer { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); color: white; margin-top: 3rem; }
    .footer-content { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; padding: 3rem 2rem; max-width: 1200px; margin: 0 auto; }
    .footer-section h3 { color: #4facfe; margin-bottom: 1rem; font-size: 1.2rem; }
    .footer-section p { color: #b8c5d6; line-height: 1.6; margin: 0.5rem 0; }
    .footer-section ul { list-style: none; padding: 0; }
    .footer-section ul li { margin: 0.5rem 0; }
    .footer-section ul li a { color: #b8c5d6; text-decoration: none; transition: color 0.3s ease; }
    .footer-section ul li a:hover { color: #4facfe; }
    .footer-bottom { background: rgba(0,0,0,0.3); text-align: center; padding: 1.5rem; border-top: 1px solid rgba(255,255,255,0.1); }
    .footer-bottom p { color: #9ca3af; margin: 0; }
</style>
<footer class="main-footer">
    <div class="footer-content">
        <div class="footer-section">
            <h3> East Gojjam VIMS</h3>
            <p>Vital Information Management System for East Gojjam Zone</p>
            <p>Empowering communities through efficient vital records management and data-driven insights.</p>
        </div>
        
        <div class="footer-section">
            <h3> Contact Information</h3>
            <p> East Gojjam Zone Administration</p>
            <p> Debre Markos, Ethiopia</p>
            <p> Phone: +251-58-771-1234</p>
            <p> Email: info@eastgojjam.gov.et</p>
        </div>
        
        <div class="footer-section">
            <h3> Quick Links</h3>
            <ul>
                <li><a href="dashboard.jsp"> Dashboard</a></li>
                <li><a href="reports.jsp"> Reports</a></li>
                <li><a href="index.jsp"> Home</a></li>
            </ul>
        </div>
    </div>
    
    <div class="footer-bottom">
        <p>&copy; 2025 East Gojjam Zone Administration. All rights reserved.</p>
    </div>
</footer>