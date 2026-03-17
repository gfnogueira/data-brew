-- Source Database Initialization
-- Simulates an operational HR system

-- Departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    manager_id INTEGER,
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    department_id INTEGER REFERENCES departments(department_id),
    job_title VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Salary history table
CREATE TABLE salary_history (
    salary_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    effective_date DATE NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Projects table
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL,
    department_id INTEGER REFERENCES departments(department_id),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Project assignments
CREATE TABLE project_assignments (
    assignment_id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(project_id),
    employee_id INTEGER REFERENCES employees(employee_id),
    role VARCHAR(50),
    hours_allocated INTEGER,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data: Departments
INSERT INTO departments (department_name, location) VALUES
('Engineering', 'San Francisco'),
('Data Science', 'San Francisco'),
('Product', 'New York'),
('Marketing', 'New York'),
('Finance', 'Chicago'),
('Human Resources', 'Chicago');

-- Insert sample data: Employees
INSERT INTO employees (first_name, last_name, email, phone, hire_date, department_id, job_title) VALUES
('John', 'Smith', 'john.smith@company.com', '+1-555-0101', '2020-03-15', 1, 'Senior Engineer'),
('Emily', 'Johnson', 'emily.johnson@company.com', '+1-555-0102', '2019-06-20', 1, 'Staff Engineer'),
('Michael', 'Williams', 'michael.williams@company.com', '+1-555-0103', '2021-01-10', 2, 'Data Scientist'),
('Sarah', 'Brown', 'sarah.brown@company.com', '+1-555-0104', '2020-08-05', 2, 'ML Engineer'),
('David', 'Jones', 'david.jones@company.com', '+1-555-0105', '2019-11-15', 3, 'Product Manager'),
('Jennifer', 'Davis', 'jennifer.davis@company.com', '+1-555-0106', '2021-04-01', 3, 'Associate PM'),
('Robert', 'Miller', 'robert.miller@company.com', '+1-555-0107', '2020-02-20', 4, 'Marketing Manager'),
('Lisa', 'Wilson', 'lisa.wilson@company.com', '+1-555-0108', '2022-01-15', 4, 'Content Strategist'),
('James', 'Taylor', 'james.taylor@company.com', '+1-555-0109', '2018-09-10', 5, 'Finance Director'),
('Amanda', 'Anderson', 'amanda.anderson@company.com', '+1-555-0110', '2021-07-20', 5, 'Financial Analyst'),
('Christopher', 'Thomas', 'christopher.thomas@company.com', '+1-555-0111', '2019-05-01', 6, 'HR Manager'),
('Jessica', 'Jackson', 'jessica.jackson@company.com', '+1-555-0112', '2022-03-10', 6, 'Recruiter');

-- Update managers
UPDATE departments SET manager_id = 2 WHERE department_id = 1;
UPDATE departments SET manager_id = 3 WHERE department_id = 2;
UPDATE departments SET manager_id = 5 WHERE department_id = 3;
UPDATE departments SET manager_id = 7 WHERE department_id = 4;
UPDATE departments SET manager_id = 9 WHERE department_id = 5;
UPDATE departments SET manager_id = 11 WHERE department_id = 6;

-- Insert sample data: Salary history
INSERT INTO salary_history (employee_id, effective_date, salary) VALUES
(1, '2020-03-15', 120000.00),
(1, '2021-03-15', 135000.00),
(1, '2022-03-15', 150000.00),
(2, '2019-06-20', 140000.00),
(2, '2020-06-20', 155000.00),
(2, '2021-06-20', 170000.00),
(3, '2021-01-10', 110000.00),
(3, '2022-01-10', 125000.00),
(4, '2020-08-05', 115000.00),
(4, '2021-08-05', 130000.00),
(5, '2019-11-15', 125000.00),
(5, '2020-11-15', 140000.00),
(6, '2021-04-01', 95000.00),
(7, '2020-02-20', 110000.00),
(8, '2022-01-15', 85000.00),
(9, '2018-09-10', 160000.00),
(10, '2021-07-20', 90000.00),
(11, '2019-05-01', 105000.00),
(12, '2022-03-10', 75000.00);

-- Insert sample data: Projects
INSERT INTO projects (project_name, department_id, start_date, end_date, budget, status) VALUES
('Platform Modernization', 1, '2023-01-01', '2023-12-31', 500000.00, 'active'),
('ML Pipeline v2', 2, '2023-03-01', '2023-09-30', 250000.00, 'active'),
('Mobile App Launch', 3, '2023-02-01', '2023-08-31', 350000.00, 'completed'),
('Brand Refresh', 4, '2023-04-01', '2023-07-31', 150000.00, 'active'),
('Financial System Upgrade', 5, '2023-01-15', '2023-06-30', 200000.00, 'completed');

-- Insert sample data: Project assignments
INSERT INTO project_assignments (project_id, employee_id, role, hours_allocated, start_date) VALUES
(1, 1, 'Tech Lead', 40, '2023-01-01'),
(1, 2, 'Architect', 40, '2023-01-01'),
(2, 3, 'Lead Data Scientist', 40, '2023-03-01'),
(2, 4, 'ML Engineer', 40, '2023-03-01'),
(3, 5, 'Product Owner', 30, '2023-02-01'),
(3, 6, 'Product Analyst', 40, '2023-02-01'),
(4, 7, 'Project Lead', 30, '2023-04-01'),
(4, 8, 'Content Lead', 40, '2023-04-01'),
(5, 9, 'Project Sponsor', 10, '2023-01-15'),
(5, 10, 'Implementation Lead', 40, '2023-01-15');

-- Create indexes for common queries
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
CREATE INDEX idx_salary_history_employee ON salary_history(employee_id);
CREATE INDEX idx_salary_history_date ON salary_history(effective_date);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_assignments_project ON project_assignments(project_id);
CREATE INDEX idx_assignments_employee ON project_assignments(employee_id);
