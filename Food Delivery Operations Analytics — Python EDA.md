# Food Delivery Operations Analytics — Python EDA

## Scope and method

This analysis uses only the `Raw_Data` sheet from `food_delivery_operations_intelligence.xlsx`. The raw workbook was not modified. The workbook has a title row above the source headers, so the analysis reads the source header row with `skiprows=1`. Calculations use Pandas; visualizations use Matplotlib.

> **Important interpretation rule:** delivery-time fields, customer ratings, tips, and late-delivery flags are unavailable for cancelled orders. Delivery-performance KPIs therefore use completed orders where appropriate. This is a data-availability choice, not an imputation.

## 1. Import dataset

```python
import pandas as pd
df = pd.read_excel("food_delivery_operations_intelligence.xlsx", sheet_name="Raw_Data", skiprows=1)
print(df.shape)
print(df.head())
print(df.tail())
```

**Actual result:** `df.shape = (50000, 37)`. The dataset contains 50,000 order records and 43 source columns.

## 2. Basic inspection

### Source columns and types

| Column                              | Data type      |
|:------------------------------------|:---------------|
| order_id                            | str            |
| customer_id                         | str            |
| restaurant_id                       | str            |
| driver_id                           | str            |
| order_timestamp                     | datetime64[us] |
| order_date                          | datetime64[us] |
| order_hour                          | int64          |
| day_of_week                         | str            |
| is_weekend                          | int64          |
| city                                | str            |
| delivery_area                       | str            |
| customer_age                        | int64          |
| customer_type                       | str            |
| restaurant_type                     | str            |
| restaurant_primary_category         | str            |
| restaurant_rating                   | float64        |
| items_count                         | int64          |
| subtotal                            | float64        |
| discount_percent                    | int64          |
| tax_amount                          | float64        |
| service_fee                         | float64        |
| delivery_fee                        | float64        |
| order_total                         | float64        |
| payment_method                      | str            |
| tip_amount                          | float64        |
| distance_km                         | float64        |
| weather                             | str            |
| traffic_level                       | str            |
| delivery_partner_experience_months  | int64          |
| delivery_partner_rating             | float64        |
| restaurant_preparation_time_minutes | int64          |
| estimated_delivery_time_minutes     | int64          |
| actual_delivery_time_minutes        | float64        |
| late_delivery                       | float64        |
| order_status                        | str            |
| cancellation_reason                 | str            |
| customer_rating                     | float64        |
| Cancellation_Flag                   | int64          |
| Completed_Flag                      | int64          |
| Delivery_Delay_Minutes              | float64        |
| Late_Delivery_Flag                  | int64          |
| Distance_Category                   | category       |
| Hour_Category                       | category       |

### Important categorical values

**`order_status`** (2 non-null categories): Completed, Cancelled

**`cancellation_reason`** (5 non-null categories): Driver Unassigned, Changed Mind, Restaurant Unavailable, Customer Cancelled, Long Prep Delay

**`city`** (4 non-null categories): City_C, City_A, City_B, City_D

**`traffic_level`** (3 non-null categories): Medium, High, Low

**`weather`** (4 non-null categories): Rain, Cloudy, Clear, Storm

**`restaurant_type`** (4 non-null categories): Casual Dining, Cafe, Fast Food, Fine Dining

**`restaurant_primary_category`** (6 non-null categories): Healthy, Dessert, Local, Pizza, Burger, Asian

**`customer_type`** (3 non-null categories): Premium, Regular, New

**`payment_method`** (3 non-null categories): Credit Card, Cash, Digital Wallet

**`day_of_week`** (7 non-null categories): Sunday, Wednesday, Tuesday, Thursday, Friday, Monday, Saturday

The source includes identifiers, order time fields, geography, customer and restaurant attributes, financial fields, delivery conditions, operational timing, status, cancellation reason, and ratings.

## 3. Data-quality check

- Duplicate full rows: **0**
- Duplicate `order_id` values: **0**
- Total missing cells before cleaning: **52,604**


| Column                       |   Null count |   Null % |
|:-----------------------------|-------------:|---------:|
| cancellation_reason          |        49132 |    98.26 |
| Delivery_Delay_Minutes       |          868 |     1.74 |
| actual_delivery_time_minutes |          868 |     1.74 |
| customer_rating              |          868 |     1.74 |
| late_delivery                |          868 |     1.74 |
| tip_amount                   |          868 |     1.74 |

