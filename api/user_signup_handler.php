<?php
// api/user_signup_handler.php
// Handles user registration requests from the frontend.

header('Content-Type: application/json'); // Set content type to JSON for responses
require_once '../db_config.php'; // Adjust path if db_config.php is in a different directory

$response = ['success' => false, 'message' => 'An unknown error occurred.'];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get data from the request body (assuming JSON input from fetch)
    $input = json_decode(file_get_contents('php://input'), true);

    $username = trim($input['username'] ?? '');
    $email = trim($input['email'] ?? '');
    $password = $input['password'] ?? '';
    $plan_key = trim($input['plan'] ?? ''); // 'basic', 'pro', 'elite', or empty string

    // --- Validation ---
    if (empty($username) || empty($email) || empty($password)) {
        $response['message'] = "Username, email, and password are required.";
        echo json_encode($response);
        exit;
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $response['message'] = "Invalid email format.";
        echo json_encode($response);
        exit;
    }
    if (strlen($password) < 6) {
        $response['message'] = "Password must be at least 6 characters long.";
        echo json_encode($response);
        exit;
    }

    // Check if email already exists
    $sql_check_email = "SELECT user_id FROM users WHERE email = ?";
    if ($stmt_check = $mysqli->prepare($sql_check_email)) {
        $stmt_check->bind_param("s", $email);
        $stmt_check->execute();
        $stmt_check->store_result();
        if ($stmt_check->num_rows > 0) {
            $response['message'] = "An account with this email already exists.";
            $stmt_check->close();
            echo json_encode($response);
            exit;
        }
        $stmt_check->close();
    } else {
        $response['message'] = "Database error (email check).";
        error_log("MySQLi Prepare Error (email check): " . $mysqli->error); // Log error
        echo json_encode($response);
        exit;
    }

    // Hash the password
    $password_hash = password_hash($password, PASSWORD_DEFAULT);

    // Prepare SQL to insert user
    // Always set initial payment_status to 'none' on registration
    $initial_payment_status = 'none';

    $sql_insert_user = "INSERT INTO users (username, email, password_hash, plan_id, payment_status) VALUES (?, ?, ?, ?, ?)";
    if ($stmt_insert = $mysqli->prepare($sql_insert_user)) {
        $stmt_insert->bind_param("sssss", $username, $email, $password_hash, $plan_key, $initial_payment_status);
        
        if ($stmt_insert->execute()) {
            $response['success'] = true;
            $response['message'] = "Signup successful! You can now log in.";
        } else {
            $response['message'] = "Signup failed. Please try again.";
            error_log("MySQLi Execute Error (user insert): " . $stmt_insert->error); // Log error
        }
        $stmt_insert->close();
    } else {
        $response['message'] = "Database error (user insert).";
        error_log("MySQLi Prepare Error (user insert): " . $mysqli->error); // Log error
    }
} else {
    $response['message'] = "Invalid request method.";
}

$mysqli->close();
echo json_encode($response);
?>
