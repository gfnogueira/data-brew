# Airflow Patterns – PoC

This is a quick Proof of Concept to demonstrate three simple and powerful patterns in Apache Airflow:

- 🧩 **Task Groups**: For visual organization and better readability
- ⚙️ **Dynamic DAGs**: For scalable, DRY pipeline generation
- ⏱️ **Sensors with Timeout + Fallback**: For robust and resilient workflows

## 🔧 Requirements

- Python 3.7 or higher
- pip
- Virtualenv (optional, but recommended)

## 🚀 Getting Started

### 1. Clone this repo

```bash
git clone https://github.com/gfnogueira/airflow-patterns-poc.git
cd airflow-patterns-poc
```

### 2. Create a virtual environment (optional)

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Airflow

```bash
AIRFLOW_VERSION=2.8.1
PYTHON_VERSION="$(python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
```

### 4. Initialize Airflow

```bash
export AIRFLOW_HOME=~/airflow
airflow db init
```

### 5. Create admin user

```bash
airflow users create \
  --username admin \
  --firstname Admin \
  --lastname Nogueira \
  --role Admin \
  --email admin@example.com \
  --password admin
```

### 6. Start Airflow

In two terminals:

```bash
# Terminal 1
airflow webserver --port 8080

# Terminal 2
airflow scheduler
```

Access the UI at [http://localhost:8080](http://localhost:8080)


#### Optional terminal run

 

✅ Run in background with &

```bash
# Start the webserver in the background
airflow webserver --port 8080 &

# Start the scheduler in the background
airflow scheduler &
```



### 7. DAGs

All example DAGs are located in the `dags/` folder:
- `task_group.py`
- `dynamic_dags.py`
- `sensor_timeout_fallback.py`

Just place them in `$AIRFLOW_HOME/dags/` or set a custom path via `airflow.cfg`.

---

## 🧪 Demo Overview

Each DAG demonstrates a specific pattern covered in the presentation:

| DAG Name               | Pattern                     |
|------------------------|-----------------------------|
| `task_group`           | Task Group usage            |
| `dag_pipeline1`, `2`   | Dynamic DAG generation      |
| `sensor_timeout_pattern` | Timeout & fallback with sensor |

---