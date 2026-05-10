## Analyzing top traffic sources

SELECT 
	wss.utm_content,
    COUNT(DISTINCT wss.website_session_id) AS sessions,
    COUNT(DISTINCT ods.order_id) AS orders,
    COUNT(DISTINCT ods.order_id)/COUNT(DISTINCT wss.website_session_id) * 100 AS session_to_order_conv_rt
FROM website_sessions AS wss
	LEFT JOIN orders AS ods
		ON ods.website_session_id = wss.website_session_id
WHERE wss.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;

#Finding Top Traffic Sources - Assignment - 01
-- Problem : Find out where the bulk of our website sessions are coming from, through yesterday(WHERE created_at < '2012-04-12')? Provide breakdown by UTM source, campaign and referring domain.

SELECT
	utm_source,
	utm_campaign,
	http_referer,
    COUNT(DISTINCT website_session_id) AS session
FROM website_sessions
WHERE DATE(created_at) < '2012-04-12'
GROUP BY 1,2,3
ORDER BY 4 DESC
;

 -- Assignement - 02 
 -- Problem: Calculate the conversion rate(CVR) from session to order for gsearch. if CVR less than 4% let us know
 
SELECT 
    COUNT(DISTINCT wss.website_session_id) AS sessions,
    COUNT(DISTINCT ods.order_id) AS orders,
    COUNT(DISTINCT ods.order_id)/COUNT(DISTINCT wss.website_session_id) * 100 AS session_to_order_conv_rt
FROM website_sessions AS wss
LEFT JOIN orders AS ods
	ON ods.website_session_id = wss.website_session_id 
WHERE 
	DATE(wss.created_at) < '2012-04-14'
    AND wss.utm_source = 'gsearch'
    AND wss.utm_campaign = 'nonbrand'
;