<?php
session_start();
// admin_manage_plans.php
// Page for admins to manage membership plans.

require_once 'db_config.php'; // Includes session_start() and $mysqli connection

// Check if the admin is logged in, otherwise redirect to login page
if (!isset($_SESSION["admin_loggedin"]) || $_SESSION["admin_loggedin"] !== true) {
    header("location: admin_login.php");
    exit;
}

$admin_username = htmlspecialchars($_SESSION["admin_username"]);
$feedback_message = ''; // For success or error messages
$feedback_type = '';    // 'success' or 'error' or 'warning'

// Variables for pre-filling the form when editing
$edit_mode = false;
$edit_plan_key = '';
$edit_plan_name = '';
$edit_price = '';
$edit_description = '';

// --- Handle Actions (Add, Edit, Delete Plan) ---

// Handle ADD or UPDATE PLAN action
if ($_SERVER["REQUEST_METHOD"] == "POST" && (isset($_POST['action_add_plan']) || isset($_POST['action_update_plan']))) {
    $plan_key = trim($_POST['plan_key']);
    $plan_name = trim($_POST['plan_name']);
    $price = trim($_POST['price']);
    $description = trim($_POST['description']);
    $original_plan_key = isset($_POST['original_plan_key']) ? trim($_POST['original_plan_key']) : $plan_key;

    // Validate inputs
    if (empty($plan_key) || empty($plan_name) || !is_numeric($price) || $price < 0) {
        $feedback_message = "Plan Key, Plan Name, and a valid Price are required.";
        $feedback_type = 'error';
    } elseif (strlen($plan_key) > 50 || strlen($plan_name) > 100) {
        $feedback_message = "Plan Key (max 50 chars) or Plan Name (max 100 chars) is too long.";
        $feedback_type = 'error';
    } else {
        if (isset($_POST['action_add_plan'])) { // ADDING A NEW PLAN
            // Check if plan_key already exists
            $sql_check_key = "SELECT plan_key FROM plans WHERE plan_key = ?";
            if ($stmt_check = $mysqli->prepare($sql_check_key)) {
                $stmt_check->bind_param("s", $plan_key);
                $stmt_check->execute();
                $stmt_check->store_result();
                if ($stmt_check->num_rows > 0) {
                    $feedback_message = "Plan Key '" . htmlspecialchars($plan_key) . "' already exists. Choose a unique key.";
                    $feedback_type = 'error';
                } else {
                    // Plan key is unique, proceed to insert
                    $sql_insert = "INSERT INTO plans (plan_key, plan_name, price, description) VALUES (?, ?, ?, ?)";
                    if ($stmt_insert = $mysqli->prepare($sql_insert)) {
                        $stmt_insert->bind_param("ssds", $plan_key, $plan_name, $price, $description);
                        if ($stmt_insert->execute()) {
                            $feedback_message = "Plan '" . htmlspecialchars($plan_name) . "' added successfully!";
                            $feedback_type = 'success';
                        } else {
                            $feedback_message = "Error adding plan: " . $stmt_insert->error;
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
                $feedback_message = "Database error (prepare check key): " . $mysqli->error;
                $feedback_type = 'error';
            }
        } elseif (isset($_POST['action_update_plan'])) { // UPDATING AN EXISTING PLAN
            // If plan_key is being changed, ensure the new one isn't taken by another plan
            if ($plan_key !== $original_plan_key) {
                $sql_check_new_key = "SELECT plan_key FROM plans WHERE plan_key = ?";
                $stmt_check_new_key = $mysqli->prepare($sql_check_new_key);
                $stmt_check_new_key->bind_param("s", $plan_key);
                $stmt_check_new_key->execute();
                $stmt_check_new_key->store_result();
                if ($stmt_check_new_key->num_rows > 0) {
                    $feedback_message = "The new Plan Key '" . htmlspecialchars($plan_key) . "' is already in use by another plan.";
                    $feedback_type = 'error';
                    // Keep edit mode with current (failed) values
                    $edit_mode = true;
                    $edit_plan_key = $plan_key; // Show the problematic new key
                    $edit_plan_name = $plan_name;
                    $edit_price = $price;
                    $edit_description = $description;
                    // We need $original_plan_key in the form again if edit fails due to new key collision
                    $_GET['edit_plan_key'] = $original_plan_key; // To repopulate form correctly
                }
                $stmt_check_new_key->close();
            }

            if ($feedback_type !== 'error') { // Proceed if no key collision
                $sql_update = "UPDATE plans SET plan_key = ?, plan_name = ?, price = ?, description = ? WHERE plan_key = ?";
                if ($stmt_update = $mysqli->prepare($sql_update)) {
                    $stmt_update->bind_param("ssdss", $plan_key, $plan_name, $price, $description, $original_plan_key);
                    if ($stmt_update->execute()) {
                        $feedback_message = "Plan '" . htmlspecialchars($plan_name) . "' updated successfully!";
                        $feedback_type = 'success';
                         // If plan_key was changed, update users and payments tables (this can be complex)
                        if ($plan_key !== $original_plan_key) {
                            // Update users table
                            $sql_update_users_plan = "UPDATE users SET plan_id = ? WHERE plan_id = ?";
                            $stmt_users = $mysqli->prepare($sql_update_users_plan);
                            $stmt_users->bind_param("ss", $plan_key, $original_plan_key);
                            $stmt_users->execute();
                            $stmt_users->close();

                            // Update payments table
                            $sql_update_payments_plan = "UPDATE payments SET plan_key = ? WHERE plan_key = ?";
                            $stmt_payments = $mysqli->prepare($sql_update_payments_plan);
                            $stmt_payments->bind_param("ss", $plan_key, $original_plan_key);
                            $stmt_payments->execute();
                            $stmt_payments->close();
                            $feedback_message .= " Associated user and payment records updated to new plan key.";
                        }
                    } else {
                        $feedback_message = "Error updating plan: " . $stmt_update->error;
                        $feedback_type = 'error';
                    }
                    $stmt_update->close();
                } else {
                    $feedback_message = "Database error (prepare update): " . $mysqli->error;
                    $feedback_type = 'error';
                }
            }
        }
    }
}

// Handle EDIT action (Load plan data into form)
if (isset($_GET['action']) && $_GET['action'] == 'edit_plan' && isset($_GET['plan_key'])) {
    $plan_key_to_edit = trim($_GET['plan_key']);
    $sql_fetch_single_plan = "SELECT plan_key, plan_name, price, description FROM plans WHERE plan_key = ?";
    if ($stmt_fetch_single = $mysqli->prepare($sql_fetch_single_plan)) {
        $stmt_fetch_single->bind_param("s", $plan_key_to_edit);
        $stmt_fetch_single->execute();
        $result_single = $stmt_fetch_single->get_result();
        if ($plan_data = $result_single->fetch_assoc()) {
            $edit_mode = true;
            $edit_plan_key = $plan_data['plan_key'];
            $edit_plan_name = $plan_data['plan_name'];
            $edit_price = $plan_data['price'];
            $edit_description = $plan_data['description'];
        } else {
            $feedback_message = "Plan not found for editing.";
            $feedback_type = 'warning';
        }
        $stmt_fetch_single->close();
    } else {
        $feedback_message = "Database error (prepare fetch single plan): " . $mysqli->error;
        $feedback_type = 'error';
    }
}


// Handle DELETE PLAN action
if (isset($_GET['action']) && $_GET['action'] == 'delete_plan' && isset($_GET['plan_key'])) {
    $plan_key_to_delete = trim($_GET['plan_key']);

    // Check if any users or payments are associated with this plan
    $sql_check_associations_users = "SELECT COUNT(*) as count FROM users WHERE plan_id = ?";
    $stmt_check_users = $mysqli->prepare($sql_check_associations_users);
    $stmt_check_users->bind_param("s", $plan_key_to_delete);
    $stmt_check_users->execute();
    $user_count = $stmt_check_users->get_result()->fetch_assoc()['count'];
    $stmt_check_users->close();

    $sql_check_associations_payments = "SELECT COUNT(*) as count FROM payments WHERE plan_key = ?";
    $stmt_check_payments = $mysqli->prepare($sql_check_associations_payments);
    $stmt_check_payments->bind_param("s", $plan_key_to_delete);
    $stmt_check_payments->execute();
    $payment_count = $stmt_check_payments->get_result()->fetch_assoc()['count'];
    $stmt_check_payments->close();

    if ($user_count > 0 || $payment_count > 0) {
        $feedback_message = "Cannot delete plan '" . htmlspecialchars($plan_key_to_delete) . "'. It is associated with " . $user_count . " user(s) and " . $payment_count . " payment(s). Please update or remove these associations first.";
        $feedback_type = 'warning';
    } else {
        $sql_delete = "DELETE FROM plans WHERE plan_key = ?";
        if ($stmt_delete = $mysqli->prepare($sql_delete)) {
            $stmt_delete->bind_param("s", $plan_key_to_delete);
            if ($stmt_delete->execute()) {
                if ($stmt_delete->affected_rows > 0) {
                    $feedback_message = "Plan '" . htmlspecialchars($plan_key_to_delete) . "' deleted successfully!";
                    $feedback_type = 'success';
                } else {
                    $feedback_message = "Plan not found or already deleted.";
                    $feedback_type = 'warning';
                }
            } else {
                $feedback_message = "Error deleting plan: " . $stmt_delete->error;
                $feedback_type = 'error';
            }
            $stmt_delete->close();
        } else {
            $feedback_message = "Database error (prepare delete): " . $mysqli->error;
            $feedback_type = 'error';
        }
    }
}


// --- Fetch All Plans for Display ---
$plans_list = [];
$sql_fetch_all_plans = "SELECT plan_key, plan_name, price, description FROM plans ORDER BY plan_name ASC";
if ($result_all_plans = $mysqli->query($sql_fetch_all_plans)) {
    while ($row_plan = $result_all_plans->fetch_assoc()) {
        $plans_list[] = $row_plan;
    }
    $result_all_plans->free();
} else {
    $feedback_message = "Error fetching plans list: " . $mysqli->error;
    $feedback_type = 'error';
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Plans - Admin</title>
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
            <a href="admin_dashboard.php" class="admin-nav-link"> <i class="fas fa-tachometer-alt"></i>Dashboard </a>
            <a href="admin_manage_users.php" class="admin-nav-link"> <i class="fas fa-users"></i>Manage Users </a>
            <a href="admin_manage_payments.php" class="admin-nav-link"> <i class="fas fa-credit-card"></i>Manage Payments </a>
            <a href="admin_manage_plans.php" class="admin-nav-link bg-teal-600 text-white"> <i class="fas fa-clipboard-list"></i>Manage Plans </a>
            <a href="admin_logout.php" class="admin-nav-link mt-10 bg-red-600 hover:bg-red-700"> <i class="fas fa-sign-out-alt"></i>Logout </a>
        </nav>
    </aside>

    <div class="flex-grow p-8">
        <header class="mb-8 flex justify-between items-center">
            <h1 class="text-3xl font-bold text-teal-400"><?php echo $edit_mode ? 'Edit Plan' : 'Manage Plans'; ?></h1>
            <div class="text-gray-300">Welcome, <span class="font-semibold"><?php echo $admin_username; ?></span>!</div>
        </header>

        <?php if (!empty($feedback_message)): ?>
            <div class="feedback-<?php echo htmlspecialchars($feedback_type); ?>">
                <?php echo htmlspecialchars($feedback_message); ?>
            </div>
        <?php endif; ?>

        <div class="mb-8 bg-gray-800 p-6 rounded-lg shadow-md">
            <h2 class="text-xl font-semibold text-teal-400 mb-4"><?php echo $edit_mode ? 'Update Plan Details' : 'Add New Plan'; ?></h2>
            <form action="admin_manage_plans.php" method="POST">
                <?php if ($edit_mode): ?>
                    <input type="hidden" name="action_update_plan" value="1">
                    <input type="hidden" name="original_plan_key" value="<?php echo htmlspecialchars($edit_plan_key); // Use original key for WHERE clause if key is changed ?>">
                <?php else: ?>
                    <input type="hidden" name="action_add_plan" value="1">
                <?php endif; ?>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                        <label for="plan_key" class="block text-sm font-medium text-gray-300 mb-1">Plan Key (Unique ID, e.g., 'basic', 'pro_monthly')</label>
                        <input type="text" name="plan_key" id="plan_key" value="<?php echo htmlspecialchars($edit_plan_key); ?>" required maxlength="50" class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                    </div>
                    <div>
                        <label for="plan_name" class="block text-sm font-medium text-gray-300 mb-1">Plan Name (Display Name)</label>
                        <input type="text" name="plan_name" id="plan_name" value="<?php echo htmlspecialchars($edit_plan_name); ?>" required maxlength="100" class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                    </div>
                    <div>
                        <label for="price" class="block text-sm font-medium text-gray-300 mb-1">Price (Birr)</label>
                        <input type="number" name="price" id="price" value="<?php echo htmlspecialchars($edit_price); ?>" required step="0.01" min="0" class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500">
                    </div>
                </div>
                <div class="mb-4">
                    <label for="description" class="block text-sm font-medium text-gray-300 mb-1">Description (Optional)</label>
                    <textarea name="description" id="description" rows="3" class="w-full p-2 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-teal-500 focus:border-teal-500"><?php echo htmlspecialchars($edit_description); ?></textarea>
                </div>
                <div class="flex items-center space-x-4">
                    <button type="submit" class="bg-teal-500 hover:bg-teal-600 text-white font-semibold py-2 px-4 rounded-lg">
                        <i class="fas <?php echo $edit_mode ? 'fa-save' : 'fa-plus'; ?>"></i> <?php echo $edit_mode ? 'Update Plan' : 'Add Plan'; ?>
                    </button>
                    <?php if ($edit_mode): ?>
                        <a href="admin_manage_plans.php" class="bg-gray-500 hover:bg-gray-600 text-white font-semibold py-2 px-4 rounded-lg">Cancel Edit</a>
                    <?php endif; ?>
                </div>
            </form>
        </div>

        <div class="bg-gray-800 p-6 rounded-lg shadow-md overflow-x-auto">
            <h2 class="text-xl font-semibold text-teal-400 mb-4">Existing Plans List</h2>
            <?php if (empty($plans_list) && !($feedback_type == 'error' && strpos($feedback_message, "fetching plans list") !== false)): ?>
                <p class="text-gray-400">No plans found. Add one using the form above.</p>
            <?php elseif (!empty($plans_list)): ?>
            <table class="min-w-full divide-y divide-gray-700">
                <thead class="bg-gray-700">
                    <tr>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Plan Key</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Name</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Price (Birr)</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Description</th>
                        <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-gray-800 divide-y divide-gray-700">
                    <?php foreach ($plans_list as $plan): ?>
                    <tr>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300 font-medium"><?php echo htmlspecialchars($plan['plan_key']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-200"><?php echo htmlspecialchars($plan['plan_name']); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-300"><?php echo htmlspecialchars(number_format($plan['price'], 2)); ?></td>
                        <td class="px-4 py-3 text-sm text-gray-400 max-w-xs truncate" title="<?php echo htmlspecialchars($plan['description']); ?>"><?php echo nl2br(htmlspecialchars(substr($plan['description'], 0, 100) . (strlen($plan['description']) > 100 ? '...' : ''))); ?></td>
                        <td class="px-4 py-3 whitespace-nowrap text-sm font-medium">
                            <a href="admin_manage_plans.php?action=edit_plan&plan_key=<?php echo urlencode($plan['plan_key']); ?>" class="table-action-btn text-blue-400 hover:text-blue-300" title="Edit Plan"><i class="fas fa-edit"></i> Edit</a>
                            <a href="admin_manage_plans.php?action=delete_plan&plan_key=<?php echo urlencode($plan['plan_key']); ?>" 
                               onclick="return confirm('Are you sure you want to delete the plan \'<?php echo htmlspecialchars(addslashes($plan['plan_name'])); ?>\' (Key: <?php echo htmlspecialchars(addslashes($plan['plan_key'])); ?>)? This action cannot be undone if no users or payments are associated with it.');" 
                               class="table-action-btn text-red-500 hover:text-red-400" title="Delete Plan"><i class="fas fa-trash-alt"></i> Delete</a>
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
