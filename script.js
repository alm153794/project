// script.js - Consolidated for PHP Backend Interaction

// --- GLOBAL STATE ---
let currentUser = null; // Will be populated by checkUserLoginStatus

// --- INITIALIZATION ---
document.addEventListener('DOMContentLoaded', async () => {
    await checkUserLoginStatus(); // This will populate currentUser

    updateNavigation();
    updateCopyrightYear();
    setupMobileMenu();
    setupSmoothScroll();
    highlightActiveNavLink();
    setupContactForm(); // Now sends to PHP

    const currentPage = window.location.pathname.split("/").pop() || "index.html";

    if (currentPage === 'signup.php' || currentPage === 'signup.html') { // Allow for both during transition
        setupSignupForm();
        prefillPlanFromURL();
    } else if (currentPage === 'login.html') {
        setupLoginForm();
    } else if (currentPage === 'dashboard.html') {
        if (!currentUser || !currentUser.loggedIn) {
            window.location.href = 'login.html';
            return;
        }
        setupDashboard();
    }
    // For pricing.php, plan data is loaded by PHP itself.
});

// --- COOKIE UTILS ---
function setCookie(name, value, days) {
    let expires = "";
    if (days) {
        const date = new Date();
        date.setTime(date.getTime() + (days*24*60*60*1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + encodeURIComponent(value) + expires + "; path=/";
}
function getCookie(name) {
    const value = "; " + document.cookie;
    const parts = value.split("; " + name + "=");
    if (parts.length === 2) return decodeURIComponent(parts.pop().split(";").shift());
    return "";
}
function deleteCookie(name) {
    document.cookie = name + "=; Max-Age=0; path=/";
}

// --- AUTHENTICATION & USER STATE FUNCTIONS ---

async function checkUserLoginStatus() {
    try {
        const response = await fetch('api/user_auth_check.php', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        if (!response.ok) {
            console.error('Auth check failed with status:', response.status);
            currentUser = { loggedIn: false };
            return;
        }
        const data = await response.json();
        if (data.loggedIn && data.user) {
            currentUser = {
                loggedIn: true,
                username: data.user.username,
                email: data.user.email,
                plan: data.user.plan,
                paymentCompleted: data.user.paymentCompleted
            };
        } else {
            currentUser = { loggedIn: false };
        }
    } catch (error) {
        console.error('Error checking user login status:', error);
        currentUser = { loggedIn: false };
    }
}

function setupSignupForm() {
    const signupForm = document.getElementById('signup-form');
    if (!signupForm) return;

    signupForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const username = document.getElementById('signup-username').value.trim();
        const email = document.getElementById('signup-email').value.trim();
        const password = document.getElementById('signup-password').value;
        const confirmPassword = document.getElementById('signup-confirm-password').value;
        const planSelect = document.getElementById('membership-plan');
        const plan = planSelect ? planSelect.value : '';
        const messageEl = document.getElementById('signup-message');

        clearMessage(messageEl);

        if (!username || !email || !password || !confirmPassword) {
            displayMessage(messageEl, 'All fields are required.', false);
            return;
        }
        if (!/\S+@\S+\.\S+/.test(email)) {
            displayMessage(messageEl, 'Please enter a valid email address.', false);
            return;
        }
        if (password.length < 6) {
            displayMessage(messageEl, 'Password must be at least 6 characters.', false);
            return;
        }
        if (password !== confirmPassword) {
            displayMessage(messageEl, 'Passwords do not match.', false);
            return;
        }

        try {
            const response = await fetch('api/user_signup_handler.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, email, password, plan })
            });
            const data = await response.json();
            if (data.success) {
                displayMessage(messageEl, data.message + ' Redirecting to login...', true);
                setTimeout(() => {
                    window.location.href = 'login.html';
                }, 2500);
            } else {
                displayMessage(messageEl, data.message || 'Signup failed.', false);
            }
        } catch (error) {
            console.error('Signup error:', error);
            displayMessage(messageEl, 'An error occurred during signup. Please try again.', false);
        }
    });
}

function setupLoginForm() {
    const loginForm = document.getElementById('login-form');
    if (!loginForm) return;

    // Prefill email if cookie exists
    const rememberedEmail = getCookie('remembered_email');
    if (rememberedEmail) {
        const emailInput = document.getElementById('login-email');
        if (emailInput) emailInput.value = rememberedEmail;
    }

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('login-email').value.trim();
        const password = document.getElementById('login-password').value;
        const rememberMe = document.getElementById('remember-me');
        const messageEl = document.getElementById('login-message');
        
        clearMessage(messageEl);

        if (!email || !password) {
            displayMessage(messageEl, 'Email and password are required.', false);
            return;
        }
        if (!/\S+@\S+\.\S+/.test(email)) {
            displayMessage(messageEl, 'Please enter a valid email address.', false);
            return;
        }

        try {
            const response = await fetch('api/user_login_handler.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });
            const data = await response.json();
            if (data.success && data.user) {
                currentUser = {
                    loggedIn: true,
                    username: data.user.username,
                    email: data.user.email,
                    plan: data.user.plan,
                    paymentCompleted: data.user.paymentCompleted
                };
                // Set or clear cookie based on "Remember Me"
                if (rememberMe && rememberMe.checked) {
                    setCookie('remembered_email', email, 7);
                } else {
                    deleteCookie('remembered_email');
                }
                displayMessage(messageEl, data.message + ' Redirecting to dashboard...', true);
                setTimeout(() => {
                    window.location.href = 'dashboard.html';
                }, 1500);
            } else {
                displayMessage(messageEl, data.message || 'Login failed.', false);
            }
        } catch (error) {
            console.error('Login error:', error);
            displayMessage(messageEl, 'An error occurred during login. Please try again.', false);
        }
    });
}

