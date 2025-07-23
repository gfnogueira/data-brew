# Redshift Proof of Concept (PoC)

This PoC demonstrates basic ingestion, querying, and visualization capabilities using Amazon Redshift.

## Goals
- Load CSV data into Redshift
- Run analytical queries
- Connect to BI tools (e.g., QuickSight)

## Steps
1. Deploy Redshift Serverless (or provisioned)
2. Use `scripts/load_data.sql` to ingest data from S3
3. Run queries from `scripts/sample_queries.sql`
4. Connect Redshift to your favorite BI tool
