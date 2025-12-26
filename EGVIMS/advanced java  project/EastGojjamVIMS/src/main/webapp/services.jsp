<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Services - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        .services-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            color: white;
            text-align: center;
            padding: 80px 20px 40px;
        }
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 3rem auto;
            padding: 0 2rem;
        }
        .service-card {
            background: white;
            padding: 2.5rem;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            text-align: left;
        }
        .service-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }
        .service-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            display: block;
        }
        .service-card h3 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }
        .service-card p {
            color: #666;
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }
        .service-features {
            list-style: none;
            padding: 0;
        }
        .service-features li {
            color: #555;
            margin-bottom: 0.5rem;
            padding-left: 1.5rem;
            position: relative;
        }
        .service-features li:before {
            content: "✓";
            color: #4facfe;
            font-weight: bold;
            position: absolute;
            left: 0;
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
        <div class="logo">East Gojjam VIMS - Services</div>
        <a href="index.jsp" class="back-btn">← Back to Home</a>
    </header>
    
    <div class="services-section">
        <h1 style="font-size: 3rem; margin-bottom: 1rem;">System Functions</h1>
        <p style="font-size: 1.2rem; max-width: 800px; margin: 0 auto;">What the East Gojjam VIMS system works with</p>
    </div>
    
    <div class="services-grid">
        <div class="service-card">
            <span class="service-icon"></span>
            <h3>Birth Records Management</h3>
            <p>System manages complete birth registration data.</p>
            <ul class="service-features">
                <li>Child personal information</li>
                <li>Parent details and relationships</li>
                <li>Birth location and date</li>
                <li>Registration and certificate data</li>
                <li>Medical birth information</li>
            </ul>
        </div>
        
        <div class="service-card">
            <span class="service-icon"></span>
            <h3>Death Records Management</h3>
            <p>System handles comprehensive death documentation.</p>
            <ul class="service-features">
                <li>Deceased person information</li>
                <li>Death date, time and location</li>
                <li>Cause of death documentation</li>
                <li>Age and demographic data</li>
                <li>Death certificate generation</li>
            </ul>
        </div>
        
        <div class="service-card">
            <span class="service-icon"></span>
            <h3>Marriage Records Management</h3>
            <p>System processes marriage registration data.</p>
            <ul class="service-features">
                <li>Bride and groom information</li>
                <li>Marriage date and location</li>
                <li>Witness and officiant details</li>
                <li>Marriage certificate data</li>
                <li>Legal marriage documentation</li>
            </ul>
        </div>
        
        <div class="service-card">
            <span class="service-icon"></span>
            <h3>Divorce Records Management</h3>
            <p>System manages divorce documentation.</p>
            <ul class="service-features">
                <li>Husband and wife information</li>
                <li>Divorce date and location</li>
                <li>Court decree information</li>
                <li>Legal separation details</li>
                <li>Divorce certificate data</li>
            </ul>
        </div>
        
        <div class="service-card">
            <span class="service-icon"></span>
            <h3>Immigration Records Management</h3>
            <p>System tracks population movement data.</p>
            <ul class="service-features">
                <li>Person immigration information</li>
                <li>Immigration type and date</li>
                <li>Origin and destination countries</li>
                <li>Visa and permit documentation</li>
                <li>Population movement tracking</li>
            </ul>
        </div>
        
        <div class="service-card">
            <span class="service-icon"></span>
            <h3>Statistical Data Processing</h3>
            <p>System generates comprehensive reports.</p>
            <ul class="service-features">
                <li>Population statistics by gender</li>
                <li>Geographic data by wereda</li>
                <li>Demographic trend analysis</li>
                <li>Record count summaries</li>
                <li>Data export capabilities</li>
            </ul>
        </div>
    </div>
    
    <footer style="background: #2c3e50; color: white; text-align: center; padding: 2rem; margin-top: 3rem;">
        <p>&copy; 2025 East Gojjam Zone Administration. All rights reserved.</p>
    </footer>
</body>
</html>