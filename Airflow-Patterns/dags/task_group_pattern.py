from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.utils.task_group import TaskGroup
from datetime import datetime

with DAG("task_group", start_date=datetime(2023, 1, 1), schedule_interval="@daily", catchup=False) as dag:
    start = DummyOperator(task_id="start")

    with TaskGroup("extract_group") as extract:
        t1 = DummyOperator(task_id="extract_from_api")
        t2 = DummyOperator(task_id="extract_from_db")

    process = DummyOperator(task_id="process_data")
    end = DummyOperator(task_id="end")

    start >> extract >> process >> end