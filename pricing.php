    <?php
    // pricing.php
    // Dynamically displays membership plans from the database.

    require_once 'db_config.php'; // For database connection and session start

    // Fetch all plans from the database
    $plans = [];
    $sql_fetch_plans = "SELECT plan_key, plan_name, price, description FROM plans ORDER BY price ASC"; // Order by price or some other logic
    if ($result_plans = $mysqli->query($sql_fetch_plans)) {
        while ($row_plan = $result_plans->fetch_assoc()) {
            $plans[] = $row_plan;
        }
        $result_plans->free();
    } else {
        // Handle error fetching plans, e.g., display a message
        // echo "Error fetching plans: " . $mysqli->error;
    }
    // $mysqli->close(); // Connection will be closed at the end of the script by PHP
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Pricing Plans - Vision Gym Fitness House</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <link rel="stylesheet" href="style.css">
        <style>
            body { font-family: 'Inter', sans-serif; }
            .nav-link { transition: color 0.3s ease; }
            .nav-link:hover { color: #2dd4bf; }
            .active-nav-link { color: #2dd4bf; font-weight: 600; }
            .section-title::after { content: ''; display: block; width: 60px; height: 4px; background-color: #2dd4bf; margin: 10px auto 0; border-radius: 2px; }
            .feature-card:hover { transform: translateY(-5px); box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); }
            .cta-button { transition: all 0.3s ease; }
            .cta-button:hover { transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05); }
            .popular-plan-highlight {
                border: 2px solid #2dd4bf; /* Teal border */
                box-shadow: 0 0 15px rgba(45, 212, 191, 0.5); /* Teal glow */
            }
        </style>
    </head>
    <body class="bg-gray-900 text-gray-100">

        <nav class="bg-gray-800/80 backdrop-blur-md shadow-lg fixed w-full z-50 top-0">
            <div class="container mx-auto px-6 py-3 flex justify-between items-center">
                <a href="index.html" class="text-2xl font-bold text-teal-400">Vision Gym<span class="text-white">Fitness</span>House</a>
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

        <main>
            <section id="pricing" class="py-16 md:py-24 bg-gray-800 pt-32">
                <div class="container mx-auto px-6">
                    <h2 class="section-title text-3xl md:text-4xl font-bold text-center mb-12">Membership <span class="text-teal-400">Plans</span></h2>
                    <p class="text-center text-gray-400 mb-12 max-w-2xl mx-auto">
                        Choose the plan that best fits your fitness goals and lifestyle. All plans come with access to our top-notch facilities and a supportive community. No hidden fees, just straightforward pricing.
                    </p>
                    
                    <?php if (empty($plans)): ?>
                        <p class="text-center text-xl text-yellow-400">No membership plans are currently available. Please check back later.</p>
                    <?php else: ?>
                        <div class="grid grid-cols-1 md:grid-cols-<?php echo min(count($plans), 3); ?> gap-8">
                            <?php foreach ($plans as $plan): ?>
                                <?php
                                    $is_popular = (strpos(strtolower($plan['plan_name']), 'pro') !== false); 
                                    $card_classes = "feature-card bg-gray-900 p-8 rounded-lg shadow-xl border border-gray-700 flex flex-col";
                                    if ($is_popular) {
                                        $card_classes = "feature-card bg-teal-600 p-8 rounded-lg shadow-2xl relative border-2 border-teal-400 flex flex-col popular-plan-highlight";
                                    }
                                ?>
                                <div class="<?php echo $card_classes; ?>">
                                    <?php if ($is_popular): ?>
                                        <span class="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-yellow-400 text-gray-900 text-xs font-bold px-3 py-1 rounded-full">POPULAR</span>
                                    <?php endif; ?>
                                    <h3 class="text-2xl font-semibold <?php echo $is_popular ? 'text-white' : 'text-teal-400'; ?> mb-2"><?php echo htmlspecialchars($plan['plan_name']); ?></h3>
                                    <p class="text-4xl font-bold <?php echo $is_popular ? 'text-white' : ''; ?> mb-1">
                                        Birr<?php echo htmlspecialchars(number_format($plan['price'], 2)); ?>
                                        <span class="text-lg font-normal <?php echo $is_popular ? 'text-gray-200' : 'text-gray-400'; ?>">/month</span>
                                    </p>
                                    <p class="<?php echo $is_popular ? 'text-gray-200' : 'text-gray-400'; ?> mb-6 min-h-[40px]">
                                        <?php echo htmlspecialchars(!empty($plan['description']) ? substr($plan['description'], 0, 100) . (strlen($plan['description']) > 100 ? '...' : '') : 'Access to our great facilities.'); ?>
                                    </p>
                                    
                                    <ul class="space-y-2 <?php echo $is_popular ? 'text-gray-100' : 'text-gray-300'; ?> mb-8 flex-grow">
                                        <li><i class="fas fa-check <?php echo $is_popular ? 'text-yellow-300' : 'text-teal-500'; ?> mr-2"></i>Full Gym Floor Access</li>
                                        <li><i class="fas fa-check <?php echo $is_popular ? 'text-yellow-300' : 'text-teal-500'; ?> mr-2"></i>Cardio Zone</li>
                                        <?php if ($plan['price'] > 30): ?>
                                            <li><i class="fas fa-check <?php echo $is_popular ? 'text-yellow-300' : 'text-teal-500'; ?> mr-2"></i>Group Fitness Classes</li>
                                        <?php else: ?>
                                            <li><i class="fas fa-times <?php echo $is_popular ? 'text-red-300' : 'text-red-500'; ?> mr-2"></i>Group Fitness Classes</li>
                                        <?php endif; ?>
                                        <?php if ($plan['price'] > 60): ?>
                                            <li><i class="fas fa-check <?php echo $is_popular ? 'text-yellow-300' : 'text-teal-500'; ?> mr-2"></i>Personal Training Discount</li>
                                        <?php endif; ?>
                                    </ul>
                                    <a href="signup.php?plan=<?php echo htmlspecialchars($plan['plan_key']); ?>" 
                                       class="cta-button mt-auto w-full text-center <?php echo $is_popular ? 'bg-white hover:bg-gray-100 text-teal-600' : 'bg-teal-500 hover:bg-teal-600 text-white'; ?> font-semibold py-3 px-6 rounded-lg">
                                        Sign Up for <?php echo htmlspecialchars($plan['plan_name']); ?>
                                    </a>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>

                    <div class="text-center mt-12 text-gray-400">
                        <p>All memberships are billed monthly. Cancel anytime with 30 days notice. <br>Day passes available for 150 Birr at the front desk.</p>
                    </div>
                </div>
            </section>
        </main>

        <footer class="bg-gray-900 border-t border-gray-700 py-12">
            <div class="container mx-auto px-6 text-center text-gray-400">
                <div class="mb-4">
                    <a href="index.html" class="text-xl font-bold text-teal-400">Gym<span class="text-white">Fitness</span>House</a>
                </div>
                <div class="space-x-4 mb-4">
                     <a href="#" class="hover:text-teal-400" aria-label="Facebook.com"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="hover:text-teal-400" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                    <a href="#" class="hover:text-teal-400" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="hover:text-teal-400" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
                </div>
                <p class="text-sm">&copy; <span id="current-year"><?php echo date("Y"); ?></span>Vision Gym Fitness House. All Rights Reserved.</p>
                 <p class="text-xs mt-2">Designed with <i class="fas fa-heart text-red-500"></i> & Tailwind CSS</p>
            </div>
        </footer>

        <script src="script.js"></script>
    </body>
    </html>
    