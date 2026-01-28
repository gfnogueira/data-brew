# pg_activity - PostgreSQL Real-Time Monitoring

PoC using pg_activity, an open source PostgreSQL monitoring tool that provides a top-like interface for real-time database activity monitoring.

## What is pg_activity?

pg_activity is a command-line tool for monitoring PostgreSQL server activity in real-time. It's maintained by Dalibo Labs and provides a top-like interface showing running queries, connections, locks, and system resources.

**Official Repository**: https://github.com/dalibo/pg_activity

**Features**:
- Real-time query monitoring
- Process and connection tracking
- Lock detection and analysis
- Resource usage statistics
- Interactive filtering and sorting
- Color-coded performance metrics

## Installation

### macOS

```bash
brew install pg-activity
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get install pg-activity
```

### Python (pip)

```bash
pip install pg-activity
```

### From Source

```bash
git clone https://github.com/dalibo/pg_activity.git
cd pg_activity
pip install .
```

## Prerequisites

- PostgreSQL 9.6+ (tested on PostgreSQL 12+)
- Python 3.7+
- psycopg2 library

## Quick Start

### Basic Usage

```bash
# Connect to local PostgreSQL
pg_activity -U postgres -d mydb

# Connect to remote PostgreSQL
pg_activity -h localhost -U postgres -d mydb

# With password prompt
pg_activity -h localhost -U postgres -d mydb -W
```

### Docker Setup

This PoC includes a Docker Compose setup for easy testing:

```bash
# Start PostgreSQL
docker-compose up -d

# Run pg_activity
pg_activity -h localhost -p 5433 -U postgres -d testdb

## Interactive Commands

Once pg_activity is running, you can use these keyboard shortcuts:

- **Space**: Pause/Resume refresh
- **r**: Refresh now
- **q**: Quit
- **+/-**: Increase/Decrease refresh interval
- **f**: Filter by database/user/query
- **k**: Kill a query (with confirmation)
- **c**: Cancel a query
- **s**: Sort by different columns
- **?**: Show help

## Display Modes

pg_activity supports different display profiles:

```bash
# Narrow terminal (default)
pg_activity -U postgres -d mydb

# Wide terminal
pg_activity -U postgres -d mydb --profile wide

# Minimal display
pg_activity -U postgres -d mydb --profile minimal
```

## Use Cases

- **Performance Monitoring**: Identify slow queries in real-time
- **Troubleshooting**: Find blocking queries and locks
- **Capacity Planning**: Monitor connection and resource usage
- **Development**: Debug query performance during development
- **Production Monitoring**: Real-time visibility into database activity

## Example Output

pg_activity displays:
- **PID**: Process ID
- **Database**: Database name
- **User**: Connection user
- **Client**: Client address
- **CPU %**: CPU usage
- **Mem %**: Memory usage
- **Read/s**: Read operations per second
- **Write/s**: Write operations per second
- **Time**: Query duration
- **Query**: SQL query text

## Advanced Options

```bash
# Filter by database
pg_activity -U postgres --dbname mydb

# Filter by user
pg_activity -U postgres --filter user:postgres

# Set refresh interval (seconds)
pg_activity -U postgres --refresh 2

# Show only active queries
pg_activity -U postgres --no-idle

# Exclude system databases
pg_activity -U postgres --no-database postgres,template0,template1
```

## Integration

pg_activity can be integrated into monitoring workflows:

```bash
# Run in non-interactive mode for scripts
pg_activity -U postgres -d mydb --no-pause --refresh 5 > monitoring.log

# Use with watch command
watch -n 1 "pg_activity -U postgres -d mydb --no-pause"
```

## Comparison with Other Tools

- **pgBadger**: Analyzes historical logs (this tool monitors real-time)
- **pg_stat_statements**: Provides query statistics (this tool shows live activity)
- **pgAdmin**: GUI tool (this tool is CLI-based)

## Resources

- **Official Documentation**: https://github.com/dalibo/pg_activity
- **Dalibo Labs**: https://labs.dalibo.com/pg_activity
- **PostgreSQL Monitoring**: https://www.postgresql.org/docs/current/monitoring.html

## Troubleshooting

### Connection Issues

```bash
# Check PostgreSQL is running
docker-compose ps

# Test connection
psql -h localhost -p 5433 -U postgres -d testdb

# Check pg_activity version
pg_activity --version
```

### Permission Issues

pg_activity requires:
- Connection to PostgreSQL
- Ability to query `pg_stat_activity`
- Ability to query `pg_locks` (for lock information)

Grant necessary permissions:
```sql
GRANT pg_monitor TO your_user;
```

## Notes

- pg_activity reads from `pg_stat_activity` view
- Requires PostgreSQL 9.6+ for full functionality
- Works with AWS RDS (with appropriate permissions)
- Can monitor multiple databases simultaneously
- Non-intrusive (read-only monitoring)

---