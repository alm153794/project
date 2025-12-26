<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    .main-header { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; padding: 1.5rem 2rem; box-shadow: 0 4px 20px rgba(79, 172, 254, 0.3); }
    .header-content { display: flex; justify-content: space-between; align-items: center; max-width: 1200px; margin: 0 auto; }
    .logo-section { display: flex; align-items: center; gap: 1rem; }
    .header-logo { width: 50px; height: 50px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
    .header-text h1 { margin: 0; font-size: 1.8rem; text-shadow: 2px 2px 4px rgba(0,0,0,0.2); }
    .header-text p { margin: 0; opacity: 0.9; font-size: 0.9rem; }
    .user-section { display: flex; align-items: center; gap: 1rem; }
    .user-section span { font-weight: 600; }
    .logout-btn { background: rgba(255,255,255,0.2); color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 25px; transition: all 0.3s ease; }
    .logout-btn:hover { background: rgba(255,255,255,0.3); transform: translateY(-2px); }
    .language-switcher { display: flex; gap: 0.5rem; margin-right: 1rem; }
    .lang-btn { background: rgba(255,255,255,0.2); color: white; padding: 0.3rem 0.6rem; text-decoration: none; border-radius: 15px; font-size: 0.8rem; transition: all 0.3s ease; }
    .lang-btn:hover, .lang-btn.active { background: rgba(255,255,255,0.4); }
</style>
<header class="main-header">
    <div class="header-content">
        <div class="logo-section">
            <div class="header-logo">
                <img src="uploads/images/logo.jpg" alt="East Gojjam VIMS Logo" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover;">
            </div>
            <div class="header-text">
                <h1>East Gojjam VIMS</h1>
                <p>Vital Information Management System</p>
            </div>
        </div>
        
        <div class="user-section">
            <span>Welcome, <%= session.getAttribute("fullName") %></span>
            <% if (!"admin".equals(session.getAttribute("role"))) { %>
                <a href="feedback.jsp" style="background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 25px; margin-right: 1rem;"> Feedback</a>
            <% } %>
            <a href="login?logout=true" class="logout-btn"> Logout</a>
        </div>
    </div>
</header>