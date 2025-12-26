<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>East Gojjam VIMS - Login</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <script src="assets/js/validation.js"></script>
    <style>
        body { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%); 
            min-height: 100vh; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .login-container { 
            background: rgba(255,255,255,0.95); 
            padding: 3rem; 
            border-radius: 20px; 
            box-shadow: 0 25px 50px rgba(0,0,0,0.2); 
            backdrop-filter: blur(15px); 
            border: 1px solid rgba(255,255,255,0.3);
            max-width: 450px;
            width: 100%;
            text-align: center;
        }
        .login-header h1 { 
            color: #2c3e50; 
            font-size: 2.5rem; 
            margin-bottom: 0.5rem; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .login-header p { 
            color: #7f8c8d; 
            font-size: 1.1rem; 
            margin-bottom: 2rem;
        }
        .form-group { 
            margin-bottom: 1.5rem; 
            text-align: left;
        }
        .form-group label { 
            display: block; 
            color: #2c3e50; 
            font-weight: 600; 
            margin-bottom: 0.5rem;
        }
        .form-group input { 
            width: 100%; 
            padding: 1rem; 
            border: 2px solid #e0e6ed; 
            border-radius: 10px; 
            font-size: 1rem; 
            transition: all 0.3s ease;
            box-sizing: border-box;
        }
        .form-group input:focus { 
            outline: none; 
            border-color: #4facfe; 
            box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.1);
        }
        .login-btn { 
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); 
            color: white; 
            padding: 1rem 2rem; 
            border: none; 
            border-radius: 25px; 
            font-size: 1.1rem; 
            font-weight: bold; 
            cursor: pointer; 
            width: 100%; 
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(79, 172, 254, 0.3);
        }
        .login-btn:hover { 
            background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%); 
            transform: translateY(-3px); 
            box-shadow: 0 15px 35px rgba(79, 172, 254, 0.4);
        }
        .error-message { 
            background: linear-gradient(135deg, #ff6b6b, #ee5a24); 
            color: white; 
            padding: 1rem; 
            border-radius: 10px; 
            margin-bottom: 1.5rem;
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.3);
        }
        .login-footer { 
            margin-top: 2rem; 
            color: #7f8c8d; 
            font-size: 0.9rem;
        }
        .logo { 
            width: 80px; 
            height: 80px; 
            margin: 0 auto 1rem; 
            background: linear-gradient(135deg, #4facfe, #00f2fe); 
            border-radius: 50%; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 2rem; 
            color: white;
        }
    </style>
</head>
<body class="login-body">
    <div class="login-container">
        <div class="login-header">
            <div class="logo">
                <img src="uploads/images/logo.jpg" alt="East Gojjam VIMS Logo" style="width: 80px; height: 80px; border-radius: 50%; object-fit: cover;">
            </div>
            <h1> East Gojjam VIMS</h1>
            <p>Vital Information Management System</p>
        </div>
        
        <form action="login" method="post" class="login-form">
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <button type="submit" class="login-btn">Login</button>
        </form>
        
        <div class="login-footer">
            <p>&copy; 2025 East Gojjam Zone Administration</p>
        </div>
    </div>
</body>
</html>