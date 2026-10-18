# iceberg-medallion

Medallion pipeline on an open lakehouse. MinIO holds the Parquet, Nessie
serves the Iceberg REST catalog, PyIceberg writes the bronze and silver
tables, DuckDB reads them and lands the gold aggregates. No Spark.

## The three layers

    bronze    raw CSV drops landed as Iceberg tables with no schema cleaning
    silver    typed, deduped, joined, ready for query
    gold      daily revenue and customer cohort rollups

## End to end

    seeds/*.csv
         |
         v
    pipeline.bronze   -->   bronze.customers, bronze.orders   (append)
         |
         v
    pipeline.silver   -->   silver.customers, silver.orders   (replace)
         |
         v
    pipeline.gold     -->   gold.daily_revenue, gold.customer_cohort

Each arrow is a PyIceberg write against the Nessie catalog. Silver and gold
replace the table on each run so the shape stays canonical; bronze appends
so a reader can trust the raw history.

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
