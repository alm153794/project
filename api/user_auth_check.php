<?php
// api/user_auth_check.php
// Checks if a user is currently logged in via session and refreshes key data from DB.

header('Content-Type: application/json');
require_once '../db_config.php'; // db_config.php also starts the session

$response = ['loggedIn' => false];

if (isset($_SESSION["user_loggedin"]) && $_SESSION["user_loggedin"] === true && isset($_SESSION["user_id"])) {
    $user_id = $_SESSION["user_id"];
    // Keep username and email from session for efficiency, assuming they don't change frequently outside of a profile edit page
    $current_username = $_SESSION["user_username"] ?? 'Guest';
    $current_email = $_SESSION["user_email"] ?? '';

    // Fetch the latest plan_id and payment_status from the database for the logged-in user
    $sql_refresh_status = "SELECT plan_id, payment_status FROM users WHERE user_id = ?";
    
    // Default to session values if DB query fails, or if user has no plan/status yet
    $refreshed_plan_id = $_SESSION["user_plan_id"] ?? null; 
    $refreshed_payment_status = $_SESSION["user_payment_status"] ?? 'none';

    if ($stmt_refresh = $mysqli->prepare($sql_refresh_status)) {
        $stmt_refresh->bind_param("i", $user_id);
        if ($stmt_refresh->execute()) {
            $result_refresh = $stmt_refresh->get_result();
            if ($user_status_data = $result_refresh->fetch_assoc()) {
                $refreshed_plan_id = $user_status_data['plan_id'];
                $refreshed_payment_status = $user_status_data['payment_status'];

                // Update session variables with the fresh data from the database
                $_SESSION["user_plan_id"] = $refreshed_plan_id;
                $_SESSION["user_payment_status"] = $refreshed_payment_status;
            }
        } else {
            error_log("Error executing statement in user_auth_check: " . $stmt_refresh->error);
        }
        $stmt_refresh->close();
    } else {
        error_log("Error preparing statement in user_auth_check: " . $mysqli->error);
    }

    // If user has no plan, always return 'none' for plan and paymentCompleted
    $plan_for_js = ($refreshed_plan_id && $refreshed_plan_id !== '' && strtolower($refreshed_plan_id) !== 'none') ? $refreshed_plan_id : null;
    $payment_status_for_js = ($plan_for_js) ? $refreshed_payment_status : 'none';

    $response['loggedIn'] = true;
    $response['user'] = [
        'username' => $current_username,
        'email' => $current_email,
        'plan' => $plan_for_js, // This is the plan_key or null if not set
        // For JS compatibility, return both boolean and string status:
        'paymentCompleted' => ($payment_status_for_js === 'completed') ? 'completed' : (
            ($payment_status_for_js === 'pending_approval') ? 'pending_approval' : (
                ($payment_status_for_js === 'failed') ? 'failed' : (
                    ($payment_status_for_js === 'none' || $payment_status_for_js === null) ? null : $payment_status_for_js
                )
            )
        ),
        'rawPaymentStatus' => $refreshed_payment_status // The actual status string from DB
    ];
}

// $mysqli object is typically closed automatically when the script ends if db_config.php was included.
echo json_encode($response);
?>
