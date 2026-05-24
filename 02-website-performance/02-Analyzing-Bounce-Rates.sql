-- BUSINESS CONTEXT: We want to see landing page performance for a cetain time period

-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identify the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounced sessions, by LP

-- finding the minimum website pageview id associated with each session we care about

SELECT
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp
INNER JOIN website_sessions AS ws
	ON wp.website_session_id = ws.website_session_id
    AND ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
	wp.website_session_id
;

-- same query as above, but storing it as temporary table

CREATE TEMPORARY TABLE first_pageviews_demo
SELECT
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp
INNER JOIN website_sessions AS ws
	ON wp.website_session_id = ws.website_session_id
    AND ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
	wp.website_session_id
;


-- next, we will bring in the langing page to each session


CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT
	fpd.website_session_id,
    wp.pageview_url AS landing_page
FROM first_pageviews_demo AS fpd
LEFT JOIN website_pageviews AS wp
	ON wp.website_pageview_id = fpd.min_pageview_id -- website pageview is the landing page view
;

-- next, we make a table to include a count of pageviews per session

-- first, I will show all the sessions. Then we will limit to bounced sessions and create a temp table

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
	slp.website_session_id,
    slp.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page_demo AS slp
LEFT JOIN website_pageviews AS wp
	ON wp.website_session_id = slp.website_session_id
GROUP BY
	slp.website_session_id,
    slp.landing_page
HAVING
	COUNT(wp.website_pageview_id) = 1
;


SELECT
	slp.landing_page,
    slp.website_session_id,
    bso.website_session_id AS bounced_website_session_id
FROM sessions_w_landing_page_demo AS slp
LEFT JOIN bounced_sessions_only AS bso
	ON slp.website_session_id = bso.website_session_id
ORDER BY
	slp.website_session_id
;


-- final output
-- we will use the same query we previously ran and run a count of records
-- we will group by landing page, and then we'll add a bounce rate column

SELECT
	slp.landing_page,
    COUNT(DISTINCT slp.website_session_id) AS sessions,
    COUNT(DISTINCT bso.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bso.website_session_id)/COUNT(DISTINCT slp.website_session_id) AS bounced_rate
FROM sessions_w_landing_page_demo AS slp
LEFT JOIN bounced_sessions_only AS bso
	ON slp.website_session_id = bso.website_session_id
GROUP BY 
	slp.landing_page
ORDER BY
	sessions DESC
;

-- Assignment - 01
-- Problem: Show bounce rates for traffic landing on the homepage. 
-- Show sessions, bonced sessions and bounce rate. keep date range below '2012-06-14'


CREATE TEMPORARY TABLE first_pageviews AS 
SELECT
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp
INNER JOIN website_sessions AS ws
	ON wp.website_session_id = ws.website_session_id
    AND ws.created_at < '2012-06-14'
GROUP BY
	wp.website_session_id
;


-- next, we will bring in the langing page to each session

DROP TEMPORARY TABLE IF EXISTS sessions_w_landing_page;
CREATE TEMPORARY TABLE sessions_w_landing_page AS
SELECT
	fpd.website_session_id,
    wp.pageview_url AS landing_page
FROM first_pageviews AS fpd
LEFT JOIN website_pageviews AS wp
	ON wp.website_pageview_id = fpd.min_pageview_id -- website pageview is the landing page view
WHERE wp.pageview_url = "/home"
;

-- next, we make a table to include a count of pageviews per session

-- first, I will show all the sessions. Then we will limit to bounced sessions and create a temp table

DROP TEMPORARY TABLE IF EXISTS bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions AS
SELECT
	slp.website_session_id,
    slp.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page AS slp
LEFT JOIN website_pageviews AS wp
	ON wp.website_session_id = slp.website_session_id
GROUP BY
	slp.website_session_id,
    slp.landing_page
HAVING
	COUNT(wp.website_pageview_id) = 1
;


SELECT
	slp.landing_page,
    slp.website_session_id,
    bso.website_session_id AS bounced_website_session_id
FROM sessions_w_landing_page AS slp
LEFT JOIN bounced_sessions AS bso
	ON slp.website_session_id = bso.website_session_id
ORDER BY
	slp.website_session_id
;


-- final output
-- we will use the same query we previously ran and run a count of records
-- we will group by landing page, and then we'll add a bounce rate column

SELECT
	slp.landing_page,
    COUNT(DISTINCT slp.website_session_id) AS sessions,
    COUNT(DISTINCT bso.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bso.website_session_id)/COUNT(DISTINCT slp.website_session_id) AS bounced_rate
