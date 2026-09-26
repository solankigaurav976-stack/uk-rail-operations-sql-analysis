-- UK Rail Operations Performance Analysis
-- Data Cleaning & Preparation
-- Source: Office of Rail and Road (ORR) Table 3124


-- Raw staging table

CREATE TABLE rail_cancellations_raw (
    time_period TEXT,
    national_or_operator TEXT,
    trains_planned TEXT,
    trains_part_cancelled TEXT,
    trains_full_cancelled TEXT,
    cancellation_number TEXT,
    infrastructure_network_management TEXT,
    infrastructure_owner_external_event TEXT,
    train_operator_fault TEXT,
    operator_external_event TEXT,
    periodic_cancellation_percentage TEXT,
    moving_annual_average_percentage TEXT
);


-- Analytical table

CREATE TABLE rail_cancellations (
    time_period TEXT,
    national_or_operator TEXT,
    trains_planned INTEGER,
    trains_part_cancelled INTEGER,
    trains_full_cancelled INTEGER,
    cancellation_number NUMERIC,
    infrastructure_network_management NUMERIC,
    infrastructure_owner_external_event NUMERIC,
    train_operator_fault NUMERIC,
    operator_external_event NUMERIC,
    periodic_cancellation_percentage NUMERIC,
    moving_annual_average_percentage NUMERIC
);


-- Convert source [z] values to NULL
-- and cast fields to analytical data types.

INSERT INTO rail_cancellations
SELECT
    time_period,
    national_or_operator,

    NULLIF(NULLIF(TRIM(trains_planned), '[z]'), '')::INTEGER,
    NULLIF(NULLIF(TRIM(trains_part_cancelled), '[z]'), '')::INTEGER,
    NULLIF(NULLIF(TRIM(trains_full_cancelled), '[z]'), '')::INTEGER,

    NULLIF(NULLIF(TRIM(cancellation_number), '[z]'), '')::NUMERIC,
    NULLIF(NULLIF(TRIM(infrastructure_network_management), '[z]'), '')::NUMERIC,
    NULLIF(NULLIF(TRIM(infrastructure_owner_external_event), '[z]'), '')::NUMERIC,
    NULLIF(NULLIF(TRIM(train_operator_fault), '[z]'), '')::NUMERIC,
    NULLIF(NULLIF(TRIM(operator_external_event), '[z]'), '')::NUMERIC,

    NULLIF(NULLIF(TRIM(periodic_cancellation_percentage), '[z]'), '')::NUMERIC,
    NULLIF(NULLIF(TRIM(moving_annual_average_percentage), '[z]'), '')::NUMERIC

FROM rail_cancellations_raw;
