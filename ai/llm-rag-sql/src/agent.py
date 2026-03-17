"""SQL Agent using LangChain and OpenAI."""
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate
from src.config import Config
from src.database import Database
from src.vectorstore import VectorStore


class SQLAgent:
    """Agent for natural language to SQL conversion."""
    
    def __init__(self):
        self.llm = ChatOpenAI(
            model="gpt-4o-mini",
            api_key=Config.OPENAI_API_KEY,
            temperature=0
        )
        self.db = Database()
        self.vectorstore = VectorStore()
        self._index_schema()
    
    def _index_schema(self) -> None:
        """Index database schema in vector store."""
        schema = self.db.get_schema_info()
        
        # Split schema by tables for better retrieval
        tables = schema.split("\nTable: ")
        docs = []
        ids = []
        
        for i, table in enumerate(tables):
            if table.strip():
                docs.append(f"Table: {table}")
                ids.append(f"table_{i}")
        
        if docs:
            self.vectorstore.clear()
            self.vectorstore.add_documents(docs, ids)
    
    def ask(self, question: str) -> dict:
        """Process a natural language question and return SQL + results."""
        # Get relevant schema context
        context = self.vectorstore.search(question)
        schema_context = "\n".join(context)
        
        # Generate SQL
        prompt = ChatPromptTemplate.from_messages([
            ("system", """You are a SQL expert. Given a database schema and a question, 
generate a valid PostgreSQL query. Return ONLY the SQL query, nothing else.

Important rules:
- Use proper JOINs when needed
- Always use table aliases for clarity
- Include LIMIT clause for large result sets
- Use aggregate functions correctly with GROUP BY

Schema:
{schema}"""),
            ("user", "{question}")
        ])
        
        chain = prompt | self.llm
        response = chain.invoke({"schema": schema_context, "question": question})
        sql = response.content.strip().replace("```sql", "").replace("```", "").strip()
        
        # Execute SQL with error handling
        try:
            results = self.db.execute(sql)
            
            # Extract column names
            columns = None
            if results and hasattr(results, 'keys'):
                columns = list(results.keys())
            elif results:
                # Try to get from cursor description
                try:
                    columns = [desc[0] for desc in results.cursor.description]
                except:
                    pass
            
            # Convert to list of tuples
            result_list = [tuple(row) for row in results]
            
            return {
                "question": question,
                "sql": sql,
                "results": result_list,
                "columns": columns,
                "error": None
            }
        except Exception as e:
            error_msg = str(e)
            
            # Provide helpful error messages
            if "syntax error" in error_msg.lower():
                error_msg += "\n💡 The generated SQL has a syntax error. Try rephrasing your question."
            elif "does not exist" in error_msg.lower():
                error_msg += "\n💡 The query references a table or column that doesn't exist."
            elif "permission denied" in error_msg.lower():
                error_msg += "\n💡 Database permission issue. Check your credentials."
            
            return {
                "question": question,
                "sql": sql,
                "results": None,
                "columns": None,
                "error": error_msg
            }
