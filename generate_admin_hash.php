<?php
// generate_admin_hash.php
$plainPassword = 'yourSecureAdminPassword123'; // CHOOSE A STRONG PASSWORD
$hashedPassword = password_hash($plainPassword, PASSWORD_DEFAULT);
echo "Admin Username: admin<br>";
echo "Plain Password (for your reference only, don't store this): " . htmlspecialchars($plainPassword) . "<br>";
echo "Hashed Password (use this in database): " . htmlspecialchars($hashedPassword);
?>