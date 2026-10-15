# First Project Guide: Food Delivery Operations Analytics

## Project Overview

Your first resume project is **Food Delivery Operations Analytics**, using Excel, Power BI, and Python.

The goal is to analyze food-delivery order data and generate business insights about delivery performance, cancellations, traffic, weather, order timing, and service issues. The project includes data cleaning and exploratory analysis in Python, a summary report in Excel, and a management dashboard in Power BI with KPI cards, charts, and slicers.

## Important: Make Evidence-Based Claims

The project may eventually demonstrate that you:
1. Analyzed operational order data.
2. Identified delivery-performance trends, cancellations, traffic patterns, and service issues.
3. Cleaned, validated, and organized a large dataset.
4. Performed exploratory data analysis (EDA) using Python and Pandas.
5. Created a KPI-based report and interactive Power BI dashboard.
6. Compared performance by order time, cancellation reason, traffic level, and weather condition.
7. Produced analytical insights to support business decisions and process improvements.

Only claim that you completed these tasks after the corresponding work is actually finished and supported by project files or screenshots.

---

## Final Deliverables

| Deliverable | Suggested file or evidence |
|---|---|
| Raw data | `data/raw/food_delivery_raw.csv` |
| Cleaned data | `data/processed/food_delivery_clean.csv` |
| Data dictionary | `docs/data_dictionary.xlsx` or a Markdown file |
| Python analysis | `notebooks/01_food_delivery_analysis.ipynb` |
| Python charts | `outputs/charts/` |
| Excel report | `outputs/excel/food_delivery_analysis.xlsx` |
| Power BI dashboard | `outputs/powerbi/food_delivery_operations_dashboard.pbix` |
| Dashboard screenshots | `outputs/screenshots/` |
| Final project report | `docs/project_report.md` or PDF |
| GitHub documentation | `README.md` |

If Power BI Desktop is not available on your Windows computer, complete the Python and Excel deliverables first and create the Power BI dashboard later. Since your resume mentions Power BI, keeping the `.pbix` file and screenshots is recommended.

## Recommended Folder Structure

```text
food-delivery-operations-analytics/
├── data/
│   ├── raw/
│   └── processed/
├── notebooks/
├── src/
├── outputs/
│   ├── charts/
│   ├── excel/
│   ├── powerbi/
│   └── screenshots/
├── docs/
├── README.md
└── requirements.txt
```

**Rule:** Never overwrite the raw data. Keep the original file unchanged in `data/raw/`. Save the cleaned file separately in `data/processed/`.

---

## Step 1 — Choose and Download a Dataset

Choose a food-delivery order dataset with as many of these columns as possible:
- Order ID
- Order date or order time
- Delivery time or preparation time
- Cancellation status or cancellation reason
- Traffic level
- Weather condition
- Delivery-person or vehicle information, if available
- Order value or item quantity, if available

If the dataset does not contain traffic, weather, time, cancellation, or delivery-duration fields, you will not be able to support the project's key claims. Choose a more suitable dataset.

Save the downloaded CSV as `data/raw/food_delivery_raw.csv`.

If you use a sample dataset, record its original source in the README. Do not use a file with an unknown source in a professional portfolio.

## Step 2 — Install the Tools

Required tools:
1. Python 3.10 or later
2. Jupyter Notebook or VS Code
3. Excel or LibreOffice Calc
4. Power BI Desktop
5. Git and a GitHub account

Install the Python packages:

```bash
pip install pandas numpy matplotlib seaborn openpyxl jupyter
```

Create `requirements.txt` with:

```text
pandas
numpy
matplotlib
seaborn
openpyxl
jupyter
```

## Step 3 — Inspect the Raw Data

Create a notebook named `01_food_delivery_analysis.ipynb` and run:

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

pd.set_option("display.max_columns", None)

raw_path = "../data/raw/food_delivery_raw.csv"
df = pd.read_csv(raw_path)

print("Rows and columns:", df.shape)
display(df.head())
df.info()
display(df.describe(include="all").T)
```

Record:
- Total rows and columns
- Column names
- Numeric, text/category, and date/time columns
- Columns with missing values
- Duplicate-row count

Use this notebook heading:

```markdown
## 1. Initial data inspection
```

This step is complete when the dataset loads, the first five rows are visible, and the shape and data types have been recorded.

## Step 4 — Create a Data Dictionary

Document each column's business meaning. Example:

| Column | Meaning | Data type | Example |
|---|---|---|---|
| `order_id` | Identifier for each order | Text | FD1001 |
| `order_date` | Date the order was placed | Date | 2025-01-15 |
| `order_time` | Time the order was placed | Time | 19:30 |
| `delivery_minutes` | Minutes required to complete delivery | Number | 42 |
| `traffic_level` | Traffic conditions during delivery | Category | High |
| `weather` | Weather during the order/delivery | Category | Rainy |
| `cancelled` | Whether the order was cancelled | Category | Yes/No |
| `cancellation_reason` | Reason for cancellation | Category | Late delivery |

Adapt this table to the real column names in your dataset. Do not guess the meaning of a column; consult the source documentation.

## Step 5 — Clean the Data

### 5.1 Standardize column names

```python
clean = df.copy()

