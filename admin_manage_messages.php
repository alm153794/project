<?php
session_start();
// admin_manage_messages.php
require_once 'db_config.php';

if (!isset($_SESSION["admin_loggedin"]) || $_SESSION["admin_loggedin"] !== true) {
    header("location: admin_login.php");
    exit;
}

$admin_username = htmlspecialchars($_SESSION["admin_username"]);
$feedback_message = '';
$feedback_type = '';

// Handle message actions (delete, mark as read, etc.)
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['action'], $_POST['message_id'])) {
    $message_id = intval($_POST['message_id']);
    if ($_POST['action'] === 'mark_read') {
        $mysqli->query("UPDATE messages SET is_read = 1 WHERE message_id = $message_id");
        $feedback_message = "Message marked as read.";
        $feedback_type = "success";
    } elseif ($_POST['action'] === 'delete') {
        $mysqli->query("DELETE FROM messages WHERE message_id = $message_id");
        $feedback_message = "Message deleted.";
        $feedback_type = "success";
    }
}

// Fetch all messages
$messages = [];
$sql = "SELECT message_id, name, email, subject, message, received_at, is_read FROM messages ORDER BY received_at DESC";
if ($result = $mysqli->query($sql)) {
    while ($row = $result->fetch_assoc()) {
        $messages[] = $row;
    }
    $result->free();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Messages - Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .admin-nav-link {
            display: block;
            padding: 0.75rem 1.5rem;
            margin-bottom: 0.5rem;
            border-radius: 0.375rem;
            background-color: #374151;
            color: #e5e7eb;
            transition: background-color 0.3s ease, color 0.3s ease;
        }
        .admin-nav-link:hover {
            background-color: #4b5563;
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
            <h1 class="text-3xl font-bold text-teal-400"><i class="fas fa-envelope mr-2"></i>Manage Messages</h1>
            <div class="text-gray-300">Welcome, <span class="font-semibold"><?php echo $admin_username; ?></span>!</div>
        </header>

        <?php if (!empty($feedback_message)): ?>
            <div class="mb-4 px-4 py-3 rounded <?php echo $feedback_type === 'success' ? 'bg-green-700 text-green-200' : 'bg-red-700 text-red-200'; ?>">
                <?php echo htmlspecialchars($feedback_message); ?>
            </div>
        <?php endif; ?>

        <div class="bg-gray-800 p-6 rounded-lg shadow-md overflow-x-auto">
            <?php if (empty($messages)): ?>
                <p class="text-gray-400">No messages found.</p>
            <?php else: ?>
                <table class="min-w-full divide-y divide-gray-700">
                    <thead>
                        <tr>
                            <th class="px-4 py-2 text-left text-xs font-semibold text-gray-300 uppercase">Name</th>
                            <th class="px-4 py-2 text-left text-xs font-semibold text-gray-300 uppercase">Email</th>
                            <th class="px-4 py-2 text-left text-xs font-semibold text-gray-300 uppercase">Subject</th>
                            <th class="px-4 py-2 text-left text-xs font-semibold text-gray-300 uppercase">Message</th>
                            <th class="px-4 py-2 text-left text-xs font-semibold text-gray-300 uppercase">Received</th>
                            <th class="px-4 py-2 text-center text-xs font-semibold text-gray-300 uppercase">Status</th>
                            <th class="px-4 py-2 text-center text-xs font-semibold text-gray-300 uppercase">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-700">
                        <?php foreach ($messages as $msg): ?>
                            <tr class="<?php echo $msg['is_read'] ? 'bg-gray-700' : 'bg-gray-900'; ?>">
                                <td class="px-4 py-2"><?php echo htmlspecialchars($msg['name']); ?></td>
                                <td class="px-4 py-2"><?php echo htmlspecialchars($msg['email']); ?></td>
                                <td class="px-4 py-2"><?php echo htmlspecialchars($msg['subject']); ?></td>
                                <td class="px-4 py-2 max-w-xs truncate" title="<?php echo htmlspecialchars($msg['message']); ?>">
                                    <?php echo htmlspecialchars(mb_strimwidth($msg['message'], 0, 40, '...')); ?>
                                </td>
                                <td class="px-4 py-2"><?php echo htmlspecialchars(date('Y-m-d H:i', strtotime($msg['received_at']))); ?></td>
                                <td class="px-4 py-2 text-center">
                                    <?php if ($msg['is_read']): ?>
                                        <span class="inline-block px-2 py-1 text-xs bg-green-700 rounded text-green-100">Read</span>
                                    <?php else: ?>
                                        <span class="inline-block px-2 py-1 text-xs bg-yellow-700 rounded text-yellow-100">Unread</span>
                                    <?php endif; ?>
                                </td>
                                <td class="px-4 py-2 text-center">
                                    <form method="post" class="inline">
                                        <input type="hidden" name="message_id" value="<?php echo $msg['message_id']; ?>">
                                        <button type="submit" name="action" value="mark_read" class="bg-teal-600 hover:bg-teal-700 text-white px-2 py-1 rounded text-xs mr-1" <?php if ($msg['is_read']) echo 'disabled'; ?>>
                                            <i class="fas fa-check"></i> Mark as Read
                                        </button>
                                    </form>
                                    <form method="post" class="inline" onsubmit="return confirm('Are you sure you want to delete this message?');">
                                        <input type="hidden" name="message_id" value="<?php echo $msg['message_id']; ?>">
                                        <button type="submit" name="action" value="delete" class="bg-red-600 hover:bg-red-700 text-white px-2 py-1 rounded text-xs">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </form>
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