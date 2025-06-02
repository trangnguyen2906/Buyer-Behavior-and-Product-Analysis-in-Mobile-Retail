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

🎯 **Objective**: This part explores who the customers are, how often they purchase, and their preferences by segment, with the goal to:

- Identify high-value customer segments by age, gender, and region

- Reveal loyal customers based on order frequency and total spending

- Understand which demographics prefer specific brands or models

- Support targeted marketing and customer segmentation strategies

#### 🟡 **How many customers buy each month?**

> ➤ Track customer volume over time to monitor acquisition and retention trends.
  
```sql
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
  
```sql
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
  
```sql
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

```sql
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

```sql
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

```sql
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

```sql
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


### 2️⃣ Product Sales & Trend Analysis 

#### Total Sales per Month
➤ Monitor overall revenue trends to guide planning, promotions, and inventory decisions.

```sql
SELECT 
  FORMAT_DATE('%Y-%m', PARSE_DATE('%Y %m %d', DatePurchase)) AS Month,
  SUM(SalesValue) AS TotalSales
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY Month
ORDER BY Month;
```
<img src="https://drive.google.com/uc?export=view&id=1bzbRFijdMtxhYZRv8rdVi-PqbYs1vxOp" width="450"/>

💡 **Findings:**

- Total sales **grew consistently** from January to May.

- May 2015 recorded the highest total revenue, suggesting strong market demand or effective promotions.


####  🟡 What is the average order value per month?
> ➤ Monitor purchasing behavior trends over time

```sql
SELECT
  FORMAT_DATE('%Y-%m', PARSE_DATE('%Y %m %d', DatePurchase)) AS Month,
  ROUND(AVG(SalesValue), 2) AS AvgOrderValue
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY Month
ORDER BY Month;
```
<img src="https://drive.google.com/uc?id=1O6Ck_-Ay2uPDhbUY5qDVTQLfpRAcpw07" width="450"/>

#### 💡 Findings: Avg Order Value stayed stable (~44.5M–48.6M VND), peaking in January.

#### 🟡 Which phone models are both high-selling and consistently ordered over months?
> ➤ Identify stable products to support inventory planning and continuous marketing.

```sql
SELECT 
  ProductName,
  ProductBrand,
  COUNT(TransactionID) AS TotalOrders,
  COUNT(DISTINCT EXTRACT(MONTH FROM PARSE_DATE('%Y %m %d', DatePurchase))) AS ActiveMonths
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY ProductName, ProductBrand
HAVING ActiveMonths >= 3
ORDER BY TotalOrders DESC, ActiveMonths DESC
```

<img src="https://drive.google.com/uc?id=1ct7RSGDHppu7Jp6HiX14VmpKoPGRz5SS" width="700"/>

#### 💡 Findings: 
- Samsung dominates with multiple models having high order volumes over 5 active months (e.g., S5360, Galaxy S3 Mini, S6102).

- Lumia 520 Black (NOKIA) is the single most ordered model, though only active in 3 months, suggesting short-term demand spikes.

- Q-SMART shows solid mid-range presence with stable orders for S1 and S15 series.



#### 🟡 What are the top revenue-generating brands by market, and their best-selling model?
> ➤ Discover which brands perform best in each region and identify their top-selling product to support regional inventory and sales strategies.

```sql
WITH brand_revenue AS (
  SELECT 
    GeographicalArea,
    ProductBrand,
    SUM(SalesValue) AS TotalRevenue
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY GeographicalArea, ProductBrand
),

product_orders AS (
  SELECT 
    GeographicalArea,
    ProductBrand,
    ProductName,
    COUNT(TransactionID) AS TotalOrders
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY GeographicalArea, ProductBrand, ProductName
),

ranked_products AS (
  SELECT *,
    RANK() OVER (PARTITION BY GeographicalArea, ProductBrand ORDER BY TotalOrders DESC) AS product_rank
  FROM product_orders
),

