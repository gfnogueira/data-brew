# Data Quality Profiler

Simple and objective tool for data quality analysis with professional HTML report generation.

## Features

- **Automatic Quality Analysis**
  - Null values and duplicates detection
  - Outlier identification in numeric columns
  - Format validation (email, date, etc)
  - Distribution and skewness analysis

- **Visual Reports**
  - Interactive HTML reports
  - Complete descriptive statistics
  - Quality scores per column and dataset
  - Issue detection and recommendations

- **Multiple Output Formats**
  - Console output with formatted tables
  - HTML reports for sharing
  - JSON export for programmatic access

## Quick Start

### Installation

```bash
cd data-quality-profiler
pip install -r requirements.txt
```

### Basic Usage

```bash
# Complete analysis with HTML report
python data_quality_profiler.py sample_data/sales.csv --output report.html

# Terminal analysis only
python data_quality_profiler.py sample_data/sales.csv

# Export to JSON
python data_quality_profiler.py sample_data/sales.csv --json report.json
```

## Output Example

The HTML report includes:
- **Overview**: Overall quality score, statistical summary
- **By Column**: Detailed analysis of each column
- **Issues Detected**: List of found issues
- **Numeric Statistics**: Min, Max, Mean, Median, Standard Deviation, Outliers

### Usage Examples

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run basic analysis (terminal)
python data_quality_profiler.py sample_data/sales.csv

# 3. Generate HTML report
python data_quality_profiler.py sample_data/sales.csv --output report.html

# 4. Export to JSON as well
python data_quality_profiler.py sample_data/sales.csv --output report.html --json report.json
```

## Project Structure

```
data-quality-profiler/
├── data_quality_profiler.py  # Main script
├── requirements.txt          # Dependencies
├── README.md                 # Documentation
├── sample_data/              # Sample data
│   └── sales.csv
└── rules.yaml                # Example custom rules
```

## Use Cases

- **Data Profiling**: Understand data quality before using datasets
- **Data Validation**: Validate data after ETL/transformations
- **Documentation**: Generate quality reports for stakeholders
- **Debugging**: Identify issues in data pipelines

## Dependencies

- pandas: Data manipulation
- jinja2: HTML templates
- typer: CLI interface
- rich: Console formatting
- numpy: Numerical operations

## Quality Metrics

The tool calculates quality scores based on:
- Null percentage (penalizes high null rates)
- Duplicate count (penalizes excessive duplicates)
- Outlier percentage (for numeric columns)
- Format validation (email, date detection)

Each column receives a score from 0-100, and an overall dataset score is calculated.

---

**Usefulness**: High for data engineering workflows
