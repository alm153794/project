<?php
session_start();
// admin_manage_users.php
// Page for admins to manage registered users.

require_once 'db_config.php'; // Includes session_start() and $mysqli connection

// Check if the admin is logged in, otherwise redirect to login page
if (!isset($_SESSION["admin_loggedin"]) || $_SESSION["admin_loggedin"] !== true) {
    header("location: admin_login.php");
    exit;
}

$admin_username = htmlspecialchars($_SESSION["admin_username"]);
$feedback_message = ''; // For success or error messages
$feedback_type = ''; // 'success' or 'error'

// --- Handle Actions (Add, Edit, Delete) ---

// Handle ADD USER action
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['action']) && $_POST['action'] == 'add_user') {
    $new_username = trim($_POST['username']);
    $new_email = trim($_POST['email']);
    $new_password = $_POST['password'];
    $new_plan_id = !empty($_POST['plan_id']) ? trim($_POST['plan_id']) : null; // Can be null
    $new_payment_status = trim($_POST['payment_status']);

    // Validate inputs
    if (empty($new_username) || empty($new_email) || empty($new_password) || empty($new_payment_status)) {
        $feedback_message = "All fields (Username, Email, Password, Payment Status) are required to add a user.";
        $feedback_type = 'error';
    } elseif (!filter_var($new_email, FILTER_VALIDATE_EMAIL)) {
        $feedback_message = "Invalid email format.";
        $feedback_type = 'error';
    } elseif (strlen($new_password) < 6) {
        $feedback_message = "Password must be at least 6 characters long.";
        $feedback_type = 'error';
    } else {
        // Check if email already exists
        $sql_check_email = "SELECT user_id FROM users WHERE email = ?";
        if ($stmt_check = $mysqli->prepare($sql_check_email)) {
            $stmt_check->bind_param("s", $new_email);
            $stmt_check->execute();
            $stmt_check->store_result();
            if ($stmt_check->num_rows > 0) {
                $feedback_message = "User with this email already exists.";
                $feedback_type = 'error';
            } else {
                // Email is unique, proceed to insert
                $password_hash = password_hash($new_password, PASSWORD_DEFAULT);
                $sql_insert = "INSERT INTO users (username, email, password_hash, plan_id, payment_status) VALUES (?, ?, ?, ?, ?)";
                if ($stmt_insert = $mysqli->prepare($sql_insert)) {
                    $stmt_insert->bind_param("sssss", $new_username, $new_email, $password_hash, $new_plan_id, $new_payment_status);
                    if ($stmt_insert->execute()) {
                        $feedback_message = "User added successfully!";
                        $feedback_type = 'success';
                    } else {
                        $feedback_message = "Error adding user: " . $stmt_insert->error;
                        $feedback_type = 'error';
                    }
                    $stmt_insert->close();
                } else {
                    $feedback_message = "Database error (prepare insert): " . $mysqli->error;
                    $feedback_type = 'error';
                }
            }
            $stmt_check->close();
        } else {
            $feedback_message = "Database error (prepare check email): " . $mysqli->error;
            $feedback_type = 'error';
        }
    }
}

// Handle DELETE USER action (via GET for simplicity, POST with CSRF is better)
if (isset($_GET['action']) && $_GET['action'] == 'delete_user' && isset($_GET['user_id'])) {
    $user_id_to_delete = intval($_GET['user_id']);
    // It's good to have a confirmation step in a real app.
    // Also, consider what happens to related data (e.g., payments). Cascade delete is set for payments.

    $sql_delete = "DELETE FROM users WHERE user_id = ?";
    if ($stmt_delete = $mysqli->prepare($sql_delete)) {
        $stmt_delete->bind_param("i", $user_id_to_delete);
        if ($stmt_delete->execute()) {
            if ($stmt_delete->affected_rows > 0) {
                $feedback_message = "User deleted successfully!";
                $feedback_type = 'success';
            } else {
                $feedback_message = "User not found or already deleted.";
                $feedback_type = 'warning';
            }
        } else {
            $feedback_message = "Error deleting user: " . $stmt_delete->error;
            $feedback_type = 'error';
        }
        $stmt_delete->close();
    } else {
        $feedback_message = "Database error (prepare delete): " . $mysqli->error;
        $feedback_type = 'error';
    }
    // Redirect to clean URL after action
    // header("Location: admin_manage_users.php"); // This can cause issues if feedback message needs to be shown
    // exit;
}


// --- Fetch Data for Display ---
$users = [];
$sql_fetch_users = "SELECT u.user_id, u.username, u.email, u.plan_id, p.plan_name, u.payment_status, u.registration_date, u.last_login 
                    FROM users u
                    LEFT JOIN plans p ON u.plan_id = p.plan_key
                    ORDER BY u.registration_date DESC";
if ($result = $mysqli->query($sql_fetch_users)) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
    $result->free();
} else {
    $feedback_message = "Error fetching users: " . $mysqli->error;
    $feedback_type = 'error';
}

// Fetch plans for dropdowns
$plans = [];
$sql_fetch_plans = "SELECT plan_key, plan_name, price FROM plans ORDER BY plan_name ASC";
if ($result_plans = $mysqli->query($sql_fetch_plans)) {
    while ($row_plan = $result_plans->fetch_assoc()) {
        $plans[] = $row_plan;
    }
    $result_plans->free();
}

