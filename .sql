--TASK MANAGEMENT SYSTEM SCHEMA (ADVANCED SINGLE-PAGE VERSION)

/* USERS TABLE*/
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




/*USER ROLES TABLE*/
CREATE TABLE user_roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    role ENUM('admin', 'manager', 'employee') NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);




/* PROJECTS TABLE (Optional: For task grouping)*/
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);





/*TASKS TABLE*/
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    due_date DATE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);





/* TASK ASSIGNMENTS TABLE*/
CREATE TABLE task_assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    assigned_to INT NOT NULL,
    assigned_by INT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    FOREIGN KEY (assigned_by) REFERENCES users(id)
);




/* TASK STATUS HISTORY TABLE*/
CREATE TABLE task_status_updates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'blocked') NOT NULL,
    updated_by INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);







-- 7. TASK LOGS TABLE (For auditing actions)
CREATE TABLE task_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT,
    action VARCHAR(50),
    message TEXT,
    triggered_by INT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    FOREIGN KEY (triggered_by) REFERENCES users(id)
);







-- 8. TRIGGER TO LOG TASK CREATION
DELIMITER $$
CREATE TRIGGER after_task_insert
AFTER INSERT ON tasks
FOR EACH ROW
BEGIN
    INSERT INTO task_logs (task_id, action, message, triggered_by)
    VALUES (NEW.id, 'CREATE', CONCAT('Task "', NEW.title, '" created'), NEW.created_by);
END$$
DELIMITER ;







-- 9. SAMPLE DATA INSERTION
INSERT INTO users (name, email, password_hash) VALUES
('Admin1', 'admin1@sys.com', 'hashed123'),
('Manager1', 'manager@sys.com', 'hashed456'),
('Emp1', 'emp1@sys.com', 'hashed789');

INSERT INTO user_roles (user_id, role) VALUES
(1, 'admin'), (2, 'manager'), (3, 'employee');

INSERT INTO projects (name, description, created_by) VALUES
('Website Revamp', 'New design using Tailwind CSS', 1);

INSERT INTO tasks (project_id, title, description, priority, due_date, created_by) VALUES
(1, 'Create Landing Page', 'Design and code home page', 'high', '2025-08-15', 2);

INSERT INTO task_assignments (task_id, assigned_to, assigned_by) VALUES
(1, 3, 2);

INSERT INTO task_status_updates (task_id, status, updated_by) VALUES
(1, 'in_progress', 3);








-- 10. TRANSACTION: TRANSFER TASK FROM EMP3 TO EMP2
START TRANSACTION;
DELETE FROM task_assignments WHERE task_id = 1 AND assigned_to = 3;
INSERT INTO task_assignments (task_id, assigned_to, assigned_by) VALUES (1, 2, 1);
COMMIT;






-- 11. INDEXES FOR PERFORMANCE
CREATE INDEX idx_role ON user_roles(role);
CREATE INDEX idx_project_task ON tasks(project_id);
CREATE INDEX idx_task_assignment ON task_assignments(task_id);
CREATE INDEX idx_status_task ON task_status_updates(task_id);






-- 12. EXPLAIN QUERY
EXPLAIN SELECT t.title, u.name AS assignee
FROM tasks t
JOIN task_assignments ta ON t.id = ta.task_id
JOIN users u ON ta.assigned_to = u.id
JOIN user_roles ur ON u.id = ur.user_id
WHERE ur.role = 'employee';
