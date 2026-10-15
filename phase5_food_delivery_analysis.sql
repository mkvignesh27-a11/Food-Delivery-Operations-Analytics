-- PHASE 5: FOOD DELIVERY OPERATIONS ANALYTICS (MySQL 8.0+)
-- Source: food_delivery_eda_cleaned.csv
-- The source workbook/CSV is preserved. Run setup/import once, then run analysis sections.

CREATE DATABASE IF NOT EXISTS food_delivery_db;
USE food_delivery_db;
DROP TABLE IF EXISTS food_delivery_orders;

CREATE TABLE food_delivery_orders (    `order_id` VARCHAR(20) NOT NULL,
    `customer_id` VARCHAR(20) NOT NULL,
    `restaurant_id` VARCHAR(20) NOT NULL,
    `driver_id` VARCHAR(20) NOT NULL,
    `order_timestamp` DATETIME NOT NULL,
    `order_date` DATE NOT NULL,
    `order_hour` TINYINT NOT NULL,
    `day_of_week` VARCHAR(12) NOT NULL,
    `is_weekend` TINYINT NOT NULL,
    `city` VARCHAR(20) NOT NULL,
    `delivery_area` VARCHAR(40) NOT NULL,
    `customer_age` TINYINT NOT NULL,
    `customer_type` VARCHAR(20) NOT NULL,
    `restaurant_type` VARCHAR(30) NOT NULL,
    `restaurant_primary_category` VARCHAR(30) NOT NULL,
    `restaurant_rating` DECIMAL(3,1) NOT NULL,
    `items_count` TINYINT NOT NULL,
    `subtotal` DECIMAL(10,2) NOT NULL,
    `discount_percent` TINYINT NOT NULL,
    `tax_amount` DECIMAL(10,2) NOT NULL,
    `service_fee` DECIMAL(10,2) NOT NULL,
    `delivery_fee` DECIMAL(10,2) NOT NULL,
    `order_total` DECIMAL(10,2) NOT NULL,
    `payment_method` VARCHAR(30) NOT NULL,
    `tip_amount` DECIMAL(10,2) NULL,
    `distance_km` DECIMAL(6,1) NOT NULL,
    `weather` VARCHAR(20) NOT NULL,
    `traffic_level` VARCHAR(20) NOT NULL,
    `delivery_partner_experience_months` SMALLINT NOT NULL,
    `delivery_partner_rating` DECIMAL(3,1) NOT NULL,
    `restaurant_preparation_time_minutes` SMALLINT NOT NULL,
    `estimated_delivery_time_minutes` SMALLINT NOT NULL,
    `actual_delivery_time_minutes` DECIMAL(6,1) NULL,
    `late_delivery` TINYINT NULL,
    `order_status` VARCHAR(20) NOT NULL,
    `cancellation_reason` VARCHAR(40) NULL,
    `customer_rating` DECIMAL(3,1) NULL,
    `Cancellation_Flag` TINYINT NOT NULL,
    `Completed_Flag` TINYINT NOT NULL,
    `Delivery_Delay_Minutes` DECIMAL(6,1) NULL,
    `Late_Delivery_Flag` TINYINT NOT NULL,
    `Distance_Category` VARCHAR(20) NOT NULL,
    `Hour_Category` VARCHAR(25) NOT NULL,
    PRIMARY KEY (`order_id`),
    INDEX idx_status (`order_status`),
    INDEX idx_city (`city`),
    INDEX idx_order_date (`order_date`),
    INDEX idx_traffic_weather (`traffic_level`, `weather`)
) ENGINE=InnoDB;
-- DATA IMPORT (run from a client allowed to use LOCAL INFILE)
-- MySQL Workbench: enable Preferences > SQL Editor > DBMS connection read timeout as needed,
-- connect with LOCAL INFILE enabled, then run this LOAD DATA statement.
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE '/home/ubuntu/food_delivery_eda/food_delivery_eda_cleaned.csv'
INTO TABLE food_delivery_orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@v1, @v2, @v3, @v4, @v5, @v6, @v7, @v8, @v9, @v10, @v11, @v12, @v13, @v14, @v15, @v16, @v17, @v18, @v19, @v20, @v21, @v22, @v23, @v24, @v25, @v26, @v27, @v28, @v29, @v30, @v31, @v32, @v33, @v34, @v35, @v36, @v37, @v38, @v39, @v40, @v41, @v42, @v43)
SET
    `order_id` = @v1,
    `customer_id` = @v2,
    `restaurant_id` = @v3,
    `driver_id` = @v4,
    `order_timestamp` = STR_TO_DATE(NULLIF(@v5, ''), '%Y-%m-%d %H:%i:%s'),
    `order_date` = STR_TO_DATE(NULLIF(@v6, ''), '%Y-%m-%d'),
    `order_hour` = @v7,
    `day_of_week` = @v8,
    `is_weekend` = @v9,
    `city` = @v10,
    `delivery_area` = @v11,
    `customer_age` = @v12,
    `customer_type` = @v13,
    `restaurant_type` = @v14,
    `restaurant_primary_category` = @v15,
    `restaurant_rating` = @v16,
    `items_count` = @v17,
    `subtotal` = @v18,
    `discount_percent` = @v19,
    `tax_amount` = @v20,
    `service_fee` = @v21,
    `delivery_fee` = @v22,
    `order_total` = @v23,
    `payment_method` = @v24,
    `tip_amount` = NULLIF(@v25, ''),
    `distance_km` = @v26,
    `weather` = @v27,
    `traffic_level` = @v28,
    `delivery_partner_experience_months` = @v29,
    `delivery_partner_rating` = @v30,
    `restaurant_preparation_time_minutes` = @v31,
    `estimated_delivery_time_minutes` = @v32,
    `actual_delivery_time_minutes` = NULLIF(@v33, ''),
    `late_delivery` = NULLIF(@v34, ''),
    `order_status` = @v35,
    `cancellation_reason` = NULLIF(@v36, ''),
    `customer_rating` = NULLIF(@v37, ''),
    `Cancellation_Flag` = @v38,
    `Completed_Flag` = @v39,
    `Delivery_Delay_Minutes` = NULLIF(@v40, ''),
    `Late_Delivery_Flag` = @v41,
    `Distance_Category` = @v42,
    `Hour_Category` = @v43;
