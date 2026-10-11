# iceberg-medallion

Medallion pipeline on an open lakehouse. MinIO holds the Parquet, Nessie
serves the Iceberg REST catalog, PyIceberg writes the bronze and silver
tables, DuckDB reads them and lands the gold aggregates. No Spark.

## The three layers

    bronze    raw CSV drops landed as Iceberg tables with no schema cleaning
    silver    typed, deduped, joined, ready for query
    gold      daily revenue and customer cohort rollups

## Run

    make up
    make bootstrap
    make pipeline
    make preview
    make down
