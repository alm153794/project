# Gym Fitness House Management System

A comprehensive web-based system for managing a gym, including user memberships, payments, and administrative tasks.

## Features

- **User Authentication**: Secure login and registration for members and admins
- **Membership Management**: Browse and subscribe to different gym plans
- **Payment Tracking**: Record and monitor payment status and history
- **Admin Dashboard**: Manage users, view payments, and handle inquiries
- **Messaging System**: Users can send messages/inquiries to administration
- **Plan Management**: Dynamic pricing and description for membership tiers

## Technology Stack

- **Backend**: PHP
- **Database**: MySQL
- **Frontend**: HTML, CSS, JavaScript
- **Server**: Apache / Nginx

## Database Setup

1. Install MySQL Server
2. Run the `sql.txt` script to create the database and tables
3. Configure database connection in `db_config.php`
4. Default Database Name: `gym_fitness_house_db`

## Installation

1. Clone the project to your web server root (e.g., htdocs or www)
2. Import the database schema using `sql.txt`
3. Verify credentials in `db_config.php`
4. Access the application via browser (e.g., `http://localhost/phpass`)

## Project Structure

```
phpass/
├── db_config.php      # Database connection settings
├── sql.txt            # Database schema and initial data
├── .gitignore         # Git configuration
└── README.md          # Project documentation
```

## User Roles

- **Admin**: Full access to manage users, payments, and system settings
- **User**: View plans, manage subscription, view payment history

## Membership Plans

- **Basic Access**: $29.00 - Access to all gym equipment during standard hours
- **Pro Fitness**: $59.00 - All Basic features plus unlimited group classes
- **Elite Performance**: $99.00 - All Pro features plus personal training sessions

## License
© 2024 Gym Fitness House. All rights reserved.
