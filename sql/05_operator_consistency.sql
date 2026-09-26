-- UK Rail Operations Performance Analysis
-- Operator Consistency Analysis
-- Source: Office of Rail and Road (ORR) Table 3124


-- 1. Operator performance consistency
-- Measures average rate, variability and frequency of periods
-- where cancellation rate exceeded 5%.

WITH operator_metrics AS (
    SELECT
        national_or_operator AS operator,

        COUNT(periodic_cancellation_percentage)
            AS reporting_periods,

        ROUND(
            AVG(periodic_cancellation_percentage),
            2
        ) AS average_rate,

        ROUND(
            STDDEV(periodic_cancellation_percentage),
            2
        ) AS rate_variability,

        COUNT(*) FILTER (
            WHERE periodic_cancellation_percentage > 5
        ) AS periods_above_5_percent

    FROM rail_cancellations

    WHERE periodic_cancellation_percentage IS NOT NULL
      AND national_or_operator NOT IN (
          'Great Britain',
          'England and Wales',
          'Scotland'
      )

    GROUP BY national_or_operator

    HAVING COUNT(periodic_cancellation_percentage) >= 10
)

SELECT
    operator,
    reporting_periods,
    average_rate,
    rate_variability,
    periods_above_5_percent,

    ROUND(
        periods_above_5_percent::NUMERIC
        / reporting_periods * 100,
        2
    ) AS percentage_periods_above_5

FROM operator_metrics

ORDER BY
    percentage_periods_above_5 DESC,
    average_rate DESC;


-- 2. Peak cancellation rate for each operator

WITH ranked_periods AS (
    SELECT
        national_or_operator AS operator,
        time_period,
        periodic_cancellation_percentage AS cancellation_rate,

        RANK() OVER (
            PARTITION BY national_or_operator
            ORDER BY periodic_cancellation_percentage DESC
        ) AS rate_rank

    FROM rail_cancellations

    WHERE periodic_cancellation_percentage IS NOT NULL
      AND national_or_operator NOT IN (
          'Great Britain',
          'England and Wales',
          'Scotland'
      )
)

SELECT
    operator,
    time_period,

    ROUND(
        cancellation_rate,
        2
    ) AS peak_cancellation_rate

FROM ranked_periods

WHERE rate_rank = 1

ORDER BY peak_cancellation_rate DESC;


-- 3. Operators with the most reporting periods above 5%

SELECT
    national_or_operator AS operator,

    COUNT(*) FILTER (
        WHERE periodic_cancellation_percentage > 5
    ) AS periods_above_5_percent,

    COUNT(periodic_cancellation_percentage)
        AS reporting_periods,

    ROUND(
        COUNT(*) FILTER (
            WHERE periodic_cancellation_percentage > 5
        )::NUMERIC
        / COUNT(periodic_cancellation_percentage) * 100,
        2
    ) AS percentage_periods_above_5

FROM rail_cancellations

WHERE periodic_cancellation_percentage IS NOT NULL
  AND national_or_operator NOT IN (
      'Great Britain',
      'England and Wales',
      'Scotland'
  )

GROUP BY national_or_operator

HAVING COUNT(periodic_cancellation_percentage) >= 10

ORDER BY percentage_periods_above_5 DESC;