async function logoutUser() {
    try {
        const response = await fetch('api/user_logout_handler.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
        const data = await response.json();
        if (data.success) {
            currentUser = { loggedIn: false };
            updateNavigation(); 
            const currentPageFile = window.location.pathname.split("/").pop() || "index.html";
            if (currentPageFile.includes('dashboard.html')) {
                window.location.href = 'index.html';
            } else {
                 window.location.reload(); 
            }
        } else {
            console.error('Logout failed:', data.message);
        }
    } catch (error) {
        console.error('Error during logout:', error);
    }
}

// --- NAVIGATION ---
function updateNavigation() {
    const navLinksContainer = document.getElementById('nav-links'); 
    const mobileMenuContainer = document.getElementById('mobile-menu'); 
    
    const clearAuthLinks = (container) => {
        if (container) {
            container.querySelectorAll('.auth-link, .auth-greeting, #nav-logout-button, .auth-link-mobile, #mobile-nav-logout-button').forEach(el => el.remove());
        }
    };

    clearAuthLinks(navLinksContainer);
    clearAuthLinks(mobileMenuContainer);

    const dashboardUserGreeting = document.getElementById('user-greeting');
    const dashboardUserGreetingMobile = document.getElementById('user-greeting-mobile');

    if (currentUser && currentUser.loggedIn) {
        const greetingText = `Hi, ${currentUser.username}!`;

        if (dashboardUserGreeting) dashboardUserGreeting.textContent = greetingText;
        if (dashboardUserGreetingMobile) dashboardUserGreetingMobile.textContent = greetingText;

        if (navLinksContainer) {
            const dashboardLink = createNavLink('dashboard.html', 'Dashboard', 'auth-link');
            navLinksContainer.appendChild(dashboardLink);

            const logoutButton = document.createElement('button');
            logoutButton.id = 'nav-logout-button';
            logoutButton.className = 'bg-red-500 hover:bg-red-600 text-white px-3 py-2 rounded-md text-sm font-medium auth-link cta-button';
            logoutButton.textContent = 'Logout';
            logoutButton.addEventListener('click', logoutUser);
            navLinksContainer.appendChild(logoutButton);
        }

        if (mobileMenuContainer) {
            const dashboardLinkMobile = createNavLink('dashboard.html', 'Dashboard', 'auth-link-mobile', true);
            mobileMenuContainer.appendChild(dashboardLinkMobile);

            const logoutButtonMobile = document.createElement('button');
            logoutButtonMobile.id = 'mobile-nav-logout-button';
            logoutButtonMobile.className = 'block w-full text-left bg-red-500 hover:bg-red-600 text-white mt-1 mx-4 mb-2 px-4 py-2 text-sm rounded-md auth-link-mobile cta-button';
            logoutButtonMobile.textContent = 'Logout';
            logoutButtonMobile.addEventListener('click', logoutUser);
            mobileMenuContainer.appendChild(logoutButtonMobile);
        }
    } else {
        if (dashboardUserGreeting) dashboardUserGreeting.textContent = '';
        if (dashboardUserGreetingMobile) dashboardUserGreetingMobile.textContent = '';

        if (navLinksContainer) {
            const loginLink = createNavLink('login.html', 'Login', 'auth-link');
            navLinksContainer.appendChild(loginLink);
            const signupLink = createNavLink('signup.php', 'Sign Up', 'auth-link cta-button bg-teal-500 hover:bg-teal-600 text-white'); // Link to .php
            navLinksContainer.appendChild(signupLink);
        }

        if (mobileMenuContainer) {
            const loginLinkMobile = createNavLink('login.html', 'Login', 'auth-link-mobile', true);
            mobileMenuContainer.appendChild(loginLinkMobile);
            const signupLinkMobile = createNavLink('signup.php', 'Sign Up', 'auth-link-mobile cta-button bg-teal-500 hover:bg-teal-600 text-white text-center mt-1 mx-4 mb-2', true); // Link to .php
            mobileMenuContainer.appendChild(signupLinkMobile);
        }
    }
    highlightActiveNavLink();
}

function createNavLink(href, text, baseClass, isMobile = false) {
    const link = document.createElement('a');
    link.href = href;
    link.textContent = text;
    link.setAttribute('data-page', href);
    if (isMobile) {
        link.className = `block nav-link hover:text-teal-400 px-4 py-2 text-sm ${baseClass}`;
    } else {
        link.className = `nav-link hover:text-teal-400 px-3 py-2 rounded-md text-sm font-medium ${baseClass}`;
    }
    if (baseClass.includes('cta-button')) {
        if(!isMobile) {
            link.classList.remove('nav-link'); 
        }
    }
    return link;
}

function highlightActiveNavLink() {
    let currentPageFile = window.location.pathname.split("/").pop() || "index.html";
    // Normalize for .php extensions if they exist
    if (currentPageFile === "pricing.html") currentPageFile = "pricing.php";
    if (currentPageFile === "signup.html") currentPageFile = "signup.php";

    const navLinks = document.querySelectorAll('#nav-links a, #mobile-menu a, .auth-link, .auth-link-mobile');

    navLinks.forEach(link => {
        let linkPage = link.getAttribute('data-page');
        if (linkPage) {
             // Normalize linkPage for .php as well
            if (linkPage === "pricing.html") linkPage = "pricing.php";
            if (linkPage === "signup.html") linkPage = "signup.php";

            if (linkPage === currentPageFile) {
                link.classList.add('active-nav-link');
            } else {
                link.classList.remove('active-nav-link');
            }
        }
    });
}

// --- DASHBOARD FUNCTIONS ---
function setupDashboard() {
    if (!currentUser || !currentUser.loggedIn) {
        window.location.href = 'login.html'; 
        return;
    }
    
    const userPlanEl = document.getElementById('user-plan');
    const dashboardPaymentSection = document.getElementById('dashboard-payment-section');
    const dashSelectedPlanInput = document.getElementById('dash-selected-plan');
    const manageSubscriptionButton = document.getElementById('manage-subscription-button');
    const paymentStatusMessage = document.getElementById('payment-status-message');

    if (userPlanEl) {
        const planKey = currentUser.plan; 
        let planDisplayName = "No Plan Selected";
        if (planKey && planKey !== 'none' && planKey !== null) {
            planDisplayName = planKey.charAt(0).toUpperCase() + planKey.slice(1);
        }

        // Reset status message
        if (paymentStatusMessage) paymentStatusMessage.textContent = "";

        if (planKey && planKey !== 'none' && planKey !== null) {
            // Show payment status
            if (
                currentUser.paymentCompleted === true ||
                currentUser.paymentCompleted === 'completed'
            ) {
                userPlanEl.textContent = `Your current plan: ${planDisplayName}. Payment Confirmed.`;
                if (dashboardPaymentSection) dashboardPaymentSection.classList.add('hidden');
                if (manageSubscriptionButton) manageSubscriptionButton.textContent = "Manage Subscription";
                if (paymentStatusMessage) {
                    paymentStatusMessage.textContent = "✅ Your payment is approved!";
                    paymentStatusMessage.className = "mt-4 text-center text-base font-semibold text-green-400";
                }
            } else if (
                currentUser.paymentCompleted === 'pending_approval'
            ) {
                userPlanEl.textContent = `Your selected plan: ${planDisplayName}.`;
                if (dashboardPaymentSection) dashboardPaymentSection.classList.add('hidden');
                if (manageSubscriptionButton) manageSubscriptionButton.textContent = "Complete Payment";
                if (paymentStatusMessage) {
                    paymentStatusMessage.textContent = "⏳ Your payment is pending admin approval.";
                    paymentStatusMessage.className = "mt-4 text-center text-base font-semibold text-yellow-400";
                }
            } else if (currentUser.paymentCompleted === 'failed') {
                userPlanEl.textContent = `Your selected plan: ${planDisplayName}. Payment failed. Please try again.`;
                if (dashboardPaymentSection && dashSelectedPlanInput) {
                    dashboardPaymentSection.classList.remove('hidden');
                    dashSelectedPlanInput.value = planDisplayName;
                }
                if (manageSubscriptionButton) manageSubscriptionButton.textContent = "Complete Payment";
                if (paymentStatusMessage) {
                    paymentStatusMessage.textContent = "❌ Your payment was rejected. Please resubmit or contact support.";
                    paymentStatusMessage.className = "mt-4 text-center text-base font-semibold text-red-400";
                }
            } else if (
                !currentUser.paymentCompleted ||
                currentUser.paymentCompleted === 'none' ||
                currentUser.paymentCompleted === '' ||
                currentUser.paymentCompleted === null
            ) {
                // Show payment form for 'none', null, undefined, or empty
                userPlanEl.textContent = `Your selected plan: ${planDisplayName}.`;
                if (dashboardPaymentSection && dashSelectedPlanInput) {
                    dashboardPaymentSection.classList.remove('hidden');
                    dashSelectedPlanInput.value = planDisplayName;
                }
                if (manageSubscriptionButton) manageSubscriptionButton.textContent = "Complete Payment";
                if (paymentStatusMessage) paymentStatusMessage.textContent = "";
            }
        } else {
            userPlanEl.textContent = "You have not selected a membership plan yet.";
            if (manageSubscriptionButton) manageSubscriptionButton.textContent = "Choose a Plan";
            if (dashboardPaymentSection) dashboardPaymentSection.classList.add('hidden');
            if (paymentStatusMessage) paymentStatusMessage.textContent = "";
        }
    }
    
    if (manageSubscriptionButton) {
        manageSubscriptionButton.addEventListener('click', () => {
            if (currentUser.plan && currentUser.plan !== 'none' && currentUser.plan !== null && !currentUser.paymentCompleted) {
                 const paymentForm = document.getElementById('dashboard-payment-section');
                 if (paymentForm) {
                    paymentForm.classList.remove('hidden');
                    paymentForm.scrollIntoView({ behavior: 'smooth' });
                 }
            } else {
                window.location.href = 'pricing.php'; 
            }
        });
    }

    const dashboardPaymentForm = document.getElementById('dashboard-payment-form');
    if (dashboardPaymentForm) {
        dashboardPaymentForm.addEventListener('submit', (e) => handlePaymentSubmission(e, 'dashboard-payment-message', 'dash-selected-plan'));
    }
}

async function handlePaymentSubmission(event, messageElementId, planInputElementId) {
    event.preventDefault();
    const messageEl = document.getElementById(messageElementId);
    const planInput = document.getElementById(planInputElementId);
    const planDisplayName = planInput ? planInput.value : "Selected Plan";
    const transactionIdInput = document.getElementById('dash-transaction-id');
    const transactionId = transactionIdInput ? transactionIdInput.value.trim() : "";

    clearMessage(messageEl);

    if (!transactionId) {
        displayMessage(messageEl, 'Please enter your CBE transaction ID.', false);
        return;
    }

    displayMessage(messageEl, `Submitting transaction ID for ${planDisplayName}...`, true, 'text-yellow-400');

    try {
        const planKeyToSubmit = currentUser.plan;
        if (!planKeyToSubmit || planKeyToSubmit === 'none' || planKeyToSubmit === null) {
            displayMessage(messageEl, 'No plan selected for payment.', false);
            return;
        }

        const response = await fetch('api/user_payment_handler.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                plan_key: planKeyToSubmit,
                transaction_id: transactionId
            })
        });
        const data = await response.json();

        if (data.success) {
            displayMessage(messageEl, data.message || `Transaction ID submitted for approval!`, true);
            if (currentUser) {
                currentUser.paymentCompleted = 'pending_approval'; // Set to pending
            }
            setupDashboard();
            const formToReset = document.getElementById('dashboard-payment-form');
            if (formToReset) formToReset.reset();
            if (document.getElementById('dashboard-payment-section')) {
                document.getElementById('dashboard-payment-section').classList.add('hidden');
            }
        } else {
            displayMessage(messageEl, data.message || 'Submission failed.', false);
        }
    } catch (error) {
        console.error('Payment submission error:', error);
        displayMessage(messageEl, 'An error occurred during submission.', false);
    }
}

