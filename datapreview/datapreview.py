#!/usr/bin/env python3
"""
datapreview - Command-line data file explorer and profiler.

Provides quick preview and statistical analysis for CSV, Parquet, and JSON files.
"""
import json
import sys
from pathlib import Path
from typing import Optional

import pandas as pd
import typer
from rich.console import Console
from rich.table import Table

app = typer.Typer(help="Quick data file exploration and profiling.")
console = Console()


class DataProfiler:
    """Handles data loading, profiling, and statistics generation."""

    SUPPORTED_FORMATS = {".csv", ".parquet", ".json"}

    def __init__(self, filepath: Path):
        self.filepath = filepath
        self.df: Optional[pd.DataFrame] = None
        self._validate_file()

    def _validate_file(self) -> None:
        """Validate that the file exists and has a supported format."""
        if not self.filepath.exists():
            raise FileNotFoundError(f"File not found: {self.filepath}")

        if self.filepath.suffix.lower() not in self.SUPPORTED_FORMATS:
            raise ValueError(
                f"Unsupported format: {self.filepath.suffix}. "
                f"Supported: {', '.join(self.SUPPORTED_FORMATS)}"
            )

    def load(self, nrows: Optional[int] = None) -> pd.DataFrame:
        """Load the data file into a DataFrame."""
        suffix = self.filepath.suffix.lower()

        if suffix == ".csv":
            self.df = pd.read_csv(self.filepath, nrows=nrows)
        elif suffix == ".parquet":
            self.df = pd.read_parquet(self.filepath)
            if nrows:
                self.df = self.df.head(nrows)
        elif suffix == ".json":
            self.df = pd.read_json(self.filepath)
            if nrows:
                self.df = self.df.head(nrows)

        return self.df

    def get_schema(self) -> list[dict]:
        """Extract schema information from the DataFrame."""
        if self.df is None:
            self.load()

        schema = []
        for col in self.df.columns:
            schema.append({
                "column": col,
                "dtype": str(self.df[col].dtype),
                "nullable": self.df[col].isna().any(),
            })
        return schema

    def get_statistics(self) -> dict:
        """Generate comprehensive statistics for the dataset."""
        if self.df is None:
            self.load()

        stats = {
            "file": str(self.filepath),
            "rows": len(self.df),
            "columns": len(self.df.columns),
            "memory_mb": round(self.df.memory_usage(deep=True).sum() / 1024 / 1024, 2),
            "column_stats": [],
        }

        for col in self.df.columns:
            col_stats = {
                "column": col,
                "dtype": str(self.df[col].dtype),
                "null_count": int(self.df[col].isna().sum()),
                "null_pct": round(self.df[col].isna().mean() * 100, 1),
                "unique": int(self.df[col].nunique()),
            }

            # Add numeric statistics for applicable columns
            if pd.api.types.is_numeric_dtype(self.df[col]):
                col_stats["min"] = float(self.df[col].min()) if not self.df[col].isna().all() else None
                col_stats["max"] = float(self.df[col].max()) if not self.df[col].isna().all() else None
                col_stats["mean"] = round(float(self.df[col].mean()), 2) if not self.df[col].isna().all() else None

            stats["column_stats"].append(col_stats)

        return stats


def render_preview(df: pd.DataFrame, title: str, max_rows: int = 10) -> None:
    """Render a formatted preview table of the DataFrame."""
    table = Table(title=title, show_lines=True)

    for col in df.columns:
        table.add_column(str(col), overflow="fold")

    for _, row in df.head(max_rows).iterrows():
        table.add_row(*[str(v) if pd.notna(v) else "NULL" for v in row])

    console.print(table)
    console.print(f"\nShowing {min(max_rows, len(df))} of {len(df)} rows\n")


def render_schema(schema: list[dict]) -> None:
    """Render the schema as a formatted table."""
    table = Table(title="Schema")
    table.add_column("Column", style="cyan")
    table.add_column("Type", style="green")
    table.add_column("Nullable", style="yellow")

    for col in schema:
        table.add_row(
            col["column"],
            col["dtype"],
            "Yes" if col["nullable"] else "No"
        )

    console.print(table)


def render_statistics(stats: dict) -> None:
    """Render statistics as formatted tables."""

    summary = Table(title="Dataset Summary")
    summary.add_column("Metric", style="cyan")
    summary.add_column("Value", style="white")

    summary.add_row("File", stats["file"])
    summary.add_row("Rows", f"{stats['rows']:,}")
    summary.add_row("Columns", str(stats["columns"]))
    summary.add_row("Memory", f"{stats['memory_mb']} MB")

    console.print(summary)
    console.print()

    col_table = Table(title="Column Statistics")
    col_table.add_column("Column", style="cyan")
    col_table.add_column("Type", style="green")
    col_table.add_column("Nulls", justify="right")
    col_table.add_column("Null %", justify="right")
    col_table.add_column("Unique", justify="right")
    col_table.add_column("Min", justify="right")
    col_table.add_column("Max", justify="right")
    col_table.add_column("Mean", justify="right")

    for col in stats["column_stats"]:
        col_table.add_row(
            col["column"],
            col["dtype"],
            str(col["null_count"]),
            f"{col['null_pct']}%",
            str(col["unique"]),
            str(col.get("min", "-")),
            str(col.get("max", "-")),
            str(col.get("mean", "-")),
        )

    console.print(col_table)


@app.command()
def main(
    filepath: Path = typer.Argument(..., help="Path to the data file"),
    rows: int = typer.Option(10, "--rows", "-r", help="Number of rows to preview"),
    stats: bool = typer.Option(False, "--stats", "-s", help="Show detailed statistics"),
    schema: bool = typer.Option(False, "--schema", help="Show schema only"),
    output: Optional[Path] = typer.Option(None, "--output", "-o", help="Export statistics to JSON"),
):
    """
    Preview and profile data files.

    Supports CSV, Parquet, and JSON formats.
    """
    try:
        profiler = DataProfiler(filepath)

        if schema:
            profiler.load(nrows=1)
            render_schema(profiler.get_schema())
            return

        profiler.load()

        if stats:
            statistics = profiler.get_statistics()
            render_statistics(statistics)

            if output:
                output.write_text(json.dumps(statistics, indent=2))
                console.print(f"\nStatistics exported to {output}")
        else:
            render_preview(profiler.df, f"Preview: {filepath.name}", max_rows=rows)
            render_schema(profiler.get_schema())

    except FileNotFoundError as e:
        console.print(f"[red]Error:[/red] {e}")
        sys.exit(1)
    except ValueError as e:
        console.print(f"[red]Error:[/red] {e}")
        sys.exit(1)
    except Exception as e:
        console.print(f"[red]Unexpected error:[/red] {e}")
        sys.exit(1)


if __name__ == "__main__":
    app()
