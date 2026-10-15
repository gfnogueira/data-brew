# iceberg-medallion

Medallion pipeline on an open lakehouse. MinIO holds the Parquet, Nessie
serves the Iceberg REST catalog, PyIceberg writes the bronze and silver
tables, DuckDB reads them and lands the gold aggregates. No Spark.

## The three layers

    bronze    raw CSV drops landed as Iceberg tables with no schema cleaning
    silver    typed, deduped, joined, ready for query
    gold      daily revenue and customer cohort rollups

## The bronze step

Where: pipeline/bronze.py
Reads: seeds/*.csv via pyarrow
Writes: bronze.customers and bronze.orders as Iceberg tables
Shape: no type casting, no dedup. One row in, one row out. The duplicate
       o-10006 in orders_2026_10_15.csv lands as a duplicate on purpose.

## Run

    make up
    make bootstrap
    make pipeline
    make preview
    make down
