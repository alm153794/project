<?php
// api/user_payment_handler.php
// Handles payment submission from the user dashboard (CBE transaction ID only).

header('Content-Type: application/json');
require_once '../db_config.php'; // db_config.php also starts the session

$response = ['success' => false, 'message' => 'An unknown error occurred.'];

// Check if user is logged in
if (!isset($_SESSION["user_loggedin"]) || $_SESSION["user_loggedin"] !== true || !isset($_SESSION["user_id"])) {
    $response['message'] = "User not authenticated. Please log in.";
    echo json_encode($response);
    exit;
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = $_SESSION["user_id"];

    $plan_key = trim($input['plan_key'] ?? '');
    $transaction_id = trim($input['transaction_id'] ?? '');

    // --- Basic Validation ---
    if (empty($plan_key) || empty($transaction_id)) {
        $response['message'] = "Plan and transaction ID are required.";
        echo json_encode($response);
        exit;
    }

    // Validate plan_key against the plans table to get the amount
    $plan_price = 0;
    $sql_get_plan = "SELECT price FROM plans WHERE plan_key = ?";
    if ($stmt_plan = $mysqli->prepare($sql_get_plan)) {
        $stmt_plan->bind_param("s", $plan_key);
        $stmt_plan->execute();
        $result_plan = $stmt_plan->get_result();
        if ($plan_details = $result_plan->fetch_assoc()) {
            $plan_price = $plan_details['price'];
        } else {
            $response['message'] = "Invalid membership plan selected.";
            $stmt_plan->close();
            echo json_encode($response);
            exit;
        }
        $stmt_plan->close();
    } else {
        $response['message'] = "Database error (fetching plan details).";
        error_log("MySQLi Prepare Error (fetch plan): " . $mysqli->error);
        echo json_encode($response);
        exit;
    }

    if ($plan_price <= 0) {
        $response['message'] = "Plan price is invalid. Cannot process payment.";
        echo json_encode($response);
        exit;
    }

    // --- Prevent duplicate transaction IDs for the same user and plan ---
    $sql_check_duplicate = "SELECT payment_id FROM payments WHERE user_id = ? AND plan_key = ? AND transaction_id = ?";
    if ($stmt_check = $mysqli->prepare($sql_check_duplicate)) {
        $stmt_check->bind_param("iss", $user_id, $plan_key, $transaction_id);
        $stmt_check->execute();
        $stmt_check->store_result();
        if ($stmt_check->num_rows > 0) {
            $response['message'] = "You have already submitted this transaction ID for this plan.";
            $stmt_check->close();
            echo json_encode($response);
            exit;
        }
        $stmt_check->close();
    }

    // --- Record Payment in 'payments' table ---
    $payment_status_initial = 'pending_approval'; // Admin needs to approve this

    $sql_insert_payment = "INSERT INTO payments (user_id, plan_key, amount_paid, transaction_id, status) VALUES (?, ?, ?, ?, ?)";
    if ($stmt_payment = $mysqli->prepare($sql_insert_payment)) {
        $stmt_payment->bind_param("isdss", $user_id, $plan_key, $plan_price, $transaction_id, $payment_status_initial);

        if ($stmt_payment->execute()) {
            // --- Update 'users' table ---
            $user_payment_status_update = 'pending_approval';
            $sql_update_user = "UPDATE users SET plan_id = ?, payment_status = ? WHERE user_id = ?";
            if ($stmt_update_user = $mysqli->prepare($sql_update_user)) {
                $stmt_update_user->bind_param("ssi", $plan_key, $user_payment_status_update, $user_id);
                if ($stmt_update_user->execute()) {
                    // Update session variables as well
                    $_SESSION["user_plan_id"] = $plan_key;
                    $_SESSION["user_payment_status"] = $user_payment_status_update;

                    $response['success'] = true;
                    $response['message'] = "Transaction ID submitted successfully! Your payment is now pending admin approval.";
                    $response['user_payment_status'] = $user_payment_status_update;
                } else {
                    $response['message'] = "Payment recorded, but failed to update user profile. Please contact support.";
                    error_log("CRITICAL: User update failed after payment for user_id: $user_id. Payment ID: " . $stmt_payment->insert_id);
                }
                $stmt_update_user->close();
            } else {
                $response['message'] = "Database error (updating user). Payment recorded. Contact support.";
                error_log("MySQLi Prepare Error (update user after payment): " . $mysqli->error . " for user_id: $user_id");
            }
        } else {
            $response['message'] = "Failed to record payment. Please try again.";
            error_log("MySQLi Execute Error (insert payment): " . $stmt_payment->error);
        }
        $stmt_payment->close();
    } else {
        $response['message'] = "Database error (recording payment).";
        error_log("MySQLi Prepare Error (insert payment): " . $mysqli->error);
    }
} else {
    $response['message'] = "Invalid request method.";
}

$mysqli->close();
echo json_encode($response);
?>
