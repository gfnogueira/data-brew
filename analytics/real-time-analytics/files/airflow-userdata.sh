#!/bin/bash

# Install Docker
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg lsb-release curl -y
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
 
# Create paths and download Airflow compose
mkdir /home/ubuntu/airflow
PATH_AIRFLOW="/home/ubuntu/airflow"
cd $PATH_AIRFLOW || exit

mkdir -p ./dags ./logs ./plugins
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml'
 
# Create file .env with User UID, needed by docker permissions and fix permissions
echo -e "AIRFLOW_UID=$(id -u)" > .env
sudo chown ubuntu:ubuntu $PATH_AIRFLOW -R
 
# Starting airflow
sudo docker compose up airflow-init
sudo docker compose up -d

# Docker compose file
DOCKER_COMPOSE_FILE="$PATH_AIRFLOW/docker-compose.yaml"



if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    sudo sed -i "s/AIRFLOW__CORE__LOAD_EXAMPLES:.*/AIRFLOW__CORE__LOAD_EXAMPLES: 'false'/" "$DOCKER_COMPOSE_FILE"
else
    echo "docker-compose.yaml not found in: $DOCKER_COMPOSE_FILE"
fi

# Restart Docker Compose
sudo docker compose down
sudo docker compose up -d
sudo docker ps