**Quality conclusion:** missing values are concentrated in cancellation-only or completion-only fields: `cancellation_reason` is blank for completed orders, while `tip_amount`, actual delivery time, late-delivery flag, and customer rating are blank for cancelled orders. There are no duplicate records or duplicate order IDs. No broad imputation was applied.

## 4. Data cleaning

The raw data was preserved. Cleaning was limited to parsing `order_timestamp` and `order_date` as datetimes and using explicit derived flags/categories for analysis. No rows were removed because duplicate checks found no duplicates and missingness aligned with order status.


**Before:** shape `(50000, 37)`, null cells `52,604`, duplicate rows `0`.


**After:** shape `(50000, 43)`, null cells `53,472` in the analysis copy, duplicate rows `0`.

## 5. Feature engineering

```python
df["Cancellation_Flag"] = (df["order_status"] == "Cancelled").astype(int)
df["Completed_Flag"] = (df["order_status"] == "Completed").astype(int)
df["Delivery_Delay_Minutes"] = df["actual_delivery_time_minutes"] - df["estimated_delivery_time_minutes"]
df["Late_Delivery_Flag"] = df["late_delivery"].fillna(0).astype(int)
df["Distance_Category"] = pd.cut(df["distance_km"], [-np.inf, 2, 5, 8, 12, np.inf], labels=["0–2 km", ">2–5 km", ">5–8 km", ">8–12 km", ">12 km"])
```

These columns are analysis helpers: flags make counts and rates readable; delay measures actual minus estimated time; distance categories convert a numeric distance into operational bands that can be compared.

## 6. KPI analysis

| KPI               |   Calculated value |
|:------------------|-------------------:|
| Total Orders      |           50000    |
| Completed Orders  |           49132    |
| Cancelled Orders  |             868    |
| Completion Rate   |              98.26 |
| Cancellation Rate |               1.74 |

### Validation against supplied Excel reference values

| Metric                               |   Reference value |   Calculated value | Matches reference   |
|:-------------------------------------|------------------:|-------------------:|:--------------------|
| Total Orders                         |          50000    |           50000    | True                |
| Cancelled Orders                     |            868    |             868    | True                |
| Cancellation Rate %                  |              1.74 |               1.74 | True                |
| Changed Mind cancellations           |            153    |             153    | True                |
| Customer Cancelled cancellations     |            154    |             154    | True                |
| Driver Unassigned cancellations      |            386    |             386    | True                |
| Long Prep Delay cancellations        |             15    |              15    | True                |
| Restaurant Unavailable cancellations |            160    |             160    | True                |
| Average Preparation Time             |             15.55 |              15.54 | True                |
| Average Actual Delivery Time         |             35.15 |              35.15 | True                |
| Average Estimated Delivery Time      |             30.92 |              30.92 | True                |
| Late Deliveries                      |          17968    |           17968    | True                |
| Late Delivery Rate %                 |             36.57 |              36.57 | True                |

All supplied KPI and cancellation/delivery reference values match the calculated values within the stated rounding precision.

## 7. Cancellation analysis

### Cancellation reasons
| Cancellation Reason    |   Cancelled Orders |   Share of Cancellations % |
|:-----------------------|-------------------:|---------------------------:|
| Driver Unassigned      |                386 |                      44.47 |
| Restaurant Unavailable |                160 |                      18.43 |
| Customer Cancelled     |                154 |                      17.74 |
| Changed Mind           |                153 |                      17.63 |
| Long Prep Delay        |                 15 |                       1.73 |

### City-wise cancellation exposure
| city   |   Orders |   Cancelled_Orders |   Cancellation_Rate % |
|:-------|---------:|-------------------:|----------------------:|
| City_A |    19888 |                361 |                  1.82 |
| City_B |    14885 |                258 |                  1.73 |
| City_C |    10178 |                172 |                  1.69 |
| City_D |     5049 |                 77 |                  1.53 |

