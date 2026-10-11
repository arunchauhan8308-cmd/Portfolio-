use SalesAnalytics;
 SELECT * FROM sales_analytics;

SELECT
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  SUM(quantity) AS total_quantity,
  COUNT(DISTINCT order_id) AS total_orders
FROM
  sales_analytics;

SELECT
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin
FROM
  sales_analytics;

--How does sales and profit vary by region?
SELECT
  Region,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit
FROM
  sales_analytics
GROUP BY
  Region
ORDER BY
  Total_Sales DESC;

--"which region sells more?"
SELECT
  Region,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit,
  ROUND(
    SUM(Profit) / SUM(Sales) * 100,
    2
  ) AS Profit_Margin
FROM
  sales_analytics
GROUP BY
  Region
ORDER BY
  Total_Sales DESC;

--Which product categories generate the most sales and profit?
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY Category
ORDER BY Total_Sales DESC;

SELECT
    Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY Sub_Category
ORDER BY Total_Profit DESC;

SELECT
    Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_analytics
GROUP BY Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;

--Sales Trend Over Time
--Sales by Year
SELECT
    YEAR(Order_Date) AS Sales_Year,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_analytics
GROUP BY YEAR(Order_Date)
ORDER BY Sales_Year;

--Monthly Sales
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Month_Number,
    DATENAME(MONTH,Order_Date) AS Month_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_analytics
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH,Order_Date)
ORDER BY
    Sales_Year,
    Month_Number;

--Year over Year Sales growth
WITH yearly_sales AS (
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        SUM(Sales) AS Total_Sales
    FROM sales_analytics
    GROUP BY YEAR(Order_Date)
)

SELECT
    Sales_Year,
    ROUND(Total_Sales, 2) AS Total_Sales,
    ROUND(
        (Total_Sales - LAG(Total_Sales) OVER (ORDER BY Sales_Year))
        / LAG(Total_Sales) OVER (ORDER BY Sales_Year) * 100,
        2
    ) AS YoY_Growth_Percent
FROM yearly_sales
ORDER BY Sales_Year;

--Top 10 Customers
SELECT TOP 10
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_analytics
GROUP BY Customer_Name
ORDER BY Total_Sales DESC;


--Which products are contributing most to overall losses?
SELECT TOP 10
    Product_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_analytics
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


--Rank Products by Sales
SELECT
    Category,
    Product_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY SUM(Sales) DESC
    ) AS Sales_Rank
FROM sales_analytics
GROUP BY
    Category,
    Product_Name
ORDER BY
    Category,
    Sales_Rank;

--Top Products by Profit Within Each Category
--Which products are the most profitable within each category?
SELECT
    Category,
    Product_Name,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY SUM(Profit) DESC
    ) AS Profit_Rank
FROM sales_analytics
GROUP BY
    Category,
    Product_Name
ORDER BY
    Category,
    Profit_Rank;

--Which customers generate the highest profit, and what is their profit margin?

SELECT top 10
    Customer_Name,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY Customer_Name
ORDER BY Total_Profit DESC;

--How do sales and profitability vary across shipping modes?
SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY Ship_Mode
ORDER BY Total_Sales DESC;

--Regional Performance by Segment
--How does each customer segment perform within each region?
SELECT
    Region,
    Segment,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY
    Region,
    Segment
ORDER BY
    Region,
    Total_Sales DESC;

--On average, how much revenue does the business generate per order?
SELECT
    ROUND(
        SUM(Sales) /
        COUNT(DISTINCT Order_ID),
        2
    ) AS Average_Order_Value
FROM sales_analytics;

--Does higher discounting appear to be associated with lower profitability?
SELECT
    ROUND(Discount * 100, 0) AS Discount_Percent,
    COUNT(*) AS Order_Lines,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM sales_analytics
GROUP BY Discount
ORDER BY Discount;

--Which categories receive higher discounts, and how does their profitability compare?
SELECT
    Category,
    ROUND(AVG(Discount) * 100, 2) AS Avg_Discount_Percent,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY Category
ORDER BY Avg_Discount_Percent DESC;

--Which states generate the most sales and profit?
SELECT
    State,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY State
ORDER BY Total_Sales DESC;

--Which 10 states contribute the most profit?
SELECT top 10
    State,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) /
        SUM(Sales) * 100,
        2
    ) AS Profit_Margin
FROM sales_analytics
GROUP BY State
ORDER BY Total_Profit DESC;

--What are the top 3 products by sales within each category?
WITH product_sales AS (
    SELECT
        Category,
        Product_Name,
        ROUND(SUM(Sales), 2) AS Total_Sales,
        ROUND(SUM(Profit), 2) AS Total_Profit
    FROM sales_analytics
    GROUP BY
        Category,
        Product_Name
),
ranked_products AS (
    SELECT
        Category,
        Product_Name,
        Total_Sales,
        Total_Profit,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Sales DESC
        ) AS Product_Rank
    FROM product_sales
)
SELECT
    Category,
    Product_Name,
    Total_Sales,
    Total_Profit,
    Product_Rank
FROM ranked_products
WHERE Product_Rank <= 3
ORDER BY
    Category,
    Product_Rank;