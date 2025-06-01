# 📊 Analyze Consumer Behavior & Enhance Product Strategy in Mobile Retail using SQL
---

## 📑 Table of Contents  
1. [📌 Background & Overview](#-background--overview)  
2. [📂 Dataset Description & Data Structure](#-dataset-description--data-structure)  
3. [🔎 Final Conclusion & Recommendations](#-final-conclusion--recommendations)

---

## 📌 Background & Overview  


### 🎯 Objective:
### 📖 What is this project about? What Business Question will it solve?
- Mobile retailers often struggle to align their **product strategies** with actual **consumer purchase behaviors.**
  
- Understanding **who buys what, when, and how** (e.g. through bundles or installments) is critical for:
  +  Making informed **inventory decisions**
  +  Launching targeted **marketing campaigns**
  +  Increasing **revenue per customer**

- This project **uses SQL** to analyze mobile phone transaction data to solve the following problem:

> How can mobile retailers **improve product strategy** and **sales decisions** based on consumer purchase patterns in mobile retail?

✅ Identify which customer segments (by age/gender) drive the most purchases and revenue

✅ Discover top-performing products and seasonal trends

✅ Analyze add-on and installment behavior to guide pricing and bundling strategies


### 👤 Who is this project for?  

📊 **Data analysts** in retail

🧠 **Strategy teams** in mobile retail companies

💼 **Retail decision-makers** looking to align supply with demand

📣 **Marketing teams** aiming to personalize offers and boost campaign ROI



---

## 📂 Dataset Description & Data Structure  

### 📌 Data Source  
- **Source**: Internal mobile retail sales records
- **Size**:
  - `Phone_Sales.csv`: 95,307 rows × 15 columns
  - `Accessories_Sales.csv`: 35,642 rows × 7 columns
- **Format**: `.csv` files

### 📊 Data Structure & Relationships  

#### 1️⃣ Tables Used:  
- `Phone_Sales`: Logs all phone-related purchases
- `Accessories_Sales`: Tracks sales of add-ons such as accessories or insurance

These two tables can be **joined via `transactionID` or `customer_code`**

#### 2️⃣ Table Schema & Data Snapshot  

**Table 1: Phone_Sales**

| Column Name        | Data Type | Description                            |
|--------------------|-----------|----------------------------------------|
| TransactionID      | TEXT      | Unique transaction identifier          |
| CustomerCode       | TEXT      | Unique customer identifier             |
| ProductName        | TEXT      | Name of the phone model                |
| ProductBrand       | TEXT      | Brand of the phone                     |
| DatePurchase       | DATE      | Date of transaction                    |
| GeographicalArea   | TEXT      | City or region of purchase             |
| Payment_method     | TEXT      | Payment type (e.g., Full, Installment) |
| Bank               | TEXT      | Bank used for installment (if any)     |
| Color              | TEXT      | Color of phone                         |
| Carrier            | TEXT      | Mobile carrier (e.g., Mobifone)        |
| SexType            | TEXT      | Gender of the customer                 |
| YearOldRange       | TEXT      | Age group of customer                  |
| Unitprice          | FLOAT     | Price per phone unit                   |
| SalesValue         | FLOAT     | Total transaction value                |
| Unit               | INT       | Quantity purchased         


**Table 2: Accessories Sales**

| Column Name         | Data Type | Description                            |
|---------------------|-----------|----------------------------------------|
| TransactionID       | TEXT      | Transaction ID (can match phone sales) |
| CustomerCode        | TEXT      | Unique customer identifier             |
| Accessories_name    | TEXT      | Name of the accessory                  |
| Accessories_subname | TEXT      | Accessory subtype                      |
| Unitprice           | FLOAT     | Unit price of accessory                |
| Unit                | INT       | Quantity purchased                     |
| SalesValue          | FLOAT     | Total value of the transaction  


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
