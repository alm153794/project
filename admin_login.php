<?php
// admin_login.php
// This script handles admin login.

// Include database configuration
require_once 'db_config.php';

// Initialize variables to store messages
$login_error = '';

// Check if the form has been submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get username and password from the form
    // It's important to sanitize inputs, though for this example, we'll keep it simple.
    // In a real application, use filter_input or prepared statements thoroughly.
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if (empty($username) || empty($password)) {
        $login_error = "Username and password are required.";
    } else {
        // Prepare SQL statement to prevent SQL injection
        $sql = "SELECT admin_id, username, password_hash FROM admins WHERE username = ?";
        
        if ($stmt = $mysqli->prepare($sql)) {
            // Bind variables to the prepared statement as parameters
            $stmt->bind_param("s", $param_username);
            
            // Set parameters
            $param_username = $username;
            
            // Attempt to execute the prepared statement
            if ($stmt->execute()) {
                // Store result
                $stmt->store_result();
                
                // Check if username exists, if yes then verify password
                if ($stmt->num_rows == 1) {                    
                    // Bind result variables
                    $stmt->bind_result($admin_id, $db_username, $hashed_password);
                    if ($stmt->fetch()) {
                        // Verify the password
                        if (password_verify($password, $hashed_password)) {
                            // Password is correct, so start a new session
                            // session_start(); // Already started in db_config.php
                            
                            // Store data in session variables
                            $_SESSION["admin_loggedin"] = true;
                            $_SESSION["admin_id"] = $admin_id;
                            $_SESSION["admin_username"] = $db_username;                            
                            
                            // Redirect admin to dashboard page
                            header("location: admin_dashboard.php");
                            exit; // Ensure no further code is executed after redirect
                        } else {
                            // Password is not valid
                            $login_error = "Invalid username or password.";
                        }
                    }
                } else {
                    // Username doesn't exist
                    $login_error = "Invalid username or password.";
                }
            } else {
                $login_error = "Oops! Something went wrong. Please try again later.";
            }

            // Close statement
            $stmt->close();
        } else {
            $login_error = "Database query failed. Please try again later.";
        }
    }
    
    // Close connection (optional here, as it's usually closed at the end of script execution)
    // $mysqli->close(); // Can be omitted if db_config.php is included in subsequent pages
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Gym Fitness House</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css"> <style>
        body { font-family: 'Inter', sans-serif; }
        .cta-button { transition: all 0.3s ease; }
        .cta-button:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05); }
    </style>
</head>
<body class="bg-gray-900 text-gray-100 flex flex-col min-h-screen">
    <nav class="bg-gray-800/80 backdrop-blur-md shadow-lg fixed w-full z-50 top-0">
        <div class="container mx-auto px-6 py-3 flex justify-between items-center">
            <a href="index.html" class="text-2xl font-bold text-teal-400">Gym<span class="text-white">Fitness</span>House - Admin</a>
        </div>
    </nav>

    <main class="flex-grow flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8 pt-32">
        <div class="max-w-md w-full space-y-8 bg-gray-800 p-10 rounded-xl shadow-2xl">
            <div>
                <h2 class="mt-6 text-center text-3xl font-extrabold text-white">
                    Admin Panel Login
                </h2>
            </div>
            <?php 
            if(!empty($login_error)){
                echo '<div class="p-3 rounded-md bg-red-700 text-red-100 text-center">' . htmlspecialchars($login_error) . '</div>';
            }
            ?>
            <form id="admin-login-form" class="mt-8 space-y-6" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
                <div class="rounded-md shadow-sm -space-y-px">
                    <div>
                        <label for="username" class="sr-only">Username</label>
                        <input id="username" name="username" type="text" autocomplete="username" required
                               class="appearance-none rounded-none relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-gray-200 placeholder-gray-400 rounded-t-md focus:outline-none focus:ring-teal-500 focus:border-teal-500 focus:z-10 sm:text-sm"
                               placeholder="Admin Username">
                    </div>
                    <div>
                        <label for="password" class="sr-only">Password</label>
                        <input id="password" name="password" type="password" autocomplete="current-password"
                               required
                               class="appearance-none rounded-none relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-gray-200 placeholder-gray-400 rounded-b-md focus:outline-none focus:ring-teal-500 focus:border-teal-500 focus:z-10 sm:text-sm"
                               placeholder="Password">
                    </div>
                </div>

                <div>
                    <button type="submit"
                            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-teal-600 hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-teal-500 cta-button">
                        Sign in
                    </button>
                </div>
            </form>
        </div>
    </main>

    <footer class="bg-gray-900 border-t border-gray-700 py-12 mt-auto">
        <div class="container mx-auto px-6 text-center text-gray-400">
            <p class="text-sm">&copy; <span id="current-year"><?php echo date("Y"); ?></span> Gym Fitness House. Admin Panel.</p>
        </div>
    </footer>
</body>
</html>