### Cancellation reasons by city
| city   |   Changed Mind |   Customer Cancelled |   Driver Unassigned |   Long Prep Delay |   Restaurant Unavailable |
|:-------|---------------:|---------------------:|--------------------:|------------------:|-------------------------:|
| City_A |             64 |                   68 |                 155 |                 4 |                       70 |
| City_B |             53 |                   40 |                 118 |                 2 |                       45 |
| City_C |             28 |                   30 |                  78 |                 6 |                       30 |
| City_D |              8 |                   16 |                  35 |                 3 |                       15 |

### Hour-wise and day-wise cancellations
|   order_hour |   Orders |   Cancellations |
|-------------:|---------:|----------------:|
|            0 |      429 |               6 |
|            1 |      437 |               7 |
|            2 |      408 |               3 |
|            3 |      407 |               3 |
|            4 |      425 |               3 |
|            5 |      404 |               9 |
|            6 |      868 |              16 |
|            7 |     1301 |              13 |
|            8 |     1675 |              28 |
|            9 |     2106 |              37 |
|           10 |     2618 |              46 |
|           11 |     3441 |              60 |
|           12 |     4208 |              79 |
|           13 |     3836 |              73 |
|           14 |     3098 |              53 |
|           15 |     1610 |              25 |
|           16 |     1725 |              28 |
|           17 |     2121 |              35 |
|           18 |     3803 |              59 |
|           19 |     4746 |              90 |
|           20 |     4318 |             101 |
|           21 |     3382 |              63 |
|           22 |     1734 |              20 |
|           23 |      900 |              11 |
| day_of_week   |   Orders |   Cancellations |
|:--------------|---------:|----------------:|
| Monday        |     6665 |             125 |
| Tuesday       |     6671 |             113 |
| Wednesday     |     8212 |             162 |
| Thursday      |     8472 |             156 |
| Friday        |     6624 |             107 |
| Saturday      |     6698 |             103 |
| Sunday        |     6658 |             102 |

**Finding → Evidence → Business meaning**


- **Finding:** `Driver Unassigned` is the largest cancellation reason. **Evidence:** 386 of 868 cancellations (44.47%). **Business meaning:** this is the first operational category to investigate; the data does not prove the root cause.

- **Finding:** city cancellation rates differ. **Evidence:** rates range from 1.53% to 1.82%. **Business meaning:** compare city-level assignment, restaurant, and traffic mix before choosing an intervention.

## 8. Delivery performance

| Metric                                    |    Value |
|:------------------------------------------|---------:|
| Average preparation time (minutes)        |    15.54 |
| Average estimated delivery time (minutes) |    30.92 |
| Average actual delivery time (minutes)    |    35.15 |
| Average delivery delay (minutes)          |     4.23 |
| Late deliveries                           | 17968    |
| Late delivery rate                        |    36.57 |

**Business interpretation:** completed orders average approximately 35.15 minutes actual delivery time versus 30.92 minutes estimated, giving an average delay of 4.23 minutes. This describes the observed gap; it does not by itself establish why delays occur.

## 9. City analysis
| city   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:-------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| City_A |    19888 |              19527 |                361 |               34.99 |                37.59 |             36.77 |                1.82 |
| City_B |    14885 |              14627 |                258 |               36.01 |                38.19 |             41.09 |                1.73 |
| City_C |    10178 |              10006 |                172 |               34.06 |                33.12 |             34.13 |                1.69 |
| City_D |     5049 |               4972 |                 77 |               35.47 |                34.73 |             43.2  |                1.53 |

City results are presented as differences in volume, cancellation exposure, delivery time, and late-delivery rate. No city is labeled “best” or “worst.”

## 10. Traffic analysis
| traffic_level   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:----------------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| High            |    15313 |              14948 |                365 |               39.89 |                38.65 |             37.85 |                2.38 |
| Low             |    15165 |              14987 |                178 |               30.59 |                34.66 |             38.32 |                1.17 |
| Medium          |    19522 |              19197 |                325 |               35.02 |                36.44 |             38.3  |                1.66 |

## 11. Weather analysis
| weather   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:----------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| Clear     |    28248 |              27857 |                391 |               33.56 |                24.49 |             38.3  |                1.38 |
| Cloudy    |    12810 |              12581 |                229 |               35.12 |                38.76 |             37.3  |                1.79 |
| Rain      |     7627 |               7427 |                200 |               39.16 |                69.18 |             38.61 |                2.62 |
| Storm     |     1315 |               1267 |                 48 |               47.07 |                89.19 |             41.26 |                3.65 |

