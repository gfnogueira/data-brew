-- -----------------------------------------------
-- Create a sample table to store user data
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id INT,
    name VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP
);

-- -----------------------------------------------
-- Load CSV data from an S3 bucket using COPY
-- - This command reads data directly from S3
-- -----------------------------------------------
COPY users
FROM 's3://demo-redshift-csv/sample-users.csv'
IAM_ROLE 'arn:aws:iam::xxxx:role/service-role/AmazonRedshift-CommandsAccessRole-20250730T204952'
FORMAT AS CSV
IGNOREHEADER 1;

-- -----------------------------------------------
-- Query to verify that the data was loaded
-- - This will return all rows ordered by timestamp
-- -----------------------------------------------
SELECT *
FROM users
ORDER BY created_at;

-- -----------------------------------------------
-- Simple analytical query
-- - Count how many users were created per day
-- -----------------------------------------------
SELECT
  DATE(created_at) AS signup_date,
  COUNT(*) AS total_users
FROM users
GROUP BY signup_date
ORDER BY signup_date;