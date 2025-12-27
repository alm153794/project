<?php
// signup.php
// Handles user registration page and dynamically lists membership plans.

require_once 'db_config.php'; // For database connection and session start

// Fetch all plans from the database to populate the dropdown
$plans = [];
$sql_fetch_plans = "SELECT plan_key, plan_name, price FROM plans ORDER BY price ASC"; // Order by price or some other logic
if ($result_plans = $mysqli->query($sql_fetch_plans)) {
    while ($row_plan = $result_plans->fetch_assoc()) {
        $plans[] = $row_plan;
    }
    $result_plans->free();
} else {
    // Optional: Log an error if plans can't be fetched, but don't break the page.
    // The form will just show "No plans available".
    error_log("Error fetching plans for signup page: " . $mysqli->error);
}
// $mysqli->close(); // Connection will be closed at the end of the script by PHP
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Vision Gym Fitness House</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="style.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .cta-button { transition: all 0.3s ease; }
        .cta-button:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05); }
        .nav-link { transition: color 0.3s ease; }
        .nav-link:hover { color: #2dd4bf; }
        .active-nav-link { color: #2dd4bf; font-weight: 600; }
    </style>
</head>
<body class="bg-gray-900 text-gray-100 flex flex-col min-h-screen">

    <nav class="bg-gray-800/80 backdrop-blur-md shadow-lg fixed w-full z-50 top-0">
        <div class="container mx-auto px-6 py-3 flex justify-between items-center">
            <a href="index.html" class="text-2xl font-bold text-teal-400">Gym<span class="text-white">Fitness</span>House</a>
            <div class="hidden md:flex space-x-4 items-center" id="nav-links">
                <a href="index.html" class="nav-link" data-page="index.html">Home</a>
                <a href="about.html" class="nav-link" data-page="about.html">About Us</a>
                <a href="classes.html" class="nav-link" data-page="classes.html">Classes</a>
                <a href="pricing.php" class="nav-link" data-page="pricing.php">Pricing</a>
                <a href="contact.html" class="nav-link" data-page="contact.html">Contact</a>
                </div>
            <div class="md:hidden flex items-center">
                <button id="mobile-menu-button" class="text-gray-200 hover:text-teal-400 focus:outline-none">
                    <i class="fas fa-bars text-2xl"></i>
                </button>
            </div>
        </div>
        <div id="mobile-menu" class="md:hidden hidden bg-gray-800">
            <a href="index.html" class="block nav-link px-4 py-2 text-sm" data-page="index.html">Home</a>
            <a href="about.html" class="block nav-link px-4 py-2 text-sm" data-page="about.html">About Us</a>
            <a href="classes.html" class="block nav-link px-4 py-2 text-sm" data-page="classes.html">Classes</a>
            <a href="pricing.php" class="block nav-link px-4 py-2 text-sm" data-page="pricing.php">Pricing</a>
            <a href="contact.html" class="block nav-link px-4 py-2 text-sm" data-page="contact.html">Contact</a>
            </div>
    </nav>

    <main class="flex-grow flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8 pt-32">
        <div class="max-w-md w-full space-y-8 bg-gray-800 p-10 rounded-xl shadow-2xl">
            <div>
                <h2 class="mt-6 text-center text-3xl font-extrabold text-white">
                    Create your account
                </h2>
            </div>
            <form id="signup-form" class="mt-8 space-y-6">
                <div>
                    <label for="signup-username" class="sr-only">Username</label>
                    <input id="signup-username" name="username" type="text" autocomplete="username" required
                           class="appearance-none rounded-md relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-gray-200 placeholder-gray-400 focus:outline-none focus:ring-teal-500 focus:border-teal-500 sm:text-sm"
                           placeholder="Username">
                </div>
                <div>
                    <label for="signup-email" class="sr-only">Email address</label>
                    <input id="signup-email" name="email" type="email" autocomplete="email" required
                           class="appearance-none rounded-md relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-gray-200 placeholder-gray-400 focus:outline-none focus:ring-teal-500 focus:border-teal-500 sm:text-sm"
                           placeholder="Email address">
                </div>
                <div>
                    <label for="signup-password" class="sr-only">Password</label>
                    <input id="signup-password" name="password" type="password" autocomplete="new-password" required
                           class="appearance-none rounded-md relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-gray-200 placeholder-gray-400 focus:outline-none focus:ring-teal-500 focus:border-teal-500 sm:text-sm"
                           placeholder="Password (min. 6 characters)">
                </div>
                <div>
                    <label for="signup-confirm-password" class="sr-only">Confirm Password</label>
                    <input id="signup-confirm-password" name="confirm-password" type="password" autocomplete="new-password" required
                           class="appearance-none rounded-md relative block w-full px-3 py-3 border border-gray-700 bg-gray-700 text-gray-200 placeholder-gray-400 focus:outline-none focus:ring-teal-500 focus:border-teal-500 sm:text-sm"
                           placeholder="Confirm Password">
                </div>

                <div>
                    <label for="membership-plan" class="block text-sm font-medium text-gray-300 mb-1">Choose a Membership Plan (Optional)</label>
                    <select id="membership-plan" name="membership-plan" class="w-full p-3 rounded-md bg-gray-700 text-gray-200 border border-gray-600 focus:ring-2 focus:ring-teal-500 focus:border-teal-500">
                        <option value="">Select a plan...</option>
                        <?php if (!empty($plans)): ?>
                            <?php foreach ($plans as $plan): ?>
                                <option value="<?php echo htmlspecialchars($plan['plan_key']); ?>">
                                    <?php echo htmlspecialchars($plan['plan_name']); ?> - $<?php echo htmlspecialchars(number_format($plan['price'], 2)); ?>/month
                                </option>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <option value="" disabled>No plans available at the moment.</option>
                        <?php endif; ?>
                    </select>
                </div>

                <div>
                    <button type="submit"
                            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-teal-600 hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-teal-500 cta-button">
                        Sign up
                    </button>
                </div>
                <p id="signup-message" class="text-center text-sm"></p>
            </form>
             <p class="mt-2 text-center text-sm text-gray-400">
                Already have an account?
                <a href="login.html" class="font-medium text-teal-500 hover:text-teal-400">
                    Sign in
                </a>
            </p>
        </div>
    </main>

    <footer class="bg-gray-900 border-t border-gray-700 py-12 mt-auto">
        <div class="container mx-auto px-6 text-center text-gray-400">
            <div class="mb-4">
                <a href="index.html" class="text-xl font-bold text-teal-400">Vision Gym<span class="text-white">Fitness</span>House</a>
            </div>
            <p class="text-sm">&copy; <span id="current-year"><?php echo date("Y"); ?></span> Gym Fitness House. All Rights Reserved.</p>
        </div>
    </footer>
    <script src="script.js"></script>
</body>
</html>