## 12. Distance analysis

| Statistic   |    Value |
|:------------|---------:|
| count       | 50000    |
| mean        |     4.73 |
| std         |     2.78 |
| min         |     0.8  |
| 25%         |     2.8  |
| 50%         |     4.1  |
| 75%         |     5.9  |
| max         |    20    |

The distance bands (0–2, >2–5, >5–8, >8–12, >12 km) are operationally interpretable ranges that make short-, medium-, and long-distance performance comparable.

| Distance_Category   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:--------------------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| 0–2 km              |     5333 |               5267 |                 66 |               22.59 |                29.43 |             37.01 |                1.24 |
| >2–5 km             |    27301 |              26818 |                483 |               30.07 |                34.52 |             37.7  |                1.77 |
| >5–8 km             |    11917 |              11711 |                206 |               41.2  |                40.23 |             38.27 |                1.73 |
| >8–12 km            |     4195 |               4106 |                 89 |               54.87 |                44.86 |             40.93 |                2.12 |
| >12 km              |     1254 |               1230 |                 24 |               76.32 |                49.35 |             43.23 |                1.91 |

## 13. Restaurant analysis
### Restaurant type
| restaurant_type   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:------------------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| Cafe              |     8140 |               7999 |                141 |               31.29 |                35.25 |             22.14 |                1.73 |
| Casual Dining     |    13063 |              12848 |                215 |               38.6  |                37.06 |             52.32 |                1.65 |
| Fast Food         |    27593 |              27106 |                487 |               34.11 |                36.88 |             33.17 |                1.76 |
| Fine Dining       |     1204 |               1179 |                 25 |               47.74 |                32.91 |            107.51 |                2.08 |
### Cuisine/category
| restaurant_primary_category   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:------------------------------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| Asian                         |     3799 |               3744 |                 55 |               36.65 |                37.26 |             46.42 |                1.45 |
| Burger                        |    16184 |              15905 |                279 |               34    |                35.76 |             33.91 |                1.72 |
| Dessert                       |     9587 |               9418 |                169 |               35.47 |                36.84 |             38.87 |                1.76 |
| Healthy                       |     3588 |               3541 |                 47 |               37.26 |                34.2  |             46.31 |                1.31 |
| Local                         |    12747 |              12498 |                249 |               35.04 |                37.57 |             37.32 |                1.95 |
| Pizza                         |     4095 |               4026 |                 69 |               36.07 |                37.51 |             41.24 |                1.68 |
### Rating and preparation relationship
|   restaurant_rating |   Orders |   Cancelled_Orders |   Avg_Preparation |   Cancellation_Rate % |
|--------------------:|---------:|-------------------:|------------------:|----------------------:|
|                 2.8 |       84 |                  0 |             15.33 |                  0    |
|                 3.1 |       59 |                  4 |             14.05 |                  6.78 |
|                 3.2 |      505 |                 10 |             19.03 |                  1.98 |
|                 3.3 |      865 |                 11 |             17.92 |                  1.27 |
|                 3.4 |      618 |                  7 |             14.76 |                  1.13 |
|                 3.5 |      723 |                 10 |             17.74 |                  1.38 |
|                 3.6 |     3968 |                 62 |             14.93 |                  1.56 |
|                 3.7 |     1178 |                 24 |             16.44 |                  2.04 |
|                 3.8 |      719 |                 15 |             13.37 |                  2.09 |
|                 3.9 |    10352 |                186 |             14.39 |                  1.8  |
|                 4   |      781 |                 14 |             16.73 |                  1.79 |
|                 4.1 |      891 |                 23 |             15.47 |                  2.58 |
|                 4.2 |     7107 |                131 |             14.6  |                  1.84 |
|                 4.3 |     3496 |                 47 |             16.69 |                  1.34 |
|                 4.4 |     2865 |                 54 |             17.09 |                  1.88 |
|                 4.5 |     2323 |                 33 |             15.71 |                  1.42 |
|                 4.6 |     2671 |                 41 |             17.79 |                  1.54 |
|                 4.7 |     2385 |                 31 |             16.78 |                  1.3  |
|                 4.8 |     5485 |                104 |             13.04 |                  1.9  |
|                 4.9 |      388 |                  8 |             18.93 |                  2.06 |
|                 5   |     2537 |                 53 |             19.8  |                  2.09 |

