from airflow import DAG
from airflow.sensors.time_delta import TimeDeltaSensor
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

with DAG("sensor_timeout_pattern", start_date=datetime(2025, 1, 1), schedule_interval=None, catchup=False) as dag:
    wait = TimeDeltaSensor(
        task_id="wait_5_seconds",
        delta=timedelta(seconds=5),
        timeout=10,
        mode="reschedule"
    )

    fallback = PythonOperator(
        task_id="fallback",
        python_callable=lambda: print("Sensor failed or timed out – running fallback.")
    )

    wait >> fallback