use Sales_MIS;
-- STEP 1: Display the first 10 sales records
UPDATE Sales_MIS.db_accessadmin.Sales_MIS
SET Discount = TRIM(REPLACE(Discount, '%', ''));

ALTER TABLE Sales_MIS.db_accessadmin.Sales_MIS
ALTER COLUMN Discount float;

SELECT TOP 10 *
FROM Sales_MIS.db_accessadmin.Sales_MIS;


-- STEP 1B: Count all sales records

SELECT
    COUNT(*) AS Total_Rows
FROM Sales_MIS.db_accessadmin.Sales_MIS;


-- STEP 2.1: Check missing values in important columns

SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE WHEN Order_ID IS NULL
             THEN 1 ELSE 0 END) AS Missing_Order_ID,

    SUM(CASE WHEN Order_Date IS NULL
             THEN 1 ELSE 0 END) AS Missing_Order_Date,

    SUM(CASE WHEN Sales IS NULL
             THEN 1 ELSE 0 END) AS Missing_Sales,

    SUM(CASE WHEN Cost IS NULL
             THEN 1 ELSE 0 END) AS Missing_Cost,

    SUM(CASE WHEN Profit IS NULL
             THEN 1 ELSE 0 END) AS Missing_Profit,

    SUM(CASE WHEN Region IS NULL
             THEN 1 ELSE 0 END) AS Missing_Region,

    SUM(CASE WHEN Salesperson IS NULL
             THEN 1 ELSE 0 END) AS Missing_Salesperson

FROM Sales_MIS.db_accessadmin.Sales_MIS;


-- STEP 2.2: Find duplicate Order_ID values

SELECT
    Order_ID,
    COUNT(*) AS Occurrences
FROM Sales_MIS.db_accessadmin.Sales_MIS
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY Occurrences DESC;


-- STEP 3.1: Overall Sales KPI Report

SELECT
    COUNT(*) AS Total_Records,

    COUNT(DISTINCT Order_ID) AS Unique_Orders,

    SUM(Sales) AS Total_Revenue,

    SUM(Cost) AS Total_Cost,

    SUM(Profit) AS Total_Profit,

    AVG(Sales) AS Average_Sales_Per_Record,

    AVG(Profit) AS Average_Profit_Per_Record,

    SUM(Quantity) AS Total_Quantity_Sold,
    
    SUM(Target) AS total_Target,

    CASE
        WHEN SUM(Sales) = 0 THEN NULL
        ELSE
            ROUND(
                SUM(Profit) * 100.0 / SUM(Sales),
                2
            )
    END AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS;


-- STEP 3.2: Profitability Summary

SELECT
    CASE
        WHEN Profit > 0 THEN 'Profitable'
        WHEN Profit < 0 THEN 'Loss'
        WHEN Profit = 0 THEN 'Break-even'
        ELSE 'Missing Profit'
    END AS Profit_Status,

    COUNT(*) AS Record_Count,

    SUM(Sales) AS Total_Sales,

    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS
GROUP BY
    CASE
        WHEN Profit > 0 THEN 'Profitable'
        WHEN Profit < 0 THEN 'Loss'
        WHEN Profit = 0 THEN 'Break-even'
        ELSE 'Missing Profit'
    END
ORDER BY Record_Count DESC;


-- STEP 4.1: Monthly Sales Performance Report

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,

    DATENAME(MONTH, Order_Date) AS Month_Name,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Sales) AS Total_Revenue,

    SUM(Profit) AS Total_Profit,

    SUM(Quantity) AS Total_Quantity_Sold

FROM Sales_MIS.db_accessadmin.Sales_MIS

WHERE Order_Date IS NOT NULL

GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date)

ORDER BY
    Sales_Year,
    Sales_Month;


-- STEP 4.2: Month-over-Month Revenue Growth

WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        SUM(Sales) AS Total_Revenue
    FROM Sales_MIS.db_accessadmin.Sales_MIS
    WHERE Order_Date IS NOT NULL
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),
SalesGrowth AS
(
    SELECT
        Sales_Year,
        Sales_Month,
        Total_Revenue,

        LAG(Total_Revenue) OVER
        (
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Revenue

    FROM MonthlySales
)
SELECT
    Sales_Year,
    Sales_Month,
    Total_Revenue,
    Previous_Month_Revenue,

    CASE
        WHEN Previous_Month_Revenue IS NULL
          OR Previous_Month_Revenue = 0
        THEN NULL
        ELSE ROUND(
            (Total_Revenue - Previous_Month_Revenue)
            * 100.0 / Previous_Month_Revenue,
            2
        )
    END AS MoM_Growth_Percent

FROM SalesGrowth
ORDER BY Sales_Year, Sales_Month;


-- STEP 5.1: Region-wise Sales Performance

SELECT
    Region,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Quantity) AS Total_Quantity_Sold,

    SUM(Sales) AS Total_Revenue,

    SUM(Cost) AS Total_Cost,

    SUM(Profit) AS Total_Profit,

    CASE
        WHEN SUM(Sales) = 0 THEN NULL
        ELSE ROUND(
            SUM(Profit) * 100.0 / SUM(Sales),
            2
        )
    END AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Region

ORDER BY Total_Revenue DESC;


-- STEP 5.2: Top Region by Revenue

SELECT TOP 1
    Region,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Region

ORDER BY SUM(Sales) DESC;


-- STEP 5.3: Regions with Negative Total Profit

SELECT
    Region,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Region

HAVING SUM(Profit) < 0

ORDER BY Total_Profit ASC;


-- STEP 6.1: Salesperson Performance Report

SELECT
    Salesperson,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Quantity) AS Total_Quantity_Sold,

    SUM(Sales) AS Total_Revenue,

    SUM(Profit) AS Total_Profit,

    CASE
        WHEN SUM(Sales) = 0 THEN NULL
        ELSE ROUND(
            SUM(Profit) * 100.0 / SUM(Sales),
            2
        )
    END AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Salesperson

ORDER BY Total_Revenue DESC;


-- STEP 6.2: Salesperson Target Achievement

SELECT
    Salesperson,

    SUM(Sales) AS Total_Revenue,

    SUM(Target) AS Total_Target,

    SUM(Sales) - SUM(Target) AS Target_Variance,

    CASE
        WHEN SUM(Target) = 0 THEN NULL
        ELSE ROUND(
            SUM(Sales) * 100.0 / SUM(Target),
            2
        )
    END AS Target_Achievement_Percent,

    CASE
        WHEN SUM(Target) = 0 THEN 'No Target'
        WHEN SUM(Sales) >= SUM(Target) THEN 'Target Achieved'
        ELSE 'Target Not Achieved'
    END AS Target_Status

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Salesperson

ORDER BY Target_Achievement_Percent DESC;


-- STEP 6.3: Top 5 Salespeople by Revenue

SELECT TOP 5
    Salesperson,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Salesperson

ORDER BY SUM(Sales) DESC;


-- STEP 7.1: Product Performance Report

SELECT
    Product_ID,
    Product_Name,
    Category,

    SUM(Quantity) AS Total_Quantity_Sold,

    SUM(Sales) AS Total_Revenue,

    SUM(Cost) AS Total_Cost,

    SUM(Profit) AS Total_Profit,

    CASE
        WHEN SUM(Sales) = 0 THEN NULL
        ELSE ROUND(
            SUM(Profit) * 100.0 / SUM(Sales),
            2
        )
    END AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    Product_ID,
    Product_Name,
    Category

ORDER BY Total_Revenue DESC;


-- STEP 7.2: Top 5 Products by Revenue

SELECT TOP 5
    Product_ID,
    Product_Name,
    SUM(Quantity) AS Total_Quantity_Sold,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    Product_ID,
    Product_Name

ORDER BY SUM(Sales) DESC;


-- STEP 7.3: Products with Negative Total Profit

SELECT
    Product_ID,
    Product_Name,
    Category,

    SUM(Sales) AS Total_Revenue,

    SUM(Cost) AS Total_Cost,

    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    Product_ID,
    Product_Name,
    Category

HAVING SUM(Profit) < 0