-- 5.2 IMPORT VALIDATION
SELECT COUNT(*) AS total_rows FROM food_delivery_orders;
SELECT * FROM food_delivery_orders LIMIT 10;

-- 5.3 BASIC SQL
SELECT DISTINCT `city` FROM food_delivery_orders ORDER BY `city`;
SELECT DISTINCT `order_status` FROM food_delivery_orders ORDER BY `order_status`;
SELECT DISTINCT `cancellation_reason` FROM food_delivery_orders WHERE `cancellation_reason` IS NOT NULL ORDER BY `cancellation_reason`;
SELECT * FROM food_delivery_orders WHERE `order_status` = 'Cancelled' LIMIT 10;
SELECT * FROM food_delivery_orders WHERE `order_total` > (SELECT AVG(`order_total`) FROM food_delivery_orders) ORDER BY `order_total` DESC LIMIT 10;
SELECT * FROM food_delivery_orders ORDER BY `order_timestamp` DESC LIMIT 10;

-- 5.4 DATA VALIDATION
SELECT `order_id`, COUNT(*) AS id_count FROM food_delivery_orders GROUP BY `order_id` HAVING COUNT(*) > 1;
SELECT `order_status`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `order_status`;
SELECT DISTINCT `traffic_level` FROM food_delivery_orders ORDER BY `traffic_level`;
SELECT DISTINCT `weather` FROM food_delivery_orders ORDER BY `weather`;
SELECT SUM(`tip_amount` IS NULL) AS null_tip_amount, SUM(`actual_delivery_time_minutes` IS NULL) AS null_actual_delivery_time, SUM(`late_delivery` IS NULL) AS null_late_delivery, SUM(`cancellation_reason` IS NULL) AS null_cancellation_reason, SUM(`customer_rating` IS NULL) AS null_customer_rating FROM food_delivery_orders;

