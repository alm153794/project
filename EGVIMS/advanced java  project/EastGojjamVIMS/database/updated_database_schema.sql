-- East Gojjam VIMS - Updated Database Schema
-- Final working version with all fixes applied

DROP DATABASE IF EXISTS East_Gojjam_VIMS_db;
CREATE DATABASE East_Gojjam_VIMS_db;
USE East_Gojjam_VIMS_db;

-- Users table for authentication and role management
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('admin', 'data_entry', 'guest') NOT NULL DEFAULT 'guest',
    status ENUM('active', 'deactive') NOT NULL DEFAULT 'active',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);

-- Birth records table
CREATE TABLE birth_records (
    record_id VARCHAR(20) PRIMARY KEY,
    child_first_name VARCHAR(50) NOT NULL,
    child_middle_name VARCHAR(50),
    child_last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female') NOT NULL,
    date_of_birth DATE NOT NULL,
    place_of_birth VARCHAR(100) NOT NULL,
    father_full_name VARCHAR(100) NOT NULL,
    mother_full_name VARCHAR(100) NOT NULL,
    wereda VARCHAR(100) NOT NULL DEFAULT 'Debre Markos',
    kebele VARCHAR(100) NOT NULL DEFAULT 'Kebele 01',
    registration_date DATE NOT NULL,
    registered_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    photo_path VARCHAR(255),
    FOREIGN KEY (registered_by) REFERENCES users(user_id)
);

-- Death records table
CREATE TABLE death_records (
    record_id VARCHAR(20) PRIMARY KEY,
    deceased_first_name VARCHAR(50) NOT NULL,
    deceased_middle_name VARCHAR(50),
    deceased_last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female') NOT NULL,
    date_of_death DATE NOT NULL,
    age_at_death INT NOT NULL,
    place_of_death VARCHAR(100) NOT NULL,
    cause_of_death TEXT,
    birth_record_id VARCHAR(20),
    wereda VARCHAR(100) NOT NULL DEFAULT 'Debre Markos',
    kebele VARCHAR(100) NOT NULL DEFAULT 'Kebele 01',
    registration_date DATE NOT NULL,
    registered_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    photo_path VARCHAR(255),
    FOREIGN KEY (registered_by) REFERENCES users(user_id),
    FOREIGN KEY (birth_record_id) REFERENCES birth_records(record_id)
);

-- Marriage records table
CREATE TABLE marriage_records (
    record_id VARCHAR(20) PRIMARY KEY,
    groom_first_name VARCHAR(50) NOT NULL,
    groom_middle_name VARCHAR(50),
    groom_last_name VARCHAR(50) NOT NULL,
    groom_age INT NOT NULL,
    groom_record_id VARCHAR(20),
    bride_first_name VARCHAR(50) NOT NULL,
    bride_middle_name VARCHAR(50),
    bride_last_name VARCHAR(50) NOT NULL,
    bride_age INT NOT NULL,
    bride_record_id VARCHAR(20),
    marriage_date DATE NOT NULL,
    marriage_place VARCHAR(100) NOT NULL,
    wereda VARCHAR(100) NOT NULL DEFAULT 'Debre Markos',
    kebele VARCHAR(100) NOT NULL DEFAULT 'Kebele 01',
    registration_date DATE NOT NULL,
    registered_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    photo_path VARCHAR(255),
    FOREIGN KEY (registered_by) REFERENCES users(user_id),
    FOREIGN KEY (groom_record_id) REFERENCES birth_records(record_id),
    FOREIGN KEY (bride_record_id) REFERENCES birth_records(record_id)
);

-- Divorce records table
CREATE TABLE divorce_records (
    record_id VARCHAR(20) PRIMARY KEY,
    husband_first_name VARCHAR(50) NOT NULL,
    husband_middle_name VARCHAR(50),
    husband_last_name VARCHAR(50) NOT NULL,
    husband_age INT NOT NULL,
    husband_record_id VARCHAR(20),
    wife_first_name VARCHAR(50) NOT NULL,
    wife_middle_name VARCHAR(50),
    wife_last_name VARCHAR(50) NOT NULL,
    wife_age INT NOT NULL,
    wife_record_id VARCHAR(20),
    marriage_date DATE NOT NULL,
    divorce_date DATE NOT NULL,
    divorce_place VARCHAR(100) NOT NULL,
    divorce_reason TEXT,
    marriage_record_id VARCHAR(20),
    wereda VARCHAR(100) NOT NULL DEFAULT 'Debre Markos',
    kebele VARCHAR(100) NOT NULL DEFAULT 'Kebele 01',
    registration_date DATE NOT NULL,
    registered_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    photo_path VARCHAR(255),
    FOREIGN KEY (registered_by) REFERENCES users(user_id),
    FOREIGN KEY (marriage_record_id) REFERENCES marriage_records(record_id),
    FOREIGN KEY (husband_record_id) REFERENCES birth_records(record_id),
    FOREIGN KEY (wife_record_id) REFERENCES birth_records(record_id)
);

-- Immigration records table
CREATE TABLE immigration_records (
    record_id VARCHAR(20) PRIMARY KEY,
    person_first_name VARCHAR(50) NOT NULL,
    person_middle_name VARCHAR(50),
    person_last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female') NOT NULL,
    date_of_birth DATE NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    passport_number VARCHAR(50),
    immigration_type ENUM('Immigration', 'Emigration') NOT NULL,
    from_country VARCHAR(50),
    to_country VARCHAR(50),
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    immigration_date DATE NOT NULL,
    purpose TEXT,
    duration_days INT,
    birth_record_id VARCHAR(20),
    person_record_id VARCHAR(20),
    wereda VARCHAR(100) NOT NULL DEFAULT 'Debre Markos',
    kebele VARCHAR(100) NOT NULL DEFAULT 'Kebele 01',
    registration_date DATE NOT NULL,
    registered_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    photo_path VARCHAR(255),
    FOREIGN KEY (registered_by) REFERENCES users(user_id),
    FOREIGN KEY (birth_record_id) REFERENCES birth_records(record_id)
);

