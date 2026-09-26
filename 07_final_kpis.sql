-- UK Rail Operations Performance Analysis
-- Final KPI Summary
-- Source: Office of Rail and Road (ORR) Table 3124


-- 1. Overall dataset KPIs

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT national_or_operator)
        AS total_operators_and_aggregates,

    COUNT(DISTINCT time_period)
        AS reporting_periods,

    SUM(trains_planned)
        AS total_trains_planned,

    ROUND(
        SUM(cancellation_number),
        2
    ) AS total_cancellation_score

FROM rail_cancellations;


-- 2. Overall operator cancellation KPI

SELECT
    ROUND(
        SUM(cancellation_number)
        / NULLIF(SUM(trains_planned), 0)
        * 100,
        2
    ) AS overall_cancellation_rate

FROM rail_cancellations

WHERE national_or_operator NOT IN (
    'Great Britain',
    'England and Wales',
    'Scotland'
);


-- 3. Top operators by cancellation rate

SELECT
    national_or_operator AS operator,

    SUM(trains_planned)
        AS trains_planned,

    ROUND(
        SUM(cancellation_number),
        2
    ) AS cancellation_score,

    ROUND(
        SUM(cancellation_number)
        / NULLIF(SUM(trains_planned), 0)
        * 100,
        2
    ) AS cancellation_rate

FROM rail_cancellations

WHERE national_or_operator NOT IN (
    'Great Britain',
    'England and Wales',
    'Scotland'
)

GROUP BY national_or_operator

HAVING SUM(trains_planned) >= 100000

ORDER BY cancellation_rate DESC

LIMIT 10;


-- 4. Cancellation causes

WITH cancellation_causes AS (

    SELECT
        'Train Operator Fault' AS cancellation_cause,
        SUM(train_operator_fault) AS cancellation_score

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )

    UNION ALL

    SELECT
        'Infrastructure & Network Management',
        SUM(infrastructure_network_management)

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )

    UNION ALL

    SELECT
        'Infrastructure Owner External Event',
        SUM(infrastructure_owner_external_event)

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )

    UNION ALL

    SELECT
        'Operator External Event',
        SUM(operator_external_event)

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )
)

SELECT
    cancellation_cause,

    ROUND(
        cancellation_score,
        2
    ) AS cancellation_score,

    ROUND(
        cancellation_score
        / SUM(cancellation_score) OVER ()
        * 100,
        2
    ) AS percentage_of_total

FROM cancellation_causes

ORDER BY percentage_of_total DESC;


-- 5. Highest cancellation period

SELECT
    time_period,

    ROUND(
        AVG(periodic_cancellation_percentage),
        2
    ) AS average_cancellation_rate,

    ROUND(
        MAX(periodic_cancellation_percentage),
        2
    ) AS highest_operator_rate

FROM rail_cancellations

WHERE periodic_cancellation_percentage IS NOT NULL

  AND national_or_operator NOT IN (
      'Great Britain',
      'England and Wales',
      'Scotland'
  )

GROUP BY time_period

ORDER BY average_cancellation_rate DESC

LIMIT 10;
