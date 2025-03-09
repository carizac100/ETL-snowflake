{{ config(materialized='table') }}

WITH customers_src AS (
  SELECT
    id AS customer_id,
    name AS customer_name
  FROM {{ source('JAFFLE_SHOP', 'CUSTOMERS') }}
),
orders_src AS (
  SELECT
    id AS order_id,
    user_id AS customer_id,
    order_date,
    status
  FROM {{ source('JAFFLE_SHOP', 'ORDERS') }}
),
customer_orders AS (
  SELECT
    customer_id,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS most_recent_order_date,
    COUNT(order_id) AS number_of_orders
  FROM orders_src
  GROUP BY customer_id
),
final AS (
  SELECT
    cs.customer_id,
    cs.customer_name,
    co.first_order_date,
    co.most_recent_order_date,
    COALESCE(co.number_of_orders, 0) AS number_of_orders
  FROM customers_src AS cs
  LEFT JOIN customer_orders AS co ON cs.customer_id = co.customer_id
)

SELECT * FROM final;
