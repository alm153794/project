<?php
session_start();
// admin_manage_payments.php
// Page for admins to manage user payments.

require_once 'db_config.php'; // Includes session_start() and $mysqli connection

// Check if the admin is logged in, otherwise redirect to login page
if (!isset($_SESSION["admin_loggedin"]) || $_SESSION["admin_loggedin"] !== true) {
    header("location: admin_login.php");
    exit;
}

$admin_username = htmlspecialchars($_SESSION["admin_username"]);
$feedback_message = ''; // For success or error messages
$feedback_type = '';    // 'success' or 'error' or 'warning'

// --- Handle Actions (Approve, Reject/Fail Payment) ---
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['action']) && isset($_POST['payment_id'])) {
    $payment_id_action = intval($_POST['payment_id']);
    $action = $_POST['action'];
    $user_id_for_update = null; // Will be fetched if needed

    // Fetch user_id associated with this payment for updating user's status
    $sql_get_user_id = "SELECT user_id FROM payments WHERE payment_id = ?";
    if($stmt_get_uid = $mysqli->prepare($sql_get_user_id)){
        $stmt_get_uid->bind_param("i", $payment_id_action);
        $stmt_get_uid->execute();
        $result_uid = $stmt_get_uid->get_result();
        if($row_uid = $result_uid->fetch_assoc()){
            $user_id_for_update = $row_uid['user_id'];
        }
        $stmt_get_uid->close();
    }

    if ($action == 'approve_payment') {
        $new_payment_status = 'approved';
        $new_user_payment_status = 'completed';
    } elseif ($action == 'reject_payment') {
        $new_payment_status = 'failed'; // Or 'rejected' if you add that to ENUM
        $new_user_payment_status = 'failed';
    } else {
        $new_payment_status = null; // Invalid action
    }

    if ($new_payment_status && $user_id_for_update) {
        $mysqli->begin_transaction(); // Start transaction

        try {
            // Update payments table
            $sql_update_payment = "UPDATE payments SET status = ? WHERE payment_id = ?";
            $stmt_update_payment = $mysqli->prepare($sql_update_payment);
            $stmt_update_payment->bind_param("si", $new_payment_status, $payment_id_action);
            $stmt_update_payment->execute();

            // Update users table
            $sql_update_user = "UPDATE users SET payment_status = ? WHERE user_id = ?";
            $stmt_update_user = $mysqli->prepare($sql_update_user);
            $stmt_update_user->bind_param("si", $new_user_payment_status, $user_id_for_update);
            $stmt_update_user->execute();
            
            $mysqli->commit(); // Commit transaction
            $feedback_message = "Payment status updated successfully to '" . htmlspecialchars($new_payment_status) . "'.";
            $feedback_type = 'success';

        } catch (mysqli_sql_exception $exception) {
            $mysqli->rollback(); // Rollback on error
            $feedback_message = "Error updating payment status: " . $exception->getMessage();
            $feedback_type = 'error';
        } finally {
            if (isset($stmt_update_payment)) $stmt_update_payment->close();
            if (isset($stmt_update_user)) $stmt_update_user->close();
        }
    } elseif (!$user_id_for_update) {
        $feedback_message = "Could not find user associated with the payment.";
        $feedback_type = 'error';
    } else {
        $feedback_message = "Invalid action specified.";
        $feedback_type = 'error';
    }
}


// --- Fetch Data for Display ---
$payments = [];
$current_filter = isset($_GET['filter']) ? trim($_GET['filter']) : 'all'; // Default to 'all' or specific filter

$sql_fetch_payments = "SELECT p.payment_id, p.user_id, u.username AS user_username, u.email AS user_email, 
                              p.plan_key, pl.plan_name, p.amount_paid, p.payment_date, p.transaction_id, p.status
                       FROM payments p
                       JOIN users u ON p.user_id = u.user_id
                       LEFT JOIN plans pl ON p.plan_key = pl.plan_key";

$where_clauses = [];
$bind_params_types = "";
$bind_params_values = [];

if ($current_filter != 'all') {
    $where_clauses[] = "p.status = ?";
    $bind_params_types .= "s";
    $bind_params_values[] = $current_filter;
}

