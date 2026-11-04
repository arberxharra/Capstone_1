-- Sales territory analysis: Maine

USE sample_sales;

-- The purpose of this query is to identify who is the manager of my assigned territory. 
SELECT SalesManager, State, RegionalDirector, Region
FROM management 
WHERE State LIKE '%Maine%';

-- 1. What is the total revenue overall for sales in the assigned territoy, plus the start date and the end date that tell you 
-- what period the data covers. 

SELECT sl.State,
	SUM(ss.Sale_Amount) AS Total_Revenue,
	MIN(ss.Transaction_Date) AS Start_Date,
	MAX(ss.Transaction_Date) AS End_Date
FROM store_sales ss
INNER JOIN store_locations sl
		ON ss.Store_ID = sl.StoreID
WHERE sl.State = 'Maine';


-- 2. What is the revenue breakdown by year and month for the sales territory?

SELECT DATE_FORMAT(ss.Transaction_Date,'%Y-%m') AS Revenue_Month,
	SUM(ss.Sale_Amount) AS Monthly_Rvenue
FROM store_sales ss
INNER JOIN store_locations sl
		ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Maine'
GROUP BY Revenue_Month
ORDER BY Revenue_Month DESC;

-- We can find patterns when breaking down sales by month. For us to see results filtered for New Jersy, we join the store_sales table with the store_location table, 
-- which contains the State fied. We use Group BY to ensure that are results are caluclated per month. 

-- 3. Provide a comparison of total revenue for the specific sales territory and the region it belongs to.

WITH Northeast_Sales AS (
    SELECT sl.State, ss.Sale_Amount AS Revenue
    FROM store_sales ss
    INNER JOIN store_locations sl 
		ON ss.Store_ID = sl.StoreId
    INNER JOIN management m 
		ON sl.State = m.State
    WHERE m.Region = 'Northeast'
)
SELECT 
    'Northeast' AS Region,
    State,
    SUM(Revenue) AS Total_Revenue,
    (SELECT SUM(Revenue) FROM Northeast_Sales) AS Northeast_Total,
    ROUND(SUM(Revenue) / (SELECT SUM(Revenue) FROM Northeast_Sales) * 100, 2) 
    AS Region_Percentage_Contribution
FROM Northeast_Sales
GROUP BY State
ORDER BY Total_Revenue DESC;


-- 4. What is the number of transactions per month and average transaction amount by product category for the sales territory?

SELECT DATE_FORMAT(ss.Transaction_Date, '%Y-%m') AS Revenue_Month,
		ic.Category AS Product_Category,
        COUNT(*) AS Transction_Count,
        ROUND(AVG(ss.Sale_Amount),2) AS Average_Transaction_Amount,
        SUM(ss.Sale_Amount) AS Category_Revenue
FROM store_sales ss
INNER JOIN store_locations sl
		ON ss.Store_ID = sl.StoreId
INNER JOIN products p 
		ON ss.Prod_Num = p.ProdNum
INNER JOIN inventory_categories ic
		ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'Maine'
GROUP BY Revenue_Month, Product_Category
ORDER BY Revenue_Month, Category_Revenue DESC;