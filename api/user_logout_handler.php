<?php
// api/user_logout_handler.php
// Handles user logout requests.

header('Content-Type: application/json');
require_once '../db_config.php'; // db_config.php also starts the session

// Unset all of the user-specific session variables.
unset($_SESSION["user_loggedin"]);
unset($_SESSION["user_id"]);
unset($_SESSION["user_username"]);
unset($_SESSION["user_email"]);
unset($_SESSION["user_plan_id"]);
unset($_SESSION["user_payment_status"]);

// If you want to destroy the entire session (including admin if logged in simultaneously, which is unlikely for same browser):
// $_SESSION = array();
// if (ini_get("session.use_cookies")) {
//     $params = session_get_cookie_params();
//     setcookie(session_name(), '', time() - 42000,
//         $params["path"], $params["domain"],
//         $params["secure"], $params["httponly"]
//     );
// }
// session_destroy();

echo json_encode(['success' => true, 'message' => 'Logged out successfully.']);
?>
