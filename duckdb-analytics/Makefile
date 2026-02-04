.PHONY: all generate transform analytics shell clean

all: generate transform analytics

generate:
	@echo "Generating synthetic data..."
	python scripts/generate_data.py

transform:
	@echo "Converting CSV to Parquet..."
	python scripts/transform.py

analytics:
	@echo "Running analytical queries..."
	python scripts/analytics.py

shell:
	@echo "Starting interactive DuckDB shell..."
	python scripts/shell.py

clean:
	@echo "Cleaning generated files..."
	rm -rf data/raw/*.csv
	rm -rf data/processed/*.parquet
	rm -f analytics.duckdb

install:
	pip install -r requirements.txt
