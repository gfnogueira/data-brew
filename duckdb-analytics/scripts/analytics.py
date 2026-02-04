"""
Analytical queries and reports using DuckDB.

Demonstrates DuckDB capabilities for OLAP workloads including
aggregations, window functions, and complex joins.
"""

from pathlib import Path
from typing import Optional

import duckdb
from rich.console import Console
from rich.table import Table

DATA_DIR = Path(__file__).parent.parent / "data" / "processed"
console = Console()


def create_connection() -> duckdb.DuckDBPyConnection:
    """Create DuckDB connection with Parquet files registered as views."""
    conn = duckdb.connect()

    # Register Parquet files as views
    for parquet_file in DATA_DIR.glob("*.parquet"):
        table_name = parquet_file.stem
        conn.execute(f"""
            CREATE VIEW {table_name} AS 
            SELECT * FROM read_parquet('{parquet_file}')
        """)

    return conn


def print_result(title: str, result: list, columns: list):
    """Print query results in formatted table."""
    table = Table(title=title, show_header=True, header_style="bold")

    for col in columns:
        table.add_column(col)

    for row in result:
        table.add_row(*[str(v) for v in row])

    console.print(table)
    console.print()


def revenue_by_category(conn: duckdb.DuckDBPyConnection):
    """Total revenue and transaction count by product category."""
    query = """
        SELECT 
            p.category,
            COUNT(DISTINCT t.transaction_id) AS transactions,
            SUM(t.quantity) AS units_sold,
            ROUND(SUM(t.total_amount), 2) AS total_revenue,
            ROUND(AVG(t.total_amount), 2) AS avg_transaction
        FROM transactions t
        JOIN products p ON t.product_id = p.product_id
        WHERE t.is_returned = FALSE
        GROUP BY p.category
        ORDER BY total_revenue DESC
    """
    result = conn.execute(query).fetchall()
    columns = ["Category", "Transactions", "Units Sold", "Revenue", "Avg Transaction"]
    print_result("Revenue by Product Category", result, columns)


def monthly_sales_trend(conn: duckdb.DuckDBPyConnection):
    """Monthly sales trend with month-over-month growth."""
    query = """
        WITH monthly AS (
            SELECT 
                DATE_TRUNC('month', transaction_date) AS month,
                COUNT(*) AS transactions,
                ROUND(SUM(total_amount), 2) AS revenue
            FROM transactions
            WHERE is_returned = FALSE
            GROUP BY DATE_TRUNC('month', transaction_date)
        )
        SELECT 
            STRFTIME(month, '%Y-%m') AS month,
            transactions,
            revenue,
            ROUND(
                100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) 
                / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 
                1
            ) AS mom_growth_pct
        FROM monthly
        ORDER BY month DESC
        LIMIT 12
    """
    result = conn.execute(query).fetchall()
    columns = ["Month", "Transactions", "Revenue", "MoM Growth %"]
    print_result("Monthly Sales Trend (Last 12 Months)", result, columns)


def top_customers(conn: duckdb.DuckDBPyConnection, limit: int = 10):
    """Top customers by total spend with segment information."""
    query = f"""
        SELECT 
            c.customer_id,
            c.first_name || ' ' || c.last_name AS customer_name,
            c.segment,
            COUNT(DISTINCT t.transaction_id) AS orders,
            ROUND(SUM(t.total_amount), 2) AS total_spend,
            ROUND(AVG(t.total_amount), 2) AS avg_order_value
        FROM transactions t
        JOIN customers c ON t.customer_id = c.customer_id
        WHERE t.is_returned = FALSE
        GROUP BY c.customer_id, c.first_name, c.last_name, c.segment
        ORDER BY total_spend DESC
        LIMIT {limit}
    """
    result = conn.execute(query).fetchall()
    columns = ["Customer ID", "Name", "Segment", "Orders", "Total Spend", "AOV"]
    print_result(f"Top {limit} Customers by Spend", result, columns)


def store_performance(conn: duckdb.DuckDBPyConnection):
    """Store performance analysis by region."""
    query = """
        SELECT 
            s.region,
            s.store_type,
            COUNT(DISTINCT s.store_id) AS stores,
            COUNT(DISTINCT t.transaction_id) AS transactions,
            ROUND(SUM(t.total_amount), 2) AS revenue,
            ROUND(SUM(t.total_amount) / COUNT(DISTINCT s.store_id), 2) AS revenue_per_store
        FROM transactions t
        JOIN stores s ON t.store_id = s.store_id
        WHERE t.is_returned = FALSE
        GROUP BY s.region, s.store_type
        ORDER BY revenue DESC
    """
    result = conn.execute(query).fetchall()
    columns = ["Region", "Store Type", "Stores", "Transactions", "Revenue", "Revenue/Store"]
    print_result("Store Performance by Region", result, columns)