ORDER BY Total_Profit ASC;


-- STEP 7.4: Category-wise Sales Performance

SELECT
    Category,

    SUM(Quantity) AS Total_Quantity_Sold,

    SUM(Sales) AS Total_Revenue,

    SUM(Profit) AS Total_Profit,

    CASE
        WHEN SUM(Sales) = 0 THEN NULL
        ELSE ROUND(
            SUM(Profit) * 100.0 / SUM(Sales),
            2
        )
    END AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Category

ORDER BY Total_Revenue DESC;


-- STEP 8.1: Customer Performance Report

SELECT
    Customer_ID,
    Customer_Name,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Quantity) AS Total_Quantity_Purchased,

    SUM(Sales) AS Total_Revenue,

    SUM(Profit) AS Total_Profit,

    CASE
        WHEN SUM(Sales) = 0 THEN NULL
        ELSE ROUND(
            SUM(Profit) * 100.0 / SUM(Sales),
            2
        )
    END AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    Customer_ID,
    Customer_Name

ORDER BY Total_Revenue DESC;


-- STEP 8.2: Top 10 Customers

SELECT TOP 10
    Customer_ID,
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    Customer_ID,
    Customer_Name

ORDER BY SUM(Sales) DESC;


-- STEP 8.3: Customer Revenue Contribution

WITH CustomerSales AS
(
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Sales) AS Customer_Revenue
    FROM Sales_MIS.db_accessadmin.Sales_MIS
    GROUP BY
        Customer_ID,
        Customer_Name
)
SELECT
    Customer_ID,
    Customer_Name,
    Customer_Revenue,

    ROUND(
        Customer_Revenue * 100.0 /
        NULLIF(SUM(Customer_Revenue) OVER (), 0),
        2
    ) AS Revenue_Contribution_Percent

FROM CustomerSales
ORDER BY Customer_Revenue DESC;


-- STEP 8.4: Customers with Negative Total Profit

SELECT
    Customer_ID,
    Customer_Name,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    Customer_ID,
    Customer_Name

HAVING SUM(Profit) < 0

ORDER BY Total_Profit ASC;


-- STEP 9.1: Discount-Level Performance Analysis

SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount > 0 AND Discount <= 0.10
            THEN 'Low Discount (0-10%)'
        WHEN Discount > 0.10 AND Discount <= 0.20
            THEN 'Medium Discount (10-20%)'
        WHEN Discount > 0.20
            THEN 'High Discount (Above 20%)'
        ELSE 'Missing or Invalid Discount'
    END AS Discount_Level,

    COUNT(*) AS Total_Records,

    SUM(Sales) AS Total_Revenue,

    SUM(Profit) AS Total_Profit,

    AVG(Discount) AS Average_Discount

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount > 0 AND Discount <= 0.10
            THEN 'Low Discount (0-10%)'
        WHEN Discount > 0.10 AND Discount <= 0.20
            THEN 'Medium Discount (10-20%)'
        WHEN Discount > 0.20
            THEN 'High Discount (Above 20%)'
        ELSE 'Missing or Invalid Discount'
    END

ORDER BY Total_Revenue DESC;




-- STEP 9.2: High-Discount Transactions Making a Loss

SELECT
    Order_ID,
    Order_Date,
    Product_Name,
    Region,
    Salesperson,
    Sales,
    Cost,
    Discount,
    Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

WHERE Discount > 0.20
  AND Profit < 0

ORDER BY Profit ASC;


-- STEP 9.3: Top 10 Transactions by Discount

SELECT TOP 10
    Order_ID,
    Order_Date,
    Product_Name,
    Salesperson,
    Region,
    Sales,
    Discount,
    Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

WHERE Discount IS NOT NULL

ORDER BY Discount DESC;


-- STEP 10.1: Loss-Making Transactions

SELECT
    Order_ID,
    Order_Date,
    Product_Name,
    Category,
    Region,
    Salesperson,
    Sales,
    Cost,
    Profit,
    Discount

FROM Sales_MIS.db_accessadmin.Sales_MIS

WHERE Profit < 0

ORDER BY Profit ASC;


