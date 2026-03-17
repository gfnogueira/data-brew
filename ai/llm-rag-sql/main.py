#!/usr/bin/env python3
"""Enhanced CLI for LLM-RAG-SQL - Week 2."""
import argparse
import json
from pathlib import Path
from datetime import datetime
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.markdown import Markdown
from src.agent import SQLAgent


console = Console()
HISTORY_FILE = Path(".query_history.json")


def main():
    parser = argparse.ArgumentParser(
        description="Chat with your database using natural language"
    )
    parser.add_argument(
        "question",
        nargs="?",
        help="Your question about the data"
    )
    parser.add_argument(
        "--interactive", "-i",
        action="store_true",
        help="Start interactive mode"
    )
    parser.add_argument(
        "--history",
        action="store_true",
        help="Show query history"
    )
    parser.add_argument(
        "--examples",
        action="store_true",
        help="Show example queries"
    )
    
    args = parser.parse_args()
    
    console.print(Panel.fit(
        "[bold blue]LLM-RAG-SQL[/bold blue] - Week 2\n"
        "Natural Language to SQL with History",
        border_style="blue"
    ))
    
    if args.history:
        show_history()
        return
    
    if args.examples:
        show_examples()
        return
    
    agent = SQLAgent()
    
    if args.interactive:
        console.print("\n[dim]Type 'exit' to quit[/dim]\n")
        while True:
            question = console.input("[bold green]You:[/bold green] ")
            if question.lower() in ("exit", "quit", "q"):
                break
            process_question(agent, question)
    elif args.question:
        process_question(agent, args.question)
    else:
        parser.print_help()


def process_question(agent: SQLAgent, question: str) -> None:
    """Process a question and display results."""
    with console.status("[bold blue]Thinking..."):
        result = agent.ask(question)
    
    # Save to history
    save_to_history(question, result)
    
    # Show SQL
    console.print(f"\n[bold cyan]SQL:[/bold cyan]")
    console.print(Panel(result["sql"], border_style="cyan"))
    
    # Show results or error
    if result["error"]:
        console.print(f"[bold red]Error:[/bold red] {result['error']}")
        console.print("[dim]💡 Tip: Try rephrasing your question[/dim]")
    elif result["results"]:
        table = Table(show_header=True, header_style="bold magenta", border_style="dim")
        
        # Add columns with actual names from result
        if result.get("columns"):
            for col in result["columns"]:
                table.add_column(col, overflow="fold")
        else:
            for i in range(len(result["results"][0])):
                table.add_column(f"Col {i+1}")
        
        # Add rows (limit to 20)
        for row in result["results"][:20]:
            table.add_row(*[str(v) if v is not None else "[dim]null[/dim]" for v in row])
        
        console.print(table)
        console.print(f"\n[dim]📊 {len(result['results'])} row(s) returned[/dim]")
        
        if len(result["results"]) > 20:
            console.print(f"[dim]... showing first 20 of {len(result['results'])} rows[/dim]")
    else:
        console.print("[dim]✓ Query executed successfully (no results)[/dim]")
    
    console.print()


def save_to_history(question: str, result: dict) -> None:
    """Save query to history file."""
    try:
        history = []
        if HISTORY_FILE.exists():
            history = json.loads(HISTORY_FILE.read_text())
        
        history.append({
            "timestamp": datetime.now().isoformat(),
            "question": question,
            "sql": result["sql"],
            "success": result["error"] is None,
            "row_count": len(result["results"]) if result["results"] else 0
        })
        
        # Keep only last 50 queries
        history = history[-50:]
        HISTORY_FILE.write_text(json.dumps(history, indent=2))
    except Exception:
        pass  # Silent fail for history


def show_history() -> None:
    """Display query history."""
    if not HISTORY_FILE.exists():
        console.print("[dim]No query history yet[/dim]")
        return
    
    history = json.loads(HISTORY_FILE.read_text())
    
    table = Table(title="Query History", show_header=True, header_style="bold cyan")
    table.add_column("#", style="dim", width=4)
    table.add_column("Time", style="cyan")
    table.add_column("Question", style="white")
    table.add_column("Status", justify="center")
    table.add_column("Rows", justify="right")
    
    for i, entry in enumerate(reversed(history[-10:]), 1):
        time = datetime.fromisoformat(entry["timestamp"]).strftime("%m/%d %H:%M")
        status = "[green]✓[/green]" if entry["success"] else "[red]✗[/red]"
        table.add_row(
            str(i),
            time,
            entry["question"][:50] + "..." if len(entry["question"]) > 50 else entry["question"],
            status,
            str(entry["row_count"])
        )
    
    console.print(table)
    console.print(f"\n[dim]Showing last {min(10, len(history))} of {len(history)} queries[/dim]")


def show_examples() -> None:
    """Display example queries."""
    examples = [
        ("📊 Analytics", [
            "What is the total revenue?",
            "Show top 5 selling products",
            "Which city has the most customers?",
        ]),
        ("🔍 Data Exploration", [
            "How many sales do we have?",
            "List all product categories",
            "Show customers from New York",
        ]),
        ("📈 Aggregations", [
            "What is the average order value?",
            "Count sales by category",
            "Show revenue by month",
        ]),
    ]
    
    console.print("\n[bold cyan]Example Queries[/bold cyan]\n")
    
    for category, queries in examples:
        console.print(f"[bold]{category}[/bold]")
        for query in queries:
            console.print(f"  • {query}")
        console.print()
    
    console.print("[dim]💡 Try: python main.py \"Your question here\"[/dim]\n")


if __name__ == "__main__":
    main()