top_models AS (
  SELECT 
    GeographicalArea,
    ProductBrand,
    ProductName AS BestSellingProduct,
    TotalOrders
  FROM ranked_products
  WHERE product_rank = 1
)

SELECT 
  b.GeographicalArea,
  b.ProductBrand,
  b.TotalRevenue,
  t.BestSellingProduct,
  t.TotalOrders
FROM brand_revenue b
JOIN top_models t 
  ON b.GeographicalArea = t.GeographicalArea AND b.ProductBrand = t.ProductBrand
ORDER BY b.GeographicalArea, b.TotalRevenue DESC;
```

<img src="https://drive.google.com/uc?id=1k1JLF5gXpx2bEA9LlYHK-SnPW0rxfH6v" width="950"/>

#### 💡 Findings:  
- Samsung led revenue across all regions; Nokia and Q-SMART performed well in key cities with standout models.
- Each region shows unique brand strengths beyond Samsung—e.g., ST26i Xperia J (Sony) in the Red River Delta, Touch S02i (Mobiistar) in the South -> indicating **region-specific stocking should prioritize top-performing models per market.**


### 3️⃣ Accessories, Insurance & Installment Behavior
🎯 **Objective**: Analyze how customers engage with add-on products (insurance and accessories) and installment payment methods, in order to:

- Identify cross-sell opportunities through insurance and accessory attach rates

- Understand installment preferences by customer demographics (e.g., age) and product pricing

- Support pricing, bundling, and financing strategies for each brand and model

#### 🟡 **What is the attach rate of insurance and accessories for each phone brand?**
> ➤ This helps evaluate how well each brand drives cross-selling opportunities through add-ons.

```sql
--  Phone transactions by brand
WITH phone_orders AS (
  SELECT TransactionID, ProductBrand
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
),

--  Insurance transactions
insurance_orders AS (
  SELECT DISTINCT TransactionID
  FROM `mobile-retail-2025.mobile_retail_analysis.Acccessories_Sales`
  WHERE Accessories_subname = 'Bảo hiểm'
),

--  Accessory (non-insurance) transactions
accessory_orders AS (
  SELECT DISTINCT TransactionID
  FROM `mobile-retail-2025.mobile_retail_analysis.Acccessories_Sales`
  WHERE Accessories_subname != 'Bảo hiểm'
),

attach_rate_by_brand AS (
  SELECT 
    p.ProductBrand,
    COUNT(DISTINCT p.TransactionID) AS Total_Transactions,
    COUNT(DISTINCT i.TransactionID) AS Insurance_Transactions,
    COUNT(DISTINCT a.TransactionID) AS Accessory_Transactions
  FROM phone_orders p
  LEFT JOIN insurance_orders i ON p.TransactionID = i.TransactionID
  LEFT JOIN accessory_orders a ON p.TransactionID = a.TransactionID
  GROUP BY p.ProductBrand
)

SELECT 
  ProductBrand,
  Total_Transactions,
  Insurance_Transactions,
  ROUND(Insurance_Transactions / Total_Transactions * 100, 2) AS Insurance_Attach_Rate,
  Accessory_Transactions,
  ROUND(Accessory_Transactions / Total_Transactions * 100, 2) AS Accessory_Attach_Rate
FROM attach_rate_by_brand
ORDER BY Insurance_Attach_Rate DESC;
```

<img src="https://drive.google.com/uc?export=view&id=1_zZ0m1Y0LFBqZSq2E215b3MfCpJrdFST" width="1000"/>

#### 💡 Findings: 
- **BlackBerry** leads in insurance attach rate (55.56%) and shows strong accessory sales (44.44%).

- **Apple iPhone** has a solid insurance attach rate (20.03%) and high accessory attach rate (79.97%).

- **Samsung** dominates accessory attach rate (88.43%) with moderate insurance uptake (11.57%).

- Most other brands (e.g., Nokia, Q-SMART, Sony) show **0% attach rates, revealing missed cross-sell opportunities.**

#### 🟡 **Which age groups are more likely to use installment payments?**

```sql
WITH pay_by AS (
  SELECT 
    YearOldRange,
    COUNT(CASE WHEN Payment_method = 'Trả góp' THEN TransactionID END) AS Installment_Orders,
    COUNT(CASE WHEN Payment_method = 'Tiền mặt' THEN TransactionID END) AS Cash_Orders
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY YearOldRange
)
SELECT 
  YearOldRange,
  Installment_Orders,
  Cash_Orders,
  ROUND(Installment_Orders / (Installment_Orders + Cash_Orders) * 100, 2) AS Installment_Ratio
