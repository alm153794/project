<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>About Us - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        .about-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            color: white;
            text-align: center;
            padding: 80px 20px 40px;
        }
        .about-content {
            max-width: 1200px;
            margin: 3rem auto;
            padding: 0 2rem;
        }
        .about-card {
            background: white;
            padding: 3rem;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
            text-align: left;
        }
        .about-card h2 {
            color: #2c3e50;
            margin-bottom: 1.5rem;
            font-size: 2rem;
        }
        .about-card p {
            color: #666;
            line-height: 1.8;
            margin-bottom: 1.5rem;
            font-size: 1.1rem;
        }
        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        .team-card {
            background: #f8f9fa;
            padding: 2rem;
            border-radius: 10px;
            text-align: center;
        }
        .team-card h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }
        .team-card .role {
            color: #4facfe;
            font-weight: 600;
            margin-bottom: 1rem;
        }
        .header {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            padding: 1.5rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 20px rgba(79, 172, 254, 0.3);
        }
        .logo {
            font-size: 1.8rem;
            font-weight: 800;
            color: white;
            text-decoration: none;
        }
        .back-btn {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        .back-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 107, 107, 0.4);
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="logo">East Gojjam VIMS - About Us</div>
        <a href="index.jsp" class="back-btn">← Back to Home</a>
    </header>
    
    <div class="about-section">
        <h1 style="font-size: 3rem; margin-bottom: 1rem;">About Us</h1>
        <p style="font-size: 1.2rem; max-width: 800px; margin: 0 auto;">Learn more about East Gojjam Zone Administration and our commitment to digital transformation</p>
    </div>
    
    <div class="about-content">
        <div class="about-card">
            <h2> East Gojjam Zone Administration</h2>
            <p>East Gojjam Zone Administration is a governmental body responsible for the administrative governance of East Gojjam Zone in the Amhara Region of Ethiopia. Located in Debre Markos, we serve over 2.5 million residents across 18 woredas, ensuring efficient public service delivery and sustainable development.</p>
            <p>Our administration is committed to modernizing public services through digital transformation initiatives, with the Vital Information Management System (VIMS) being a flagship project that demonstrates our dedication to leveraging technology for better governance.</p>
        </div>
        
        <div class="about-card">
            <h2> Our Mission</h2>
            <p>To provide efficient, transparent, and accessible vital record management services to the people of East Gojjam Zone through innovative digital solutions that ensure data accuracy, security, and availability for informed decision-making and improved public service delivery.</p>
        </div>
        
        <div class="about-card">
            <h2> Our Vision</h2>
            <p>To become a leading example of digital governance in Ethiopia, where every citizen has seamless access to vital record services, and government decisions are backed by accurate, real-time demographic data that supports sustainable development and improved quality of life.</p>
        </div>
        
        <div class="about-card">
            <h2> Why VIMS?</h2>
            <p>The East Gojjam Vital Information Management System was developed to address the challenges of manual record keeping, data inconsistency, and limited access to vital statistics. Our system ensures:</p>
            <ul style="color: #666; line-height: 1.8; margin-left: 2rem;">
                <li>Accurate and secure digital record storage</li>
                <li>Real-time access to vital statistics for planning</li>
                <li>Streamlined certificate issuance processes</li>
                <li>Comprehensive demographic analysis capabilities</li>
                <li>Improved transparency and accountability</li>
            </ul>
        </div>
        
        <div class="about-card">
            <h2> Our Team</h2>
            <p>Our dedicated team of professionals works tirelessly to ensure the success of the VIMS project and the delivery of quality services to our community.</p>
            
            <div class="team-grid">
                <div class="team-card">
                    <h4>Ato Mulugeta Assefa</h4>
                    <div class="role">Zone Administrator</div>
                    <p>Leading the digital transformation initiative and overseeing strategic implementation of VIMS across the zone.</p>
                </div>
                
                <div class="team-card">
                    <h4>W/ro Almaz Tadesse</h4>
                    <div class="role">IT Department Head</div>
                    <p>Managing technical aspects of the system and ensuring data security and system reliability.</p>
                </div>
                
                <div class="team-card">
                    <h4>Ato Bekele Worku</h4>
                    <div class="role">Records Management Director</div>
                    <p>Overseeing vital records operations and ensuring compliance with national standards.</p>
                </div>
                
                <div class="team-card">
                    <h4>W/ro Hanan Mohammed</h4>
                    <div class="role">Data Analysis Coordinator</div>
                    <p>Managing statistical analysis and generating insights from demographic data for policy making.</p>
                </div>
            </div>
        </div>
        
        <div class="about-card">
            <h2> Contact Information</h2>
            <p><strong>Address:</strong> East Gojjam Zone Administration Office<br>
            Debre Markos, Amhara Region, Ethiopia</p>
            <p><strong>Phone:</strong> +251-58-771-1234<br>
            <strong>Email:</strong> info@eastgojjamvims.gov.et<br>
            <strong>Website:</strong> www.eastgojjam.gov.et</p>
            <p><strong>Office Hours:</strong> Monday - Friday: 8:00 AM - 5:00 PM<br>
            Saturday: 8:00 AM - 12:00 PM</p>
        </div>
    </div>
    
    <footer style="background: #2c3e50; color: white; text-align: center; padding: 2rem; margin-top: 3rem;">
        <p>&copy; 2025 East Gojjam Zone Administration. All rights reserved.</p>
    </footer>
</body>
</html>