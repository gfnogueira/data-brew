#!/usr/bin/env python3
"""
dbdocs - Database documentation generator for PostgreSQL.

Extracts schema information and generates Markdown documentation.
"""
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

import psycopg2
import typer
from jinja2 import Template
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn

app = typer.Typer(help="Generate documentation from PostgreSQL database schemas.")
console = Console()


@dataclass
class Column:
    """Represents a database column."""
    name: str
    data_type: str
    nullable: bool
    default: Optional[str]
    is_primary_key: bool = False
    comment: Optional[str] = None


@dataclass
class ForeignKey:
    """Represents a foreign key relationship."""
    column: str
    references_table: str
    references_column: str


@dataclass
class Index:
    """Represents a database index."""
    name: str
    columns: list[str]
    is_unique: bool


@dataclass
class Table:
    """Represents a database table with its metadata."""
    name: str
    schema: str
    columns: list[Column] = field(default_factory=list)
    foreign_keys: list[ForeignKey] = field(default_factory=list)
    indexes: list[Index] = field(default_factory=list)
    comment: Optional[str] = None
    sample_data: list[dict] = field(default_factory=list)


class SchemaExtractor:
    """Extracts schema information from PostgreSQL database."""

    def __init__(self, connection_params: dict):
        self.conn_params = connection_params
        self.conn = None

    def connect(self) -> None:
        """Establish database connection."""
        self.conn = psycopg2.connect(**self.conn_params)

    def close(self) -> None:
        """Close database connection."""
        if self.conn:
            self.conn.close()

    def get_tables(self, schema: str = "public") -> list[str]:
        """Retrieve list of tables in the specified schema."""
        query = """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s
            AND table_type = 'BASE TABLE'
            ORDER BY table_name
        """
        with self.conn.cursor() as cur:
            cur.execute(query, (schema,))
            return [row[0] for row in cur.fetchall()]

    def get_columns(self, table: str, schema: str = "public") -> list[Column]:
        """Retrieve column information for a table."""
        query = """
            SELECT 
                c.column_name,
                c.data_type,
                c.is_nullable,
                c.column_default,
                CASE WHEN pk.column_name IS NOT NULL THEN true ELSE false END as is_pk,
                pgd.description
            FROM information_schema.columns c
            LEFT JOIN (
                SELECT ku.column_name
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage ku
                    ON tc.constraint_name = ku.constraint_name
                WHERE tc.constraint_type = 'PRIMARY KEY'
                AND tc.table_name = %s
                AND tc.table_schema = %s
            ) pk ON c.column_name = pk.column_name
            LEFT JOIN pg_catalog.pg_statio_all_tables st
                ON st.schemaname = c.table_schema AND st.relname = c.table_name
            LEFT JOIN pg_catalog.pg_description pgd
                ON pgd.objoid = st.relid AND pgd.objsubid = c.ordinal_position
            WHERE c.table_name = %s
            AND c.table_schema = %s
            ORDER BY c.ordinal_position
        """
        with self.conn.cursor() as cur:
            cur.execute(query, (table, schema, table, schema))
            return [
                Column(
                    name=row[0],
                    data_type=row[1],
                    nullable=row[2] == "YES",
                    default=row[3],
                    is_primary_key=row[4],
                    comment=row[5],
                )
                for row in cur.fetchall()
            ]

    def get_foreign_keys(self, table: str, schema: str = "public") -> list[ForeignKey]:
        """Retrieve foreign key relationships for a table."""
        query = """
            SELECT
                kcu.column_name,
                ccu.table_name AS references_table,
                ccu.column_name AS references_column
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
                ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage ccu
                ON ccu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_name = %s
            AND tc.table_schema = %s
        """
        with self.conn.cursor() as cur:
            cur.execute(query, (table, schema))
            return [
                ForeignKey(
                    column=row[0],
                    references_table=row[1],
                    references_column=row[2],
                )
                for row in cur.fetchall()
            ]

    def get_indexes(self, table: str, schema: str = "public") -> list[Index]:
        """Retrieve index information for a table."""
        query = """
            SELECT
                i.relname as index_name,
                array_agg(a.attname ORDER BY array_position(ix.indkey, a.attnum)) as columns,
                ix.indisunique as is_unique
            FROM pg_class t
            JOIN pg_index ix ON t.oid = ix.indrelid
            JOIN pg_class i ON i.oid = ix.indexrelid
            JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
            JOIN pg_namespace n ON n.oid = t.relnamespace
            WHERE t.relname = %s
            AND n.nspname = %s
            AND NOT ix.indisprimary
            GROUP BY i.relname, ix.indisunique
        """
        with self.conn.cursor() as cur:
            cur.execute(query, (table, schema))
            return [
                Index(name=row[0], columns=row[1], is_unique=row[2])
                for row in cur.fetchall()
            ]

    def get_table_comment(self, table: str, schema: str = "public") -> Optional[str]:
        """Retrieve table comment if exists."""
        query = """
            SELECT obj_description(
                (quote_ident(%s) || '.' || quote_ident(%s))::regclass, 'pg_class'
            )
        """
        with self.conn.cursor() as cur:
            cur.execute(query, (schema, table))
            result = cur.fetchone()
            return result[0] if result else None

    def get_sample_data(self, table: str, schema: str = "public", limit: int = 5) -> list[dict]:
        """Retrieve sample rows from a table."""
        query = f'SELECT * FROM "{schema}"."{table}" LIMIT %s'
        with self.conn.cursor() as cur:
            cur.execute(query, (limit,))
            columns = [desc[0] for desc in cur.description]
            return [dict(zip(columns, row)) for row in cur.fetchall()]

    def extract_table(self, table_name: str, schema: str = "public", include_samples: bool = False) -> Table:
        """Extract complete metadata for a single table."""
        table = Table(
            name=table_name,
            schema=schema,
            columns=self.get_columns(table_name, schema),
            foreign_keys=self.get_foreign_keys(table_name, schema),
            indexes=self.get_indexes(table_name, schema),
            comment=self.get_table_comment(table_name, schema),
        )

        if include_samples:
            try:
                table.sample_data = self.get_sample_data(table_name, schema)
            except Exception:
                table.sample_data = []

        return table