def payment_method_analysis(conn: duckdb.DuckDBPyConnection):
    """Payment method distribution and average transaction value."""
    query = """
        SELECT 
            payment_method,
            COUNT(*) AS transactions,
            ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_total,
            ROUND(SUM(total_amount), 2) AS total_revenue,
            ROUND(AVG(total_amount), 2) AS avg_transaction
        FROM transactions
        WHERE is_returned = FALSE
        GROUP BY payment_method
        ORDER BY transactions DESC
    """
    result = conn.execute(query).fetchall()
    columns = ["Payment Method", "Transactions", "% of Total", "Revenue", "Avg Transaction"]
    print_result("Payment Method Analysis", result, columns)


def product_return_rate(conn: duckdb.DuckDBPyConnection):
    """Product categories with highest return rates."""
    query = """
        SELECT 
            p.category,
            COUNT(*) AS total_transactions,
            SUM(CASE WHEN t.is_returned THEN 1 ELSE 0 END) AS returns,
            ROUND(
                100.0 * SUM(CASE WHEN t.is_returned THEN 1 ELSE 0 END) / COUNT(*), 
                2
            ) AS return_rate_pct
        FROM transactions t
        JOIN products p ON t.product_id = p.product_id
        GROUP BY p.category
        ORDER BY return_rate_pct DESC
    """
    result = conn.execute(query).fetchall()
    columns = ["Category", "Transactions", "Returns", "Return Rate %"]
    print_result("Return Rate by Category", result, columns)


def customer_segment_analysis(conn: duckdb.DuckDBPyConnection):
    """Customer segment metrics and lifetime value proxy."""
    query = """
        SELECT 
            c.segment,
            COUNT(DISTINCT c.customer_id) AS customers,
            COUNT(DISTINCT t.transaction_id) AS transactions,
            ROUND(SUM(t.total_amount), 2) AS total_revenue,
            ROUND(SUM(t.total_amount) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer,
            ROUND(AVG(t.total_amount), 2) AS avg_order_value
        FROM customers c
        LEFT JOIN transactions t ON c.customer_id = t.customer_id AND t.is_returned = FALSE
        GROUP BY c.segment
        ORDER BY revenue_per_customer DESC
    """
    result = conn.execute(query).fetchall()
    columns = ["Segment", "Customers", "Transactions", "Revenue", "Rev/Customer", "AOV"]
    print_result("Customer Segment Analysis", result, columns)


def data_quality_summary(conn: duckdb.DuckDBPyConnection):
    """Data quality metrics for all tables."""
    tables = ["transactions", "products", "customers", "stores"]
    results = []

    for table in tables:
        query = f"SELECT COUNT(*) FROM {table}"
        row_count = conn.execute(query).fetchone()[0]

        # Check for potential issues
        null_query = f"""
            SELECT COUNT(*) 
            FROM {table} 
            WHERE {table}_id IS NULL OR {table}_id = ''
        """

        # Simplified null check for primary key
        if table == "transactions":
            pk_col = "transaction_id"
        elif table == "products":
            pk_col = "product_id"
        elif table == "customers":
            pk_col = "customer_id"
        else:
            pk_col = "store_id"

        null_count = conn.execute(f"""
            SELECT COUNT(*) FROM {table} WHERE {pk_col} IS NULL
        """).fetchone()[0]

        results.append((table, row_count, null_count, "OK" if null_count == 0 else "WARN"))

    columns = ["Table", "Row Count", "Null PKs", "Status"]
    print_result("Data Quality Summary", results, columns)


def main():
    """Execute all analytical reports."""
    console.print("\n[bold]DuckDB Analytics Report[/bold]")
    console.print("=" * 60)
    console.print()

    conn = create_connection()

    # Execute all reports
    data_quality_summary(conn)
    revenue_by_category(conn)
    monthly_sales_trend(conn)
    top_customers(conn)
    store_performance(conn)
    payment_method_analysis(conn)
    product_return_rate(conn)
    customer_segment_analysis(conn)

    conn.close()


if __name__ == "__main__":
    main()
