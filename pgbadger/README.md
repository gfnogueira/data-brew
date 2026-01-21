# pgBadger - PostgreSQL Log Analyzer

PoC using pgBadger, an open source PostgreSQL log analyzer that generates detailed HTML reports about database performance, queries, and activity.

## What is pgBadger?

pgBadger is a PostgreSQL log analyzer written in Perl that parses PostgreSQL CSV log files and generates HTML reports. It's a well-established open source tool used in production environments for database monitoring and performance analysis.

**Official Repository**: https://github.com/darold/pgbadger

## Features

- **Query Performance Analysis**: Identifies slow queries and bottlenecks
- **Connection Statistics**: Tracks database connections and sessions
- **Error Detection**: Finds errors and warnings in logs
- **Temporary Files**: Monitors temp file usage
- **Checkpoint Statistics**: Analyzes checkpoint activity
- **HTML Reports**: Professional, interactive HTML reports

## Prerequisites

- PostgreSQL with logging enabled
- Perl 5.10+ (for pgBadger)
- PostgreSQL log files in CSV format

## Installation

### Install pgBadger

```bash
# macOS
brew install pgbadger

# Linux (Ubuntu/Debian)
sudo apt-get install pgbadger

# Or from source
git clone https://github.com/darold/pgbadger.git
cd pgbadger
perl Makefile.PL
make && sudo make install
```

### Configure PostgreSQL Logging

Edit `postgresql.conf`:

```ini
# Enable logging
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB

# Log format (CSV required for pgBadger)
log_destination = 'csvlog'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '

# What to log
log_min_duration_statement = 0  # Log all queries
log_connections = on
log_disconnections = on
log_duration = on
log_statement = 'all'  # or 'ddl', 'mod', 'all'
```

Restart PostgreSQL after configuration.

## Usage

### Basic Analysis

```bash
# Analyze a single log file
pgbadger /path/to/postgresql-*.log -o report.html

# Analyze multiple log files
pgbadger /path/to/postgresql-*.log -o report.html

# Analyze with specific options
pgbadger --prefix '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ' \
         /path/to/postgresql-*.log \
         -o report.html
```

### Advanced Options

```bash
# Include query samples
pgbadger --sample 100 /path/to/logs/*.log -o report.html

# Set timezone
pgbadger -T UTC /path/to/logs/*.log -o report.html

# Exclude specific databases
pgbadger --exclude-database template0,template1 /path/to/logs/*.log -o report.html

# Incremental reports (daily)
pgbadger --incremental /path/to/logs/ -o reports/
```

## Docker Setup

For easy testing, use the provided docker-compose setup:

```bash
# Start PostgreSQL with logging enabled
docker-compose up -d

# Generate some activity (optional)
docker-compose exec postgres psql -U postgres -d testdb -c "SELECT pg_sleep(1);"

# Wait for logs to be generated, then analyze
pgbadger ./logs/postgresql-*.log -o report.html

# Open report
open report.html
```

## Report Sections

The generated HTML report includes:

1. **Overview**: Summary statistics
2. **Time Range**: Log analysis period
3. **Queries**: Most frequent and slowest queries
4. **Connections**: Connection statistics
5. **Errors**: Errors and warnings
6. **Checkpoints**: Checkpoint activity
7. **Temporary Files**: Temp file usage
8. **Sessions**: Session statistics

## Use Cases

- **Performance Monitoring**: Identify slow queries and bottlenecks
- **Capacity Planning**: Understand database usage patterns
- **Troubleshooting**: Find errors and problematic queries
- **Security Auditing**: Review database access patterns
- **Compliance**: Generate audit reports for compliance

## Example Output

After running pgBadger, you'll get an HTML report with:
- Query performance graphs
- Top slow queries
- Connection statistics
- Error summaries
- Interactive charts and tables

## Integration

pgBadger can be integrated into monitoring pipelines:

```bash
# Daily cron job
0 1 * * * pgbadger --incremental /var/log/postgresql/ -o /var/www/reports/
```

## Resources

- **Official Documentation**: https://pgbadger.darold.net/documentation.html
- **GitHub Repository**: https://github.com/darold/pgbadger
- **PostgreSQL Logging**: https://www.postgresql.org/docs/current/runtime-config-logging.html

## Notes

- pgBadger requires CSV format logs (not standard text logs)
- Large log files may take time to process
- Reports are self-contained HTML files (no server needed)
- Can process compressed log files (.gz, .bz2)

---

**Tool Type**: Open Source (Perl)  
**Market Status**: Established tool, widely used  
**Complexity**: Simple to use, powerful results
