<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Feedback - East Gojjam VIMS</title>
    <link rel="stylesheet" type="text/css" href="assets/css/global.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            min-height: 100vh;
            margin: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .feedback-container {
            max-width: 700px;
            margin: 50px auto;
            padding: 3rem;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .feedback-header {
            text-align: center;
            margin-bottom: 2.5rem;
        }
        .feedback-title {
            font-size: 2.5rem;
            color: #2c3e50;
            margin-bottom: 0.5rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }
        .feedback-subtitle {
            color: #666;
            font-size: 1.1rem;
            opacity: 0.8;
        }
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            text-align: center;
            font-weight: 600;
            animation: slideIn 0.5s ease-out;
        }
        .alert-success {
            background: linear-gradient(135deg, #d4edda, #c3e6cb);
            color: #155724;
            border: 2px solid #28a745;
        }
        .alert-error {
            background: linear-gradient(135deg, #f8d7da, #f5c6cb);
            color: #721c24;
            border: 2px solid #dc3545;
        }
        .form-group {
            margin-bottom: 1.5rem;
        }
        .form-label {
            display: block;
            margin-bottom: 0.7rem;
            font-weight: 700;
            color: #2c3e50;
            font-size: 1rem;
        }
        .form-input, .form-textarea {
            width: 100%;
            padding: 1rem;
            border: 2px solid #e0e6ed;
            border-radius: 12px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.9);
            box-sizing: border-box;
        }
        .form-input:focus, .form-textarea:focus {
            outline: none;
            border-color: #4facfe;
            box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.2);
            transform: translateY(-2px);
        }
        .form-textarea {
            min-height: 120px;
            resize: vertical;
        }
        .button-group {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }
        .btn {
            padding: 1rem 2rem;
            border: none;
            border-radius: 25px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
        }
        .btn-primary {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4);
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #20c997, #17a2b8);
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(40, 167, 69, 0.6);
        }
        .btn-secondary {
            background: linear-gradient(135deg, #6c757d, #495057);
            color: white;
            box-shadow: 0 4px 15px rgba(108, 117, 125, 0.4);
        }
        .btn-secondary:hover {
            background: linear-gradient(135deg, #495057, #343a40);
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(108, 117, 125, 0.6);
        }
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        .feedback-container {
            animation: fadeIn 0.6s ease-out;
        }
        @media (max-width: 768px) {
            .feedback-container {
                margin: 20px;
                padding: 2rem;
            }
            .button-group {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="feedback-container">
        <div class="feedback-header">
            <h1 class="feedback-title"> Send Feedback</h1>
            <p class="feedback-subtitle">We value your feedback! Please share your thoughts about the East Gojjam VIMS system.</p>
        </div>
        
        <% if ("true".equals(request.getParameter("success"))) { %>
            <div class="alert alert-success">
                ✅ Feedback submitted successfully! Thank you for your valuable input.
            </div>
        <% } %>
        
        <% if ("true".equals(request.getParameter("error"))) { %>
            <div class="alert alert-error">
                ❌ Error submitting feedback. Please try again.
            </div>
        <% } %>
        
        <form action="feedback-handler.jsp" method="post">
            <div class="form-group">
                <label class="form-label"> Your Name</label>
                <input type="text" name="name" class="form-input" placeholder="Enter your full name" required>
            </div>
            
            <div class="form-group">
                <label class="form-label"> Email Address</label>
                <input type="email" name="email" class="form-input" placeholder="Enter your email address" required>
            </div>
            
            <div class="form-group">
                <label class="form-label"> Subject</label>
                <input type="text" name="subject" class="form-input" placeholder="Brief description of your feedback" required>
            </div>
            
            <div class="form-group">
                <label class="form-label"> Your Message</label>
                <textarea name="message" class="form-textarea" placeholder="Please share your detailed feedback, suggestions, or report any issues you've encountered..." required></textarea>
            </div>
            
            <div class="button-group">
                <button type="submit" class="btn btn-primary"> Send Feedback</button>
                <a href="index.jsp" class="btn btn-secondary"> Back to Home</a>
            </div>
        </form>
    </div>
</body>
</html>