FROM pay_by
ORDER BY Installment_Orders DESC;
```
<img src="https://drive.google.com/uc?export=view&id=1i696HnZpWgV3oZ5uCkrIenXJvBFIyk0G" width="700"/>

#### 💡 Findings: 
- The age group 31–35 has the highest installment usage ratio at 7.91%
- All other age groups maintain a **roughly 6–7%** installment share.
- While **cash remains dominant**, the interest in installments is strongest among **working-age adults (26–35)**.

#### 🟡 **Which phone brands have the highest rate of installment purchases?**

```sql
WITH brand_payment_stats AS (
  SELECT 
    ProductBrand,
    COUNT(TransactionID) AS Total_Orders,
    COUNT(CASE WHEN Payment_method = 'Trả góp' THEN 1 END) AS Installment_Orders
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  GROUP BY ProductBrand
)
SELECT 
  ProductBrand,
  Installment_Orders,
  Total_Orders,
  ROUND(Installment_Orders / Total_Orders * 100, 2) AS Installment_Rate_Percent
FROM brand_payment_stats
ORDER BY Installment_Rate_Percent DESC;
```
<img src="https://drive.google.com/uc?export=view&id=13HPmgPlaCcyzSx4YWO7LWnqdgiJb_tR7" width="700"/>

#### 💡 Findings: 
- **Apple** and **Sony** lead in installment rate (~12%), despite lower sales volume.

- **Nokia** and **Samsung** have the highest **installment volumes**, but lower rates (~10.5% and 6.5%) due to broad product ranges.

- **Low-cost brands** (e.g., Q-SMART, Mobiistar) have **very low installment usage** (<5%).



#### 🟡 **Installment Rate by ProductName (top 3 Brands)**

```sql
WITH product_installment_stats AS (
  SELECT 
    ProductBrand,
    ProductName,
    Unitprice,
    COUNT(TransactionID) AS Total_Orders,
    COUNT(CASE WHEN Payment_method = 'Trả góp' THEN 1 END) AS Installment_Orders
  FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
  WHERE ProductBrand IN ('NOKIA', 'SAMSUNG', 'Q-SMART')
  GROUP BY ProductBrand, ProductName, Unitprice
  HAVING Total_Orders >= 100
),
ranked_products AS (
  SELECT *,
    ROUND(Installment_Orders / Total_Orders * 100, 2) AS Installment_Rate_Percent,
    DENSE_RANK() OVER (PARTITION BY ProductBrand ORDER BY Installment_Orders / Total_Orders DESC) AS rank
  FROM product_installment_stats
)
SELECT 
  ProductBrand,
  ProductName,
  Unitprice,
  Installment_Orders,
  Total_Orders,
  Installment_Rate_Percent
FROM ranked_products
WHERE rank <= 6
ORDER BY ProductBrand, rank;
```
<img src="https://drive.google.com/uc?export=view&id=195s5lPg29C5RsCyu8TAp8YETWUsWEMz2" width="700"/>

#### 💡 Findings: 
Installment behavior is price-driven: Customers **tend to choose installment payments for higher-priced models** **(>5M VND)**, while lower-priced phones are mostly paid in full.

---

## 🔎 Final Conclusion & Recommendations  

👉🏻 Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following:  

📌 Key Takeaways:  
✔️ Recommendation 1  
✔️ Recommendation 2  
✔️ Recommendation 3
