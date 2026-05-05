# Project 1 — Step-by-Step Build Instructions

> Read this end-to-end before you start coding. Each step has a "Done when" check so you know whether to move on.

---

## Phase 0 — One-time machine setup (~30 minutes)

### 0.1 Install Python 3.11

Download from python.org. During install, **tick the "Add Python to PATH" box**. Verify in PowerShell:

```powershell
python --version
# Should print: Python 3.11.x
```

### 0.2 Install VS Code + extensions

Install VS Code from code.visualstudio.com. Open it, go to the Extensions pane (Ctrl+Shift+X) and install:

- **Python** (Microsoft)
- **Jupyter** (Microsoft)
- **SQLite Viewer** (Florian Klampfer) — lets you click on a `.db` file and browse it
- **GitLens** (optional but very useful)

### 0.3 Install Power BI Desktop

Download from powerbi.microsoft.com → "Power BI Desktop". It's free and Windows-only. The Yoga 380 handles it without issue.

### 0.4 Install Git and authenticate to GitHub

```powershell
# Install Git from git-scm.com, then in PowerShell:
git config --global user.name "Ajayi Oluwafemi"
git config --global user.email "oluwafemiajayi90@gmail.com"
```

For pushing to GitHub, the easiest approach is to install **GitHub CLI** (`gh`) from cli.github.com and run `gh auth login` once.

**Done when:** `python --version`, `git --version`, and `gh --version` all print versions.

---

## Phase 1 — Get the project on disk and into Git (~15 minutes)

### 1.1 Unzip this scaffold

I've handed you a zip (`telecom-network-performance-analytics.zip`). Unzip it somewhere sensible like `C:\Users\<you>\projects\`.

### 1.2 Initialise Git and push to GitHub

Open PowerShell inside the project folder:

```powershell
cd C:\Users\<you>\projects\telecom-network-performance-analytics

git init
git add .
git commit -m "chore: initial scaffold"

# Create the repo on GitHub via the CLI
gh repo create telecom-network-performance-analytics --public --source=. --remote=origin
git push -u origin main
```

**Done when:** the repo appears on your GitHub profile with the README rendered.

### 1.3 Set up the Python virtual environment

```powershell
python -m venv .venv
.venv\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
```

You should see `(.venv)` at the start of your prompt after activation. If `pip install` is slow, that's normal — it's about 400MB total.

**Done when:** `python -c "import pandas, sklearn; print('ok')"` prints `ok`.

### 1.4 Download the dataset

1. Go to https://www.kaggle.com/datasets/blastchar/telco-customer-churn
2. Sign in (free), click **Download** — you'll get `archive.zip`
3. Unzip it and copy `WA_Fn-UseC_-Telco-Customer-Churn.csv` into `data/raw/`

The `.gitignore` is already set up to keep this file out of Git, which is correct — never commit raw data.

**Done when:** the file `data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv` exists and is roughly 1MB.

### 1.5 Build the SQLite warehouse

```powershell
python src/load_to_sqlite.py
```

You should see something like:

```
[OK] Loaded 7,043 rows from WA_Fn-UseC_-Telco-Customer-Churn.csv
     Columns: ['customer_id', 'gender', ...]
[OK] Wrote 7,043 rows to .../data/processed/telecom.db
```

**Done when:** `data/processed/telecom.db` exists. Open it with the SQLite Viewer extension in VS Code to confirm there's a `customers` table.

---

## Phase 2 — Notebook 1: EDA (~3 hours)

Open `notebooks/01_eda.ipynb` in VS Code. The cells are stubbed with `# TODO:` comments telling you exactly what code to write.

### How to work through it

1. Activate the venv (`.venv\Scripts\activate`) before opening VS Code, or pick the venv as the kernel from the top-right of the notebook.
2. Work cell-by-cell, top to bottom. Run each cell with **Shift+Enter**.
3. After each plot, **write a 1–2 sentence markdown cell** under it interpreting what you see. This is the difference between a portfolio piece and a homework dump.
4. The TODOs are comments, not function signatures — you can write the code however feels natural.

### Specific guidance for the harder cells

**Cleaning `TotalCharges`:**
```python
df["TotalCharges"] = pd.to_numeric(df["TotalCharges"], errors="coerce").fillna(0.0)
df["churn_flag"] = (df["Churn"] == "Yes").astype(int)
```

**Helper for grouped churn rate:**
```python
def churn_by(col):
    g = df.groupby(col)["churn_flag"].agg(["count", "sum", "mean"])
    g.columns = ["customers", "churned", "churn_rate"]
    g["churn_rate"] = (g["churn_rate"] * 100).round(2)
    return g.sort_values("churn_rate", ascending=False)

churn_by("Contract")
```