-- 5.5 AGGREGATES
SELECT COUNT(*) AS total_orders, SUM(`order_total`) AS total_order_value, AVG(`order_total`) AS average_order_value, AVG(`distance_km`) AS average_distance_km, AVG(`restaurant_preparation_time_minutes`) AS average_preparation_minutes, AVG(`estimated_delivery_time_minutes`) AS average_estimated_minutes, AVG(`actual_delivery_time_minutes`) AS average_actual_minutes, MIN(`actual_delivery_time_minutes`) AS minimum_actual_minutes, MAX(`actual_delivery_time_minutes`) AS maximum_actual_minutes FROM food_delivery_orders;

-- 5.6 KPI ANALYSIS (delivery metrics use completed/non-null outcomes)
SELECT COUNT(*) AS total_orders, SUM(`order_status`='Completed') AS completed_orders, SUM(`order_status`='Cancelled') AS cancelled_orders, ROUND(100*AVG(`order_status`='Completed'),3) AS completion_rate_pct, ROUND(100*AVG(`order_status`='Cancelled'),3) AS cancellation_rate_pct, SUM(`order_status`='Completed' AND `late_delivery`=1) AS late_deliveries, ROUND(100*SUM(`order_status`='Completed' AND `late_delivery`=1)/NULLIF(SUM(`order_status`='Completed' AND `actual_delivery_time_minutes` IS NOT NULL),0),3) AS late_delivery_rate_pct FROM food_delivery_orders;

-- 5.7 GROUP BY
SELECT `city`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `city` ORDER BY orders DESC;
SELECT `city`, SUM(`Cancellation_Flag`) AS cancelled_orders FROM food_delivery_orders GROUP BY `city` ORDER BY cancelled_orders DESC;
SELECT `order_status`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `order_status`;
SELECT `cancellation_reason`, COUNT(*) AS cancellations FROM food_delivery_orders WHERE `cancellation_reason` IS NOT NULL GROUP BY `cancellation_reason` ORDER BY cancellations DESC;
SELECT `traffic_level`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `traffic_level`;
SELECT `weather`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `weather`;
SELECT `customer_type`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `customer_type`;
SELECT `payment_method`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `payment_method`;
SELECT `restaurant_type`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `restaurant_type`;
SELECT `restaurant_primary_category`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `restaurant_primary_category`;
SELECT `day_of_week`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `day_of_week`;
SELECT `order_hour`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `order_hour` ORDER BY `order_hour`;

-- 5.8 HAVING: thresholds are transparent and operationally useful
SELECT `city`, SUM(`Cancellation_Flag`) AS cancelled_orders FROM food_delivery_orders GROUP BY `city` HAVING SUM(`Cancellation_Flag`) > 200;
SELECT `restaurant_type`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `restaurant_type` HAVING COUNT(*) >= 1000 AND AVG(`Cancellation_Flag`) > 0.02;
SELECT `traffic_level`, COUNT(*) AS orders, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `traffic_level` HAVING AVG(`actual_delivery_time_minutes`) > (SELECT AVG(`actual_delivery_time_minutes`) FROM food_delivery_orders);
SELECT `restaurant_primary_category`, COUNT(*) AS orders FROM food_delivery_orders GROUP BY `restaurant_primary_category` HAVING COUNT(*) >= 1000;

