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