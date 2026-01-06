# datapreview

A command-line tool for quick data file exploration and profiling.

## Features

- Preview CSV, Parquet, and JSON files with formatted output
- Automatic type inference and statistics
- Column-level analysis including null counts and unique values
- Memory-efficient streaming for large files

## Installation

```bash
pip install -r requirements.txt
```

## Usage

```bash
# Preview (first 10 rows)
python datapreview.py sample_data/customers.csv

# Preview with more rows
python datapreview.py sample_data/customers.csv --rows 20

# Show schema only (column types)
python datapreview.py sample_data/customers.csv --schema

# Show detailed statistics
python datapreview.py sample_data/customers.csv --stats

# Export statistics to JSON
python datapreview.py sample_data/customers.csv --stats --output profile.json
```

## Supported Formats

| Format  | Extension | Engine    |
|---------|-----------|-----------|
| CSV     | .csv      | pandas    |
| Parquet | .parquet  | pyarrow   |
| JSON    | .json     | pandas    |

## Output

The tool provides:

- **Preview**: Formatted table with sample rows
- **Schema**: Column names, types, and nullable status
- **Statistics**: Row count, null percentages, unique values, min/max for numeric columns

## Examples

### Preview

```bash
python datapreview.py sample_data/customers.csv
```

```
                                                      Preview: customers.csv             
┏━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━┓
┃ customer_id ┃ name              ┃ email                       ┃ city         ┃ total_purchases ┃ last_purchase_date ┃ is_active ┃
┡━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━┩
│ 1           │ John Smith        │ john.smith@techcorp.com     │ New York     │ 15              │ 2025-12-15         │ True      │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 2           │ Maria Garcia      │ maria.garcia@dataflow.io    │ Los Angeles  │ 8               │ 2025-11-20         │ True      │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 3           │ David Chen        │ david.chen@cloudbase.net    │ Chicago      │ 23              │ 2025-12-28         │ True      │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 4           │ Sarah Johnson     │ NULL                        │ Houston      │ 5               │ 2025-10-05         │ False     │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 5           │ Michael Brown     │ michael.brown@nexuslab.co   │ Phoenix      │ 12              │ 2025-12-01         │ True      │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 6           │ Emily Davis       │ emily.davis@brightwave.org  │ Philadelphia │ 0               │ NULL               │ False     │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 7           │ James Wilson      │ james.wilson@codestream.dev │ San Antonio  │ 31              │ 2025-12-30         │ True      │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 8           │ Lisa Anderson     │ lisa.anderson@quantumbit.io │ San Diego    │ 7               │ 2025-11-15         │ True      │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 9           │ Robert Taylor     │ robert.taylor@infracore.net │ Dallas       │ 19              │ 2025-12-22         │ True      │
├─────────────┼───────────────────┼─────────────────────────────┼──────────────┼─────────────────┼────────────────────┼───────────┤
│ 10          │ Jennifer Martinez │ NULL                        │ Seattle      │ 2               │ 2025-09-18         │ False     │
└─────────────┴───────────────────┴─────────────────────────────┴──────────────┴─────────────────┴────────────────────┴───────────┘

Showing 10 of 65 rows

                  Schema                  
┏━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━━━┓
┃ Column             ┃ Type   ┃ Nullable ┃
┡━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━╇━━━━━━━━━━┩
│ customer_id        │ int64  │ No       │
│ name               │ object │ No       │
│ email              │ object │ Yes      │
│ city               │ object │ No       │
│ total_purchases    │ int64  │ No       │
│ last_purchase_date │ object │ Yes      │
│ is_active          │ bool   │ No       │
└────────────────────┴────────┴──────────┘
```

### Schema

```bash
python datapreview.py sample_data/customers.csv --schema
```

```
                  Schema                  
┏━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━━━┓
┃ Column             ┃ Type   ┃ Nullable ┃
┡━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━╇━━━━━━━━━━┩
│ customer_id        │ int64  │ No       │
│ name               │ object │ No       │
│ email              │ object │ No       │
│ city               │ object │ No       │
│ total_purchases    │ int64  │ No       │
│ last_purchase_date │ object │ No       │
│ is_active          │ bool   │ No       │
└────────────────────┴────────┴──────────┘
```

### Statistics

```bash
python datapreview.py sample_data/customers.csv --stats
```

```
            Dataset Summary            
┏━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ Metric  ┃ Value                     ┃
┡━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ File    │ sample_data/customers.csv │
│ Rows    │ 65                        │
│ Columns │ 7                         │
│ Memory  │ 0.02 MB                   │
└─────────┴───────────────────────────┘

                              Column Statistics                               
┏━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━┳━━━━━┳━━━━━━┳━━━━━━━┓
┃ Column             ┃ Type   ┃ Nulls ┃ Null % ┃ Unique ┃ Min ┃  Max ┃  Mean ┃
┡━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━╇━━━━━━━╇━━━━━━━━╇━━━━━━━━╇━━━━━╇━━━━━━╇━━━━━━━┩
│ customer_id        │ int64  │     0 │   0.0% │     65 │ 1.0 │ 65.0 │  33.0 │
│ name               │ object │     0 │   0.0% │     65 │   - │    - │     - │
│ email              │ object │     7 │  10.8% │     58 │   - │    - │     - │
│ city               │ object │     0 │   0.0% │     61 │   - │    - │     - │
│ total_purchases    │ int64  │     0 │   0.0% │     36 │ 0.0 │ 35.0 │ 14.43 │
│ last_purchase_date │ object │     4 │   6.2% │     48 │   - │    - │     - │
│ is_active          │ bool   │     0 │   0.0% │      2 │ 0.0 │  1.0 │  0.82 │
└────────────────────┴────────┴───────┴────────┴────────┴─────┴──────┴───────┘
```
