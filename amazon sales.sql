CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Customer_ID INT,
    Product_ID INT,
    Product_Category VARCHAR(100),
    Quantity INT,
    Price DECIMAL(10,2),
    Shipping_Cost DECIMAL(10,2),
    Total_Amount DECIMAL(10,2)
);

INSERT INTO Orders (Order_ID, Product_ID, Price, Quantity)
VALUES
  (1, 101, 10.99, 2),
  (2, 102, 29.99, 1),
  (3, 103, 15.99, 3),
  (4, 101, 18.49, 2),  -- Using the mean value for missing price
  (5, 104, 22.99, 4);

-- Yearly Sales Trend:

SELECT
    YEAR(OrderDate) AS Year,
    SUM(TotalAmount) AS TotalSales
FROM
    Orders
GROUP BY
    YEAR(OrderDate)
ORDER BY
    Year;

-- Top-Performing Product Categories by Year:

SELECT
    YEAR(OrderDate) AS Year,
    Product_Category,
    SUM(Quantity * Price) AS TotalRevenue
FROM
    Orders
GROUP BY
    YEAR(OrderDate), Product_Category
ORDER BY
    Year, TotalRevenue DESC;

-- Customer Segmentation Based on Annual Spending:

WITH CustomerYearlySpend AS (
    SELECT
        Customer_ID,
        YEAR(OrderDate) AS Year,
        SUM(TotalAmount) AS AnnualSpend
    FROM
        Orders
    GROUP BY
        Customer_ID, YEAR(OrderDate)
)
SELECT
    Customer_ID,
    CASE
        WHEN AnnualSpend >= 1000 THEN 'High-Value Customer'
        WHEN AnnualSpend >= 500 THEN 'Medium-Value Customer'
        ELSE 'Low-Value Customer'
    END AS CustomerSegment
FROM
    CustomerYearlySpend;

-- Product Performance Analysis by Year:

WITH ProductYearlyPerformance AS (
    SELECT
        Product_ID,
        YEAR(OrderDate) AS Year,
        SUM(Quantity) AS UnitsSold,
        SUM(TotalAmount) AS TotalRevenue
    FROM
        Orders
    GROUP BY
        Product_ID, YEAR(OrderDate)
)
SELECT
    Product_ID,
    Year,
    UnitsSold,
    TotalRevenue,
    LAG(UnitsSold) OVER (PARTITION BY Product_ID ORDER BY Year) AS PrevYearUnitsSold,
    LAG(TotalRevenue) OVER (PARTITION BY Product_ID ORDER BY Year) AS PrevYearRevenue
FROM
    ProductYearlyPerformance;

--  Identifying Seasonal Trends:

SELECT
    MONTH(OrderDate) AS Month,
    YEAR(OrderDate) AS Year,
    SUM(TotalAmount) AS MonthlySales
FROM
    Orders
GROUP BY
    MONTH(OrderDate), YEAR(OrderDate)
ORDER BY
    Year, Month;

-- Data Inspection:

-- Check for null values:

SELECT COUNT(*) FROM Orders WHERE Order_ID IS NULL OR Order_Date IS NULL OR ...;

-- Data Aggregation:

SELECT Product_Category, SUM(Total_Amount) AS Total_Category_Sales
FROM Orders
GROUP BY Product_Category;

-- Data Enrichment:

SELECT O.*, P.Product_Description
FROM Orders O
JOIN Products P ON O.Product_ID = P.Product_ID;

-- Top-Selling Products by Revenue:

SELECT
  Product_ID,
  SUM(Quantity * Price) AS Total_Revenue
FROM
  Orders
GROUP BY
  Product_ID
ORDER BY
  Total_Revenue DESC
LIMIT 10;

-- Customer Segmentation Based on Purchase Frequency:

WITH CustomerPurchaseFrequency AS (
  SELECT
    Customer_ID,
    COUNT(*) AS Purchase_Count
  FROM
    Orders
  GROUP BY
    Customer_ID
)
SELECT
  Customer_ID,
  CASE
    WHEN Purchase_Count >= 10 THEN 'Frequent Shopper'
    WHEN Purchase_Count >= 5 THEN 'Regular Shopper'
    ELSE 'Occasional Shopper'
  END AS Customer_Segment
FROM
  CustomerPurchaseFrequency;

-- Sales Trend Analysis by Month and Year:

SELECT
  YEAR(Order_Date) AS Year,
  MONTH(Order_Date) AS Month,
  SUM(Total_Amount) AS Monthly_Sales
FROM
  Orders
GROUP BY
  YEAR(Order_Date), MONTH(Order_Date)
ORDER BY
  Year, Month;

--  Identifying High-Value Customers:

SELECT
  Customer_ID,
  SUM(Total_Amount) AS Total_Spend
FROM
  Orders
GROUP BY
  Customer_ID
HAVING
  SUM(Total_Amount) > 1000;  -- Adjust the threshold as needed

-- Analyzing Product Performance by Category:

SELECT
  Product_Category,
  COUNT(*) AS Number_of_Products,
  SUM(Quantity) AS Total_Units_Sold,
  AVG(Price) AS Average_Price
FROM
  Orders
GROUP BY
  Product_Category;

-- Cohort Analysis:

