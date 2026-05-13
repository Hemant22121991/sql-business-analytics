-- creating temporary tables

SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY 1
ORDER BY pvs DESC
;


CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY 1
;

SELECT
	-- fp.website_session_id,
    wp.pageview_url AS landing_page, -- aka "entry page"
    COUNT(DISTINCT fp.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview AS fp
LEFT JOIN website_pageviews AS wp
 ON fp.min_pv_id = wp.website_pageview_id
GROUP BY 1
;


-- Assingnment - 01
-- Problem: Find out most-viewed website pages, ranked by session volume

SELECT 
	pageview_url,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC
;

 -- Outcome : home, products and the-original-mr-fuzzy pages are getting most of the traffic
 -- dig more about other pages if they need more work
 
 
 -- Assingnment - 01
-- Problem : Pull all entry pages and rank them on entry volume

CREATE TEMPORARY TABLE first_pagevw
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 1
;

SELECT
    wp.pageview_url AS landing_page, -- aka "entry page"
    COUNT(DISTINCT fp.website_session_id) AS sessions_hitting_this_landing_page
FROM first_pagevw AS fp
LEFT JOIN website_pageviews AS wp
 ON fp.min_pv_id = wp.website_pageview_id
WHERE wp.created_at < '2012-06-12'
GROUP BY 1
;

-- Output: home page have is obviously the most landing page. This need to be the best to increase traffic