-- 5.9 CANCELLATION ANALYSIS
SELECT `cancellation_reason`, COUNT(*) AS cancellations, ROUND(100*COUNT(*)/(SELECT COUNT(*) FROM food_delivery_orders WHERE `Cancellation_Flag`=1),3) AS share_of_cancellations_pct FROM food_delivery_orders WHERE `Cancellation_Flag`=1 GROUP BY `cancellation_reason` ORDER BY cancellations DESC;
SELECT ROUND(100*AVG(`Cancellation_Flag`),3) AS overall_cancellation_rate_pct FROM food_delivery_orders;
SELECT `city`, SUM(`Cancellation_Flag`) AS cancellations, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `city`;
SELECT `city`, `cancellation_reason`, COUNT(*) AS cancellations FROM food_delivery_orders WHERE `Cancellation_Flag`=1 GROUP BY `city`, `cancellation_reason` ORDER BY `city`, cancellations DESC;
SELECT COUNT(*) AS driver_unassigned_cancellations FROM food_delivery_orders WHERE `cancellation_reason`='Driver Unassigned';
SELECT `city`, COUNT(*) AS driver_unassigned_cancellations FROM food_delivery_orders WHERE `cancellation_reason`='Driver Unassigned' GROUP BY `city`;
SELECT `order_hour`, SUM(`Cancellation_Flag`) AS cancellations FROM food_delivery_orders GROUP BY `order_hour` ORDER BY `order_hour`;
SELECT `day_of_week`, SUM(`Cancellation_Flag`) AS cancellations FROM food_delivery_orders GROUP BY `day_of_week`;
SELECT `traffic_level`, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `traffic_level`;
SELECT `weather`, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `weather`;
SELECT `Distance_Category`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `Distance_Category` ORDER BY FIELD(`Distance_Category`, '0–2 km','>2–5 km','>5–8 km','>8–12 km','>12 km');

-- 5.10 CASE WHEN (same bands as Python)
SELECT `order_id`, CASE WHEN `Cancellation_Flag`=1 THEN 'Cancelled' ELSE 'Completed' END AS cancellation_status, CASE WHEN `actual_delivery_time_minutes` IS NULL THEN 'No delivery outcome' WHEN `actual_delivery_time_minutes` > `estimated_delivery_time_minutes` THEN 'Late' ELSE 'On time' END AS delivery_performance_status, CASE WHEN `distance_km` <= 2 THEN '0–2 km' WHEN `distance_km` <= 5 THEN '>2–5 km' WHEN `distance_km` <= 8 THEN '>5–8 km' WHEN `distance_km` <= 12 THEN '>8–12 km' ELSE '>12 km' END AS distance_category FROM food_delivery_orders LIMIT 10;

-- 5.11 DELIVERY PERFORMANCE
SELECT AVG(`restaurant_preparation_time_minutes`) AS avg_preparation_minutes, AVG(`estimated_delivery_time_minutes`) AS avg_estimated_minutes, AVG(`actual_delivery_time_minutes`) AS avg_actual_minutes, AVG(`actual_delivery_time_minutes`-`estimated_delivery_time_minutes`) AS avg_delay_minutes, SUM(`late_delivery`=1) AS late_deliveries, SUM(`late_delivery`=0) AS on_time_deliveries, ROUND(100*AVG(`late_delivery`),3) AS late_delivery_rate_pct FROM food_delivery_orders WHERE `order_status`='Completed' AND `actual_delivery_time_minutes` IS NOT NULL;

-- 5.12–5.17 reusable segment analysis
SELECT `city`, COUNT(*) AS orders, SUM(`Completed_Flag`) AS completed_orders, SUM(`Cancellation_Flag`) AS cancelled_orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes, ROUND(100*SUM(`Late_Delivery_Flag`)/NULLIF(SUM(`Completed_Flag`),0),3) AS late_delivery_rate_pct, AVG(`order_total`) AS avg_order_value FROM food_delivery_orders GROUP BY `city`;
SELECT `traffic_level`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancelled_orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes, ROUND(100*SUM(`Late_Delivery_Flag`)/NULLIF(SUM(`Completed_Flag`),0),3) AS late_delivery_rate_pct, AVG(`order_total`) AS avg_order_value FROM food_delivery_orders GROUP BY `traffic_level`;
SELECT `weather`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancelled_orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes, ROUND(100*SUM(`Late_Delivery_Flag`)/NULLIF(SUM(`Completed_Flag`),0),3) AS late_delivery_rate_pct, AVG(`order_total`) AS avg_order_value FROM food_delivery_orders GROUP BY `weather`;
SELECT `Distance_Category`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes, ROUND(100*SUM(`Late_Delivery_Flag`)/NULLIF(SUM(`Completed_Flag`),0),3) AS late_delivery_rate_pct FROM food_delivery_orders GROUP BY `Distance_Category`;
SELECT `restaurant_type`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancelled_orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`restaurant_preparation_time_minutes`) AS avg_preparation_minutes, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `restaurant_type`;
SELECT `restaurant_primary_category`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancelled_orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`restaurant_preparation_time_minutes`) AS avg_preparation_minutes, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `restaurant_primary_category`;
SELECT `customer_type`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`order_total`) AS avg_order_value, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `customer_type`;
SELECT `payment_method`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`order_total`) AS avg_order_value, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `payment_method`;

