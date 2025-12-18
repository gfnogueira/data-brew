"""Vector store for schema embeddings."""
import chromadb
from src.config import Config


class VectorStore:
    """ChromaDB vector store handler."""
    
    def __init__(self):
        self.client = chromadb.HttpClient(
            host=Config.CHROMA_HOST,
            port=int(Config.CHROMA_PORT)
        )
        self.collection = self.client.get_or_create_collection(
            name="schema_docs",
            metadata={"hnsw:space": "cosine"}
        )
    
    def add_documents(self, documents: list[str], ids: list[str]) -> None:
        """Add documents to the vector store."""
        self.collection.add(
            documents=documents,
            ids=ids
        )
    
    def search(self, query: str, n_results: int = 3) -> list[str]:
        """Search for similar documents."""
        results = self.collection.query(
            query_texts=[query],
            n_results=n_results
        )
        return results["documents"][0] if results["documents"] else []
    
    def clear(self) -> None:
        """Clear all documents from the collection."""
        self.client.delete_collection("schema_docs")
        self.collection = self.client.get_or_create_collection(
            name="schema_docs",
            metadata={"hnsw:space": "cosine"}
        )
