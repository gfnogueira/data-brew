from airflow import DAG
from airflow.operators.dummy import DummyOperator
from datetime import datetime

def create_pipeline(name):
    with DAG(dag_id=f"dag_{name}", start_date=datetime(2025, 1, 1), schedule_interval="@daily", catchup=False) as dag:
        start = DummyOperator(task_id="start")
        end = DummyOperator(task_id="end")
        start >> end
        return dag

for name in ["pipeline1", "pipeline2"]:
    globals()[f"dag_{name}"] = create_pipeline(name)