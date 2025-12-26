<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reports - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .main-content { background: rgba(255,255,255,0.95); margin: 2rem; border-radius: 20px; padding: 2rem; backdrop-filter: blur(15px); box-shadow: 0 20px 40px rgba(0,0,0,0.1); }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; margin: 3rem 0; }
        .stat-card { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; padding: 2rem; border-radius: 15px; text-align: center; box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3); transition: all 0.3s ease; }
        .stat-card:hover { transform: translateY(-10px); box-shadow: 0 20px 40px rgba(79, 172, 254, 0.4); }
        .stat-number { font-size: 3rem; font-weight: bold; margin: 1rem 0; text-shadow: 2px 2px 4px rgba(0,0,0,0.2); }
        .chart-container { background: white; padding: 2rem; border-radius: 15px; margin: 1rem; box-shadow: 0 10px 30px rgba(0,0,0,0.1); transition: all 0.3s ease; }
        .chart-container:hover { transform: translateY(-5px); box-shadow: 0 15px 35px rgba(0,0,0,0.15); }
        .charts-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 2rem; margin: 2rem 0; }
        .wereda-table-container { background: white; padding: 2rem; border-radius: 15px; margin: 2rem 0; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th { background: linear-gradient(135deg, #4facfe, #00f2fe); color: white; padding: 1rem; text-align: left; }
        .data-table td { padding: 1rem; border-bottom: 1px solid #eee; }
        .data-table tr:hover { background: #f8f9fa; }
        .section-title { color: #2c3e50; font-size: 2rem; margin: 2rem 0 1rem; text-align: center; }
        .filter-container { background: white; padding: 2rem; border-radius: 15px; margin: 2rem 0; box-shadow: 0 10px 30px rgba(0,0,0,0.1); text-align: center; }
        .filter-container h3 { color: #2c3e50; margin-bottom: 1rem; }
        .filter-container select { padding: 0.75rem; border: 2px solid #e0e6ed; border-radius: 10px; font-size: 1rem; margin: 0 0.5rem; }
        .period-info { background: linear-gradient(135deg, #ffeaa7, #fdcb6e); color: #2d3436; padding: 1rem; border-radius: 10px; margin: 1rem 0; text-align: center; font-weight: bold; }
    </style>
</head>
<body>
    <header style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); padding: 2rem; color: white; text-align: center; box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3);">
        <h1 style="margin: 0; font-size: 2.5rem; text-shadow: 2px 2px 4px rgba(0,0,0,0.3);">Statistical Reports Dashboard</h1>
        <p style="margin: 0.5rem 0 0; opacity: 0.9; font-size: 1.1rem;">East Gojjam VIMS Analytics & Insights</p>
        <a href="index.jsp" style="color: white; text-decoration: none; position: absolute; top: 2rem; left: 2rem; background: rgba(255,255,255,0.2); padding: 0.5rem 1rem; border-radius: 25px; transition: all 0.3s ease;" onmouseover="this.style.background='rgba(255,255,255,0.3)'" onmouseout="this.style.background='rgba(255,255,255,0.2)'">← Back to Home</a>
    </header>
    
    <div class="main-content">
        <!-- Time Period Filter -->
        <div class="filter-container">
            <h3> Select Report Period</h3>
            <select id="periodFilter" onchange="updateReports()">
                <option value="all">All Time</option>
                <option value="daily">Today</option>
                <option value="weekly">This Week</option>
                <option value="monthly">This Month</option>
                <option value="3month">Last 3 Months</option>
                <option value="6month">Last 6 Months</option>
                <option value="annual">This Year</option>
            </select>
            <input type="date" id="customDate" style="margin-left: 1rem; padding: 0.5rem; border-radius: 5px; border: 1px solid #ddd;">
            <button onclick="updateCustomDate()" class="btn btn-primary" style="margin-left: 0.5rem; padding: 0.5rem 1rem;">Apply Date</button>
        </div>
        
        <h2 class="section-title"> System Overview</h2>
            
            <%
                String period = request.getParameter("period") != null ? request.getParameter("period") : "all";
                String customDate = request.getParameter("customDate");
                
                int totalBirths = 0, totalDeaths = 0, totalMarriages = 0, totalDivorces = 0, totalImmigration = 0;
                int maleBirths = 0, femaleBirths = 0, maleDeaths = 0, femaleDeaths = 0;
                String weredaData = "";
                String monthlyData = "";
                String dailyData = "";
                
                // Build date filter SQL
                String dateFilter = "";
                if ("daily".equals(period)) {
                    dateFilter = " WHERE DATE(registration_date) = CURDATE()";
                } else if ("weekly".equals(period)) {
                    dateFilter = " WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
                } else if ("monthly".equals(period)) {
                    dateFilter = " WHERE MONTH(registration_date) = MONTH(CURDATE()) AND YEAR(registration_date) = YEAR(CURDATE())";
                } else if ("3month".equals(period)) {
                    dateFilter = " WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)";
                } else if ("6month".equals(period)) {
                    dateFilter = " WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)";
                } else if ("annual".equals(period)) {
                    dateFilter = " WHERE YEAR(registration_date) = YEAR(CURDATE())";
                } else if (customDate != null && !customDate.isEmpty()) {
                    dateFilter = " WHERE DATE(registration_date) = '" + customDate + "'";
                }
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                    
                    Statement stmt = conn.createStatement();
                    
                    // Get totals with date filter
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM birth_records" + dateFilter);
                    if (rs.next()) totalBirths = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM death_records" + dateFilter);
                    if (rs.next()) totalDeaths = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM marriage_records" + dateFilter);
                    if (rs.next()) totalMarriages = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM divorce_records" + dateFilter);
                    if (rs.next()) totalDivorces = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM immigration_records" + dateFilter);
                    if (rs.next()) totalImmigration = rs.getInt("count");
                    
                    // Gender statistics with date filter
                    String genderFilter = dateFilter.isEmpty() ? "" : " AND" + dateFilter.substring(6);
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM birth_records WHERE gender = 'Male'" + genderFilter);
                    if (rs.next()) maleBirths = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM birth_records WHERE gender = 'Female'" + genderFilter);
                    if (rs.next()) femaleBirths = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM death_records WHERE gender = 'Male'" + genderFilter);
                    if (rs.next()) maleDeaths = rs.getInt("count");
                    
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM death_records WHERE gender = 'Female'" + genderFilter);
                    if (rs.next()) femaleDeaths = rs.getInt("count");
                    
                    // Monthly trends for the year
                    StringBuilder monthLabels = new StringBuilder();
                    StringBuilder birthCounts = new StringBuilder();
                    StringBuilder deathCounts = new StringBuilder();
                    
                    for (int i = 1; i <= 12; i++) {
                        if (monthLabels.length() > 0) {
                            monthLabels.append(",");
                            birthCounts.append(",");
                            deathCounts.append(",");
                        }
                        
                        String[] months = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
                        monthLabels.append("'").append(months[i]).append("'");
                        
                        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM birth_records WHERE MONTH(registration_date) = " + i + " AND YEAR(registration_date) = YEAR(CURDATE())");
                        rs.next();
                        birthCounts.append(rs.getInt("count"));
                        
                        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM death_records WHERE MONTH(registration_date) = " + i + " AND YEAR(registration_date) = YEAR(CURDATE())");
                        rs.next();
                        deathCounts.append(rs.getInt("count"));
                    }
                    
                    monthlyData = "labels: [" + monthLabels + "], birthData: [" + birthCounts + "], deathData: [" + deathCounts + "]";
                    
                    // Kebele statistics with date filter
                    String kebeleQuery = "SELECT CONCAT(kebele, ' (', wereda, ')') as kebele_name, COUNT(*) as count FROM birth_records" + dateFilter + " GROUP BY kebele, wereda ORDER BY count DESC LIMIT 10";
                    rs = stmt.executeQuery(kebeleQuery);
                    StringBuilder kebeleLabels = new StringBuilder();
                    StringBuilder kebeleCounts = new StringBuilder();
                    while (rs.next()) {
                        if (kebeleLabels.length() > 0) { kebeleLabels.append(","); kebeleCounts.append(","); }
                        kebeleLabels.append("'").append(rs.getString("kebele_name")).append("'");
                        kebeleCounts.append(rs.getInt("count"));
                    }
                    weredaData = "labels: [" + kebeleLabels + "], data: [" + kebeleCounts + "]";
                    
                    conn.close();
                } catch (Exception e) {
                    out.println("Error: " + e.getMessage());
                }
            %>
            
            <div id="periodInfo" class="period-info">Showing statistics for: <span id="periodText">All Time</span></div>
            
            <!-- Statistics Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number"><%= totalBirths %></div>
                    <div>Total Births</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= totalDeaths %></div>
                    <div>Total Deaths</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= totalMarriages %></div>
                    <div>Total Marriages</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= totalDivorces %></div>
                    <div>Total Divorces</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= totalImmigration %></div>
                    <div>Immigration Records</div>
                </div>
            </div>
            
            <h2 class="section-title"> Visual Analytics</h2>
            <div class="charts-grid">
                <div class="chart-container">
                    <h3 style="color: #2c3e50; margin-bottom: 1rem;"> Records Overview</h3>
                    <canvas id="recordsChart"></canvas>
                </div>
                
                <div class="chart-container">
                    <h3 style="color: #2c3e50; margin-bottom: 1rem;"> Birth Gender Distribution</h3>
                    <canvas id="birthGenderChart"></canvas>
                </div>
                
                <div class="chart-container">
                    <h3 style="color: #2c3e50; margin-bottom: 1rem;"> Death Gender Distribution</h3>
                    <canvas id="deathGenderChart"></canvas>
                </div>
                
                <div class="chart-container">
                    <h3 style="color: #2c3e50; margin-bottom: 1rem;"> Monthly Trends (Current Year)</h3>
                    <canvas id="trendsChart"></canvas>
                </div>
                

            </div>
            
            <div class="wereda-table-container">
                <h2 class="section-title"> Wereda Records Summary</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Wereda</th>
                            <th>Births</th>
                            <th>Deaths</th>
                            <th>Marriages</th>
                            <th>Divorces</th>
                            <th>Immigration</th>
                            <th>Total Records</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn3 = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                                
                                String weredaSql = "SELECT DISTINCT wereda, " +
                                    "(SELECT COUNT(*) FROM birth_records b WHERE b.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as births, " +
                                    "(SELECT COUNT(*) FROM death_records d WHERE d.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as deaths, " +
                                    "(SELECT COUNT(*) FROM marriage_records m WHERE m.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as marriages, " +
                                    "(SELECT COUNT(*) FROM divorce_records dv WHERE dv.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as divorces, " +
                                    "(SELECT COUNT(*) FROM immigration_records i WHERE i.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as immigration " +
                                    "FROM (SELECT DISTINCT wereda FROM birth_records UNION SELECT DISTINCT wereda FROM death_records UNION SELECT DISTINCT wereda FROM marriage_records UNION SELECT DISTINCT wereda FROM divorce_records UNION SELECT DISTINCT wereda FROM immigration_records) t ORDER BY wereda";
                                
                                Statement stmt3 = conn3.createStatement();
                                ResultSet rs3 = stmt3.executeQuery(weredaSql);
                                
                                while (rs3.next()) {
                                    int births = rs3.getInt("births");
                                    int deaths = rs3.getInt("deaths");
                                    int marriages = rs3.getInt("marriages");
                                    int divorces = rs3.getInt("divorces");
                                    int immigration = rs3.getInt("immigration");
                                    int total = births + deaths + marriages + divorces + immigration;
                        %>
                        <tr>
                            <td><%= rs3.getString("wereda") %></td>
                            <td><%= births %></td>
                            <td><%= deaths %></td>
                            <td><%= marriages %></td>
                            <td><%= divorces %></td>
                            <td><%= immigration %></td>
                            <td><strong><%= total %></strong></td>
                        </tr>
                        <%
                                }
                                conn3.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <div class="wereda-table-container">
                <h2 class="section-title"> Kebele Records Summary</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Kebele</th>
                            <th>Woreda</th>
                            <th>Births</th>
                            <th>Deaths</th>
                            <th>Marriages</th>
                            <th>Divorces</th>
                            <th>Immigration</th>
                            <th>Total Records</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/East_Gojjam_VIMS_db", "root", "root");
                                
                                String kebeleSql = "SELECT DISTINCT kebele, wereda, " +
                                    "(SELECT COUNT(*) FROM birth_records b WHERE b.kebele = t.kebele AND b.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as births, " +
                                    "(SELECT COUNT(*) FROM death_records d WHERE d.kebele = t.kebele AND d.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as deaths, " +
                                    "(SELECT COUNT(*) FROM marriage_records m WHERE m.kebele = t.kebele AND m.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as marriages, " +
                                    "(SELECT COUNT(*) FROM divorce_records dv WHERE dv.kebele = t.kebele AND dv.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as divorces, " +
                                    "(SELECT COUNT(*) FROM immigration_records i WHERE i.kebele = t.kebele AND i.wereda = t.wereda" + dateFilter.replace(" WHERE ", " AND ") + ") as immigration " +
                                    "FROM (SELECT DISTINCT kebele, wereda FROM birth_records UNION SELECT DISTINCT kebele, wereda FROM death_records UNION SELECT DISTINCT kebele, wereda FROM marriage_records UNION SELECT DISTINCT kebele, wereda FROM divorce_records UNION SELECT DISTINCT kebele, wereda FROM immigration_records) t ORDER BY wereda, kebele";
                                
                                Statement stmt2 = conn2.createStatement();
                                ResultSet rs2 = stmt2.executeQuery(kebeleSql);
                                
                                while (rs2.next()) {
                                    int births = rs2.getInt("births");
                                    int deaths = rs2.getInt("deaths");
                                    int marriages = rs2.getInt("marriages");
                                    int divorces = rs2.getInt("divorces");
                                    int immigration = rs2.getInt("immigration");
                                    int total = births + deaths + marriages + divorces + immigration;
                        %>
                        <tr>
                            <td><%= rs2.getString("kebele") %></td>
                            <td><%= rs2.getString("wereda") %></td>
                            <td><%= births %></td>
                            <td><%= deaths %></td>
                            <td><%= marriages %></td>
                            <td><%= divorces %></td>
                            <td><%= immigration %></td>
                            <td><strong><%= total %></strong></td>
                        </tr>
                        <%
                                }
                                conn2.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='8'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
    </div>
    
    <script>
        // Records Overview Pie Chart
        const recordsCtx = document.getElementById('recordsChart').getContext('2d');
        new Chart(recordsCtx, {
            type: 'pie',
            data: {
                labels: ['Births', 'Deaths', 'Marriages', 'Divorces', 'Immigration'],
                datasets: [{
                    data: [<%= totalBirths %>, <%= totalDeaths %>, <%= totalMarriages %>, <%= totalDivorces %>, <%= totalImmigration %>],
                    backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF']
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
        
        // Birth Gender Chart
        const birthGenderCtx = document.getElementById('birthGenderChart').getContext('2d');
        new Chart(birthGenderCtx, {
            type: 'doughnut',
            data: {
                labels: ['Male', 'Female'],
                datasets: [{
                    data: [<%= maleBirths %>, <%= femaleBirths %>],
                    backgroundColor: ['#36A2EB', '#FF6384']
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
        
        // Death Gender Chart
        const deathGenderCtx = document.getElementById('deathGenderChart').getContext('2d');
        new Chart(deathGenderCtx, {
            type: 'doughnut',
            data: {
                labels: ['Male', 'Female'],
                datasets: [{
                    data: [<%= maleDeaths %>, <%= femaleDeaths %>],
                    backgroundColor: ['#36A2EB', '#FF6384']
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
        
        // Monthly Trends Bar Chart
        const trendsCtx = document.getElementById('trendsChart').getContext('2d');
        const monthlyChartData = { <%= monthlyData %> };
        new Chart(trendsCtx, {
            type: 'bar',
            data: {
                labels: monthlyChartData.labels,
                datasets: [{
                    label: 'Births',
                    data: monthlyChartData.birthData,
                    backgroundColor: '#FF6384'
                }, {
                    label: 'Deaths',
                    data: monthlyChartData.deathData,
                    backgroundColor: '#36A2EB'
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });
        

        
        // Update reports function
        function updateReports() {
            const period = document.getElementById('periodFilter').value;
            const periodTexts = {
                'all': 'All Time',
                'daily': 'Today',
                'weekly': 'This Week',
                'monthly': 'This Month',
                '3month': 'Last 3 Months',
                '6month': 'Last 6 Months',
                'annual': 'This Year'
            };
            
            document.getElementById('periodText').textContent = periodTexts[period];
            window.location.href = 'reports.jsp?period=' + period;
        }
        
        function updateCustomDate() {
            const customDate = document.getElementById('customDate').value;
            if (customDate) {
                document.getElementById('periodText').textContent = 'Custom Date: ' + customDate;
                window.location.href = 'reports.jsp?customDate=' + customDate;
            }
        }
        
        // Set current period on page load
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const period = urlParams.get('period') || 'all';
            const customDate = urlParams.get('customDate');
            
            if (customDate) {
                document.getElementById('customDate').value = customDate;
                document.getElementById('periodText').textContent = 'Custom Date: ' + customDate;
            } else {
                document.getElementById('periodFilter').value = period;
                const periodTexts = {
                    'all': 'All Time',
                    'daily': 'Today',
                    'weekly': 'This Week', 
                    'monthly': 'This Month',
                    '3month': 'Last 3 Months',
                    '6month': 'Last 6 Months',
                    'annual': 'This Year'
                };
                document.getElementById('periodText').textContent = periodTexts[period];
            }
        });

    </script>
    
    <footer style="background: #2c3e50; color: white; text-align: center; padding: 2rem;">
        <p>&copy; 2025 East Gojjam Zone Administration. All rights reserved.</p>
    </footer>
</body>
</html>