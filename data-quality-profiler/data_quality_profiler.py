#!/usr/bin/env python3
"""
Data Quality Profiler - Data quality analysis with HTML reports
"""
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np
import pandas as pd
import typer
from jinja2 import Template
from rich.console import Console
from rich.table import Table

app = typer.Typer(help="Data Quality Profiler - Data quality analysis tool")
console = Console()


class DataQualityProfiler:
    """Analyzes data quality and generates reports"""

    def __init__(self, filepath: Path):
        self.filepath = filepath
        self.df: Optional[pd.DataFrame] = None
        self.quality_report: Dict = {}

    def load_data(self) -> pd.DataFrame:
        """Load data from file"""
        suffix = self.filepath.suffix.lower()

        if suffix == ".csv":
            self.df = pd.read_csv(self.filepath)
        elif suffix == ".parquet":
            self.df = pd.read_parquet(self.filepath)
        elif suffix == ".json":
            self.df = pd.read_json(self.filepath)
        else:
            raise ValueError(f"Unsupported format: {suffix}")

        return self.df

    def detect_outliers(self, series: pd.Series) -> List[int]:
        """Detect outliers using IQR method"""
        if not pd.api.types.is_numeric_dtype(series):
            return []

        Q1 = series.quantile(0.25)
        Q3 = series.quantile(0.75)
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR

        outliers = series[(series < lower_bound) | (series > upper_bound)].index.tolist()
        return outliers

    def validate_email(self, value) -> bool:
        """Validate email format"""
        if pd.isna(value):
            return True
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, str(value)))

    def validate_date(self, value) -> bool:
        """Validate date format"""
        if pd.isna(value):
            return True
        try:
            pd.to_datetime(value)
            return True
        except:
            return False

    def analyze_column(self, col: str) -> Dict:
        """Analyze quality of a column"""
        series = self.df[col]
        is_numeric = pd.api.types.is_numeric_dtype(series)

        analysis = {
            "name": col,
            "dtype": str(series.dtype),
            "total": len(series),
            "null_count": int(series.isna().sum()),
            "null_pct": round(series.isna().mean() * 100, 2),
            "unique_count": int(series.nunique()),
            "duplicate_count": int(len(series) - series.nunique()),
            "is_numeric": is_numeric,
        }

        # Numeric statistics
        if is_numeric:
            analysis.update({
                "min": float(series.min()) if not series.isna().all() else None,
                "max": float(series.max()) if not series.isna().all() else None,
                "mean": round(float(series.mean()), 2) if not series.isna().all() else None,
                "median": round(float(series.median()), 2) if not series.isna().all() else None,
                "std": round(float(series.std()), 2) if not series.isna().all() else None,
                "outliers_count": len(self.detect_outliers(series)),
                "outliers_pct": round(len(self.detect_outliers(series)) / len(series) * 100, 2),
            })

        # Format validations
        if series.dtype == 'object':
            # Try to detect emails
            sample = series.dropna().head(100)
            if len(sample) > 0:
                email_count = sum(self.validate_email(v) for v in sample)
                if email_count > len(sample) * 0.5:
                    analysis["likely_email"] = True

                date_count = sum(self.validate_date(v) for v in sample)
                if date_count > len(sample) * 0.5:
                    analysis["likely_date"] = True

        # Quality score (0-100)
        quality_score = 100
        quality_score -= analysis["null_pct"] * 0.5  # Penalize nulls
        if analysis["duplicate_count"] > analysis["total"] * 0.5:
            quality_score -= 20  # Penalize many duplicates
        if is_numeric and analysis.get("outliers_pct", 0) > 10:
            quality_score -= 10  # Penalize many outliers

        analysis["quality_score"] = max(0, round(quality_score, 1))

        return analysis

    def generate_report(self) -> Dict:
        """Generate complete quality report"""
        if self.df is None:
            self.load_data()

        column_analyses = [self.analyze_column(col) for col in self.df.columns]

        # Detect issues
        issues = []
        for col_analysis in column_analyses:
            if col_analysis["null_pct"] > 20:
                issues.append({
                    "type": "high_null_percentage",
                    "column": col_analysis["name"],
                    "severity": "warning",
                    "message": f"{col_analysis['name']}: {col_analysis['null_pct']}% null values"
                })

            if col_analysis["duplicate_count"] > col_analysis["total"] * 0.5:
                issues.append({
                    "type": "high_duplicates",
                    "column": col_analysis["name"],
                    "severity": "warning",
                    "message": f"{col_analysis['name']}: {col_analysis['duplicate_count']} duplicates detected"
                })

            if col_analysis.get("outliers_pct", 0) > 15:
                issues.append({
                    "type": "high_outliers",
                    "column": col_analysis["name"],
                    "severity": "info",
                    "message": f"{col_analysis['name']}: {col_analysis['outliers_pct']}% outliers"
                })

        # Overall score
        avg_quality = sum(col["quality_score"] for col in column_analyses) / len(column_analyses)

        self.quality_report = {
            "file": str(self.filepath.name),
            "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "total_rows": len(self.df),
            "total_columns": len(self.df.columns),
            "overall_quality_score": round(avg_quality, 1),
            "columns": column_analyses,
            "issues": issues,
            "summary": {
                "columns_with_nulls": sum(1 for c in column_analyses if c["null_count"] > 0),
                "columns_with_duplicates": sum(1 for c in column_analyses if c["duplicate_count"] > 0),
                "numeric_columns": sum(1 for c in column_analyses if c["is_numeric"]),
                "total_issues": len(issues),
            }
        }

        return self.quality_report

    def generate_html_report(self, output_path: Path) -> None:
        """Generate HTML report"""
        if not self.quality_report:
            self.generate_report()

        html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Quality Report - {{ report.file }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: #f5f7fa;
            color: #2c3e50;
            line-height: 1.6;
            padding: 20px;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { opacity: 0.9; font-size: 1.1em; }
        .score-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .score-large {
            font-size: 4em;
            font-weight: bold;
            color: #667eea;
            text-align: center;
            margin: 20px 0;
        }
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .summary-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
        }
        .summary-card h3 {
            color: #667eea;
            font-size: 2em;
            margin-bottom: 5px;
        }
        .summary-card p {
            color: #7f8c8d;
            font-size: 0.9em;
        }
        .section {
            background: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .section h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th {
            background: #667eea;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #e0e0e0;
        }
        tr:hover { background: #f8f9fa; }
        .badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
        }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-warning { background: #fff3cd; color: #856404; }
        .badge-danger { background: #f8d7da; color: #721c24; }
        .badge-info { background: #d1ecf1; color: #0c5460; }
        .issue-item {
            padding: 15px;
            margin: 10px 0;
            border-left: 4px solid #667eea;
            background: #f8f9fa;
            border-radius: 5px;
        }
        .issue-warning { border-left-color: #ffc107; }
        .issue-danger { border-left-color: #dc3545; }
        .quality-bar {
            height: 20px;
            background: #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
            margin-top: 5px;
        }
        .quality-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transition: width 0.3s ease;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Data Quality Report</h1>
            <p><strong>File:</strong> {{ report.file }}</p>
            <p><strong>Generated:</strong> {{ report.generated_at }}</p>
        </div>

        <div class="score-card">
            <h2 style="text-align: center; margin-bottom: 10px;">Overall Quality Score</h2>
            <div class="score-large">{{ report.overall_quality_score }}/100</div>
            <div class="quality-bar">
                <div class="quality-fill" style="width: {{ report.overall_quality_score }}%"></div>
            </div>
        </div>

        <div class="summary-grid">
            <div class="summary-card">
                <h3>{{ report.total_rows | int }}</h3>
                <p>Total Rows</p>
            </div>
            <div class="summary-card">
                <h3>{{ report.total_columns | int }}</h3>
                <p>Total Columns</p>
            </div>
            <div class="summary-card">
                <h3>{{ report.summary.columns_with_nulls }}</h3>
                <p>Columns with Nulls</p>
            </div>
            <div class="summary-card">
                <h3>{{ report.summary.total_issues }}</h3>
                <p>Issues Detected</p>
            </div>
        </div>

        {% if report.issues %}
        <div class="section">
            <h2>Issues Detected</h2>
            {% for issue in report.issues %}
            <div class="issue-item issue-{{ issue.severity }}">
                <strong>{{ issue.type | replace('_', ' ') | title }}</strong><br>
                {{ issue.message }}
            </div>
            {% endfor %}
        </div>
        {% endif %}

        <div class="section">
            <h2>Column Analysis</h2>
            <table>
                <thead>
                    <tr>
                        <th>Column</th>
                        <th>Type</th>
                        <th>Nulls</th>
                        <th>Nulls %</th>
                        <th>Unique</th>
                        <th>Duplicates</th>
                        <th>Score</th>
                    </tr>
                </thead>
                <tbody>
                    {% for col in report.columns %}
                    <tr>
                        <td><strong>{{ col.name }}</strong></td>
                        <td>{{ col.dtype }}</td>
                        <td>{{ col.null_count | int }}</td>
                        <td>{{ col.null_pct }}%</td>
                        <td>{{ col.unique_count | int }}</td>
                        <td>{{ col.duplicate_count | int }}</td>
                        <td>
                            <span class="badge {% if col.quality_score >= 80 %}badge-success{% elif col.quality_score >= 60 %}badge-warning{% else %}badge-danger{% endif %}">
                                {{ col.quality_score }}
                            </span>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>

        <div class="section">
            <h2>Numeric Statistics</h2>
            <table>
                <thead>
                    <tr>
                        <th>Column</th>
                        <th>Min</th>
                        <th>Max</th>
                        <th>Mean</th>
                        <th>Median</th>
                        <th>Std Dev</th>
                        <th>Outliers</th>
                    </tr>
                </thead>
                <tbody>
                    {% for col in report.columns %}
                    {% if col.is_numeric %}
                    <tr>
                        <td><strong>{{ col.name }}</strong></td>
                        <td>{{ col.min if col.min is not none else '-' }}</td>
                        <td>{{ col.max if col.max is not none else '-' }}</td>
                        <td>{{ col.mean if col.mean is not none else '-' }}</td>
                        <td>{{ col.median if col.median is not none else '-' }}</td>
                        <td>{{ col.std if col.std is not none else '-' }}</td>
                        <td>
                            {% if col.outliers_count > 0 %}
                            <span class="badge badge-warning">{{ col.outliers_count }} ({{ col.outliers_pct }}%)</span>
                            {% else %}
                            <span class="badge badge-success">0</span>
                            {% endif %}
                        </td>
                    </tr>
                    {% endif %}
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
        """

        template = Template(html_template)
        html_content = template.render(report=self.quality_report)

        output_path.write_text(html_content, encoding='utf-8')
        console.print(f"[green]HTML report generated:[/green] {output_path}")


def render_console_report(report: Dict) -> None:
    """Render report in console"""
    console.print("\n[bold cyan]Data Quality Report[/bold cyan]")
    console.print(f"[dim]File:[/dim] {report['file']}")
    console.print(f"[dim]Generated:[/dim] {report['generated_at']}\n")

    # Overall score
    score_table = Table(title="Overall Quality Score")
    score_table.add_column("Metric", style="cyan")
    score_table.add_column("Value", style="white")
    score_table.add_row("Quality Score", f"{report['overall_quality_score']}/100")
    score_table.add_row("Total Rows", f"{report['total_rows']:,}")
    score_table.add_row("Total Columns", str(report['total_columns']))
    score_table.add_row("Issues Detected", str(len(report['issues'])))
    console.print(score_table)
    console.print()

    # Issues
    if report['issues']:
        issues_table = Table(title="Issues Detected")
        issues_table.add_column("Type", style="yellow")
        issues_table.add_column("Column", style="cyan")
        issues_table.add_column("Message", style="white")
        for issue in report['issues']:
            issues_table.add_row(
                issue['type'].replace('_', ' ').title(),
                issue['column'],
                issue['message']
            )
        console.print(issues_table)
        console.print()

    # Columns
    cols_table = Table(title="Column Analysis")
    cols_table.add_column("Column", style="cyan")
    cols_table.add_column("Type", style="green")
    cols_table.add_column("Nulls %", justify="right")
    cols_table.add_column("Unique", justify="right")
    cols_table.add_column("Score", justify="right")
    for col in report['columns']:
        score_color = "green" if col['quality_score'] >= 80 else "yellow" if col['quality_score'] >= 60 else "red"
        cols_table.add_row(
            col['name'],
            col['dtype'],
            f"{col['null_pct']}%",
            str(col['unique_count']),
            f"[{score_color}]{col['quality_score']}[/{score_color}]"
        )
    console.print(cols_table)


@app.command()
def main(
    filepath: Path = typer.Argument(..., help="Path to data file (CSV, Parquet, JSON)"),
    output: Optional[Path] = typer.Option(None, "--output", "-o", help="Path to save HTML report"),
    json_output: Optional[Path] = typer.Option(None, "--json", help="Export report as JSON"),
):
    """
    Analyze data quality and generate reports
    """
    try:
        profiler = DataQualityProfiler(filepath)
        profiler.load_data()
        report = profiler.generate_report()

        # Render in console
        render_console_report(report)

        # Generate HTML if requested
        if output:
            profiler.generate_html_report(output)

        # Export JSON if requested
        if json_output:
            json_output.write_text(json.dumps(report, indent=2, default=str), encoding='utf-8')
            console.print(f"[green]JSON report exported:[/green] {json_output}")

    except FileNotFoundError:
        console.print(f"[red]Error:[/red] File not found: {filepath}")
        sys.exit(1)
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")
        sys.exit(1)


if __name__ == "__main__":
    app()