class DocumentGenerator:
    """Generates Markdown documentation from schema metadata."""

    TEMPLATE = """# Database Documentation

**Database:** {{ database }}  
**Generated:** {{ timestamp }}  
**Tables:** {{ tables | length }}

---

## Overview

| Table | Columns | Description |
|-------|---------|-------------|
{% for table in tables -%}
| [{{ table.name }}](#{{ table.name }}) | {{ table.columns | length }} | {{ table.comment or '-' }} |
{% endfor %}

---

{% for table in tables %}
## {{ table.name }}

{% if table.comment %}
{{ table.comment }}
{% endif %}

### Columns

| Column | Type | Nullable | Default | Key | Description |
|--------|------|----------|---------|-----|-------------|
{% for col in table.columns -%}
| {{ col.name }} | `{{ col.data_type }}` | {{ 'Yes' if col.nullable else 'No' }} | {{ col.default or '-' }} | {{ 'PK' if col.is_primary_key else '' }} | {{ col.comment or '-' }} |
{% endfor %}

{% if table.foreign_keys %}
### Foreign Keys

| Column | References |
|--------|------------|
{% for fk in table.foreign_keys -%}
| {{ fk.column }} | {{ fk.references_table }}.{{ fk.references_column }} |
{% endfor %}
{% endif %}

{% if table.indexes %}
### Indexes

| Name | Columns | Unique |
|------|---------|--------|
{% for idx in table.indexes -%}
| {{ idx.name }} | {{ idx.columns | join(', ') }} | {{ 'Yes' if idx.is_unique else 'No' }} |
{% endfor %}
{% endif %}

{% if table.sample_data %}
### Sample Data

| {% for col in table.columns %}{{ col.name }} | {% endfor %}

|{% for col in table.columns %} --- |{% endfor %}

{% for row in table.sample_data -%}
| {% for col in table.columns %}{{ row[col.name] | default('-', true) }} | {% endfor %}

{% endfor %}
{% endif %}

---

{% endfor %}
"""

    def __init__(self, database: str, tables: list[Table]):
        self.database = database
        self.tables = tables

    def render(self) -> str:
        """Render the documentation as Markdown."""
        template = Template(self.TEMPLATE)
        return template.render(
            database=self.database,
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            tables=self.tables,
        )


@app.command()
def main(
    host: str = typer.Option(None, "--host", "-h", envvar="PGHOST", help="Database host"),
    port: int = typer.Option(5432, "--port", "-p", envvar="PGPORT", help="Database port"),
    database: str = typer.Option(None, "--database", "-d", envvar="PGDATABASE", help="Database name"),
    user: str = typer.Option("postgres", "--user", "-u", envvar="PGUSER", help="Database user"),
    password: str = typer.Option(None, "--password", envvar="PGPASSWORD", help="Database password"),
    schema: str = typer.Option("public", "--schema", "-s", help="Schema to document"),
    output: Optional[Path] = typer.Option(None, "--output", "-o", help="Output file path"),
    samples: bool = typer.Option(False, "--samples", help="Include sample data"),
):
    """
    Generate Markdown documentation from PostgreSQL database schema.
    """
    if not database:
        console.print("[red]Error:[/red] Database name is required (--database or PGDATABASE)")
        sys.exit(1)

    if not host:
        host = "localhost"

    conn_params = {
        "host": host,
        "port": port,
        "dbname": database,
        "user": user,
    }

    if password:
        conn_params["password"] = password

    extractor = SchemaExtractor(conn_params)

    try:
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            progress.add_task("Connecting to database...", total=None)
            extractor.connect()

            progress.add_task("Extracting schema...", total=None)
            table_names = extractor.get_tables(schema)

            if not table_names:
                console.print(f"[yellow]Warning:[/yellow] No tables found in schema '{schema}'")
                extractor.close()
                return

            tables = []
            for table_name in table_names:
                tables.append(extractor.extract_table(table_name, schema, samples))

            progress.add_task("Generating documentation...", total=None)
            generator = DocumentGenerator(database, tables)
            documentation = generator.render()

        extractor.close()

        if output:
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(documentation)
            console.print(f"Documentation written to {output}")
        else:
            console.print(documentation)

        console.print(f"\n[green]Documented {len(tables)} tables from {database}[/green]")

    except psycopg2.OperationalError as e:
        console.print(f"[red]Connection error:[/red] {e}")
        sys.exit(1)
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")
        sys.exit(1)
    finally:
        extractor.close()


if __name__ == "__main__":
    app()
