# 📊 Analyze Consumer Behavior & Enhance Product Strategy in Mobile Retail using SQL
---

## 📑 Table of Contents  
1. [📌 Background & Overview](#-background--overview)  
2. [📂 Dataset Description & Data Structure](#-dataset-description--data-structure)  
3. [🔎 Final Conclusion & Recommendations](#-final-conclusion--recommendations)

---

## 📌 Background & Overview  


### Objective:
### 📖 What is this project about? What Business Question will it solve?

Clearly outline what this project does, what business questions the project will solve. 

- Provide a brief introduction - Write in bullet point format
- Point out the main business question


 _Example:_
  This project uses Python to analyze transaction data from KPMG to:

✔️ Identify the behavior in customer's first transaction.  
✔️ Provide actionable insights to increase retention rate   
 


### 👤 Who is this project for?  

Mention who might benefit from this project 

 _Example:_

✔️ Data analysts & business analysts  
✔️ Decision-makers & stakeholders  



---

## 📂 Dataset Description & Data Structure  

### 📌 Data Source  
- Source: (Mention where the dataset is obtained from—Kaggle, company database, government sources, etc.)  
- Size: (Mention the number of rows & columns)  
- Format: (.csv, .sql, .xlsx, etc.)  

### 📊 Data Structure & Relationships  

#### 1️⃣ Tables Used:  
Mention how many tables are in the dataset.  

#### 2️⃣ Table Schema & Data Snapshot  

Table 1: Products Table  

👉🏻 Insert a screenshot of table schema 

📌If the table is too big, only capture a part of it that contains key metrics you used in the projects or put the table in toggle

 _Example:_

| Column Name | Data Type | Description |  
|-------------|----------|-------------|  
| Product_ID  | INT      | Unique identifier for each product |  
| Name        | TEXT     | Product name |  
| Category    | TEXT     | Product category |  
| Price       | FLOAT    | Price per unit |  


Table 2: Sales Transactions  

👉🏻 Insert a screenshot of table schema.


---

## ⚒️ Main Process

1️⃣ Data Cleaning & Preprocessing  
2️⃣ Exploratory Data Analysis (EDA)  
3️⃣ SQL/ Python Analysis 

```
select
  format_date('%Y %m',parse_date('%Y %m %d',DatePurchase)) month
  ,count(distinct TransactionID) order_count
from `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
group by 1
order by 1;
```

```
SELECT
 format_date('%Y %m',parse_date('%Y %m %d',DatePurchase)) month
 ,COUNT(DISTINCT CustomerCode) AS count_customer
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY month
ORDER BY month;
```

```
WITH num_trans AS ( -- calculate num customers buying by gender
    SELECT
        SexType
        ,ProductBrand
        ,COUNT(TransactionID) AS count_order
    FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
    GROUP BY 1, 2
),
ranking AS ( -- ranking
    SELECT
        SexType
        ,ProductBrand
        ,count_order
        ,DENSE_RANK() OVER (PARTITION BY SexType ORDER BY count_order DESC) AS Rank
    FROM num_trans
)
SELECT
    SexType
    ,ProductBrand
    ,count_order
FROM ranking
WHERE Rank <= 3
ORDER BY 1;
```

```
WITH num_trans AS ( -- B1: Mỗi nhóm tuổi mua bn sp
  SELECT
    YearOldRange As Age_group
    ,SUM(Unit) AS Total_units
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY 1
),
ranking AS ( -- rank
  SELECT
      Age_group
      ,Total_units
      ,DENSE_RANK() OVER (ORDER BY Total_units DESC) AS Rank
  FROM num_trans
)
SELECT
    Age_group
    ,Total_units
FROM ranking
WHERE Rank =1;
```

```
WITH total AS ( -- B1: Tính Salevalue của mỗi nhóm tuổi
  SELECT
    YearOldRange As Age_group
    ,SUM(SalesValue) AS Total_revenue
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY 1
),
ranking AS ( -- rank
  SELECT
      Age_group
      ,Total_revenue
      ,DENSE_RANK() OVER (ORDER BY Total_revenue DESC) AS Rank
  FROM total
)
SELECT
    Age_group
    ,Total_revenue
FROM ranking
WHERE Rank <=2;

```

```
WITH monthly_sales AS ( -- tính salevalue mỗi product mỗi tháng
    SELECT
        format_date('%Y %m',parse_date('%Y %m %d',DatePurchase)) AS Month
        ,ProductName
        ,SUM(SalesValue) AS total_sales
    FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
    GROUP BY 1,2
),
ranking AS ( -- ranking doanh thu của mỗi product theo tháng
    SELECT
        Month
        ,ProductName
        ,total_sales
        ,DENSE_RANK() OVER (PARTITION BY Month ORDER BY total_sales DESC) AS Rank
    FROM monthly_sales
)
SELECT
    Month
    ,ProductName
    ,total_sales
FROM ranking
WHERE Rank <= 3
ORDER BY 1
```
---

## 🔎 Final Conclusion & Recommendations  

👉🏻 Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following:  

📌 Key Takeaways:  
✔️ Recommendation 1  
✔️ Recommendation 2  
✔️ Recommendation 3
