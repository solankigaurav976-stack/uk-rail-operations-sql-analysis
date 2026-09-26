-- UK Rail Operations Performance Analysis
-- Trend Analysis
-- Source: Office of Rail and Road (ORR) Table 3124


-- 1. Cancellation rate by reporting period

SELECT
    time_period,
    COUNT(*) AS operators_reporting,
    ROUND(
        AVG(periodic_cancellation_percentage),
        2
    ) AS average_cancellation_rate,
    ROUND(
        MIN(periodic_cancellation_percentage),
        2
    ) AS lowest_operator_rate,
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
ORDER BY time_period;


-- 2. Period-on-period change using LAG()

WITH period_performance AS (
    SELECT
        time_period,
        ROUND(
            AVG(periodic_cancellation_percentage),
            2
        ) AS average_cancellation_rate
    FROM rail_cancellations
    WHERE periodic_cancellation_percentage IS NOT NULL
      AND national_or_operator NOT IN (
          'Great Britain',
          'England and Wales',
          'Scotland'
      )
    GROUP BY time_period
),

period_changes AS (
    SELECT
        time_period,
        average_cancellation_rate,

        LAG(average_cancellation_rate) OVER (
            ORDER BY time_period
        ) AS previous_period_rate

    FROM period_performance
)

SELECT
    time_period,
    average_cancellation_rate,
    previous_period_rate,

    ROUND(
        average_cancellation_rate
        - previous_period_rate,
        2
    ) AS change_from_previous_period

FROM period_changes
ORDER BY time_period;


-- 3. Largest increases between reporting periods

WITH period_performance AS (
    SELECT
        time_period,
        ROUND(
            AVG(periodic_cancellation_percentage),
            2
        ) AS average_cancellation_rate
    FROM rail_cancellations
    WHERE periodic_cancellation_percentage IS NOT NULL
      AND national_or_operator NOT IN (
          'Great Britain',
          'England and Wales',
          'Scotland'
      )
    GROUP BY time_period
),

period_changes AS (
    SELECT
        time_period,
        average_cancellation_rate,

        LAG(average_cancellation_rate) OVER (
            ORDER BY time_period
        ) AS previous_period_rate

    FROM period_performance
)

SELECT
    time_period,
    average_cancellation_rate,
    previous_period_rate,

    ROUND(
        average_cancellation_rate
        - previous_period_rate,
        2
    ) AS change_from_previous_period

FROM period_changes
WHERE previous_period_rate IS NOT NULL
ORDER BY change_from_previous_period DESC
LIMIT 10;


-- 4. Largest decreases between reporting periods

WITH period_performance AS (
    SELECT
        time_period,
        ROUND(
            AVG(periodic_cancellation_percentage),
            2
        ) AS average_cancellation_rate
    FROM rail_cancellations
    WHERE periodic_cancellation_percentage IS NOT NULL
      AND national_or_operator NOT IN (
          'Great Britain',
          'England and Wales',
          'Scotland'
      )
    GROUP BY time_period
),

period_changes AS (
    SELECT
        time_period,
        average_cancellation_rate,

        LAG(average_cancellation_rate) OVER (
            ORDER BY time_period
        ) AS previous_period_rate

    FROM period_performance
)

SELECT
    time_period,
    average_cancellation_rate,
    previous_period_rate,

    ROUND(
        average_cancellation_rate
        - previous_period_rate,
        2
    ) AS change_from_previous_period

FROM period_changes
WHERE previous_period_rate IS NOT NULL
ORDER BY change_from_previous_period ASC
LIMIT 10;