-- Feedback table for user feedback system
CREATE TABLE feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('pending', 'reviewed', 'resolved') DEFAULT 'pending',
    admin_reply TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default admin user
INSERT INTO users (username, password, full_name, email, role, status) VALUES
('admin', 'admin123', 'System Administrator', 'admin@eastgojjam.gov.et', 'admin', 'active'),
('dataentry', 'data123', 'Data Entry Officer', 'dataentry@eastgojjam.gov.et', 'data_entry', 'active'),
('guest', 'guest123', 'Guest User', 'guest@eastgojjam.gov.et', 'guest', 'active');

-- Sample birth records
INSERT INTO birth_records (record_id, child_first_name, child_middle_name, child_last_name, gender, date_of_birth, place_of_birth, father_full_name, mother_full_name, wereda, kebele, registration_date, registered_by) VALUES
('ETH2020001234567', 'Abebe', 'Kebede', 'Alemu', 'Male', '2020-03-15', 'Debre Markos Hospital', 'Kebede Alemu Tadesse', 'Almaz Bekele Girma', 'Debre Markos', 'Kebele 01', '2020-03-20', 1),
('ETH2021002345678', 'Hanan', 'Mohammed', 'Ahmed', 'Female', '2021-07-22', 'Debre Markos Health Center', 'Mohammed Ahmed Hassan', 'Fatima Ibrahim Ali', 'Debre Markos', 'Kebele 02', '2021-07-25', 2),
('ETH2022003456789', 'Dawit', 'Tesfaye', 'Mengistu', 'Male', '2022-01-10', 'Bichena Hospital', 'Tesfaye Mengistu Wolde', 'Selamawit Getachew Tadesse', 'Bichena', 'Kebele 01', '2022-01-15', 1);

-- Sample death records
INSERT INTO death_records (record_id, deceased_first_name, deceased_middle_name, deceased_last_name, gender, date_of_death, age_at_death, place_of_death, cause_of_death, birth_record_id, wereda, kebele, registration_date, registered_by) VALUES
('DTH2023001234567', 'Ato', 'Girma', 'Tadesse', 'Male', '2023-05-10', 75, 'Debre Markos Hospital', 'Natural causes', NULL, 'Debre Markos', 'Kebele 03', '2023-05-12', 1);

-- Sample marriage records
INSERT INTO marriage_records (record_id, groom_first_name, groom_middle_name, groom_last_name, groom_age, bride_first_name, bride_middle_name, bride_last_name, bride_age, marriage_date, marriage_place, wereda, kebele, registration_date, registered_by) VALUES
('MAR2023001234567', 'Yohannes', 'Desta', 'Bekele', 25, 'Meron', 'Tadesse', 'Alemu', 22, '2023-06-15', 'St. George Church', 'Debre Markos', 'Kebele 01', '2023-06-20', 2);

-- Sample divorce records
INSERT INTO divorce_records (record_id, husband_first_name, husband_middle_name, husband_last_name, husband_age, wife_first_name, wife_middle_name, wife_last_name, wife_age, marriage_date, divorce_date, divorce_place, divorce_reason, wereda, kebele, registration_date, registered_by) VALUES
('DIV2023001234567', 'Alemayehu', 'Getachew', 'Tadesse', 35, 'Tigist', 'Mulugeta', 'Bekele', 30, '2018-02-14', '2023-08-20', 'Debre Markos Court', 'Irreconcilable differences', 'Debre Markos', 'Kebele 02', '2023-08-25', 1);

-- Sample immigration records
INSERT INTO immigration_records (record_id, person_first_name, person_middle_name, person_last_name, gender, date_of_birth, nationality, passport_number, immigration_type, from_country, to_country, immigration_date, purpose, wereda, kebele, registration_date, registered_by) VALUES
('IMM2023001234567', 'Sara', 'Ahmed', 'Mohammed', 'Female', '1995-04-12', 'Ethiopian', 'EP1234567', 'Emigration', 'Ethiopia', 'United States', '2023-09-10', 'Education', 'Debre Markos', 'Kebele 01', '2023-09-05', 2);

-- Create indexes for better performance
CREATE INDEX idx_birth_registration_date ON birth_records(registration_date);
CREATE INDEX idx_death_registration_date ON death_records(registration_date);
CREATE INDEX idx_marriage_registration_date ON marriage_records(registration_date);
CREATE INDEX idx_divorce_registration_date ON divorce_records(registration_date);
CREATE INDEX idx_immigration_registration_date ON immigration_records(registration_date);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_feedback_status ON feedback(status);

-- Views for reporting
CREATE VIEW record_statistics AS
SELECT 
    'Birth' as record_type, COUNT(*) as total_count, wereda, kebele
FROM birth_records 
GROUP BY wereda, kebele
UNION ALL
SELECT 
    'Death' as record_type, COUNT(*) as total_count, wereda, kebele
FROM death_records 
GROUP BY wereda, kebele
UNION ALL
SELECT 
    'Marriage' as record_type, COUNT(*) as total_count, wereda, kebele
FROM marriage_records 
GROUP BY wereda, kebele
UNION ALL
SELECT 
    'Divorce' as record_type, COUNT(*) as total_count, wereda, kebele
FROM divorce_records 
GROUP BY wereda, kebele
UNION ALL
SELECT 
    'Immigration' as record_type, COUNT(*) as total_count, wereda, kebele
FROM immigration_records 
GROUP BY wereda, kebele;