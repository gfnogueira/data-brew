import sys
from pathlib import Path

from lib.session import open_session

OPS_DIR = Path(__file__).resolve().parent.parent / "sql" / "operations"


def run_file(conn, path: Path) -> None:
    sql = path.read_text(encoding="utf-8")
    print(f"==> {path.name}")
    cursor = conn.execute(sql)
    try:
        rows = cursor.fetchall()
        if rows:
            for row in rows:
                print(f"  {row}")
    except Exception:
        pass
    print()


def main() -> int:
    files = sys.argv[1:] or sorted(p.name for p in OPS_DIR.glob("*.sql"))
    conn = open_session()
    for name in files:
        run_file(conn, OPS_DIR / name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