clean.columns = (
    clean.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_", regex=False)
    .str.replace("-", "_", regex=False)
)

print(clean.columns.tolist())
```

### 5.2 Find duplicate rows

```python
duplicate_count = clean.duplicated().sum()
print("Duplicate rows:", duplicate_count)

clean = clean.drop_duplicates()
```

Record how many duplicate rows were removed.

### 5.3 Find missing values

```python
missing = (
    clean.isna().sum()
    .sort_values(ascending=False)
    .to_frame("missing_count")
)
missing["missing_percent"] = missing["missing_count"] / len(clean) * 100
print(missing)
```

Choose a rule for each type of missing value:
- If `order_id` is missing, the row may need to be removed.
- Do not automatically replace missing `delivery_minutes` with the average; this can distort delivery-performance analysis. Consider documenting and excluding such rows from the relevant analysis.
- If `cancellation_reason` is missing because an order was not cancelled, it may be appropriate to fill it with `Not Cancelled`.
- Standardize spelling variations in category columns.

### 5.4 Convert date/time columns

```python
if "order_date" in clean.columns:
    clean["order_date"] = pd.to_datetime(
        clean["order_date"], errors="coerce"
    )

if "order_time" in clean.columns:
    clean["order_time"] = pd.to_datetime(
        clean["order_time"], errors="coerce"
    )
```

Change the column names in the code if your dataset uses different names.

### 5.5 Standardize category values

```python
for column in ["traffic_level", "weather", "cancellation_reason"]:
    if column in clean.columns:
        clean[column] = clean[column].astype("string").str.strip().str.title()
```

Values such as `High`, `high`, and `HIGH` should become one category. Do not merge categories that have different meanings, such as `No Rain` and `Rainy`.

### 5.6 Validate business rules

```python
if "delivery_minutes" in clean.columns:
    print("Negative delivery times:", (clean["delivery_minutes"] < 0).sum())

if "order_id" in clean.columns:
    print("Unique order IDs:", clean["order_id"].nunique())
    print("Duplicate order IDs:", clean["order_id"].duplicated().sum())
```

Delivery time should not be negative. If an order ID is duplicated, check the source documentation to determine whether it is a true duplicate or whether an order legitimately has multiple records.

## Step 6 — Create Analysis Columns

If the dataset contains dates and times, create useful derived columns:

```python
if "order_date" in clean.columns:
    clean["order_day"] = clean["order_date"].dt.day_name()
    clean["order_month"] = clean["order_date"].dt.to_period("M").astype(str)

if "order_time" in clean.columns:
    clean["order_hour"] = clean["order_time"].dt.hour
    clean["day_part"] = pd.cut(
        clean["order_hour"],
        bins=[-1, 6, 11, 15, 18, 22, 24],
        labels=["Night", "Morning", "Afternoon", "Evening", "Late evening", "Night 2"]
    )
```

If delivery duration is available:

```python
if "delivery_minutes" in clean.columns:
    clean["delivery_band"] = pd.cut(
        clean["delivery_minutes"],
        bins=[0, 30, 45, 60, float("inf")],
        labels=["0-30 min", "31-45 min", "46-60 min", "60+ min"]
    )
```

Adjust the bands to suit the business context and explain your chosen thresholds in the report.

## Step 7 — Save the Cleaned File

```python
processed_path = "../data/processed/food_delivery_clean.csv"
clean.to_csv(processed_path, index=False)
print("Saved:", processed_path)
```

Record the cleaning summary in the notebook:
- Initial row count
- Duplicate rows removed
- Missing values handled
- Invalid rows excluded
- Final row count
- Final column count

This provides evidence for the resume claim: “Cleaned, validated, and organized large datasets.”

## Step 8 — Perform Exploratory Data Analysis

Answer the following business questions.

### Question 1: How is delivery performance?

```python
if "delivery_minutes" in clean.columns:
    print(clean["delivery_minutes"].describe())
```

Report average, median, minimum and maximum delivery time, and the number of orders taking more than 60 minutes.

### Question 2: Which time period has slower deliveries?

```python
if {"day_part", "delivery_minutes"}.issubset(clean.columns):
    time_summary = (
        clean.groupby("day_part", observed=False)["delivery_minutes"]
        .agg(order_count="count", average_delivery="mean", median_delivery="median")
        .reset_index()
    )
    display(time_summary)