// --- CONTACT FORM (Updated to send to PHP) ---
function setupContactForm() {
    const contactForm = document.getElementById('contact-form');
    if (!contactForm) return; 

    contactForm.addEventListener('submit', async (e) => { 
        e.preventDefault();
        const name = document.getElementById('name').value.trim();
        const email = document.getElementById('email').value.trim();
        const subject = document.getElementById('subject').value.trim();
        const messageText = document.getElementById('message').value.trim(); 
        const messageEl = document.getElementById('contact-form-message');

        clearMessage(messageEl);

        if (!name || !email || !subject || !messageText) {
            displayMessage(messageEl, 'Please fill all fields.', false);
            return;
        }
        if (!/\S+@\S+\.\S+/.test(email)) {
            displayMessage(messageEl, 'Please enter a valid email address.', false);
            return;
        }

        displayMessage(messageEl, 'Sending your message...', true, 'text-yellow-400'); 

        try {
            const response = await fetch('api/contact_form_handler.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ 
                    name: name, 
                    email: email, 
                    subject: subject, 
                    message: messageText 
                })
            });
            const data = await response.json();

            if (data.success) {
                displayMessage(messageEl, data.message || 'Message sent successfully!', true);
                contactForm.reset();
            } else {
                displayMessage(messageEl, data.message || 'Failed to send message.', false);
            }
        } catch (error) {
            console.error('Contact form submission error:', error);
            displayMessage(messageEl, 'An error occurred while sending your message. Please try again.', false);
        }
    });
}

