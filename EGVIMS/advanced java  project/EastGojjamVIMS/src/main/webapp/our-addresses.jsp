<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Our Addresses - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        .address-container { max-width: 1200px; margin: 0 auto; padding: 2rem; }
        .address-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin: 2rem 0; }
        .address-card { background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .address-card h3 { color: #2c3e50; margin-bottom: 1rem; }
        .map-container { height: 400px; width: 100%; border-radius: 10px; margin: 1rem 0; }
        .contact-info { margin: 1rem 0; }
        .contact-info p { margin: 0.5rem 0; color: #555; }
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; margin: 0; padding: 20px; font-family: Arial, sans-serif; }
        .back-btn { display: inline-block; background: #4facfe; color: white; padding: 0.75rem 1.5rem; text-decoration: none; border-radius: 25px; margin-bottom: 2rem; font-weight: 600; box-shadow: 0 4px 15px rgba(79, 172, 254, 0.4); }
        .back-btn:hover { background: #3498db; transform: translateY(-2px); }
        .page-header { text-align: center; color: white; margin-bottom: 2rem; }
        .page-header h2 { font-size: 2.5rem; margin-bottom: 0.5rem; }
    </style>
</head>
<body>
    
    <div class="address-container">
        <a href="index.jsp" class="back-btn">← Back to Home</a>
        
        <div class="page-header">
            <h2> Our Addresses</h2>
            <p>East Gojjam Zone Administrator Office Locations</p>
        </div>
        
        <div class="address-grid">
            <div class="address-card">
                <h3> Main Office</h3>
                <div class="contact-info">
                    <p><strong> Address:</strong> East Gojjam Zone Administrator Office</p>
                    <p>Debre Markos, Ethiopia</p>
                    <p><strong> Email:</strong> info@eastgojjamvims.gov.et</p>
                    <p><strong> Phone:</strong> +251-58-771-1234</p>
                    <p><strong> Working Hours:</strong> Mon-Fri: 8:00 AM - 5:00 PM</p>
                </div>
            </div>
            
            <div class="address-card">
                <h3> VIMS Department</h3>
                <div class="contact-info">
                    <p><strong> Address:</strong> Vital Information Management System</p>
                    <p>2nd Floor, Main Building</p>
                    <p><strong> Email:</strong> vims@eastgojjamvims.gov.et</p>
                    <p><strong> Phone:</strong> +251-58-771-1235</p>
                    <p><strong> Working Hours:</strong> Mon-Fri: 8:30 AM - 4:30 PM</p>
                </div>
            </div>
        </div>
        
        <div class="address-card">
            <h3> Office Location Map</h3>
            <div id="officeMap" class="map-container"></div>
            <div class="contact-info">
                <p><strong>Directions:</strong> Located in the center of Debre Markos, near the main market area. The office is easily accessible by public transportation.</p>
                <p><strong>Parking:</strong> Free parking available in front of the building</p>
                <p><strong>Public Transport:</strong> Bus stops within 200 meters</p>
            </div>
        </div>
        
        <div class="address-grid">
            <div class="address-card">
                <h3> Emergency Contact</h3>
                <div class="contact-info">
                    <p><strong> Emergency Line:</strong> +251-58-771-1000</p>
                    <p><strong> Emergency Email:</strong> emergency@eastgojjamvims.gov.et</p>
                    <p><strong> Available:</strong> 24/7</p>
                </div>
            </div>
            
            <div class="address-card">
                <h3> Customer Service</h3>
                <div class="contact-info">
                    <p><strong> Service Line:</strong> +251-58-771-1199</p>
                    <p><strong> Support Email:</strong> support@eastgojjamvims.gov.et</p>
                    <p><strong> Available:</strong> Mon-Fri: 8:00 AM - 6:00 PM</p>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Initialize office location map
        var officeMap = L.map('officeMap').setView([10.3269, 37.7236], 15);
        
        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(officeMap);
        
        // Add marker for East Gojjam Zone Administrator Office
        var officeMarker = L.marker([10.3269, 37.7236]).addTo(officeMap);
        officeMarker.bindPopup('<b>East Gojjam Zone Administrator Office</b><br>Debre Markos, Ethiopia<br>VIMS Headquarters').openPopup();
        
        // Add circle to show coverage area
        L.circle([10.3269, 37.7236], {
            color: '#4facfe',
            fillColor: '#4facfe',
            fillOpacity: 0.2,
            radius: 2000
        }).addTo(officeMap);
    </script>
    
</body>
</html>