## 14. Customer and payment analysis
### Customer type
| customer_type   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:----------------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| New             |    10175 |              10008 |                167 |               35.73 |                37.56 |             40.68 |                1.64 |
| Premium         |    14727 |              14452 |                275 |               34.71 |                34.92 |             33.97 |                1.87 |
| Regular         |    25098 |              24672 |                426 |               35.18 |                37.14 |             39.62 |                1.7  |
### Payment method
| payment_method   |   Orders |   Completed_Orders |   Cancelled_Orders |   Avg_Delivery_Time |   Late_Delivery_Rate |   Avg_Order_Value |   Cancellation_Rate |
|:-----------------|---------:|-------------------:|-------------------:|--------------------:|---------------------:|------------------:|--------------------:|
| Cash             |    15050 |              14811 |                239 |               35.2  |                37.02 |             38.59 |                1.59 |
| Credit Card      |    24971 |              24523 |                448 |               35.18 |                36.58 |             38.06 |                1.79 |
| Digital Wallet   |     9979 |               9798 |                181 |               35.01 |                35.87 |             37.81 |                1.81 |

Order value, tips, and customer ratings are available in the source. Their descriptive fields were retained in the cleaned copy; cancelled-order missingness means comparisons using these fields should be restricted to non-null observations and should not be interpreted as causal.

## 15. Visualizations

The following charts were created with Matplotlib and saved in the `charts/` folder:

1. `01_completed_vs_cancelled.png`
2. `02_cancellation_reasons.png`
3. `03_cancellation_rate_city.png`
4. `04_cancellation_reasons_city.png`
5. `05_orders_cancellations_hour.png`
6. `06_orders_cancellations_day.png`
7. `07_delivery_time_distribution.png`
8. `08_late_vs_ontime.png`
9. `09_cancellation_rate_traffic.png`
10. `10_cancellation_rate_weather.png`
11. `11_cancellation_rate_distance.png`
12. `12_delivery_time_traffic.png`


![01_completed_vs_cancelled.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wMV9jb21wbGV0ZWRfdnNfY2FuY2VsbGVk.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d01WOWpiMjF3YkdWMFpXUmZkbk5mWTJGdVkyVnNiR1ZrLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc5MzQ5MTIwMH19fV19&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEYCIQD6M5VPzTuYYe440RM5e~iWyKv3QjADEJi11Op3qOlAXgIhALjRNNEhEDJ5AZD2dlCWqKBClO9ttxnxYbhIg1slRXWm)


![02_cancellation_reasons.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wMl9jYW5jZWxsYXRpb25fcmVhc29ucw.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d01sOWpZVzVqWld4c1lYUnBiMjVmY21WaGMyOXVjdy5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTM0OTEyMDB9fX1dfQ__&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEUCIQCVvv-8L6riep~rOQlB2KLxrdqprYcJpJ5vnCWg5thJ7gIgZPcSYDznTTibkS6GDNZ8lI4q4Vl4euu5BKksLuDUb0E_)


![03_cancellation_rate_city.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wM19jYW5jZWxsYXRpb25fcmF0ZV9jaXR5.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d00xOWpZVzVqWld4c1lYUnBiMjVmY21GMFpWOWphWFI1LnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc5MzQ5MTIwMH19fV19&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEYCIQC23j6xfw7di36D9DvvW0~l2zCM563UGiQY2KhpwM080wIhAMuyLBi-nBkm2FOoQe6K3SWuDplqpnR1Ez-Ue54vKpuf)


![04_cancellation_reasons_city.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wNF9jYW5jZWxsYXRpb25fcmVhc29uc19jaXR5.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d05GOWpZVzVqWld4c1lYUnBiMjVmY21WaGMyOXVjMTlqYVhSNS5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTM0OTEyMDB9fX1dfQ__&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEUCIQD2LhiCvTP9-gmJWlznShTZHWNvRjZ5pqwc8PCUjB0omQIgRvvxSpOqV6qa~1obofbJI55tevlaxmh9Xiy~xrL44Gg_)


