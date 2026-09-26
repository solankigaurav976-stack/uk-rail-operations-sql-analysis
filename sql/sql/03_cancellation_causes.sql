-- UK Rail Operations Performance Analysis
-- Cancellation Cause Analysis
-- Source: Office of Rail and Road (ORR) Table 3124


-- 1. Cancellation causes across all operators

SELECT
    cancellation_cause,
    ROUND(cancellation_score, 2) AS cancellation_score

FROM (

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

) AS cancellation_causes

ORDER BY cancellation_score DESC;


-- 2. Percentage contribution of each cancellation cause

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
        / SUM(cancellation_score) OVER () * 100,
        2
    ) AS percentage_of_total

FROM cancellation_causes

ORDER BY percentage_of_total DESC;


-- 3. Main cancellation cause by operator

WITH operator_causes AS (

    SELECT
        national_or_operator AS operator,
        'Train Operator Fault' AS cancellation_cause,
        SUM(train_operator_fault) AS cancellation_score

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )

    GROUP BY national_or_operator


    UNION ALL


    SELECT
        national_or_operator,
        'Infrastructure & Network Management',
        SUM(infrastructure_network_management)

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )

    GROUP BY national_or_operator


    UNION ALL


    SELECT
        national_or_operator,
        'Infrastructure Owner External Event',
        SUM(infrastructure_owner_external_event)

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )

    GROUP BY national_or_operator


    UNION ALL


    SELECT
        national_or_operator,
        'Operator External Event',
        SUM(operator_external_event)

    FROM rail_cancellations

    WHERE national_or_operator NOT IN (
        'Great Britain',
        'England and Wales',
        'Scotland'
    )

    GROUP BY national_or_operator
),

ranked_causes AS (

    SELECT
        operator,
        cancellation_cause,
        cancellation_score,

        RANK() OVER (
            PARTITION BY operator
            ORDER BY cancellation_score DESC
        ) AS cause_rank

    FROM operator_causes
)

SELECT
    operator,
    cancellation_cause AS main_cancellation_cause,
    ROUND(cancellation_score, 2) AS cancellation_score

FROM ranked_causes

WHERE cause_rank = 1

ORDER BY cancellation_score DESC;
