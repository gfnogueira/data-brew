#!/bin/bash
set -e

# === CONFIGURATION ===
CLEAN=true # Set to "true" to remove previous volumes and reinitialize Airflow from scratch

# === ENVIRONMENT SETUP ===
AIRFLOW_DIR="/home/ubuntu/airflow"
AIRFLOW_UID=$(id -u ubuntu)
DOCKER_COMPOSE_FILE="$AIRFLOW_DIR/docker-compose.yaml"

# === Install Docker and Docker Compose ===
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# === Create project structure ===
mkdir -p "$AIRFLOW_DIR"/{dags,logs,plugins}
cd "$AIRFLOW_DIR"

# === Download official Airflow Docker Compose file ===
curl -LfO https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml

# === Create .env file with user UID for volume permissions ===
echo "AIRFLOW_UID=$AIRFLOW_UID" > .env

# === Fix ownership of project files ===
chown -R ubuntu:ubuntu "$AIRFLOW_DIR"

# === Disable example DAGs if compose file exists ===
if [ -f "$DOCKER_COMPOSE_FILE" ]; then
  sed -i "s/AIRFLOW__CORE__LOAD_EXAMPLES:.*/AIRFLOW__CORE__LOAD_EXAMPLES: 'false'/" "$DOCKER_COMPOSE_FILE"
else
  echo "docker-compose.yaml not found in: $DOCKER_COMPOSE_FILE"
fi

# === Clean previous volumes and state if requested ===
if [ "$CLEAN" = true ]; then
  echo "Cleaning up previous volumes and state..."
  docker compose down --volumes --remove-orphans
fi

# === Initialize Airflow database and create admin user ===
docker compose up airflow-init

# === Start all Airflow services in detached mode ===
docker compose up -d

# === Show running containers ===
docker ps