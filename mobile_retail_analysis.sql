SELECT
 format_date('%Y %m',parse_date('%Y %m %d',DatePurchase)) month
 ,COUNT(DISTINCT CustomerCode) AS count_customer
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY month
ORDER BY month;



SELECT 
  SexType,
  YearOldRange,
  COUNT(TransactionID) AS Total_Orders
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY SexType, YearOldRange
ORDER BY Total_Orders DESC;

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


SELECT 
  GeographicalArea,
  COUNT(DISTINCT CustomerCode) AS UniqueCustomers
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY GeographicalArea
ORDER BY UniqueCustomers DESC;


SELECT 
  FORMAT_DATE('%Y-%m', PARSE_DATE('%Y %m %d', DatePurchase)) AS Month,
  SUM(SalesValue) AS TotalSales
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY Month
ORDER BY Month;


SELECT
  FORMAT_DATE('%Y-%m', PARSE_DATE('%Y %m %d', DatePurchase)) AS Month,
  ROUND(AVG(SalesValue), 2) AS AvgOrderValue
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY Month
ORDER BY Month;


SELECT 
  ProductName,
  ProductBrand,
  COUNT(TransactionID) AS TotalOrders,
  COUNT(DISTINCT EXTRACT(MONTH FROM PARSE_DATE('%Y %m %d', DatePurchase))) AS ActiveMonths
FROM `mobile-retail-2025.mobile_retail_analysis.Phone_Sales`
GROUP BY ProductName, ProductBrand
HAVING ActiveMonths >= 3
ORDER BY TotalOrders DESC, ActiveMonths DESC


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

