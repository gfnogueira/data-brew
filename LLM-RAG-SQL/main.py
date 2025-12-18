#!/usr/bin/env python3
"""Simple CLI for LLM-RAG-SQL - Week 1."""
import argparse
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from src.agent import SQLAgent


console = Console()


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
    
    args = parser.parse_args()
    
    console.print(Panel.fit(
        "[bold blue]LLM-RAG-SQL[/bold blue] - Week 1\n"
        "Natural Language to SQL",
        border_style="blue"
    ))
    
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
    
    # Show SQL
    console.print(f"\n[bold cyan]SQL:[/bold cyan]")
    console.print(Panel(result["sql"], border_style="cyan"))
    
    # Show results or error
    if result["error"]:
        console.print(f"[bold red]Error:[/bold red] {result['error']}")
    elif result["results"]:
        table = Table(show_header=True, header_style="bold magenta")
        
        # Add columns (use generic names for now)
        for i in range(len(result["results"][0])):
            table.add_column(f"Col {i+1}")
        
        # Add rows (limit to 10)
        for row in result["results"][:10]:
            table.add_row(*[str(v) for v in row])
        
        console.print(table)
        
        if len(result["results"]) > 10:
            console.print(f"[dim]... and {len(result['results']) - 10} more rows[/dim]")
    else:
        console.print("[dim]No results[/dim]")
    
    console.print()


if __name__ == "__main__":
    main()
