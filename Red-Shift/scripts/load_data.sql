-- Create sample table
CREATE TABLE IF NOT EXISTS users (
    id INT,
    name VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP
);

-- Load data from S3 (adjust bucket name and IAM role)
COPY users
FROM 's3://your-bucket-name/sample-users.csv'
IAM_ROLE 'arn:aws:iam::your-account-id:role/RedshiftRole'
FORMAT AS CSV
IGNOREHEADER 1;
