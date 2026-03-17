# Marquez

## Quick Start

### Prerequisites
- Docker or Podman
- curl and jq (optional, for scripts)

### Setup 
```bash
# 1. Start services
make start

# 2. Wait for services to be ready (2-3 minutes)
make status

# 3. Load demo data
chmod +x *.sh
./load-demo-data.sh

# 4. Validate setup
./validate-demo.sh

# 5. Open demo
open http://localhost:3000
```

## Demo Navigation

### The Story
Show how Marquez solves the "6-hour pipeline debugging nightmare" in 30 seconds.

### Demo Flow
1. **Open**: http://localhost:3000
2. **Click**: Jobs tab
3. **Show**: extract-orders, transform-sales, load-warehouse
4. **Click**: any job (e.g., extract-orders)
5. **WOW moment**: Graph View -> Visual lineage!

### What Audience Sees
```
raw_orders -> extract-orders -> orders_clean -> transform-sales -> sales_summary -> load-warehouse -> warehouse_sales
```

## Architecture

### Services
- **marquez-db**: PostgreSQL database
- **marquez-api**: OpenLineage-compatible REST API
- **marquez-web**: React-based web interface

### Ports
- **3000**: Web UI (main demo interface)
- **5555**: REST API
- **5432**: PostgreSQL

## Demo Data

### Pipeline Simulation
- **extract-orders**: Extracts 15,420 orders from raw database
- **transform-sales**: Processes and joins with product reference data
- **load-warehouse**: Loads 2,840 aggregated records to warehouse

### Technologies Shown
- Airflow (orchestration)
- Spark (transformation) 
- dbt (warehouse loading)

## Troubleshooting

### Common Issues
```bash
# Services not ready
make restart
./load-demo-data.sh

# Empty dashboard
./load-demo-data.sh

# Port conflicts
make stop
# Kill conflicting processes
make start

# Container issues (Podman)
podman system reset  # Nuclear option
```

### Validation
```bash
# Quick health check
curl http://localhost:5555/api/v1/namespaces
curl http://localhost:3000

# Full validation
./validate-demo.sh
```

## Container Engine Support

This demo works with both Docker and Podman:
- Automatically detects available container engine
- Uses docker-compose or podman-compose accordingly
- No code changes needed

## Files Structure

```
novo/
├── docker-compose.yml    # Container orchestration
├── Makefile             # Automation commands
├── demo-data.json       # OpenLineage events
├── load-demo-data.sh    # Data loading script
├── validate-demo.sh     # Validation script
└── README.md           # This file
```

## About Marquez

Marquez is the reference implementation of OpenLineage, created by WeWork and now a graduated project of the LF AI & Data Foundation. It provides:

- Automatic data lineage collection
- Real-time metadata tracking
- Visual lineage exploration
- OpenLineage standard compliance
- Production-scale reliability
