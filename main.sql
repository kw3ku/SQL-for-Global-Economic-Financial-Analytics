-- This file contains all the queries 
-- that are used in the main program.


/** for economic indicators including gdp, inflation rate, and trade balance */

CREATE TABLE numbers (year INT);

INSERT INTO numbers (year)
VALUES (2015), (2016), (2017), (2018), (2019), (2020), (2021), (2022), (2023), (2024);

-- # Economic indicators data for the countries
INSERT INTO economic_indicators(country_id , year, gdp, inflation_rate, trade_balance) 
SELECT c.country_id, n.year, ROUND(RAND() * 1000000 + 50000, 2) AS gdp,
ROUND(RAND() * 10, 2) AS inflation_rate,
ROUND(RAND() * 100000 - 50000, 2) AS trade_balance
FROM countries c 
CROSS JOIN numbers n;


-- # Exchange rates data for the countries

INSERT INTO exchange_rates (country_id, currency_code, year, exchange_rate)
SELECT 
    c.country_id, 
    CASE 
        WHEN c.country_code = 'USA' THEN 'USD'
        WHEN c.country_code = 'GBR' THEN 'GBP'
        WHEN c.country_code = 'JPN' THEN 'JPY'
        ELSE CONCAT(LEFT(c.country_code, 2), 'X') 
    END AS currency_code,
    n.year,
    ROUND(RAND() * 5 + 1, 4) AS exchange_rate
FROM countries c
CROSS JOIN numbers n;


/** create a new numbers and dates table **/
/** run the code one after the other in batches (1) create (2) insert **/ 

CREATE TABLE numbers_1 (
  num INT
);

INSERT INTO numbers_1 (num)
VALUES (1), (2), (3), (4), (5);


CREATE TABLE dates (
trade_date DATE
);

INSERT INTO dates (trade_date)
SELECT DATE_FORMAT(DATE('2023-01-01') + INTERVAL (a.num + b.num * 1000) DAY, '%Y-%m-%d') AS trade_date
FROM numbers_1 a
CROSS JOIN numbers_1 b
WHERE DATE('2023-01-01') + INTERVAL (a.num + b.num * 1000) DAY <= '2024-12-31';


# Use Recursive CTE (Common Table Expression)

# first 
CREATE TEMPORARY TABLE temp_dates (
  trade_date DATE
);

INSERT INTO temp_dates (trade_date)

WITH RECURSIVE date_series AS (
  -- Anchor member: Start with the first date
  SELECT DATE('2023-01-01') AS trade_date
  UNION ALL
  -- Recursive member: Add 1 day to the previous date
  SELECT trade_date + INTERVAL 1 DAY
  FROM date_series
  -- Stop when the date exceeds 2024-12-31
  WHERE trade_date + INTERVAL 1 DAY <= '2024-12-31'
)

SELECT trade_date
FROM date_series;

/* There is a limitation when using CTE with MysQl */ 
/* hence, the process have to be done assyncronously / sequentially, first into the main temp data and then dates  */

# second
INSERT INTO dates (trade_date)
SELECT trade_date
FROM temp_dates;


/* afterwards remove the temporary table and data */ 
# third
DROP TEMPORARY TABLE temp_dates;



/** for stock prices **/

INSERT INTO stock_prices (company_name, country_id, stock_symbol, trade_date, open_price, close_price, volume, market_index, volatility)
SELECT 
    CONCAT('Company_', c.country_code, '_', n.num) AS company_name,
    c.country_id,
    UPPER(CONCAT(
      SUBSTRING(c.country_code, 1, 2), -- First 2 letters of country code
      LPAD(n.num, 2, '0'), -- Company suffix (padded to 2 digits)
      REPLACE(d.trade_date, '-', ''), -- Full trade_date without hyphens
      SUBSTRING(MD5(RAND()), 1, 4) -- Random 4-character suffix
    )) AS stock_symbol,
    d.trade_date,
    ROUND(RAND() * 1000 + 50, 2) AS open_price,
    ROUND(RAND() * 1000 + 50, 2) AS close_price,
    FLOOR(RAND() * 1000000) AS volume,
    NULL AS market_index, -- Insert NULL for the new column
    NULL AS volatility -- Insert NULL for the new column
FROM countries c
CROSS JOIN numbers_1 n
CROSS JOIN dates d;

-- # Update the Market_index 

UPDATE stock_prices
SET 
    market_index = FLOOR(RAND() * 100000), -- Random market index
    volatility = ROUND(RAND() * 20, 2); -- Random volatility between 0 and 20



-- # end populating market_index



/** generate financial reports for Companies **/

# for this we create a new table numbers_2

CREATE TABLE numbers_2 (
    num INT
);

INSERT INTO numbers_2 (num)
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

# end for numbers_2

INSERT INTO financial_reports (company_name, year, revenue, net_income, assets, liabilities)
SELECT 
    sp.company_name, 
    2014 + n.num AS year, -- Generate years from 2015 to 2024
    ROUND(RAND() * 1000000 + 50000, 2) AS revenue,
    ROUND(RAND() * 200000 - 100000, 2) AS net_income,
    ROUND(RAND() * 500000 + 100000, 2) AS assets,
    ROUND(RAND() * 200000 + 50000, 2) AS liabilities
FROM stock_prices sp
CROSS JOIN numbers_2 n
GROUP BY sp.company_name, n.num;




/** end the generating of financial reports for companies **/



/** SQL Queries & Analysis **/

/** Find Top 5 Fastest Growing Economies **/

SELECT country_name, year, gdp, 
       (gdp - LAG(gdp) OVER (PARTITION BY country_name ORDER BY year)) / LAG(gdp) OVER (PARTITION BY country_name ORDER BY year) * 100 AS gdp_growth
FROM economic_indicators ei 
JOIN countries c ON ei.country_id = c.country_id
ORDER BY gdp_growth DESC
LIMIT 5;


/** Find Top 5 Countries with Highest Volatility **/
SELECT stock_symbol, company_name, volatility
FROM stock_prices
ORDER BY volatility DESC
LIMIT 5;




-- Incase of debugging, use these 
/* debugging */

DESCRIBE numbers_1;

DESCRIBE dates;

DESCRIBE countries;

DESCRIBE stock_prices;

SELECT * FROM dates;

/** Check for no duplicates **/
SELECT stock_symbol, trade_date, COUNT(*)
FROM stock_prices
GROUP BY stock_symbol, trade_date
HAVING COUNT(*) > 1;







