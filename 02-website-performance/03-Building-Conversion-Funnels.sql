SELECT *
FROM
	(SELECT * FROM website_sessions
		WHERE website_session_id <= 100) AS first_hundred
;

-- BUSINESS CONTEXT
	-- we want to build a mini conversion funnel, from /lander-2 to /cart
    -- we want to know how many people reach each step, also dropoff rates

-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each relevant pageview as the specific funnel step
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance

SELECT
	ws.website_session_id,
    wp.pageview_url,
    wp.created_at AS pageview_created_At
    , CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page
    ,CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page
    ,CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	AND wp.pageview_url IN ('/lander-2', '/products','/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.created_at
;

SELECT
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM
(
SELECT
	ws.website_session_id,
    wp.pageview_url,
    wp.created_at AS pageview_created_At
    , CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page
    ,CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page
    ,CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	AND wp.pageview_url IN ('/lander-2', '/products','/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.created_at
) AS pageview_level
GROUP BY
	website_session_id
;


CREATE TEMPORARY TABLE sesson_level_made_it_flags_Demo AS
SELECT
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM
(
SELECT
	ws.website_session_id,
    wp.pageview_url,
    wp.created_at AS pageview_created_At
    , CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page
    ,CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page
    ,CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	AND wp.pageview_url IN ('/lander-2', '/products','/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.created_at
) AS pageview_level
GROUP BY
	website_session_id
;

SELECT
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart
FROM sesson_level_made_it_flags_Demo
;


SELECT
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) 
		/COUNT(DISTINCT website_session_id) AS clicked_to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS clicked_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS clicked_to_cart
FROM sesson_level_made_it_flags_Demo
;

-- Asignement - 01:
-- Problem: build full conversion funnel, analyzing how many customers make it to each step? date range '2012-08-05' to '2012-09-12' 

-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each relevant pageview as the specific funnel step
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance


SELECT
	ws.website_session_id,
    wp.pageview_url,
    wp.created_at AS pageview_created_At,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND wp.pageview_url IN ('/lander-1', '/products','/the-original-mr-fuzzy', '/cart', '/shipping','/billing','/thank-you-for-your-order')
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND ws.created_at > '2012-08-05'
    AND ws.created_at < '2012-09-05'
ORDER BY
	ws.website_session_id,
    wp.created_at
;


DROP TEMPORARY TABLE IF EXISTS sesson_level_made_it_flags;
CREATE TEMPORARY TABLE sesson_level_made_it_flags AS
SELECT
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM
(
SELECT
	ws.website_session_id,
    wp.pageview_url,
    wp.created_at AS pageview_created_At,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND wp.pageview_url IN ('/lander-1', '/products','/the-original-mr-fuzzy', '/cart', '/shipping','/billing','/thank-you-for-your-order')
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND ws.created_at > '2012-08-05'
    AND ws.created_at < '2012-09-05'
ORDER BY
	ws.website_session_id,
    wp.created_at
) AS pageview_level
GROUP BY
	website_session_id
;


SELECT
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM sesson_level_made_it_flags
;

SELECT
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM sesson_level_made_it_flags
;

-- result: need to focus on lander, mrfuzzy and billing page, for customer conversion


-- Assingment : 02
-- Problem: New version of '/billing' is created named '/billing-2'. what % of sessions of those pages end up placing an order. Limit data upto '2012-11-10'

-- STEP-01: Finding start point to frame the analysis

SELECT
	MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'
;

-- first page view id = 53550

-- STEP-02: we will look at this without oders, then we'll add in orders

SELECT
	wp.website_session_id,
    wp.pageview_url AS billing_version_seen,
    od.order_id
FROM website_pageviews AS wp
LEFT JOIN orders AS od
	ON od.website_session_id =wp.website_session_id
WHERE wp.website_pageview_id >=53550
AND wp.created_at < '2012-11-10'
AND wp.pageview_url IN ('/billing','/billing-2')
;


SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS billing_to_order_rt
FROM (
SELECT
	wp.website_session_id,
    wp.pageview_url AS billing_version_seen,
    od.order_id
FROM website_pageviews AS wp
LEFT JOIN orders AS od
	ON od.website_session_id =wp.website_session_id
WHERE wp.website_pageview_id >=53550
AND wp.created_at < '2012-11-10'
AND wp.pageview_url IN ('/billing','/billing-2')
) AS billling_session_w_orders
GROUP BY 1
;

-- result: billing - 2 seems to be more effective