```

### Question 3: What is the impact of traffic?

```python
if {"traffic_level", "delivery_minutes"}.issubset(clean.columns):
    traffic_summary = (
        clean.groupby("traffic_level", dropna=False)["delivery_minutes"]
        .agg(order_count="count", average_delivery="mean", median_delivery="median")
        .reset_index()
        .sort_values("average_delivery", ascending=False)
    )
    display(traffic_summary)
```

### Question 4: Does performance vary by weather?

```python
if {"weather", "delivery_minutes"}.issubset(clean.columns):
    weather_summary = (
        clean.groupby("weather", dropna=False)["delivery_minutes"]
        .agg(order_count="count", average_delivery="mean", median_delivery="median")
        .reset_index()
        .sort_values("average_delivery", ascending=False)
    )
    display(weather_summary)
```

### Question 5: What is the cancellation rate?

If the `cancelled` column contains Yes/No values:

```python
if "cancelled" in clean.columns:
    cancel_rate = clean["cancelled"].astype("string").str.lower().eq("yes").mean() * 100
    print(f"Cancellation rate: {cancel_rate:.2f}%")
```

If your dataset uses a `status` column or another field, adapt the code accordingly.

### Question 6: What are the main cancellation reasons?

```python
if "cancellation_reason" in clean.columns:
    reasons = clean["cancellation_reason"].value_counts(dropna=False).reset_index()
    reasons.columns = ["cancellation_reason", "cancelled_orders"]
    display(reasons.head(10))
```

Write a business interpretation for every chart. Do not only write “The chart shows...”. For example: “High-traffic orders have a higher average delivery time than low-traffic orders, suggesting that peak-period routing or capacity should be reviewed.” Never write conclusions without actual supporting numbers.

## Step 9 — Create Python Charts

Create at least four charts:
1. Delivery-time distribution
2. Average delivery time by traffic level
3. Average delivery time by weather condition
4. Cancellation reasons

Example:

```python
import os
os.makedirs("../outputs/charts", exist_ok=True)

if {"traffic_level", "delivery_minutes"}.issubset(clean.columns):
    plt.figure(figsize=(8, 5))
    sns.barplot(
        data=clean,
        x="traffic_level",
        y="delivery_minutes",
        estimator="mean",
        errorbar=None
    )
    plt.title("Average Delivery Time by Traffic Level")
    plt.xlabel("Traffic Level")
    plt.ylabel("Average Delivery Time (minutes)")
    plt.tight_layout()
    plt.savefig("../outputs/charts/average_delivery_by_traffic.png", dpi=200)
    plt.show()
```

Every chart should have a clear title, axis labels, units, readable colors, and a dataset/source note.

## Step 10 — Create an Excel Report

Create these workbook sheets:
1. `Cleaned_Data`
2. `KPI_Summary`
3. `Traffic_Analysis`
4. `Weather_Analysis`
5. `Cancellation_Analysis`
6. `Time_Analysis`
7. `Charts`

The KPI Summary sheet should include:
- Total orders
- Completed orders
- Cancelled orders
- Cancellation rate
- Average delivery time
- Median delivery time
- Delayed-order count

Do not type KPI values manually. Use Excel formulas, PivotTables, or exports from the cleaned data.

Formatting recommendations:
- Dark fill and bold white text for the header row
- Consistent decimal formatting for numeric values
- Percentage formatting for rates
- Clear labels and borders for KPI cards
- Conditional formatting to highlight high cancellation rates or long delivery times

## Step 11 — Build the Power BI Data Model and Dashboard

Import `data/processed/food_delivery_clean.csv` into Power BI Desktop.

### Check data in Power Query

Verify:
- Correct data types
- Date columns use the Date type
- Delivery duration uses Whole Number or Decimal Number
- Category values are standardized
- No blank order IDs
- No unintended duplicate records

Python cleaning rules and Power Query rules should be consistent.

### Suggested dashboard pages

#### Page 1: Executive Overview

KPI cards:
- Total Orders
- Average Delivery Time
- Cancellation Rate
- Delayed Orders

Visuals:
- Delivery trend by date or month
- Orders by traffic level
- Orders by weather
- Slicers for date, traffic, weather, and cancellation status

#### Page 2: Delivery Performance

Visuals:
- Average delivery time by traffic
- Average delivery time by day part
- Delivery-time distribution
- Delayed-order count by category

#### Page 3: Cancellation and Service Issues

Visuals:
- Cancellation reasons bar chart
- Cancellation rate by traffic level
- Cancellation rate by weather
- Table of order-level exceptions

### Basic DAX measures

Adapt the table and column names to match your data:

```dax
Total Orders = DISTINCTCOUNT(FoodDelivery[order_id])