WITH CustomerCohort AS (
  SELECT
    Customer_ID,
    MIN(Order_Date) AS Cohort_Date,
    DATEDIFF(MONTH, MIN(Order_Date), MAX(Order_Date)) AS Cohort_Index
  FROM
    Orders
  GROUP BY
    Customer_ID
)
SELECT
  Cohort_Date,
  Cohort_Index,
  COUNT(*) AS Total_Customers,
  SUM(CASE WHEN Cohort_Index = 1 THEN 1 ELSE 0 END) AS Month_1_Retention,
  SUM(CASE WHEN Cohort_Index = 2 THEN 1 ELSE 0 END) AS Month_2_Retention,
  -- ... and so on for more months
FROM
  CustomerCohort
GROUP BY
  Cohort_Date, Cohort_Index;

--  Product Recommendation Engine:

WITH FrequentProductPairs AS (
  SELECT
    o1.Product_ID AS Product1,
    o2.Product_ID AS Product2,
    COUNT(*) AS Purchase_Count
  FROM
    Orders o1
  JOIN Orders o2 ON o1.Customer_ID = o2.Customer_ID AND o1.Order_ID <> o2.Order_ID
  GROUP BY
    o1.Product_ID, o2.Product_ID
)
SELECT
  Product1,
  Product2,
  Purchase_Count
FROM
  FrequentProductPairs
ORDER BY
  Purchase_Count DESC;

-- Customer Lifetime Value (CLTV) Analysis:

WITH CustomerPurchaseHistory AS (
  SELECT
    Customer_ID,
    MIN(Order_Date) AS First_Purchase_Date,
    MAX(Order_Date) AS Last_Purchase_Date,
    AVG(Total_Amount) AS Average_Order_Value,
    COUNT(*) AS Purchase_Frequency
  FROM
    Orders
  GROUP BY
    Customer_ID
)
SELECT
  Customer_ID,
  Average_Order_Value * Purchase_Frequency / (DATEDIFF(DAY, First_Purchase_Date, Last_Purchase_Date) / 365) AS CLTV
FROM
  CustomerPurchaseHistory;

-- Time Series Analysis with Window Functions:

SELECT
  Order_Date,
  Total_Sales,
  LAG(Total_Sales) OVER (ORDER BY Order_Date) AS Previous_Day_Sales,
  LEAD(Total_Sales) OVER (ORDER BY Order_Date) AS Next_Day_Sales,
  AVG(Total_Sales) OVER (ORDER BY Order_Date ROWS BETWEEN 7 PRECEDING AND 7 FOLLOWING) AS Rolling_7_Day_Avg
FROM
  (
    SELECT
      Order_Date,
      SUM(Total_Amount) AS Total_Sales
    FROM
      Orders
    GROUP BY
      Order_Date
  ) AS Daily_Sales;

-- Cohort Analysis with Multiple Dimensions:

WITH CustomerCohort AS (
  SELECT
    Customer_ID,
    YEAR(First_Purchase_Date) AS Cohort_Year,
    MONTH(First_Purchase_Date) AS Cohort_Month,
    DATEDIFF(MONTH, First_Purchase_Date, Order_Date) AS Cohort_Index
  FROM
    (
      SELECT
        Customer_ID,
        MIN(Order_Date) AS First_Purchase_Date,
        Order_Date
      FROM
        Orders
      GROUP BY
        Customer_ID, Order_Date
    ) AS CustomerOrders
)
SELECT
  Cohort_Year,
  Cohort_Month,
  Cohort_Index,
  COUNT(*) AS Total_Customers,
  SUM(CASE WHEN Cohort_Index = 1 THEN 1 ELSE 0 END) AS Month_1_Retention,
  SUM(CASE WHEN Cohort_Index = 2 THEN 1 ELSE 0 END) AS Month_2_Retention,
  -- ... and so on for more months
FROM
  CustomerCohort
GROUP BY
  Cohort_Year, Cohort_Month, Cohort_Index;

--  Predictive Modeling with Machine Learning:

WITH SalesData AS (
  SELECT
    Order_Date,
    Total_Sales
  FROM
    (
      SELECT
        Order_Date,
        SUM(Total_Amount) AS Total_Sales
      FROM
        Orders
      GROUP BY
        Order_Date
    ) AS Daily_Sales
)
SELECT
  *
FROM
  SalesData
JOIN (
  SELECT
    LinearReg(Order_Date, Total_Sales) AS Predicted_Sales
  FROM
    SalesData
) AS Predictions ON SalesData.Order_Date = Predictions.Order_Date;

-- Geographic Analysis with Spatial Data:

WITH CustomerLocations AS (
  SELECT
    Customer_ID,
    ST_GeomFromText('POINT(' || Longitude || ' ' || Latitude || ')') AS Location
  FROM
    Customers
)
SELECT
  COUNT(*) AS Number_of_Customers,
  ST_Centroid(ST_Collect(Location)) AS Centroid
FROM
  CustomerLocations
GROUP BY
  Country;

--  Time Series Analysis with Exponential Smoothing:

WITH ExponentialSmoothing AS (
  SELECT
    Order_Date,
    Total_Sales,
    EXP(AVG(LOG(Total_Sales))) OVER (ORDER BY Order_Date ROWS BETWEEN 7 PRECEDING AND 7 FOLLOWING) AS Exponential_Smoothing
  FROM
    (
      SELECT
        Order_Date,
        SUM(Total_Amount) AS Total_Sales
      FROM
        Orders
      GROUP BY
        Order_Date
    ) AS Daily_Sales
)
SELECT
  *
FROM
  ExponentialSmoothing;

-- 