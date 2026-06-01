# dbt Analytics Engineering

Local Proof of Concept demonstrating production-style analytics engineering with
dbt Core, a DuckDB warehouse, and a layered model design (staging → intermediate
→ marts) backed by tests, snapshots, exposures, and docs.

## Objective

Validate a dbt project that delivers a deterministic dimensional model for an
e-commerce dataset, with test coverage, lineage, snapshot history, and operational
runtime workflows suitable for a real engagement.

## Scope

- DuckDB warehouse with a configured profile and isolated schemas per layer
- Seed-driven raw layer covering customers, products, orders, and order items
- Star schema marts (dim_customers, dim_products, fct_orders) built incrementally
- Generic, singular, and custom tests across the model graph
- Snapshots (SCD type 2), macros, exposures, and generated documentation

## Architecture

```text
seeds (raw_*) --> stg_* (views) --> int_* (ephemeral) --> dim_*/fct_* (tables) --> exposures
                                                       \-> snapshots (SCD2)
```

## Project Structure

```text
analytics/dbt-analytics-engineering/
├── dbt_project.yml
├── packages.yml
├── profiles/
│   └── profiles.yml
├── seeds/
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
├── snapshots/
├── macros/
├── tests/
└── scripts/
```

## Bootstrap

```bash
cd analytics/dbt-analytics-engineering
cp .env.example .env
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
make deps
make debug
```

## Runtime Sequence

```bash
make pipeline       # deps + seed + run + snapshot + test + docs generate
make validate       # Row counts, revenue reconciliation, lifecycle distribution
make bench          # Latency benchmark across staging, marts, and full lineage
make docs-serve     # Browse the generated dbt docs and lineage graph (port 8081)
```

## Layers

| Layer | Materialization | Schema | Purpose |
| --- | --- | --- | --- |
| Raw seeds | table | `raw` | Source-of-record CSV extracts |
| Staging | view | `staging` | Casts, normalizes, and standardizes raw rows |
| Intermediate | ephemeral | `intermediate` | Joins line items with order and product context |
| Marts | table | `marts` | Star schema with dim_customers, dim_products, fct_orders |
| Snapshots | table | `snapshots` | SCD type 2 history for customers and products |

## Test Surface

- **Source tests**: unique, not_null, accepted_values, relationships on raw tables
- **Staging tests**: referential checks plus value range tests via dbt_utils
- **Marts tests**: uniqueness, relationships, accepted values, non-negative metrics
- **Singular tests**: revenue consistency, orphan line items, lifecycle correctness
- **Custom generic test**: `positive_value` reusable across numeric columns
