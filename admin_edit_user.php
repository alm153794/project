<?php
session_start();
// admin_edit_user.php
// Page for admins to edit a specific user's details.

require_once 'db_config.php'; // Includes session_start() and $mysqli connection

// Check if the admin is logged in, otherwise redirect to login page
if (!isset($_SESSION["admin_loggedin"]) || $_SESSION["admin_loggedin"] !== true) {
    header("location: admin_login.php");
    exit;
}

$admin_username = htmlspecialchars($_SESSION["admin_username"]);
$feedback_message = ''; // For success or error messages
$feedback_type = '';    // 'success' or 'error' or 'warning'

$user_id_to_edit = null;
$user_data = null; // To store fetched user data

// Check if user_id is provided in URL
if (isset($_GET['user_id']) && is_numeric($_GET['user_id'])) {
    $user_id_to_edit = intval($_GET['user_id']);

    // Fetch user data for pre-filling the form
    $sql_fetch_user = "SELECT user_id, username, email, plan_id, payment_status FROM users WHERE user_id = ?";
    if ($stmt_fetch = $mysqli->prepare($sql_fetch_user)) {
        $stmt_fetch->bind_param("i", $user_id_to_edit);
        $stmt_fetch->execute();
        $result_user = $stmt_fetch->get_result();
        if ($result_user->num_rows == 1) {
            $user_data = $result_user->fetch_assoc();
        } else {
            $feedback_message = "User not found.";
            $feedback_type = 'error';
            // To prevent further processing if user not found
            $user_id_to_edit = null; 
        }
        $stmt_fetch->close();
    } else {
        $feedback_message = "Database error (prepare fetch user): " . $mysqli->error;
        $feedback_type = 'error';
        $user_id_to_edit = null;
    }
} else {
    $feedback_message = "No user ID specified for editing.";
    $feedback_type = 'error';
}

// Handle UPDATE USER action
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['action_update_user']) && $user_id_to_edit !== null) {
    $updated_username = trim($_POST['username']);
    $updated_email = trim($_POST['email']);
    $updated_plan_id = !empty($_POST['plan_id']) ? trim($_POST['plan_id']) : null;
    $updated_payment_status = trim($_POST['payment_status']);
    $updated_password = $_POST['password']; // Optional: New password

    // Validate inputs
    if (empty($updated_username) || empty($updated_email) || empty($updated_payment_status)) {
        $feedback_message = "Username, Email, and Payment Status are required.";
        $feedback_type = 'error';
    } elseif (!filter_var($updated_email, FILTER_VALIDATE_EMAIL)) {
        $feedback_message = "Invalid email format.";
        $feedback_type = 'error';
    } else {
        // Check if the new email is already taken by ANOTHER user
        $sql_check_email = "SELECT user_id FROM users WHERE email = ? AND user_id != ?";
        if ($stmt_check_email = $mysqli->prepare($sql_check_email)) {
            $stmt_check_email->bind_param("si", $updated_email, $user_id_to_edit);
            $stmt_check_email->execute();
            $stmt_check_email->store_result();
            if ($stmt_check_email->num_rows > 0) {
                $feedback_message = "The email '" . htmlspecialchars($updated_email) . "' is already in use by another user.";
                $feedback_type = 'error';
            }
            $stmt_check_email->close();
        } else {
            $feedback_message = "Database error (email check during update): " . $mysqli->error;
            $feedback_type = 'error';
        }

        if ($feedback_type !== 'error') { // Proceed if email is not taken by another user
            // Prepare SQL update statement
            $update_fields = "username = ?, email = ?, plan_id = ?, payment_status = ?";
            $bind_types = "ssssi"; // s for username, s for email, s for plan_id, s for payment_status, i for user_id
            $bind_params = [$updated_username, $updated_email, $updated_plan_id, $updated_payment_status];

            // Handle optional password update
            if (!empty($updated_password)) {
                if (strlen($updated_password) < 6) {
                    $feedback_message = "New password must be at least 6 characters long.";
                    $feedback_type = 'error';
                } else {
                    $password_hash = password_hash($updated_password, PASSWORD_DEFAULT);
                    $update_fields .= ", password_hash = ?";
                    $bind_types = "sssssi"; // Add s for password_hash
                    $bind_params[] = $password_hash;
                }
            }
            
            if ($feedback_type !== 'error') {
                $bind_params[] = $user_id_to_edit; // Add user_id to the end for WHERE clause
                $sql_update_user = "UPDATE users SET " . $update_fields . " WHERE user_id = ?";

                if ($stmt_update = $mysqli->prepare($sql_update_user)) {
                    $stmt_update->bind_param($bind_types, ...$bind_params);
                    if ($stmt_update->execute()) {
                        $feedback_message = "User details updated successfully!";
                        $feedback_type = 'success';
                        // Refresh user_data to show updated values in the form
                        $user_data['username'] = $updated_username;
                        $user_data['email'] = $updated_email;
                        $user_data['plan_id'] = $updated_plan_id;
                        $user_data['payment_status'] = $updated_payment_status;
                    } else {
                        $feedback_message = "Error updating user: " . $stmt_update->error;
                        $feedback_type = 'error';
                    }
                    $stmt_update->close();
                } else {
                    $feedback_message = "Database error (prepare user update): " . $mysqli->error;
                    $feedback_type = 'error';
                }
            }
        }
    }
    // To ensure the form shows the attempted (but possibly failed) values if there was an error
    if ($feedback_type === 'error' && $user_data) {
        $user_data['username'] = $updated_username;
        $user_data['email'] = $updated_email;
        $user_data['plan_id'] = $updated_plan_id;
        $user_data['payment_status'] = $updated_payment_status;
    }
}


