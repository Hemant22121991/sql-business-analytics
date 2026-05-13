-- 


SELECT
    YEAR(created_at),
	WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
GROUP BY 1,2
;

-- Case pivoting

SELECT
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS count_single_item_orders,
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS count_two_item_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1
;

-- Assignment : 01
-- Problem : Pull gsearch nonbrand trended session volume by week

SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE 
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' AND
    DATE(created_at) < '2012-05-10'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at)
;

-- Outcome : The non brand traffic it does seems like sensitive to the bid changes and volume is down
-- Next step is continue to monitor and look for the ways, how could we make campaigns more efficient

-- Assignment : 02
-- Problem : Pull conversion rates from session to order by device type

SELECT 
	device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT od.order_id) AS orders,
    COUNT(DISTINCT od.order_id)/COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_order_conv_rate
FROM website_sessions AS ws
LEFT JOIN orders AS od
	ON od.website_session_id = ws.website_session_id
WHERE 
	DATE(ws.created_at) < '2012-05-11' AND
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand'
GROUP BY 1
ORDER by 3
;

-- Outcome: Desktop based traffic performing much better so stack holder should increase bid for desktop based traffic
-- Next Step to keep thinking about optimizing the bid

-- Assignment : 03
-- Problem : Pull weekly trends for both desktop and mobile for volume impact analysis for gsearch nonbrand campaigns up to 2012-04-15

SELECT 
	MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE 
	DATE(created_at) < '2012-06-09' AND
    DATE(created_at) > '2012-04-15' AND
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand'
GROUP BY 
	WEEK(created_at)
;

-- Outcome: Stackholder increased bid as per previously analysis for desktop website traffice.alter
-- As a result desktop website traffic increased in last 3 weeks