-- STEP 10.2: Salespeople with Negative Total Profit

SELECT
    Salesperson,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Salesperson

HAVING SUM(Profit) < 0

ORDER BY Total_Profit ASC;


-- STEP 10.3: Regions with Profit Margin Below 10%

SELECT
    Region,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Region

HAVING
    SUM(Sales) > 0
    AND SUM(Profit) * 100.0 / SUM(Sales) < 10

ORDER BY Profit_Margin_Percent ASC;


-- STEP 10.4: Consolidated Sales Exception Report

SELECT
    Order_ID,
    Order_Date,
    Product_Name,
    Region,
    Salesperson,
    Sales,
    Profit,

    CASE
        WHEN Profit < 0 THEN 'Loss-Making Transaction'
        WHEN Sales = 0 AND Profit > 0 THEN 'Review Sales Value'
        ELSE 'Other'
    END AS Exception_Type

FROM Sales_MIS.db_accessadmin.Sales_MIS

WHERE
    Profit < 0
    OR (Sales = 0 AND Profit > 0)

ORDER BY Profit ASC;


-- STEP 11.1: Create Monthly Sales MIS View

CREATE OR ALTER VIEW dbo.vw_Monthly_Sales_MIS
AS
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Sales) AS Total_Revenue,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity_Sold,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS
WHERE Order_Date IS NOT NULL

GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date);



SELECT *
FROM dbo.vw_Monthly_Sales_MIS
ORDER BY Sales_Year, Sales_Month;


-- STEP 11.2: Create Region Performance View

CREATE OR ALTER VIEW dbo.vw_Region_Performance
AS
SELECT
    Region,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS
GROUP BY Region;


SELECT *
FROM dbo.vw_Region_Performance
ORDER BY Total_Revenue DESC;


-- STEP 12.1: Salesperson Performance View

CREATE OR ALTER VIEW dbo.vw_Salesperson_Performance
AS
SELECT
    Salesperson,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Sales) AS Total_Revenue,

    SUM(Profit) AS Total_Profit,

    SUM(Quantity) AS Total_Quantity_Sold,
    
    SUM(Target) AS Total_Targets,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY Salesperson;


SELECT *
FROM dbo.vw_Salesperson_Performance
ORDER BY Total_Revenue DESC;


-- STEP 12.2: Product Performance View

CREATE OR ALTER VIEW dbo.vw_Product_Performance
AS
SELECT
    Product_ID,
    Product_Name,
    Category,

    SUM(Quantity) AS Total_Quantity_Sold,

    SUM(Sales) AS Total_Revenue,

    SUM(Cost) AS Total_Cost,

    SUM(Profit) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Percent

FROM Sales_MIS.db_accessadmin.Sales_MIS

GROUP BY
    Product_ID,
    Product_Name,
    Category;


SELECT *
FROM dbo.vw_Product_Performance
ORDER BY Total_Revenue DESC;


-- STEP 12.3: Sales Exception View

CREATE OR ALTER VIEW dbo.vw_Sales_Exceptions
AS
SELECT
    Order_ID,
    Order_Date,
    Product_Name,
    Category,
    Region,
    Salesperson,
    Sales,
    Cost,
    Profit,
    Discount,

    CASE
        WHEN Profit < 0
            THEN 'Loss-Making Transaction'
        WHEN Sales = 0 AND Profit > 0
            THEN 'Review Sales Value'
    END AS Exception_Type

FROM Sales_MIS.db_accessadmin.Sales_MIS

WHERE
    Profit < 0
    OR (Sales = 0 AND Profit > 0);


SELECT *
FROM dbo.vw_Sales_Exceptions
ORDER BY Profit ASC;

--STEP 12.4: Customer Performance View

USE Sales_MIS;

CREATE OR ALTER VIEW dbo.vw_Customer_Performance
AS
SELECT
    Customer_ID,
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit
FROM Sales_MIS.db_accessadmin.Sales_MIS
GROUP BY
    Customer_ID,
    Customer_Name;

SELECT *
FROM DBO.vw_Customer_Performance
ORDER BY Customer_ID ASC;