$payment_statuses = ['none', 'pending', 'pending_approval', 'completed', 'failed']; // Available payment statuses

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="style.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .admin-nav-link { display: block; padding: 0.75rem 1.5rem; margin-bottom: 0.5rem; border-radius: 0.375rem; background-color: #374151; color: #e5e7eb; transition: background-color 0.3s ease, color 0.3s ease; }
        .admin-nav-link:hover { background-color: #4b5563; color: #ffffff; }
        .admin-nav-link i { margin-right: 0.75rem; }
        .table-action-btn { padding: 0.3rem 0.6rem; font-size: 0.8rem; margin-right: 0.3rem; }
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
            <h1 class="text-3xl font-bold text-teal-400">Manage Users</h1>
            <div class="text-gray-300">Welcome, <span class="font-semibold"><?php echo $admin_username; ?></span>!</div>
        </header>

        <?php if (!empty($feedback_message)): ?>
            <div class="feedback-<?php echo htmlspecialchars($feedback_type); ?>">
                <?php echo htmlspecialchars($feedback_message); ?>
            </div>
        <?php endif; ?>

        <div class="mb-8 bg-gray-800 p-6 rounded-lg shadow-md">
            <h2 class="text-xl font-semibold text-teal-400 mb-4">Add New User</h2>
            <form action="admin_manage_users.php" method="POST">
                <input type="hidden" name="action" value="add_user">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                        <label for="username" class="block text-sm font-medium text-gray-300 mb-1">Username</label>
                        <input type="text" name="username" id="username" required class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                    </div>
                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-300 mb-1">Email</label>
                        <input type="email" name="email" id="email" required class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                    </div>
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-300 mb-1">Password</label>
                        <input type="password" name="password" id="password" required class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500" placeholder="Min. 6 characters">
                    </div>
                    <div>
                        <label for="plan_id" class="block text-sm font-medium text-gray-300 mb-1">Membership Plan</label>
                        <select name="plan_id" id="plan_id" class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                            <option value="">None</option>
                            <?php foreach ($plans as $plan): ?>
                                <option value="<?php echo htmlspecialchars($plan['plan_key']); ?>">
                                    <?php echo htmlspecialchars($plan['plan_name']); ?> ($<?php echo htmlspecialchars($plan['price']); ?>)
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                     <div>
                        <label for="payment_status" class="block text-sm font-medium text-gray-300 mb-1">Payment Status</label>
                        <select name="payment_status" id="payment_status" required class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                            <?php foreach ($payment_statuses as $status): ?>
                                <option value="<?php echo htmlspecialchars($status); ?>" <?php echo ($status == 'none' ? 'selected' : ''); ?>>
                                    <?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $status))); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <button type="submit" class="bg-teal-500 hover:bg-teal-600 text-white font-semibold py-2 px-4 rounded-lg">
                    <i class="fas fa-plus"></i> Add User
                </button>
            </form>
        </div>

        <div class="bg-gray-800 p-6 rounded-lg shadow-md overflow-x-auto">
            <h2 class="text-xl font-semibold text-teal-400 mb-4">Registered Users List</h2>
            <?php if (empty($users) && empty($feedback_type == 'error' && strpos($feedback_message, "fetching users") !== false)): ?>
                <p class="text-gray-400">No users found.</p>
            <?php elseif (!empty($users)): ?>
            <table class="min-w-full divide-y divide-gray-700">
                <thead class="bg-gray-700">
                    <tr>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">ID</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Username</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Email</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Plan</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Payment Status</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Registered</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Last Login</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-gray-800 divide-y divide-gray-700">
                    <?php foreach ($users as $user): ?>
                    <tr>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300"><?php echo htmlspecialchars($user['user_id']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-200 font-medium"><?php echo htmlspecialchars($user['username']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300"><?php echo htmlspecialchars($user['email']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300">
                            <?php echo htmlspecialchars($user['plan_name'] ?? 'N/A'); ?>
                        </td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                <?php 
                                    switch ($user['payment_status']) {
                                        case 'completed': echo 'bg-green-700 text-green-100'; break;
                                        case 'pending_approval': echo 'bg-yellow-600 text-yellow-100'; break;
                                        case 'pending': echo 'bg-blue-600 text-blue-100'; break;
                                        case 'failed': echo 'bg-red-700 text-red-100'; break;
                                        default: echo 'bg-gray-600 text-gray-100'; break;
                                    }
                                ?>">
                                <?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $user['payment_status']))); ?>
                            </span>
                        </td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-400"><?php echo htmlspecialchars(date("M d, Y H:i", strtotime($user['registration_date']))); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-400"><?php echo $user['last_login'] ? htmlspecialchars(date("M d, Y H:i", strtotime($user['last_login']))) : 'Never'; ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm font-medium">
                            <a href="admin_edit_user.php?user_id=<?php echo $user['user_id']; ?>" class="table-action-btn text-blue-400 hover:text-blue-300" title="Edit User"><i class="fas fa-edit"></i></a>
                            <a href="admin_manage_users.php?action=delete_user&user_id=<?php echo $user['user_id']; ?>" 
                               onclick="return confirm('Are you sure you want to delete this user (ID: <?php echo $user['user_id']; ?>)? This action cannot be undone.');" 
                               class="table-action-btn text-red-500 hover:text-red-400" title="Delete User"><i class="fas fa-trash-alt"></i></a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
            <?php endif; ?>
        </div>
    </div>
    <script>
        // Simple script for confirmation or future JS needs
        document.addEventListener('DOMContentLoaded', function() {
            // Example: Add more complex confirmation dialogs if needed
        });
    </script>
</body>
</html>