Average Delivery Minutes = AVERAGE(FoodDelivery[delivery_minutes])

Cancelled Orders =
CALCULATE(
    [Total Orders],
    FoodDelivery[cancelled] = "Yes"
)

Cancellation Rate =
DIVIDE([Cancelled Orders], [Total Orders], 0)

Delayed Orders =
CALCULATE(
    [Total Orders],
    FoodDelivery[delivery_minutes] > 60
)
```

The 60-minute threshold is only an example. Choose a threshold appropriate to the dataset and business context, and explain it in your report.

### Dashboard design rules

- Each page should answer a clear question.
- Avoid overcrowding a page with too many visuals.
- Reserve red for problems or exceptions.
- Keep slicer logic consistent across pages.
- Chart titles should clearly identify both the metric and the dimension.
- Record the filter state used for each dashboard screenshot.

## Step 12 — Write Business Insights

Use only insights supported by the actual data. Use this format for each insight:

> **Finding:** What did the analysis discover?  
> **Evidence:** Which metric or comparison supports it?  
> **Business implication:** What should the operations team pay attention to?  
> **Recommended action:** What action could be considered?

Example format:

> **Finding:** High-traffic periods have the longest average delivery time.  
> **Evidence:** Average delivery time for High traffic is [actual value] minutes, compared with [actual value] minutes for Low traffic.  
> **Business implication:** Peak-period congestion may contribute to late deliveries.  
> **Recommended action:** Review delivery-zone capacity, rider allocation, and peak-hour dispatch rules.

Do not fill in placeholder values until you have completed the analysis. Write at least five insights:
1. Delivery-performance insight
2. Traffic-impact insight
3. Weather-impact insight
4. Cancellation insight
5. Time-period or service-risk insight

## Step 13 — Quality Checks

Before submitting the project, confirm that:
- Raw data remains unchanged.
- The cleaned file is stored separately.
- Duplicate counts are documented.
- Missing-value handling is documented.
- Invalid values have been checked.
- KPI totals match across Python, Excel, and Power BI.
- Dashboard filters work.
- All charts have titles and units.
- There are no empty visuals or broken formulas.
- All insights are based on actual values.
- Screenshots are saved.
- The README contains tools, workflow, findings, and limitations.
- The `.pbix`, notebook, cleaned CSV, and report files are saved.

Reconciliation check:

```python
print("Python total rows:", len(clean))
print("Python unique orders:", clean["order_id"].nunique())
```

Compare these results with the Excel total and Power BI `Total Orders` measure. If the values do not match, do not consider the project complete until the discrepancy is explained.

## Step 14 — Write the GitHub README

Include these sections:

```markdown
# Food Delivery Operations Analytics

## Objective
This project analyzes food delivery operations to understand delivery performance,
cancellations, traffic patterns, weather impact, and service issues.

## Tools
- Python and Pandas
- Microsoft Excel
- Microsoft Power BI

## Workflow
1. Data inspection
2. Data cleaning and validation
3. Exploratory analysis
4. KPI reporting
5. Power BI dashboard development
6. Business insight generation

## Key KPIs
Add actual values from the completed analysis.

## Key Findings
Add five findings with actual numbers.

## Dashboard Preview
Add Power BI screenshots.

## Limitations
Document missing fields, data quality issues, assumptions, and thresholds.
```

Do not write “I analyzed...” in the README until the analysis notebook and screenshots genuinely support that claim.

## Resume Project Description

After completing the project, adapt the following description using actual results:

**Food Delivery Operations Analytics | Excel, Power BI, Python**
- Cleaned and validated a [X]-row food-delivery dataset using Python and Pandas, documenting missing values, duplicates, and invalid records.
- Analyzed delivery time, cancellation rate, traffic level, weather condition, and order timing to identify operational performance patterns.
- Built Excel KPI reports and an interactive Power BI dashboard with [X] key measures, slicers, and exception views.
- Identified [actual finding] and [actual finding], supporting recommendations for peak-hour capacity planning and delivery-process improvement.

Fill in `[X]` and `[actual finding]` only after completing the project.

## Definition of Done

The project is complete only when all three conditions are met:

1. **Reproducible analysis:** The notebook can be run from the raw CSV to recreate the cleaned file and charts.
2. **Consistent reporting:** Key KPI values match across Python, Excel, and Power BI.
3. **Evidence-backed communication:** Dashboard screenshots, the README, and the final report contain insights supported by actual values.

Do not describe the project as completed on your resume until these conditions are satisfied.

## Next Task

For the original workflow, the first task is to select a suitable food-delivery CSV and save it as `data/raw/food_delivery_raw.csv`. After downloading it, share the column names or upload the dataset so the cleaning code can be adapted to the real data.