FROM sessions_w_landing_page AS slp
LEFT JOIN bounced_sessions AS bso
	ON slp.website_session_id = bso.website_session_id
GROUP BY 
	slp.landing_page
ORDER BY
	sessions DESC
;

-- output: high bounce rate of ~ 60%

-- Assingment - 02:
-- Problem: show bounce rates for '/home' and '/lander-01'.
-- need to show time period where '/lander-1' was getting traffic

-- solution steps:
-- STEP 0: finding out when the new page /lander launched
-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounced sessions, by LP

SELECT
	MIN(created_At) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE 
	pageview_url = '/lander-1' AND
    created_at IS NOT NULL
;

-- first_created_at = '2012-06-19 00:35:54'
-- first_pageview_id = '23504'

DROP TEMPORARY TABLE IF EXISTS first_pageviews;
CREATE TEMPORARY TABLE first_pageviews AS 
SELECT
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp
INNER JOIN website_sessions AS ws
	ON wp.website_session_id = ws.website_session_id
    AND ws.created_at < '2012-07-28' -- prescribed by the assignement
    AND wp.website_pageview_id > 23504 -- the min_pageview_id we found for '\lander-1'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	wp.website_session_id
;


DROP TEMPORARY TABLE IF EXISTS sessions_w_landing_page;
CREATE TEMPORARY TABLE sessions_w_landing_page AS
SELECT
	fpd.website_session_id,
    wp.pageview_url AS landing_page
FROM first_pageviews AS fpd
LEFT JOIN website_pageviews AS wp
	ON wp.website_pageview_id = fpd.min_pageview_id -- website pageview is the landing page view
WHERE wp.pageview_url IN ("/home",'/lander-1')
;


DROP TEMPORARY TABLE IF EXISTS bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions AS
SELECT
	slp.website_session_id,
    slp.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page AS slp
LEFT JOIN website_pageviews AS wp
	ON wp.website_session_id = slp.website_session_id
GROUP BY
	slp.website_session_id,
    slp.landing_page
HAVING
	COUNT(wp.website_pageview_id) = 1
;


SELECT
	slp.landing_page,
    slp.website_session_id,
    bso.website_session_id AS bounced_website_session_id
FROM sessions_w_landing_page AS slp
LEFT JOIN bounced_sessions AS bso
	ON slp.website_session_id = bso.website_session_id
ORDER BY
	slp.website_session_id
;


SELECT
	slp.landing_page,
    COUNT(DISTINCT slp.website_session_id) AS sessions,
    COUNT(DISTINCT bso.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bso.website_session_id)/COUNT(DISTINCT slp.website_session_id) AS bounced_rate
FROM sessions_w_landing_page AS slp
LEFT JOIN bounced_sessions AS bso
	ON slp.website_session_id = bso.website_session_id
GROUP BY 
	slp.landing_page
ORDER BY
	sessions DESC
;

-- result: '/lander-1' perform well by ~5% in terms of bounced rate then '/home' for same traffic


-- Assignment - 03
-- Problem: Show volume of paid search nonbrand traffic on '/home' and '/lander-1' trended by weekly since June - 2012
-- Also show overall paid search bounce rate trended weekly?

-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing by week (bounce rate, sessions to each lander)


CREATE TEMPORARY TABLE session_w_min_pv_id_and_view_count AS
SELECT
	ws.website_session_id,
    MIN(wp.website_pageview_id) AS first_pageview_id,
    COUNT(wp.website_pageview_id) AS count_pageviews
    
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id = wp.website_session_id
    
WHERE
	ws.created_at > '2012-06-01'
    AND ws.created_at < '2012-08-31'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    
GROUP BY
	ws.website_session_id
;

CREATE TEMPORARY TABLE session_w_counts_lander_and_created_at AS
SELECT
	swc.website_session_id,
    swc.first_pageview_id,
    swc.count_pageviews,
    wp.pageview_url AS landing_page,
    wp.created_at AS session_created_at
FROM session_w_min_pv_id_and_view_count AS swc
LEFT JOIN website_pageviews AS wp
	ON swc.first_pageview_id = wp.website_pageview_id
;

SELECT
	-- YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
    -- COUNT(DISTINCT website_session_id) AS total_sessions,
    -- COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) * 1.0/COUNT(DISTINCT website_session_id) AS bounce_rate,
	COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM 
	session_w_counts_lander_and_created_at
GROUP BY
	YEARWEEK(session_created_at)
;


-- result : custom lander page showed improvement and showed less bounce rate compared to '/home' page