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

Schema:
{schema}"""),
            ("user", "{question}")
        ])
        
        chain = prompt | self.llm
        response = chain.invoke({"schema": schema_context, "question": question})
        sql = response.content.strip().replace("```sql", "").replace("```", "").strip()
        
        # Execute SQL
        try:
            results = self.db.execute(sql)
            return {
                "question": question,
                "sql": sql,
                "results": results,
                "error": None
            }
        except Exception as e:
            return {
                "question": question,
                "sql": sql,
                "results": None,
                "error": str(e)
            }
