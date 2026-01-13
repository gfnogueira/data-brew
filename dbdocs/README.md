# dbdocs

A command-line tool for generating database documentation from PostgreSQL schemas.

## Features

- Automatic schema extraction from PostgreSQL databases
- Generates Markdown documentation with table descriptions
- ERD-style relationship detection via foreign keys
- Column-level details including types, constraints, and comments
- Sample data preview for each table

## Installation

```bash
pip install -r requirements.txt
```

## Usage

```bash
# Generate documentation for all tables
python dbdocs.py --host localhost --database mydb --user postgres

# Specify output file
python dbdocs.py --host localhost --database mydb --user postgres --output docs/schema.md

# Include sample data (5 rows per table)
python dbdocs.py --host localhost --database mydb --user postgres --samples

# Filter specific schema
python dbdocs.py --host localhost --database mydb --user postgres --schema public

# Use environment variables
export PGHOST=localhost
export PGDATABASE=mydb
export PGUSER=postgres
export PGPASSWORD=secret
python dbdocs.py
```

## Environment Variables

| Variable     | Description           | Default   |
|--------------|-----------------------|-----------|
| PGHOST       | Database host         | localhost |
| PGPORT       | Database port         | 5432      |
| PGDATABASE   | Database name         | -         |
| PGUSER       | Database user         | postgres  |
| PGPASSWORD   | Database password     | -         |

## Output Structure

The generated documentation includes:

- Database overview with table count and total columns
- Table-by-table documentation with:
  - Column definitions (name, type, nullable, default)
  - Primary keys and foreign key relationships
  - Indexes
  - Table and column comments (if defined)
  - Sample data preview (optional)

