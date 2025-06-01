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

### 1️⃣ **Customer Behavior Analysis**

🎯 **Objective**: Identify who the customers are, and understand their shopping habits

#### 🟡 **How many customers buy each month?**

> ➤ Track customer volume over time to monitor acquisition and retention trends.
  
```
SELECT
 format_date('%Y %m',parse_date('%Y %m %d',DatePurchase)) month
 ,COUNT(DISTINCT CustomerCode) AS count_customer
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY month
ORDER BY month;
```
<img src="https://drive.google.com/uc?export=view&id=1klgJ6ET2CRJAbT-rKqPr9h1k8cKCPNJw" width="450"/>

#### 💡 Findings: 

- Customer volume **increased steadily** over the 5-month period:
  + From **16,130** in January to **19,934** in May.
  + This trend indicates **growing customer acquisition**

#### 🟡 **Which gender & age groups buy the most?**

> ➤ Identify the most active customer segments for targeted marketing.
  
```
SELECT 
  SexType,
  YearOldRange,
  COUNT(TransactionID) AS Total_Orders
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY SexType, YearOldRange
ORDER BY Total_Orders DESC;
```

<img src="https://drive.google.com/uc?export=view&id=1c30glEN8W8RrXCMPXMNtnYc25vChykkX" width="600"/>

#### 💡 Findings:
- The most active buyers are both **Males and Females aged 26–30.**
- Followed by customers aged 31–35 for both genders.
- Younger and older segments (e.g., “<21” and “>40”) purchase significantly less.

#### 🟡 **What are the most purchased brands per gender?**

> ➤ Understand brand preference by gender to tailor promotional campaigns.
  
```
WITH num_trans AS ( -- tính mỗi KH Nam/Nữ mua bn sp mỗi brand
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

<img src="https://drive.google.com/uc?export=view&id=1uQTvkITgKGevTUAcnywHIeLnJcoZzNb4" width="600"/>


#### 💡 Findings: 
- Top 3 brands for both genders are the same but with different order:

  + **Males:** Samsung, Nokia, Q-SMART
  
  + **Females:** Samsung, Nokia, Q-SMART (same brands, higher Samsung preference)

#### 🟡 **Which phone models are most preferred by males and females?**

> ➤ Reveal model-level product preferences for personalized recommendations.

```
WITH phone_count AS (
  SELECT 
    SexType,
    ProductName,
    COUNT(TransactionID) AS order_count
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY SexType, ProductName
),
ranked_phone AS (
  SELECT *,
    RANK() OVER (PARTITION BY SexType ORDER BY order_count DESC) AS rank
  FROM phone_count
)
SELECT 
  SexType,
  ProductName,
  order_count
FROM ranked_phone
WHERE rank <= 5
ORDER BY SexType, rank;
```

<img src="https://drive.google.com/uc?export=view&id=1Xq8CZVl_NilCT-RgEScFVKS-_kU5cXcC" width="600"/>

#### 💡 Findings: 

Both genders love **the S5360 (Toroto) series**, but females show stronger preference for **white** model.


#### 🟡 **What brands are most popular in each age group?**
> ➤ Align brand strategy with age-specific customer preferences.

```
WITH brand_age AS (
  SELECT 
    YearOldRange,
    ProductBrand,
    COUNT(TransactionID) AS order_count
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY YearOldRange, ProductBrand
),
ranked_brand_age AS (
  SELECT *,
    RANK() OVER (PARTITION BY YearOldRange ORDER BY order_count DESC) AS rank
  FROM brand_age
)
SELECT 
  YearOldRange, ProductBrand, order_count
FROM ranked_brand_age
WHERE rank <= 3
ORDER BY YearOldRange, rank;
```
<img src="https://drive.google.com/uc?export=view&id=16ZB79ry-wR0j44o21L4K0e_PEpucKCId" width="600"/>

#### 💡 Findings: 
- Across all age groups, the top 3 most preferred brands are consistent:

  + **Samsung** is dominant across all age segments
  
  + **Nokia and Q-SMART** alternate in 2nd and 3rd positions

#### 🟡 **Who are the top 10 most loyal customers based on purchase count?**

> ➤ Find high-value repeat customers to reward or upsell.

```
WITH customer_orders AS (
  SELECT 
    CustomerCode,
    COUNT(TransactionID) AS OrderCount,
    SUM(SalesValue) AS TotalSpent
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY CustomerCode
),
ranked_customers AS (
  SELECT *,
    DENSE_RANK() OVER (ORDER BY OrderCount DESC) AS loyalty_rank
  FROM customer_orders
)
SELECT 
  CustomerCode,
  OrderCount,
  TotalSpent,
  loyalty_rank
FROM ranked_customers
WHERE loyalty_rank <= 8
ORDER BY loyalty_rank;
```

<img src="https://drive.google.com/uc?export=view&id=1VH-32Uhp8faQX-o65FRpfiYcPHzC3gGm" width="600"/>

#### 💡 Findings: 
- Top loyal customers made between 9 to 27 purchases
- Highest spender spent over 35.7 million VND
- Loyalty rank is based on order frequency, not just spend

#### 🟡 **Which city/region has the most active customers?**
> ➤ Discover regional customer hotspots for local targeting or expansion.

```
SELECT 
  GeographicalArea,
  COUNT(DISTINCT CustomerCode) AS UniqueCustomers
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY GeographicalArea
ORDER BY UniqueCustomers DESC;
```
<img src="https://drive.google.com/uc?export=view&id=1BPoysQTH8P0LKotprVDlSHyTR172A9Kd" width="450"/>

#### 💡 Findings: 
- **Ho Chi Minh City** leads with a massive gap: **53,651 unique customers**

- Followed by **Southeast (13,147)** and **Red River Delta (7,220)**


2️⃣ Product Sales & Trend Analysis 

-- Product --> Dimension: Time -- Customer age -- customer gender -- market 
-- Product positive growth in all 5 months 

3️⃣ Add-On, Bundle, & Installment Behavior

#### 🟡 **Installment Usage by Age Group**

```
SELECT 
  YearOldRange,
  COUNT(TransactionID) AS Installment_Orders
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
WHERE LOWER(Payment_method) = 'installment'
GROUP BY YearOldRange
ORDER BY Installment_Orders DESC;

```

#### 🟡 **Most Purchased Phones via Installments**

```
SELECT 
  ProductName,
  COUNT(TransactionID) AS Installment_Orders
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
WHERE LOWER(Payment_method) = 'installment'
GROUP BY ProductName
ORDER BY Installment_Orders DESC
LIMIT 10;
```

---

## 🔎 Final Conclusion & Recommendations  

👉🏻 Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following:  

📌 Key Takeaways:  
✔️ Recommendation 1  
✔️ Recommendation 2  
✔️ Recommendation 3
