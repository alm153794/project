<?php
// api/contact_form_handler.php
// Handles submissions from the contact form.

header('Content-Type: application/json');
require_once '../db_config.php'; // Adjust path if db_config.php is in a different directory

$response = ['success' => false, 'message' => 'An unknown error occurred.'];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get data from the request body (assuming JSON input from fetch)
    $input = json_decode(file_get_contents('php://input'), true);

    $name = trim($input['name'] ?? '');
    $email = trim($input['email'] ?? '');
    $subject = trim($input['subject'] ?? '');
    $message_text = trim($input['message'] ?? ''); // Renamed to avoid conflict with table name

    // --- Validation ---
    if (empty($name) || empty($email) || empty($subject) || empty($message_text)) {
        $response['message'] = "All fields (Name, Email, Subject, Message) are required.";
        echo json_encode($response);
        exit;
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $response['message'] = "Invalid email format.";
        echo json_encode($response);
        exit;
    }
    if (strlen($subject) > 255) {
        $response['message'] = "Subject is too long (max 255 characters).";
        echo json_encode($response);
        exit;
    }

    // Prepare SQL to insert message
    $sql_insert_message = "INSERT INTO messages (name, email, subject, message) VALUES (?, ?, ?, ?)";
    if ($stmt_insert = $mysqli->prepare($sql_insert_message)) {
        $stmt_insert->bind_param("ssss", $name, $email, $subject, $message_text);
        
        if ($stmt_insert->execute()) {
            $response['success'] = true;
            $response['message'] = "Message sent successfully! We will get back to you soon.";
        } else {
            $response['message'] = "Failed to send message. Please try again later.";
            error_log("MySQLi Execute Error (insert message): " . $stmt_insert->error); // Log error
        }
        $stmt_insert->close();
    } else {
        $response['message'] = "Database error (prepare insert message).";
        error_log("MySQLi Prepare Error (insert message): " . $mysqli->error); // Log error
    }
} else {
    $response['message'] = "Invalid request method.";
}

$mysqli->close();
echo json_encode($response);
?>
