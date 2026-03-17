"""Database connection and schema extraction."""
from sqlalchemy import create_engine, text
from src.config import Config


class Database:
    """Database connection handler."""
    
    def __init__(self):
        self.engine = create_engine(Config.get_postgres_uri())
    
    def execute(self, query: str) -> list:
        """Execute a SQL query and return results."""
        with self.engine.connect() as conn:
            result = conn.execute(text(query))
            return result.fetchall()
    
    def get_schema_info(self) -> str:
        """Extract database schema information for LLM context."""
        query = """
        SELECT 
            table_name,
            column_name,
            data_type,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public'
        ORDER BY table_name, ordinal_position;
        """
        rows = self.execute(query)
        
        schema_text = "Database Schema:\n\n"
        current_table = None
        
        for row in rows:
            table, column, dtype, nullable = row
            if table != current_table:
                schema_text += f"\nTable: {table}\n"
                current_table = table
            schema_text += f"  - {column}: {dtype} {'(nullable)' if nullable == 'YES' else ''}\n"
        
        return schema_text