// --- COMMON UTILITY FUNCTIONS ---
function updateCopyrightYear() {
    document.querySelectorAll('#current-year').forEach(span => {
        if (span) span.textContent = new Date().getFullYear();
    });
}

function setupMobileMenu() {
    const menuButton = document.getElementById('mobile-menu-button');
    const mobileMenu = document.getElementById('mobile-menu');
    if (menuButton && mobileMenu) {
        menuButton.addEventListener('click', () => {
            mobileMenu.classList.toggle('hidden');
        });
    }
}

function setupSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const hrefAttribute = this.getAttribute('href');
            if (hrefAttribute.length > 1 && document.querySelector(hrefAttribute)) {
                e.preventDefault();
                document.querySelector(hrefAttribute).scrollIntoView({ behavior: 'smooth' });
                const mobileMenu = document.getElementById('mobile-menu');
                if (mobileMenu && !mobileMenu.classList.contains('hidden')) {
                    mobileMenu.classList.add('hidden');
                }
            }
        });
    });
}

function prefillPlanFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    const plan = urlParams.get('plan'); 
    if (plan) {
        const planSelect = document.getElementById('membership-plan');
        if (planSelect) {
            planSelect.value = plan;
        }
    }
}

function clearMessage(element) { 
    if (!element) return;
    element.textContent = '';
    element.className = 'text-center text-sm'; 
}

function displayMessage(element, message, isSuccess, customClass = null) {
    if (!element) return;
    element.textContent = message;
    
    const baseMessageClasses = ['text-center', 'text-sm', 'p-3', 'rounded-md', 'my-2', 'border'];
    let typeClasses = [];

    element.className = ''; 

    if (customClass) {
        const customClassesArray = Array.isArray(customClass) ? customClass : customClass.split(' ');
        element.classList.add(...baseMessageClasses, ...customClassesArray);
    } else {
        if (isSuccess) {
            typeClasses = ['bg-green-500', 'text-white', 'border-green-600']; 
        } else {
            typeClasses = ['bg-red-500', 'text-white', 'border-red-600'];
        }
        element.classList.add(...baseMessageClasses, ...typeClasses);
    }
}