**Saving plots:** every figure should be saved into `../images/` so the README can reference them:
```python
plt.savefig("../images/churn_by_contract.png", dpi=120, bbox_inches="tight")
```

### Commit point

When you finish notebook 01:

```powershell
git add notebooks/01_eda.ipynb images/ data/processed/telecom_clean.csv
git commit -m "feat: complete EDA notebook with cleaned dataset and 8 charts"
git push
```

**Done when:** notebook runs top-to-bottom without errors, produces 6+ saved charts, and ends with a 4-bullet summary cell.

---

## Phase 3 — Notebook 2: SQL analysis (~2 hours)

Open `notebooks/02_sql_analysis.ipynb`. This one is mostly copy-paste from `sql/churn_analysis.sql` with a 1-sentence interpretation under each result.

### The pattern

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect("../data/processed/telecom.db")

def run(sql):
    return pd.read_sql_query(sql, conn)

run("""
SELECT
    contract,
    COUNT(*) AS customers,
    ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY contract
ORDER BY churn_rate_pct DESC;
""")
```

For Q10 (the heatmap), pivot the result and pass it to seaborn:

```python
df10 = run(""" -- the Q10 SQL -- """)
pivot = df10.pivot(index="contract", columns="tenure_bucket", values="churn_rate_pct")
sns.heatmap(pivot, annot=True, fmt=".1f", cmap="Reds")
plt.title("Churn rate (%) by contract type and tenure bucket")
plt.savefig("../images/heatmap_contract_tenure.png", dpi=120, bbox_inches="tight")
```

### Commit point

```powershell
git add notebooks/02_sql_analysis.ipynb images/heatmap_contract_tenure.png
git commit -m "feat: SQL analysis notebook with 10 queries and heatmap"
git push
```

**Done when:** all 10 queries run successfully and each has a 1-sentence interpretation written in markdown.

---

## Phase 4 — Notebook 3: Churn model (~3 hours)

Open `notebooks/03_churn_model.ipynb`. This is the most technically interesting notebook.

### Specific guidance

**Feature engineering pattern:**
```python
df = pd.read_csv("../data/processed/telecom_clean.csv")
y = df["churn_flag"]
X = df.drop(columns=["customerID", "Churn", "churn_flag"])  # check the actual column name
X = pd.get_dummies(X, drop_first=True)
```

**Train/test split:**
```python
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)
```

**Logistic regression with scaling:**
```python
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score

scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

lr = LogisticRegression(max_iter=1000)
lr.fit(X_train_s, y_train)
lr_proba = lr.predict_proba(X_test_s)[:, 1]
print(f"Logistic Regression ROC-AUC: {roc_auc_score(y_test, lr_proba):.3f}")
```

**Random forest:**
```python
from sklearn.ensemble import RandomForestClassifier

rf = RandomForestClassifier(
    n_estimators=200, max_depth=10, random_state=42, class_weight="balanced", n_jobs=-1
)
rf.fit(X_train, y_train)
rf_proba = rf.predict_proba(X_test)[:, 1]
print(f"Random Forest ROC-AUC: {roc_auc_score(y_test, rf_proba):.3f}")
```

**ROC curves on one chart:**
```python
from sklearn.metrics import roc_curve

fpr_lr, tpr_lr, _ = roc_curve(y_test, lr_proba)
fpr_rf, tpr_rf, _ = roc_curve(y_test, rf_proba)

