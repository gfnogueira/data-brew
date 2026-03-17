# Airflow Patterns

PoC demonstrating three common Apache Airflow patterns:

- **Task Groups** -- visual organization and readability
- **Dynamic DAGs** -- scalable, DRY pipeline generation
- **Sensors with Timeout + Fallback** -- resilient workflows

## DAGs

Located in `dags/`:

| File | Pattern |
|------|---------|
| `task_group_pattern.py` | Task Group usage |
| `dag_pipeline-1-2_pattern.py` | Dynamic DAG generation |
| `sensor_timeout_pattern.py` | Timeout and fallback with sensor |

## Quick start

This PoC includes a `docker-compose.yaml` for running Airflow locally:

```bash
docker compose up -d
```

Access the UI at http://localhost:8080.

### Manual setup (without Docker)

```bash
python3 -m venv venv && source venv/bin/activate

AIRFLOW_VERSION=2.8.1
PYTHON_VERSION="$(python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

export AIRFLOW_HOME=~/airflow
airflow db init

airflow users create \
  --username admin --firstname Admin --lastname User \
  --role Admin --email admin@example.com --password admin

# Terminal 1
airflow webserver --port 8080

# Terminal 2
airflow scheduler
```

Copy the DAGs to `$AIRFLOW_HOME/dags/` or set a custom path in `airflow.cfg`.