// Fetch plans for dropdown
$plans = [];
$sql_fetch_plans = "SELECT plan_key, plan_name FROM plans ORDER BY plan_name ASC";
if ($result_plans = $mysqli->query($sql_fetch_plans)) {
    while ($row_plan = $result_plans->fetch_assoc()) {
        $plans[] = $row_plan;
    }
    $result_plans->free();
}

$payment_statuses = ['none', 'pending', 'pending_approval', 'completed', 'failed'];

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="style.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .admin-nav-link { display: block; padding: 0.75rem 1.5rem; margin-bottom: 0.5rem; border-radius: 0.375rem; background-color: #374151; color: #e5e7eb; transition: background-color 0.3s ease, color 0.3s ease; }
        .admin-nav-link:hover { background-color: #4b5563; color: #ffffff; }
        .admin-nav-link i { margin-right: 0.75rem; }
        .feedback-success { background-color: #10B981; color: white; padding: 0.75rem; border-radius: 0.375rem; margin-bottom: 1rem; }
        .feedback-error { background-color: #EF4444; color: white; padding: 0.75rem; border-radius: 0.375rem; margin-bottom: 1rem; }
        .feedback-warning { background-color: #F59E0B; color: white; padding: 0.75rem; border-radius: 0.375rem; margin-bottom: 1rem; }
    </style>
</head>
<body class="bg-gray-900 text-gray-100 flex min-h-screen">

    <aside class="w-64 bg-gray-800 p-6 shadow-lg flex-shrink-0">
        <div class="text-2xl font-bold text-teal-400 mb-8">Admin<span class="text-white">Panel</span></div>
        <nav>
            <a href="admin_dashboard.php" class="admin-nav-link"> <i class="fas fa-tachometer-alt"></i>Dashboard </a>
            <a href="admin_manage_users.php" class="admin-nav-link bg-teal-600 text-white"> <i class="fas fa-users"></i>Manage Users </a>
            <a href="admin_manage_payments.php" class="admin-nav-link"> <i class="fas fa-credit-card"></i>Manage Payments </a>
            <a href="admin_manage_plans.php" class="admin-nav-link"> <i class="fas fa-clipboard-list"></i>Manage Plans </a>
            <a href="admin_logout.php" class="admin-nav-link mt-10 bg-red-600 hover:bg-red-700"> <i class="fas fa-sign-out-alt"></i>Logout </a>
        </nav>
    </aside>

    <div class="flex-grow p-8">
        <header class="mb-8 flex justify-between items-center">
            <h1 class="text-3xl font-bold text-teal-400">Edit User Details</h1>
            <div class="text-gray-300">Welcome, <span class="font-semibold"><?php echo $admin_username; ?></span>!</div>
        </header>

        <?php if (!empty($feedback_message)): ?>
            <div class="feedback-<?php echo htmlspecialchars($feedback_type); ?>">
                <?php echo htmlspecialchars($feedback_message); ?>
            </div>
        <?php endif; ?>

        <?php if ($user_id_to_edit !== null && $user_data): ?>
        <div class="bg-gray-800 p-6 rounded-lg shadow-md">
            <h2 class="text-xl font-semibold text-teal-400 mb-4">Editing User ID: <?php echo htmlspecialchars($user_data['user_id']); ?></h2>
            <form action="admin_edit_user.php?user_id=<?php echo htmlspecialchars($user_id_to_edit); ?>" method="POST">
                <input type="hidden" name="action_update_user" value="1">
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-4">
                    <div>
                        <label for="username" class="block text-sm font-medium text-gray-300 mb-1">Username</label>
                        <input type="text" name="username" id="username" value="<?php echo htmlspecialchars($user_data['username']); ?>" required class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                    </div>
                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-300 mb-1">Email</label>
                        <input type="email" name="email" id="email" value="<?php echo htmlspecialchars($user_data['email']); ?>" required class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                    </div>
                    <div>
                        <label for="plan_id" class="block text-sm font-medium text-gray-300 mb-1">Membership Plan</label>
                        <select name="plan_id" id="plan_id" class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                            <option value="">None</option>
                            <?php foreach ($plans as $plan): ?>
                                <option value="<?php echo htmlspecialchars($plan['plan_key']); ?>" <?php echo ($user_data['plan_id'] == $plan['plan_key'] ? 'selected' : ''); ?>>
                                    <?php echo htmlspecialchars($plan['plan_name']); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div>
                        <label for="payment_status" class="block text-sm font-medium text-gray-300 mb-1">Payment Status</label>
                        <select name="payment_status" id="payment_status" required class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                            <?php foreach ($payment_statuses as $status): ?>
                                <option value="<?php echo htmlspecialchars($status); ?>" <?php echo ($user_data['payment_status'] == $status ? 'selected' : ''); ?>>
                                    <?php echo htmlspecialchars(ucfirst(str_replace('_', ' ', $status))); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="mb-6">
                    <label for="password" class="block text-sm font-medium text-gray-300 mb-1">New Password (Optional)</label>
                    <input type="password" name="password" id="password" class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500" placeholder="Leave blank to keep current password">
                    <p class="text-xs text-gray-400 mt-1">If you enter a new password, it must be at least 6 characters long.</p>
                </div>

                <div class="flex items-center space-x-4">
                    <button type="submit" class="bg-teal-500 hover:bg-teal-600 text-white font-semibold py-2 px-4 rounded-lg">
                        <i class="fas fa-save"></i> Update User
                    </button>
                    <a href="admin_manage_users.php" class="bg-gray-500 hover:bg-gray-600 text-white font-semibold py-2 px-4 rounded-lg">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
        <?php elseif (empty($feedback_message)): // Only show if no other major error occurred ?>
            <p class="text-gray-400">User data could not be loaded for editing. Please ensure a valid user ID is provided.</p>
        <?php endif; ?>
        
    </div>
</body>
</html>
