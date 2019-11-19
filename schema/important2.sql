SELECT 
	DATE_TRUNC('week', orders.status_date) week, orders.status status_order,
	AVG(CASE WHEN orders.status = 'completed' 
		THEN (EXTRACT(EPOCH FROM (completed.status_date::timestamp - distribution .status_date::timestamp)) / 60)
		ELSE (EXTRACT(EPOCH FROM (distribution.status_date::timestamp - ordered.status_date::timestamp)) / 60)
	END) AS time_to_current
FROM 
	order_status as orders,
	(SELECT
		order_brands_id, status_date
	FROM
		order_status
	WHERE
		status = 'ordered') as ordered,
	(SELECT
		order_brands_id, status_date
	FROM
		order_status
	WHERE
		status = 'distribution') as distribution,
	(SELECT
		order_brands_id, status_date
	FROM
		order_status
	WHERE
		status = 'completed') as completed
WHERE orders.status in ('distribution', 'completed')
AND orders.order_brands_id = ordered.order_brands_id
AND orders.order_brands_id = distribution.order_brands_id
AND orders.order_brands_id = completed.order_brands_id
GROUP BY week, status_order
ORDER BY week;