if (!empty($where_clauses)) {
    $sql_fetch_payments .= " WHERE " . implode(" AND ", $where_clauses);
}
$sql_fetch_payments .= " ORDER BY p.payment_date DESC";

if ($stmt_fetch = $mysqli->prepare($sql_fetch_payments)) {
    if (!empty($bind_params_values)) {
        $stmt_fetch->bind_param($bind_params_types, ...$bind_params_values);
    }
    if ($stmt_fetch->execute()) {
        $result = $stmt_fetch->get_result();
        while ($row = $result->fetch_assoc()) {
            $payments[] = $row;
        }
        $result->free();
    } else {
        $feedback_message = "Error fetching payments: " . $stmt_fetch->error;
        $feedback_type = 'error';
    }
    $stmt_fetch->close();
} else {
     $feedback_message = "Database error (prepare fetch payments): " . $mysqli->error;
     $feedback_type = 'error';
}

$payment_status_options = ['all', 'pending_approval', 'approved', 'failed']; // For filter dropdown

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Payments - Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="style.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .admin-nav-link { display: block; padding: 0.75rem 1.5rem; margin-bottom: 0.5rem; border-radius: 0.375rem; background-color: #374151; color: #e5e7eb; transition: background-color 0.3s ease, color 0.3s ease; }
        .admin-nav-link:hover { background-color: #4b5563; color: #ffffff; }
        .admin-nav-link i { margin-right: 0.75rem; }
        .table-action-btn { padding: 0.3rem 0.6rem; font-size: 0.8rem; margin-right: 0.3rem; border-radius: 0.25rem; }
        .feedback-success { background-color: #10B981; color: white; padding: 0.75rem; border-radius: 0.375rem; margin-bottom: 1rem; }
        .feedback-error { background-color: #EF4444; color: white; padding: 0.75rem; border-radius: 0.375rem; margin-bottom: 1rem; }
        .feedback-warning { background-color: #F59E0B; color: white; padding: 0.75rem; border-radius: 0.375rem; margin-bottom: 1rem; }
    </style>
</head>
<body class="bg-gray-900 text-gray-100 flex min-h-screen">

    <aside class="w-64 bg-gray-800 p-6 shadow-lg flex-shrink-0">
        <div class="text-2xl font-bold text-teal-400 mb-8">Admin<span class="text-white">Panel</span></div>
        <nav>
            <a href="admin_dashboard.php" class="admin-nav-link <?php echo (basename($_SERVER['PHP_SELF']) == 'admin_dashboard.php') ? 'bg-teal-600 text-white' : ''; ?>">
                <i class="fas fa-tachometer-alt"></i>Dashboard
            </a>
            <a href="admin_manage_users.php" class="admin-nav-link <?php echo (basename($_SERVER['PHP_SELF']) == 'admin_manage_users.php') ? 'bg-teal-600 text-white' : ''; ?>">
                <i class="fas fa-users"></i>Manage Users
            </a>
            <a href="admin_manage_payments.php" class="admin-nav-link <?php echo (basename($_SERVER['PHP_SELF']) == 'admin_manage_payments.php') ? 'bg-teal-600 text-white' : ''; ?>">
                <i class="fas fa-credit-card"></i>Manage Payments
            </a>
            <a href="admin_manage_plans.php" class="admin-nav-link <?php echo (basename($_SERVER['PHP_SELF']) == 'admin_manage_plans.php') ? 'bg-teal-600 text-white' : ''; ?>">
                <i class="fas fa-clipboard-list"></i>Manage Plans
            </a>
            <a href="admin_logout.php" class="admin-nav-link mt-10 bg-red-600 hover:bg-red-700">
                <i class="fas fa-sign-out-alt"></i>Logout
            </a>
        </nav>
    </aside>

    <div class="flex-grow p-8">
        <header class="mb-8 flex justify-between items-center">
            <h1 class="text-3xl font-bold text-teal-400">Manage Payments</h1>
            <div class="text-gray-300">Welcome, <span class="font-semibold"><?php echo $admin_username; ?></span>!</div>
        </header>

        <?php if (!empty($feedback_message)): ?>
            <div class="feedback-<?php echo htmlspecialchars($feedback_type); ?>">
                <?php echo htmlspecialchars($feedback_message); ?>
            </div>
        <?php endif; ?>

        <div class="mb-6 bg-gray-800 p-4 rounded-lg shadow-md">
            <form action="admin_manage_payments.php" method="GET" class="flex items-center space-x-4">
                <div>
                    <label for="filter" class="text-sm font-medium text-gray-300 mr-2">Filter by Status:</label>
                    <select name="filter" id="filter" class="p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                        <?php foreach ($payment_status_options as $status_option): ?>
                            <option value="<?php echo htmlspecialchars($status_option); ?>" <?php echo ($current_filter == $status_option) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $status_option))); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg">
                    <i class="fas fa-filter"></i> Filter
                </button>
            </form>
        </div>

        <div class="bg-gray-800 p-6 rounded-lg shadow-md overflow-x-auto">
            <h2 class="text-xl font-semibold text-teal-400 mb-4">Payments List (<?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $current_filter))); ?>)</h2>
            <?php if (empty($payments) && !($feedback_type == 'error' && strpos($feedback_message, "fetching payments") !== false)): ?>
                <p class="text-gray-400">No payments found matching the current filter.</p>
            <?php elseif (!empty($payments)): ?>
            <table class="min-w-full divide-y divide-gray-700">
                <thead class="bg-gray-700">
                    <tr>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Pay ID</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">User (ID, Name, Email)</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Plan</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Amount</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Date</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Transaction ID</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Status</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-gray-800 divide-y divide-gray-700">
                    <?php foreach ($payments as $payment): ?>
                    <tr>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300"><?php echo htmlspecialchars($payment['payment_id']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300">
                            ID: <?php echo htmlspecialchars($payment['user_id']); ?><br>
                            <?php echo htmlspecialchars($payment['user_username']); ?><br>
                            <span class="text-xs text-gray-400"><?php echo htmlspecialchars($payment['user_email']); ?></span>
                        </td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300"><?php echo htmlspecialchars($payment['plan_name'] ?? $payment['plan_key']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300">$<?php echo htmlspecialchars(number_format($payment['amount_paid'], 2)); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-400"><?php echo htmlspecialchars(date("M d, Y H:i", strtotime($payment['payment_date']))); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-400"><?php echo htmlspecialchars($payment['transaction_id']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                <?php 
                                    switch ($payment['status']) {
                                        case 'approved': echo 'bg-green-700 text-green-100'; break;
                                        case 'pending_approval': echo 'bg-yellow-600 text-yellow-100'; break;
                                        case 'failed': echo 'bg-red-700 text-red-100'; break;
                                        default: echo 'bg-gray-600 text-gray-100'; break;
                                    }
                                ?>">
                                <?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $payment['status']))); ?>
                            </span>
                        </td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm font-medium">
                            <?php if ($payment['status'] == 'pending_approval'): ?>
                                <form action="admin_manage_payments.php?filter=<?php echo htmlspecialchars($current_filter); ?>" method="POST" class="inline-block">
                                    <input type="hidden" name="payment_id" value="<?php echo $payment['payment_id']; ?>">
                                    <input type="hidden" name="action" value="approve_payment">
                                    <button type="submit" class="table-action-btn bg-green-500 hover:bg-green-600 text-white" title="Approve Payment"><i class="fas fa-check"></i> Approve</button>
                                </form>
                                <form action="admin_manage_payments.php?filter=<?php echo htmlspecialchars($current_filter); ?>" method="POST" class="inline-block mt-1 sm:mt-0">
                                    <input type="hidden" name="payment_id" value="<?php echo $payment['payment_id']; ?>">
                                    <input type="hidden" name="action" value="reject_payment">
                                    <button type="submit" class="table-action-btn bg-red-500 hover:bg-red-600 text-white" title="Reject Payment"><i class="fas fa-times"></i> Reject</button>
                                </form>
                            <?php else: ?>
                                <span class="text-gray-500 text-xs">No actions</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>
