<?php
session_start();
// admin_dashboard.php
// Main page for the admin panel.

// Include database configuration (which also starts the session)
require_once 'db_config.php';

// Check if the admin is logged in, otherwise redirect to login page
if (!isset($_SESSION["admin_loggedin"]) || $_SESSION["admin_loggedin"] !== true) {
    header("location: admin_login.php");
    exit;
}

// Get admin username for display
$admin_username = htmlspecialchars($_SESSION["admin_username"]);

// Fetch total messages count (FIXED COLUMN NAME)
$messages_count_result = $mysqli->query("SELECT COUNT(message_id) as total_messages FROM messages");
$total_messages = ($messages_count_result && $messages_count_result->num_rows > 0) ? $messages_count_result->fetch_assoc()['total_messages'] : 0;

// Fetch recent messages for display (optional, not used in cards below)
$recent_messages = [];
$recent_messages_result = $mysqli->query("SELECT name, email, subject, message, received_at FROM messages ORDER BY received_at DESC LIMIT 5");
if ($recent_messages_result) {
    while ($row = $recent_messages_result->fetch_assoc()) {
        $recent_messages[] = $row;
    }
    $recent_messages_result->free();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Gym Fitness House</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="style.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .admin-nav-link {
            display: block;
            padding: 0.75rem 1.5rem;
            margin-bottom: 0.5rem;
            border-radius: 0.375rem;
            background-color: #374151; /* bg-gray-700 */
            color: #e5e7eb; /* text-gray-200 */
            transition: background-color 0.3s ease, color 0.3s ease;
        }
        .admin-nav-link:hover {
            background-color: #4b5563; /* bg-gray-600 */
            color: #ffffff;
        }
        .admin-nav-link i {
            margin-right: 0.75rem;
        }
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
            <a href="admin_manage_messages.php" class="admin-nav-link <?php echo (basename($_SERVER['PHP_SELF']) == 'admin_manage_messages.php') ? 'bg-teal-600 text-white' : ''; ?>">
                <i class="fas fa-envelope"></i>Messages
            </a>
            <a href="admin_logout.php" class="admin-nav-link mt-10 bg-red-600 hover:bg-red-700">
                <i class="fas fa-sign-out-alt"></i>Logout
            </a>
        </nav>
    </aside>

    <div class="flex-grow p-8">
        <header class="mb-8 flex justify-between items-center">
            <h1 class="text-3xl font-bold text-teal-400">Admin Dashboard</h1>
            <div class="text-gray-300">
                Welcome, <span class="font-semibold"><?php echo $admin_username; ?></span>!
            </div>
        </header>

        <main>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <div class="bg-gray-800 p-6 rounded-lg shadow-md">
                    <h2 class="text-xl font-semibold text-teal-400 mb-2">Total Registered Users</h2>
                    <?php
                        // Fetch total users count
                        $user_count_result = $mysqli->query("SELECT COUNT(user_id) as total_users FROM users");
                        $total_users = ($user_count_result && $user_count_result->num_rows > 0) ? $user_count_result->fetch_assoc()['total_users'] : 0;
                    ?>
                    <p class="text-3xl font-bold text-white"><?php echo $total_users; ?></p>
                    <a href="admin_manage_users.php" class="mt-3 inline-block text-teal-500 hover:text-teal-300">View Users &rarr;</a>
                </div>

                <div class="bg-gray-800 p-6 rounded-lg shadow-md">
                    <h2 class="text-xl font-semibold text-teal-400 mb-2">Payments Awaiting Approval</h2>
                     <?php
                        // Fetch pending payments count
                        $pending_payments_result = $mysqli->query("SELECT COUNT(payment_id) as pending_payments FROM payments WHERE status = 'pending_approval'");
                        $pending_payments = ($pending_payments_result && $pending_payments_result->num_rows > 0) ? $pending_payments_result->fetch_assoc()['pending_payments'] : 0;
                    ?>
                    <p class="text-3xl font-bold text-white"><?php echo $pending_payments; ?></p>
                    <a href="admin_manage_payments.php?filter=pending_approval" class="mt-3 inline-block text-teal-500 hover:text-teal-300">Review Payments &rarr;</a>
                </div>

                <div class="bg-gray-800 p-6 rounded-lg shadow-md">
                    <h2 class="text-xl font-semibold text-teal-400 mb-2">Membership Plans</h2>
                     <?php
                        $plan_count_result = $mysqli->query("SELECT COUNT(plan_key) as total_plans FROM plans");
                        $total_plans = ($plan_count_result && $plan_count_result->num_rows > 0) ? $plan_count_result->fetch_assoc()['total_plans'] : 0;
                    ?>
                    <p class="text-3xl font-bold text-white"><?php echo $total_plans; ?></p>
                    <a href="admin_manage_plans.php" class="mt-3 inline-block text-teal-500 hover:text-teal-300">Manage Plans &rarr;</a>
                </div>

                <!-- Messages Card -->
                <div class="bg-gray-800 p-6 rounded-lg shadow-md">
                    <h2 class="text-xl font-semibold text-teal-400 mb-2">Messages</h2>
                    <p class="text-3xl font-bold text-white"><?php echo $total_messages; ?></p>
                    <a href="admin_manage_messages.php" class="mt-3 inline-block text-teal-500 hover:text-teal-300">View Messages &rarr;</a>
                </div>
            </div>

            <div class="mt-10 bg-gray-800 p-6 rounded-lg shadow-md">
                <h2 class="text-2xl font-semibold text-teal-400 mb-4">Quick Actions</h2>
                <div class="flex space-x-4">
                    <a href="admin_manage_users.php?action=add" class="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg">
                        <i class="fas fa-user-plus"></i> Add New User
                    </a>
                    <a href="admin_manage_payments.php" class="bg-green-500 hover:bg-green-600 text-white font-semibold py-2 px-4 rounded-lg">
                        <i class="fas fa-tasks"></i> View All Payments
                    </a>
                </div>
            </div>
            
            <div class="mt-10 bg-gray-800 p-6 rounded-lg shadow-md">
                <h3 class="text-xl font-semibold text-gray-300">System Overview</h3>
                <p class="text-gray-400 mt-2">
                    This area can be used to display more detailed statistics, recent activities, or system health information.
                    For example, you could show a chart of new user registrations over time, or a list of the latest payments.
                </p>
            </div>

        </main>
    </div>
    <script>
        // Basic script for copyright year or other minor JS needs for admin panel
        document.querySelectorAll('#current-year-admin').forEach(span => {
            if (span) {
                span.textContent = new Date().getFullYear();
            }
        });
    </script>
</body>
</html>
