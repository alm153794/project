<?php
// api/user_login_handler.php
// Handles user login requests from the frontend.

header('Content-Type: application/json');
require_once '../db_config.php'; // db_config.php also starts the session

$response = ['success' => false, 'message' => 'An unknown error occurred.'];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $input = json_decode(file_get_contents('php://input'), true);

    $email = trim($input['email'] ?? '');
    $password = $input['password'] ?? '';

    if (empty($email) || empty($password)) {
        $response['message'] = "Email and password are required.";
        echo json_encode($response);
        exit;
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $response['message'] = "Invalid email format.";
        echo json_encode($response);
        exit;
    }

    $sql = "SELECT user_id, username, email, password_hash, plan_id, payment_status FROM users WHERE email = ?";
    if ($stmt = $mysqli->prepare($sql)) {
        $stmt->bind_param("s", $email);
        if ($stmt->execute()) {
            $result = $stmt->get_result();
            if ($user = $result->fetch_assoc()) {
                if (password_verify($password, $user['password_hash'])) {
                    // Password is correct, set session variables for the user
                    $_SESSION["user_loggedin"] = true;
                    $_SESSION["user_id"] = $user['user_id'];
                    $_SESSION["user_username"] = $user['username'];
                    $_SESSION["user_email"] = $user['email'];
                    $_SESSION["user_plan_id"] = $user['plan_id'];
                    $_SESSION["user_payment_status"] = $user['payment_status'];

                    // Update last_login timestamp
                    $update_login_sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = ?";
                    if($stmt_update = $mysqli->prepare($update_login_sql)){
                        $stmt_update->bind_param('i', $user['user_id']);
                        $stmt_update->execute();
                        $stmt_update->close();
                    }

                    $response['success'] = true;
                    $response['message'] = "Login successful!";
                    $response['user'] = [
                        'username' => $user['username'],
                        'email' => $user['email'],
                        'plan' => $user['plan_id'],
                        'paymentCompleted' => ($user['payment_status'] === 'completed') // Simplified for script.js
                    ];
                } else {
                    $response['message'] = "Invalid email or password.";
                }
            } else {
                $response['message'] = "Invalid email or password.";
            }
        } else {
            $response['message'] = "Database error (execute).";
            error_log("MySQLi Execute Error (user login): " . $stmt->error);
        }
        $stmt->close();
    } else {
        $response['message'] = "Database error (prepare).";
        error_log("MySQLi Prepare Error (user login): " . $mysqli->error);
    }
} else {
    $response['message'] = "Invalid request method.";
}

$mysqli->close();
echo json_encode($response);
?>
