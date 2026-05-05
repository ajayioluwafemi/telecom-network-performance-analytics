"""
load_to_sqlite.py
-----------------
One-shot script: reads the raw Kaggle CSV, cleans the obvious problems,
and writes the result to data/processed/telecom.db as table `customers`.

Run from the project root:
    python src/load_to_sqlite.py
"""
from pathlib import Path
import sqlite3
import sys

import pandas as pd

# ----- paths -----
ROOT = Path(__file__).resolve().parent.parent
RAW_CSV = ROOT / "data" / "raw" / "WA_Fn-UseC_-Telco-Customer-Churn.csv"
DB_PATH = ROOT / "data" / "processed" / "telecom.db"


def load_and_clean(csv_path: Path) -> pd.DataFrame:
    """Load the Kaggle CSV and apply minimal cleaning."""
    if not csv_path.exists():
        sys.exit(
            f"\n[ERROR] Could not find {csv_path}\n"
            "Download the dataset from\n"
            "  https://www.kaggle.com/datasets/blastchar/telco-customer-churn\n"
            f"and place WA_Fn-UseC_-Telco-Customer-Churn.csv into {csv_path.parent}\n"
        )

    df = pd.read_csv(csv_path)

    # TotalCharges arrives as a string with blanks for new customers — coerce
    df["TotalCharges"] = pd.to_numeric(df["TotalCharges"], errors="coerce")
    df["TotalCharges"] = df["TotalCharges"].fillna(0.0)

    # Standardise column names: PascalCase -> snake_case
    df.columns = [
        "".join(["_" + c.lower() if c.isupper() else c for c in col]).lstrip("_")
        for col in df.columns
    ]

    # Churn flag as 0/1 for downstream modelling
    df["churn_flag"] = (df["churn"] == "Yes").astype(int)

    return df


def write_to_sqlite(df: pd.DataFrame, db_path: Path) -> None:
    """Write the cleaned dataframe to SQLite."""
    db_path.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(db_path) as conn:
        df.to_sql("customers", conn, if_exists="replace", index=False)
        # quick sanity check
        n = conn.execute("SELECT COUNT(*) FROM customers").fetchone()[0]
        print(f"[OK] Wrote {n:,} rows to {db_path}")


def main() -> None:
    df = load_and_clean(RAW_CSV)
    print(f"[OK] Loaded {len(df):,} rows from {RAW_CSV.name}")
    print(f"     Columns: {list(df.columns)}")
    write_to_sqlite(df, DB_PATH)


if __name__ == "__main__":
    main()
