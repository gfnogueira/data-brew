# KSQLDB Proof of Concept (PoC)

This directory contains a simple Proof of Concept for KSQLDB, the streaming SQL engine for Apache Kafka.

## What is KSQLDB?
KSQLDB enables you to build real-time data pipelines and applications using SQL syntax on Kafka topics. You can create streams, tables, and perform transformations and aggregations in real time, without writing Java code.

## PoC Overview
This PoC demonstrates:
- Creating a stream from a Kafka topic
- Creating a table for stateful aggregations
- Performing a simple transformation (filtering and aggregation)

## How to Run
1. Start Apache Kafka and KSQLDB server (see official docs)
2. Use the KSQLDB CLI or REST API to execute the SQL scripts in this directory
3. Produce sample data to the Kafka topic (see `sample_data.json`)
4. Query the results in real time

## Files
- `01_create_stream.sql` - Create a stream from a Kafka topic
- `02_create_table.sql` - Create a table for aggregations
- `03_transformations.sql` - Example transformation and aggregation
- `04_windowed_aggregation.sql` - Windowed login count per user (10-minute windows)
- `05_top_n_users.sql` - Live leaderboard: top 3 users by event count
- `06_suspicious_activity.sql` - Detect suspicious purchase activity in 1-minute windows
- `sample_data.json` - Example data to produce to Kafka

## References
- [KSQLDB Documentation](https://ksqldb.io/)
- [Kafka Quickstart](https://kafka.apache.org/quickstart)