plt.figure(figsize=(7, 6))
plt.plot(fpr_lr, tpr_lr, label=f"Logistic (AUC={roc_auc_score(y_test, lr_proba):.3f})")
plt.plot(fpr_rf, tpr_rf, label=f"Random Forest (AUC={roc_auc_score(y_test, rf_proba):.3f})")
plt.plot([0, 1], [0, 1], "k--", alpha=0.4)
plt.xlabel("False Positive Rate"); plt.ylabel("True Positive Rate")
plt.title("ROC Curves — Churn Models"); plt.legend()
plt.savefig("../images/roc_comparison.png", dpi=120, bbox_inches="tight")
```

You should see ROC-AUC around 0.83–0.85 for both models. If yours is wildly off (above 0.95 or below 0.7), there's a leakage or encoding bug — double check that you dropped `Churn` and `churn_flag` from `X`.

### Commit point

```powershell
git add notebooks/03_churn_model.ipynb images/ data/processed/retention_call_list.csv
git commit -m "feat: churn model with logistic and random forest, ROC-AUC 0.85"
git push
```

---

## Phase 5 — Power BI dashboard (~2 hours)

### 5.1 Connect Power BI to the SQLite database

Power BI doesn't have a native SQLite connector. Two options — pick one:

**Option A (easier): use the cleaned CSV.**
1. Open Power BI Desktop → **Get Data** → **Text/CSV**
2. Point it at `data/processed/telecom_clean.csv`
3. Click **Load**

**Option B (more impressive): use SQLite via ODBC.**
1. Install the SQLite ODBC driver from http://www.ch-werner.de/sqliteodbc/
2. In Windows, open **ODBC Data Sources (64-bit)** → System DSN → Add → SQLite3 ODBC Driver
3. Point it at `data/processed/telecom.db`, give it a DSN name like `TelecomDB`
4. In Power BI: **Get Data** → **ODBC** → pick `TelecomDB`

Option A is fine for this project. If asked in an interview, say "I used the CSV for portability but the pipeline is set up to swap to SQLite or Azure SQL with one connection-string change."

### 5.2 Build the dashboard

Aim for **one page, four sections**:

1. **Top strip — KPI cards:** Total customers, Churn rate %, Total MRR, MRR at risk (sum of MonthlyCharges where churn_flag=1)
2. **Left middle — bar chart:** Churn rate by Contract type
3. **Right middle — bar chart:** Churn rate by Internet Service
4. **Bottom — matrix visual:** rows=Contract, columns=tenure bucket, values=churn rate % (this is your Q10 heatmap)

Use a slicer on `gender` and `SeniorCitizen` so the dashboard is interactive.

### 5.3 Export and save

Save as `dashboard/Telecom_Performance.pbix`. Take a screenshot and put it in `images/dashboard_screenshot.png`. Add it near the top of the README.

### Commit point

```powershell
git add dashboard/Telecom_Performance.pbix images/dashboard_screenshot.png
git commit -m "feat: Power BI executive dashboard"
git push
```

> ⚠️ `.pbix` files can get large (10–50MB). If GitHub warns about file size, use Git LFS:
> ```powershell
> git lfs install
> git lfs track "*.pbix"
> git add .gitattributes
> ```

---

## Phase 6 — Executive summary PDF (~1 hour)

Write a one-page Word document with this structure:

> **Title:** Telecom Customer Churn — Executive Summary
>
> **Situation:** [2 sentences on the dataset and the business question]
>
> **Findings:** [3 bullets, each with a number]
>
> **Recommendation:** [2 bullets — what should the retention team do this quarter?]
>
> **Estimated impact:** [£/$ figure based on your danger-zone cohort analysis]

Export to PDF, save as `reports/executive_summary.pdf`, commit and push.

This is the document you bring to the interview. When they ask "tell me about a project" — you walk them through this one page.

---

## Phase 7 — Polish the README (~30 minutes)

Go back to `README.md` and:

1. Replace the placeholder findings (the X/Y/Z bullets) with your actual numbers.
2. Add the dashboard screenshot near the top: `![Dashboard](images/dashboard_screenshot.png)`
3. Add a "Project status: complete" badge at the top.
4. Push.

```powershell
git add README.md
git commit -m "docs: finalise README with findings and dashboard screenshot"
git push
```

---

## Phase 8 — Pin the repo

On your GitHub profile page → **Customise your pins** → tick this repo. It now shows on your profile.

---

## Realistic timeline

| Phase | Hours | When |
|---|---|---|
| 0 — machine setup | 0.5 | once |
| 1 — scaffold + env | 0.5 | day 1 |
| 2 — EDA notebook | 3 | day 1 evening |
| 3 — SQL notebook | 2 | day 2 evening |
| 4 — model notebook | 3 | day 3 evening |
| 5 — Power BI | 2 | day 4 |
| 6 — exec summary | 1 | day 4 |
| 7–8 — polish | 0.5 | day 4 |
| **Total** | **~12 hours** | **4 evenings** |

If you stick to this you'll have one finished, recruiter-ready repo by the end of the week. Then we move to Project 2.

---

## When you get stuck

- **`pip install` fails:** activate the venv first (`.venv\Scripts\activate`).
- **Notebook can't find pandas:** wrong kernel — top-right of the notebook, pick `.venv` Python.
- **`load_to_sqlite.py` says file not found:** double check the CSV is in `data/raw/` and named exactly `WA_Fn-UseC_-Telco-Customer-Churn.csv`.
- **Power BI can't open the CSV:** check there are no commas in the path or filename.
- **ROC-AUC is suspiciously high (>0.95):** you forgot to drop `Churn` or `churn_flag` from `X`.

When you hit a wall on a specific cell, send me the error message and I'll work through it with you.
