SELECT
	DATE_TRUNC('week', ordered.status_date) week,
	AVG(DATE_PART('day', distribution.status_date::timestamp - 
			   			ordered.status_date::timestamp) * 24 +
	 DATE_PART('hour', distribution.status_date::timestamp -
			  			ordered.status_date::timestamp) * 60 +
	 DATE_PART('minute', distribution.status_date::timestamp -
			  				ordered.status_date::timestamp)) avg_ordered_to_distribution,
	AVG(DATE_PART('day', completed.status_date::timestamp - 
			   			distribution.status_date::timestamp) * 24 +
	 DATE_PART('hour', completed.status_date::timestamp -
			  			distribution.status_date::timestamp) * 60 +
	 DATE_PART('minute', completed.status_date::timestamp -
			  				distribution.status_date::timestamp)) avg_distribution_to_complete
FROM
	(SELECT
		*
	FROM
		order_status
	WHERE
		status = 'completed') AS completed,
	(SELECT 
		*
	FROM
		order_status
	WHERE
		status = 'distribution') AS distribution,
	(SELECT
		*
	FROM
		order_status
	WHERE
		status = 'ordered') AS ordered
WHERE
	completed.order_brands_id = distribution.order_brands_id
	AND distribution.order_brands_id = ordered.order_brands_id
GROUP BY week;