![05_orders_cancellations_hour.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wNV9vcmRlcnNfY2FuY2VsbGF0aW9uc19ob3Vy.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d05WOXZjbVJsY25OZlkyRnVZMlZzYkdGMGFXOXVjMTlvYjNWeS5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTM0OTEyMDB9fX1dfQ__&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEQCIGCPz21wuw5iBIUnafk5t9qi0yW~WXdxv2xSm8IeWChxAiAEgPvWkZKzLayMMvyuA-ZsFKuu5RjOJXh3BGrWd5~l0Q__)


![06_orders_cancellations_day.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wNl9vcmRlcnNfY2FuY2VsbGF0aW9uc19kYXk.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d05sOXZjbVJsY25OZlkyRnVZMlZzYkdGMGFXOXVjMTlrWVhrLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc5MzQ5MTIwMH19fV19&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEUCIQCl2RqZ~bVvxaABvVKHX6Hs~Y1app5-c-jaK7hbe~9fTwIgBz1dQCBbigsrNUY2p7NyGBPvexjYXIj1aEiIF5iC3BE_)


![07_delivery_time_distribution.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wN19kZWxpdmVyeV90aW1lX2Rpc3RyaWJ1dGlvbg.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d04xOWtaV3hwZG1WeWVWOTBhVzFsWDJScGMzUnlhV0oxZEdsdmJnLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc5MzQ5MTIwMH19fV19&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEYCIQCjBmuko2FT7yYAk8~js~ZAHXJJJHBvbwQR-HEdffvmkQIhAONgrE3JcOaqSMypyhwEs0YbdTyQ~izkqI~vAspFkY7Q)


![08_late_vs_ontime.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wOF9sYXRlX3ZzX29udGltZQ.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d09GOXNZWFJsWDNaelgyOXVkR2x0WlEucG5nIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzkzNDkxMjAwfX19XX0_&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEYCIQDITz6JauX2ZfYgOcU4kGYv82oDWAi1hrsdlacTyjJY7AIhAIUJ~zUOG87Ww5bAZDhI4jUIfldH6tw0MXhI0I7-vrdl)


![09_cancellation_rate_traffic.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8wOV9jYW5jZWxsYXRpb25fcmF0ZV90cmFmZmlj.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4d09WOWpZVzVqWld4c1lYUnBiMjVmY21GMFpWOTBjbUZtWm1sai5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTM0OTEyMDB9fX1dfQ__&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEYCIQDu7edRjGYW2WdxAWaCrqcAhPTiygSAzwMyV5cD1obhBQIhANSnu~KcLRd9u~-h0DZjIMtYRStpMbZLA0hCmqSX2ES~)


![10_cancellation_rate_weather.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8xMF9jYW5jZWxsYXRpb25fcmF0ZV93ZWF0aGVy.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4eE1GOWpZVzVqWld4c1lYUnBiMjVmY21GMFpWOTNaV0YwYUdWeS5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTM0OTEyMDB9fX1dfQ__&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEYCIQCvQ22PGvDNKg2aRwidRdIRBuGbVvcMlOEEcUQpGmQMWwIhANoZnow7iHnZ7OexBZYXyGnab8Nk0U6G~XOCZOTYBzsy)


![11_cancellation_rate_distance.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8xMV9jYW5jZWxsYXRpb25fcmF0ZV9kaXN0YW5jZQ.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4eE1WOWpZVzVqWld4c1lYUnBiMjVmY21GMFpWOWthWE4wWVc1alpRLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc5MzQ5MTIwMH19fV19&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEUCIQDcgkSJEFJOQxoQw-74Z74e-3VI67BC2kHF0FDAxW9bKAIgZr4PdKBMRnc598lE2I3eDB4x2KEfrrsjUtv1eeOqDLE_)