-- 5.18 SUBQUERIES
SELECT * FROM food_delivery_orders WHERE `order_total` > (SELECT AVG(`order_total`) FROM food_delivery_orders) ORDER BY `order_total` DESC LIMIT 20;
SELECT `city`, 100*AVG(`Cancellation_Flag`) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `city` HAVING AVG(`Cancellation_Flag`) > (SELECT AVG(`Cancellation_Flag`) FROM food_delivery_orders);
SELECT `restaurant_id`, AVG(`restaurant_preparation_time_minutes`) AS avg_preparation_minutes FROM food_delivery_orders GROUP BY `restaurant_id` HAVING AVG(`restaurant_preparation_time_minutes`) > (SELECT AVG(`restaurant_preparation_time_minutes`) FROM food_delivery_orders);
SELECT * FROM food_delivery_orders WHERE `actual_delivery_time_minutes` > (SELECT AVG(`actual_delivery_time_minutes`) FROM food_delivery_orders WHERE `actual_delivery_time_minutes` IS NOT NULL) LIMIT 20;

-- 5.19 CTEs
WITH city_kpi AS (SELECT `city`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancellations FROM food_delivery_orders GROUP BY `city`) SELECT `city`, orders, cancellations, ROUND(100*cancellations/orders,3) AS cancellation_rate_pct FROM city_kpi;
WITH delivery AS (SELECT AVG(`actual_delivery_time_minutes`) AS avg_actual, AVG(`estimated_delivery_time_minutes`) AS avg_estimated, AVG(`actual_delivery_time_minutes`-`estimated_delivery_time_minutes`) AS avg_delay FROM food_delivery_orders WHERE `Completed_Flag`=1) SELECT * FROM delivery;
WITH traffic_kpi AS (SELECT `traffic_level`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancellations, AVG(`actual_delivery_time_minutes`) AS avg_delivery FROM food_delivery_orders GROUP BY `traffic_level`) SELECT *, ROUND(100*cancellations/orders,3) AS cancellation_rate_pct FROM traffic_kpi;
WITH totals AS (SELECT COUNT(*) AS total_orders, SUM(`Completed_Flag`) AS completed_orders, SUM(`Cancellation_Flag`) AS cancelled_orders, SUM(`Late_Delivery_Flag`) AS late_deliveries FROM food_delivery_orders) SELECT *, ROUND(100*cancelled_orders/total_orders,3) AS cancellation_rate_pct, ROUND(100*late_deliveries/completed_orders,3) AS late_delivery_rate_pct FROM totals;

-- 5.20 WINDOW FUNCTIONS: numerical orderings, not overall value judgments
WITH city_rates AS (SELECT `city`, 100*AVG(`Cancellation_Flag`) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `city`) SELECT *, ROW_NUMBER() OVER (ORDER BY cancellation_rate_pct DESC) AS row_num, RANK() OVER (ORDER BY cancellation_rate_pct DESC) AS rate_rank, DENSE_RANK() OVER (ORDER BY cancellation_rate_pct DESC) AS dense_rate_rank FROM city_rates;
WITH category_time AS (SELECT `restaurant_primary_category`, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `restaurant_primary_category`) SELECT *, RANK() OVER (ORDER BY avg_delivery_minutes DESC) AS delivery_time_rank FROM category_time;
WITH hour_cancel AS (SELECT `order_hour`, SUM(`Cancellation_Flag`) AS cancellations FROM food_delivery_orders GROUP BY `order_hour`) SELECT *, RANK() OVER (ORDER BY cancellations DESC) AS cancellation_rank, SUM(cancellations) OVER (ORDER BY `order_hour`) AS running_cancellations FROM hour_cancel ORDER BY `order_hour`;
SELECT `city`, `order_id`, `order_total`, AVG(`order_total`) OVER (PARTITION BY `city`) AS city_avg_order_value, `order_total`-AVG(`order_total`) OVER (PARTITION BY `city`) AS difference_from_city_average FROM food_delivery_orders LIMIT 20;

