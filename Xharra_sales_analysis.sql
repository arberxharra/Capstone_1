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

-- 3. Provide a comparison of total revenue for the specific sales territory and the region it belongs to.

SELECT
    m.Region,
    sl.State,
    SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
JOIN management m
    ON sl.State = m.State
WHERE m.Region = 'Northeast'
GROUP BY m.Region, sl.State
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


-- 5. Can you provide a ranking of in-store sales performance by each store in the sales territory?
SELECT ss.Store_ID AS Store_ID,
	   sl.StoreLocation AS Store_City,
    SUM(ss.Sale_Amount) AS Total_Revenue,
	COUNT(ss.Sale_Amount) AS Transaction_Count,
	ROUND(AVG(ss.Sale_Amount), 2) AS Average_Transaction_Size,
	RANK() OVER (ORDER BY SUM(ss.Sale_Amount) DESC) AS Store_Rank
FROM store_sales ss
INNER JOIN store_locations sl
	ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Maine'
GROUP BY Store_ID, Store_City
ORDER BY Store_Rank;

-- 6. What is your recommendation for where to focus sales attention in the next quarter?
/* Recommendation for Next Quarter

1. Focus on growing revenue in Maine relative to the rest of the Northeast region. Maine generated $1.88 million in revenue, which is significantly lower than Maryland ($11.46 million), 
Massachusetts ($5.73 million), and New Jersey ($5.18 million). This suggests there is substantial room for growth and market expansion within the Maine territory.

2. Prioritize the lower-performing stores. The store ranking shows a noticeable gap between the top-performing store, South Portland ($332,611.76), and the lowest-performing store, Bar Harbor ($287,452.08).
 Sales efforts, promotions, and manager coaching should be directed toward Bar Harbor, Bangor, and Lewiston to identify opportunities to increase transaction values and customer traffic.

3. Leverage successful practices from top-performing stores. South Portland, Orono, and Kennebunkport consistently generate the highest revenue and have the strongest average transaction sizes.
 Management should analyze what these stores are doing well, such as product mix, staffing strategies, or promotional efforts, and apply those practices to lower-performing locations.

4. Prepare for seasonal demand patterns. Your monthly revenue report shows that October 2025 ($93,456.68) was the strongest month, while several months generated significantly lower sales.
 The next quarter should include targeted marketing campaigns and inventory planning based on historical high-performing periods to maximize revenue opportunities.

