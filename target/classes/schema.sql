-- Drop tables in correct dependency order
DROP TABLE IF EXISTS complaint_status_history;
DROP TABLE IF EXISTS complaints;
DROP TABLE IF EXISTS users;

-- 1. Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('CUSTOMER', 'ADMIN', 'AGENT') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Complaints Table
CREATE TABLE complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    status ENUM('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED') DEFAULT 'OPEN',
    customer_id INT NOT NULL,
    assigned_agent_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_complaint_customer FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_complaint_agent FOREIGN KEY (assigned_agent_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Complaint Status History Table
CREATE TABLE complaint_status_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    status ENUM('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED') NOT NULL,
    remarks TEXT NULL,
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
    CONSTRAINT fk_history_user FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexes for performance optimization on foreign keys and email
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_complaint_customer ON complaints(customer_id);
CREATE INDEX idx_complaint_agent ON complaints(assigned_agent_id);
CREATE INDEX idx_history_complaint ON complaint_status_history(complaint_id);
CREATE INDEX idx_history_user ON complaint_status_history(changed_by);

-- Insert Sample Data
-- Note: passwords are dummy bcrypt hashes (password: "password123")
INSERT INTO users (id, name, email, password, role) VALUES 
(1, 'System Admin', 'admin@complaintportal.com', '$2a$10$tMh4bEVErC71s/9UoFfWb.X4tLlywN9B9L0/mZf7Jt234k7V.R1hS', 'ADMIN'),
(2, 'Support Agent', 'agent@complaintportal.com', '$2a$10$tMh4bEVErC71s/9UoFfWb.X4tLlywN9B9L0/mZf7Jt234k7V.R1hS', 'AGENT'),
(3, 'John Customer', 'customer@complaintportal.com', '$2a$10$tMh4bEVErC71s/9UoFfWb.X4tLlywN9B9L0/mZf7Jt234k7V.R1hS', 'CUSTOMER');

INSERT INTO complaints (id, title, description, category, status, customer_id, assigned_agent_id) VALUES
(1, 'Billing Issue', 'Overcharged on my monthly subscription fee for July.', 'Billing', 'OPEN', 3, NULL);

INSERT INTO complaint_status_history (id, complaint_id, status, remarks, changed_by) VALUES
(1, 1, 'OPEN', 'Complaint registered successfully by customer.', 3);