![12_delivery_time_traffic.png](https://private-us-east-1.manuscdn.com/sessionFile/UPz6N60SL4C3AOOR51moFd/sandbox/OSjCa7vqcFdUQw7PZNIwfh-images_1790767589487_na1fn_L2hvbWUvdWJ1bnR1L2Zvb2RfZGVsaXZlcnlfZWRhL2NoYXJ0cy8xMl9kZWxpdmVyeV90aW1lX3RyYWZmaWM.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUvVVB6Nk42MFNMNEMzQU9PUjUxbW9GZC9zYW5kYm94L09TakNhN3ZxY0ZkVVF3N1BaTkl3ZmgtaW1hZ2VzXzE3OTA3Njc1ODk0ODdfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnZiMlJmWkdWc2FYWmxjbmxmWldSaEwyTm9ZWEowY3k4eE1sOWtaV3hwZG1WeWVWOTBhVzFsWDNSeVlXWm1hV00ucG5nIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzkzNDkxMjAwfX19XX0_&Key-Pair-Id=K2QY5QTL8JSY6C&Signature=MEUCIQDN~cCHN~oFtJ0FG~qKFJTLuJilfAlsHs5fTfBmZgRa6wIgAK2y5KLcQtmJxyUHBhINCpxU~BTQEuPMwWI0a9IlfkY_)

## 16. Business insights

1. **Confirmed finding — overall cancellations:** 868 of 50,000 orders were cancelled (1.736%). **Possible follow-up:** segment the cancellation reasons by operating hour, city, and partner assignment.

2. **Confirmed finding — cancellation mix:** `Driver Unassigned` accounts for 386 cancellations (44.47%). **Possible follow-up:** inspect the workflow records behind this reason.

3. **Confirmed finding — late delivery:** 17,968 of 49,132 completed orders were flagged late (36.57%). **Possible follow-up:** examine preparation, distance, traffic, and weather together.

4. **Confirmed finding — traffic comparison:** `High` has the highest observed cancellation rate at 2.38%. **Possible explanation, not proven:** traffic may coincide with assignment or delivery-capacity pressure.

5. **Confirmed finding — weather comparison:** `Storm` has the highest observed cancellation rate at 3.65%. **Possible explanation, not proven:** weather conditions may be associated with operational friction.

6. **Confirmed finding — distance comparison:** `>8–12 km` has the highest observed cancellation rate at 2.12%. **Possible follow-up:** compare this segment by city, traffic, and partner experience.

7. **Confirmed finding — missingness:** cancellation reason is populated only for cancelled orders, while delivery outcomes are unavailable for cancelled orders. **Business meaning:** avoid treating blanks as zero or as a customer/operational outcome.

## 17. Final summary

- Final cleaned analysis DataFrame shape: **(50000, 43)**
- Total orders: **50,000**
- Completed orders: **49,132**
- Cancelled orders: **868**
- Cancellation rate: **1.736%**
- Average preparation time: **15.54 minutes**
- Average estimated delivery time: **30.92 minutes**
- Average actual delivery time: **35.15 minutes**
- Late delivery rate: **36.57%**


### Python concepts used
Pandas import/read, DataFrames, `shape`, `head`, `tail`, `info`, `describe`, data types, `isna`, `duplicated`, `value_counts`, boolean filtering, `groupby`, `agg`, `crosstab`, `merge-free feature engineering`, `pd.cut`, datetime parsing, percentages, and Matplotlib/Pandas plotting.


### Interview questions and simple answers

1. **What was the dataset size?**
   - 50,000 orders and 43 source columns.

2. **What was the cancellation rate?**
   - 1.736% (868 cancellations out of 50,000 orders).

3. **How did you handle missing values?**
   - I did not blindly impute them. Missingness aligned with cancelled orders: cancellation reasons are absent for completed orders, and delivery outcomes are absent for cancelled orders.

4. **How did you check duplicates?**
   - I checked full-row duplicates and duplicate order IDs; both counts were zero.

5. **Why create Cancellation_Flag?**
   - It converts order status into a numeric 0/1 field that makes counts and rates easy to calculate.

6. **How did you define delay?**
   - Actual delivery time minus estimated delivery time, using completed orders where both values exist.

7. **What was the largest cancellation reason?**
   - Driver Unassigned, with 386 cancellations.

8. **What was the late-delivery rate?**
   - 36.57% of completed orders.

9. **Did you prove traffic causes cancellations?**
   - No. The EDA identifies observed differences and possible areas for investigation, not causation.

10. **What would you investigate next?**
   - Break down cancellations and delays jointly by city, traffic, weather, distance, restaurant preparation, and driver assignment.


## Reproducibility
The full beginner-friendly code is in `food_delivery_eda.ipynb` and `food_delivery_eda.py`. The original workbook remains unchanged.