-- 5.21 ADVANCED BUSINESS QUERIES
SELECT ROUND(100*AVG(`Cancellation_Flag`),3) AS overall_cancellation_rate_pct, COUNT(*) AS total_orders, SUM(`Cancellation_Flag`) AS cancelled_orders FROM food_delivery_orders;
SELECT `cancellation_reason`, COUNT(*) AS cancellations, ROUND(100*COUNT(*)/SUM(COUNT(*)) OVER (),3) AS contribution_pct FROM food_delivery_orders WHERE `Cancellation_Flag`=1 GROUP BY `cancellation_reason`;
SELECT `city`, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `city`;
SELECT `city`, COUNT(*) AS driver_unassigned_cancellations FROM food_delivery_orders WHERE `cancellation_reason`='Driver Unassigned' GROUP BY `city`;
SELECT `traffic_level`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancellations, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders WHERE `traffic_level`='High' GROUP BY `traffic_level`;
SELECT `weather`, COUNT(*) AS orders, SUM(`Cancellation_Flag`) AS cancellations, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `weather`;
SELECT `Distance_Category`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `Distance_Category`;
SELECT SUM(`Late_Delivery_Flag`) AS late_deliveries, ROUND(100*SUM(`Late_Delivery_Flag`)/SUM(`Completed_Flag`),3) AS late_rate_pct FROM food_delivery_orders;
SELECT `city`, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes, ROUND(100*SUM(`Late_Delivery_Flag`)/SUM(`Completed_Flag`),3) AS late_rate_pct FROM food_delivery_orders GROUP BY `city`;
SELECT `restaurant_type`, AVG(`restaurant_preparation_time_minutes`) AS avg_preparation_minutes, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `restaurant_type`;
SELECT `customer_type`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`order_total`) AS avg_order_value FROM food_delivery_orders GROUP BY `customer_type`;
SELECT `payment_method`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`order_total`) AS avg_order_value FROM food_delivery_orders GROUP BY `payment_method`;
SELECT `order_hour`, SUM(`Cancellation_Flag`) AS cancellations FROM food_delivery_orders GROUP BY `order_hour` ORDER BY cancellations DESC;
SELECT `day_of_week`, SUM(`Cancellation_Flag`) AS cancellations FROM food_delivery_orders GROUP BY `day_of_week` ORDER BY cancellations DESC;
SELECT * FROM food_delivery_orders WHERE `order_total` >= 100 ORDER BY `order_total` DESC;
SELECT * FROM food_delivery_orders WHERE `order_total` > (SELECT AVG(`order_total`) FROM food_delivery_orders);
SELECT `city`, 100*AVG(`Cancellation_Flag`) AS cancellation_rate_pct FROM food_delivery_orders GROUP BY `city` HAVING AVG(`Cancellation_Flag`) > (SELECT AVG(`Cancellation_Flag`) FROM food_delivery_orders);
SELECT * FROM food_delivery_orders WHERE `actual_delivery_time_minutes` > (SELECT AVG(`actual_delivery_time_minutes`) FROM food_delivery_orders WHERE `actual_delivery_time_minutes` IS NOT NULL);
SELECT `city`, `traffic_level`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `city`, `traffic_level`;
SELECT `city`, `weather`, COUNT(*) AS orders, ROUND(100*AVG(`Cancellation_Flag`),3) AS cancellation_rate_pct, AVG(`actual_delivery_time_minutes`) AS avg_delivery_minutes FROM food_delivery_orders GROUP BY `city`, `weather`;
