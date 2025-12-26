<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>East Gojjam VIMS - Vital Information Management System</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            color: white;
            text-align: center;
            padding: 100px 20px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .system-login {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: bold;
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.4);
            transition: all 0.3s ease;
        }
        .system-login:hover {
            background: linear-gradient(135deg, #ee5a24, #ff3838);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 107, 107, 0.6);
        }
        .hero-title {
            font-size: 3.5rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .hero-subtitle {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 3rem;
            max-width: 1200px;
            margin-left: auto;
            margin-right: auto;
        }
        .feature-card {
            background: rgba(255,255,255,0.15);
            padding: 2rem;
            border-radius: 15px;
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255,255,255,0.2);
            transition: all 0.3s ease;
        }
        .feature-card:hover {
            transform: translateY(-8px);
            background: rgba(255,255,255,0.25);
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
        }
        .feature-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        .nav-links {
            display: flex;
            align-items: center;
            gap: 2rem;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            font-weight: 600;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            transition: all 0.3s ease;
        }
        .nav-links a:hover {
            background: rgba(255,255,255,0.2);
            transform: translateY(-2px);
            border-radius: 8px;
        }
        .header {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            padding: 1.5rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 20px rgba(79, 172, 254, 0.3);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .footer {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: white;
            position: relative;
            overflow: hidden;
        }
        .footer::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 6px;
            background: linear-gradient(90deg, #4facfe, #00f2fe, #ff6b6b, #feca57, #4facfe);
            animation: gradientShift 3s ease-in-out infinite;
        }
        @keyframes gradientShift {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.8; }
        }
        .footer-main {
            padding: 4rem 2rem 2rem;
        }
        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1.5fr;
            gap: 3rem;
            margin-bottom: 3rem;
        }
        .footer-section h3 {
            color: #4facfe;
            margin-bottom: 1.5rem;
            font-size: 1.3rem;
            font-weight: 700;
            position: relative;
        }
        .footer-section h3::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 40px;
            height: 3px;
            background: linear-gradient(90deg, #4facfe, #00f2fe);
            border-radius: 2px;
        }
        .footer-section p {
            line-height: 1.8;
            color: #b8c5d6;
            margin-bottom: 1rem;
        }
        .social-links {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .social-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: #b8c5d6;
            text-decoration: none;
            padding: 0.75rem 1rem;
            background: rgba(79, 172, 254, 0.1);
            border-radius: 25px;
            border: 1px solid rgba(79, 172, 254, 0.2);
            transition: all 0.3s ease;
            font-size: 0.9rem;
            font-weight: 500;
        }
        .social-link:hover {
            background: rgba(79, 172, 254, 0.2);
            color: #4facfe;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(79, 172, 254, 0.3);
        }
        .footer-bottom {
            background: rgba(0, 0, 0, 0.3);
            padding: 2rem;
            text-align: center;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        .footer-bottom p {
            color: #9ca3af;
            margin: 0.5rem 0;
        }
        .footer-links {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-bottom: 1rem;
        }
        .footer-links a {
            color: #b8c5d6;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        .footer-links a:hover {
            color: #4facfe;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="logo">
            <img src="uploads/images/logo.jpg" alt="East Gojjam VIMS Logo" style="height: 80px; width: auto;">
        </div>
        <nav class="nav-links">
            <a href="index.jsp">Home</a>
            <a href="verify-record.jsp"> Verify Record</a>
            <a href="our-addresses.jsp"> Our Addresses</a>
            <a href="services.jsp">Services</a>
            
            <a href="about.jsp">About</a>
            <a href="feedback.jsp" style="background: linear-gradient(135deg, #28a745, #20c997); border-radius: 25px;"> Feedback</a>
            <a href="login.jsp" class="system-login">System Login</a>
        </nav>
    </header>
    
    <div class="hero-section">
        <h1 class="hero-title">East Gojjam VIMS</h1>
        <p class="hero-subtitle">Comprehensive Vital Information Management System</p>
        <p style="font-size: 1.2rem; max-width: 800px; margin: 0 auto;">A modern web-based system for managing vital records including births, deaths, marriages, divorces, and immigration records for East Gojjam Zone, Ethiopia.</p>
        
        <div class="features">
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>Birth Records</h3>
                <p>Complete birth registration and management system with detailed record keeping</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>Death Records</h3>
                <p>Comprehensive death record management with cause tracking and statistics</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>Marriage Records</h3>
                <p>Marriage registration and certificate management system</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>Divorce Records</h3>
                <p>Divorce documentation and legal record management</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>Immigration Records</h3>
                <p>Immigration and emigration tracking for population management</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>Reports & Analytics</h3>
                <p>Statistical reports and data visualization for informed decision making</p>
            </div>
        </div>
    </div>
    
    <footer class="footer">
        <div class="footer-main">
            <div class="footer-content">
                <div class="footer-section">
                    <h3> East Gojjam VIMS</h3>
                    <p>Comprehensive Vital Information Management System serving East Gojjam Zone, Ethiopia with modern digital solutions for vital records management.</p>
                    <p>Empowering communities through digital transformation and efficient public service delivery.</p>
                </div>
                <div class="footer-section">
                    <h3> Quick Links</h3>
                    <p><a href="services.jsp" style="color: #b8c5d6; text-decoration: none;">System Functions</a></p>
                    
                    <p><a href="about.jsp" style="color: #b8c5d6; text-decoration: none;">About Us</a></p>
                    <p><a href="login.jsp" style="color: #b8c5d6; text-decoration: none;">System Login</a></p>
                </div>
                <div class="footer-section">
                    <h3> Our Services</h3>
                    <p>Birth Registration</p>
                    <p>Death Records</p>
                    <p>Marriage Certificates</p>
                    <p>Divorce Documentation</p>
                    <p>Immigration Tracking</p>
                </div>
                <div class="footer-section">
                    <h3> Contact & Social</h3>
                    <p> Debre Markos, Ethiopia<br>
                     email info@eastgojjamvims.gov.et<br>
                     +251-58-771-1234</p>
                    <div class="social-links">
                        <a href="https://facebook.com/eastgojjamzone" target="_blank" class="social-link"> Facebook</a>
                        <a href="https://twitter.com/eastgojjamzone" target="_blank" class="social-link"> Twitter</a>
                        <a href="https://instagram.com/eastgojjamzone" target="_blank" class="social-link"> Instagram</a>
                        <a href="https://linkedin.com/company/eastgojjamzone" target="_blank" class="social-link"> LinkedIn</a>
                        <a href="https://youtube.com/@eastgojjamzone" target="_blank" class="social-link"> YouTube</a>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="footer-bottom">
            <div class="footer-links">
                <a href="#">Privacy Policy</a>
                <a href="#">Terms of Service</a>
                <a href="#">Cookie Policy</a>
                <a href="#">Accessibility</a>
            </div>
            <p>&copy; 2025 East Gojjam Zone Administration. All rights reserved.</p>
            
        </div>
    </footer>



</body>
</html>