-- =============================================================================
-- BEAN THERE, MODELED THAT
-- PART D - GOLD LAYER PHYSICAL MODEL
-- Databricks SQL / Delta Lake

USE CATALOG labs_rajshreerajendradeshmukh;

CREATE SCHEMA IF NOT EXISTS gold;
USE SCHEMA gold;

-- =============================================================================
-- 1. DIMENSIONS
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_date (
    date_key       INT NOT NULL,
    full_date      DATE NOT NULL,
    day            INT,
    day_name       STRING,
    week_number    INT,
    month          INT,
    month_name     STRING,
    quarter        INT,
    year           INT,
    is_weekend     BOOLEAN,
    created_at     TIMESTAMP,
    updated_at     TIMESTAMP,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
)
USING DELTA
COMMENT 'Calendar date dimension';

CREATE TABLE IF NOT EXISTS dim_time (
    time_key       INT NOT NULL,
    full_time      STRING NOT NULL,
    hour           INT,
    minute         INT,
    am_pm          STRING,
    day_period     STRING,
    created_at     TIMESTAMP,
    updated_at     TIMESTAMP,
    CONSTRAINT pk_dim_time PRIMARY KEY (time_key)
)
USING DELTA
COMMENT 'Time-of-day dimension';

CREATE TABLE IF NOT EXISTS dim_store (
    store_key        INT NOT NULL,
    store_id         STRING NOT NULL,
    store_name       STRING NOT NULL,
    city             STRING,
    state            STRING,
    zip              STRING,
    region           STRING,
    open_date        DATE,
    square_footage   INT,
    has_drive_thru   BOOLEAN,
    created_at       TIMESTAMP,
    updated_at       TIMESTAMP,
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
)
USING DELTA
COMMENT 'Store dimension';

CREATE TABLE IF NOT EXISTS dim_employee (
    employee_key      INT NOT NULL,
    employee_id       STRING NOT NULL,
    first_name        STRING,
    last_name         STRING,
    hire_date         DATE,
    termination_date  DATE,
    role              STRING,
    home_store_id     STRING,
    hourly_rate       DECIMAL(12,2),
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,
    CONSTRAINT pk_dim_employee PRIMARY KEY (employee_key)
)
USING DELTA
COMMENT 'Employee dimension';

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key      INT NOT NULL,
    customer_id       STRING,
    first_name        STRING,
    last_name         STRING,
    signup_date       DATE,
    signup_store_id   STRING,
    current_tier      STRING,
    is_guest          BOOLEAN NOT NULL,
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,
    CONSTRAINT pk_dim_customer PRIMARY KEY (customer_key)
)
USING DELTA
COMMENT 'Customer dimension';

CREATE TABLE IF NOT EXISTS dim_customer_tier (
    customer_tier_key  INT NOT NULL,
    customer_id        STRING NOT NULL,
    tier               STRING NOT NULL,
    effective_date     DATE NOT NULL,
    end_date           DATE,
    created_at         TIMESTAMP,
    updated_at         TIMESTAMP,
    CONSTRAINT pk_dim_customer_tier PRIMARY KEY (customer_tier_key)
)
USING DELTA
COMMENT 'Customer-Tier dimension';

CREATE TABLE IF NOT EXISTS dim_product (
    product_key         INT NOT NULL,
    product_id          STRING NOT NULL,
    product_name        STRING NOT NULL,
    category            STRING,
    subcategory         STRING,
    is_seasonal         BOOLEAN,
    launch_date         DATE,
    discontinued_date  DATE,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
)
USING DELTA
COMMENT 'Product dimension';

CREATE TABLE IF NOT EXISTS dim_ingredient (
    ingredient_key    INT NOT NULL,
    ingredient_id     STRING NOT NULL,
    ingredient_name   STRING NOT NULL,
    ingredient_type   STRING,
    unit_of_measure   STRING,
    supplier_id       STRING,
    unit_cost         DECIMAL(12,4),
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,
    CONSTRAINT pk_dim_ingredient PRIMARY KEY (ingredient_key)
)
USING DELTA
COMMENT 'Ingredient dimension';

-- =============================================================================
-- 2. SUPPORTING TABLES SHOWN IN THE ERD
-- =============================================================================

CREATE TABLE IF NOT EXISTS promo_codes (
    promotion_key   INT NOT NULL,
    promo_code      STRING NOT NULL,
    description     STRING,
    discount_type   STRING,
    discount_value  DECIMAL(12,2),
    start_date      DATE,
    end_date        DATE,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    CONSTRAINT pk_promo_codes PRIMARY KEY (promotion_key)
)
USING DELTA
COMMENT 'Promotion code reference table';

CREATE TABLE IF NOT EXISTS recipes (
    recipe_key       INT NOT NULL,
    product_key      INT NOT NULL,
    ingredient_key   INT NOT NULL,
    size             STRING,
    quantity_used    DECIMAL(12,4) NOT NULL,
    unit_of_measure  STRING,
    created_at       TIMESTAMP,
    updated_at       TIMESTAMP,
    CONSTRAINT pk_recipes PRIMARY KEY (recipe_key),
    CONSTRAINT fk_recipes_product
        FOREIGN KEY (product_key) REFERENCES dim_product (product_key),
    CONSTRAINT fk_recipes_ingredient
        FOREIGN KEY (ingredient_key) REFERENCES dim_ingredient (ingredient_key)
)
USING DELTA
COMMENT 'Product recipe bridge at product, size, and ingredient grain';

-- =============================================================================
-- 3. FACT TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS Orders_fact (
    order_key        INT NOT NULL,
    order_id         STRING NOT NULL,
    date_key         INT NOT NULL,
    time_key         INT NOT NULL,
    store_key        INT NOT NULL,
    employee_key     INT NOT NULL,
    customer_key     INT,
    subtotal         DECIMAL(12,2),
    discount_total   DECIMAL(12,2),
    tax              DECIMAL(12,2),
    tip              DECIMAL(12,2),
    order_channel    STRING,
    payment_method   STRING,
    created_at       TIMESTAMP,
    updated_at       TIMESTAMP,
    CONSTRAINT pk_orders_fact PRIMARY KEY (order_key),
    CONSTRAINT fk_orders_date
        FOREIGN KEY (date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_orders_time
        FOREIGN KEY (time_key) REFERENCES dim_time (time_key),
    CONSTRAINT fk_orders_store
        FOREIGN KEY (store_key) REFERENCES dim_store (store_key),
    CONSTRAINT fk_orders_employee
        FOREIGN KEY (employee_key) REFERENCES dim_employee (employee_key),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_key) REFERENCES dim_customer (customer_key)
)
USING DELTA
COMMENT 'Order fact table; one row per order';

CREATE TABLE IF NOT EXISTS fact_sales (
    sales_key       INT NOT NULL,
    order_item_id   STRING NOT NULL,
    order_id        STRING NOT NULL,
    date_key        INT NOT NULL,
    time_key        INT NOT NULL,
    store_key       INT NOT NULL,
    product_key     INT NOT NULL,
    employee_key    INT NOT NULL,
    customer_key    INT,
    quantity        INT NOT NULL,
    unit_price      DECIMAL(12,2) NOT NULL,
    gross_sales     DECIMAL(12,2),
    item_discount   DECIMAL(12,2),
    net_sales       DECIMAL(12,2),
    promo_code      STRING,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    CONSTRAINT pk_fact_sales PRIMARY KEY (sales_key),
    CONSTRAINT fk_sales_date
        FOREIGN KEY (date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_sales_time
        FOREIGN KEY (time_key) REFERENCES dim_time (time_key),
    CONSTRAINT fk_sales_store
        FOREIGN KEY (store_key) REFERENCES dim_store (store_key),
    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_key) REFERENCES dim_product (product_key),
    CONSTRAINT fk_sales_employee
        FOREIGN KEY (employee_key) REFERENCES dim_employee (employee_key),
    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_key) REFERENCES dim_customer (customer_key)
)
USING DELTA
COMMENT 'Sales line fact; one row per POS order item';

CREATE TABLE IF NOT EXISTS fact_loyalty_transactions (
    loyalty_txn_key    INT NOT NULL,
    loyalty_txn_id     STRING NOT NULL,
    customer_key       INT NOT NULL,
    customer_tier_key  INT NOT NULL,
    date_key           INT NOT NULL,
    order_id           STRING,
    txn_type           STRING,
    points             INT,
    created_at         TIMESTAMP,
    updated_at         TIMESTAMP,
    CONSTRAINT pk_fact_loyalty_transactions PRIMARY KEY (loyalty_txn_key),
    CONSTRAINT fk_loyalty_customer
        FOREIGN KEY (customer_key) REFERENCES dim_customer (customer_key),
    CONSTRAINT fk_loyalty_tier
        FOREIGN KEY (customer_tier_key) REFERENCES dim_customer_tier (customer_tier_key),
    CONSTRAINT fk_loyalty_date
        FOREIGN KEY (date_key) REFERENCES dim_date (date_key)
)
USING DELTA
COMMENT 'Loyalty transaction fact; one row per loyalty transaction';

CREATE TABLE IF NOT EXISTS fact_employee_shifts (
    shift_key            INT NOT NULL,
    shift_id             STRING NOT NULL,
    employee_key         INT NOT NULL,
    store_key            INT NOT NULL,
    date_key             INT NOT NULL,
    time_key             INT NOT NULL,
    shift_start          TIMESTAMP NOT NULL,
    shift_end            TIMESTAMP,
    hourly_rate_at_shift DECIMAL(12,2),
    created_at           TIMESTAMP,
    updated_at           TIMESTAMP,
    CONSTRAINT pk_fact_employee_shifts PRIMARY KEY (shift_key),
    CONSTRAINT fk_shifts_employee
        FOREIGN KEY (employee_key) REFERENCES dim_employee (employee_key),
    CONSTRAINT fk_shifts_store
        FOREIGN KEY (store_key) REFERENCES dim_store (store_key),
    CONSTRAINT fk_shifts_date
        FOREIGN KEY (date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_shifts_time
        FOREIGN KEY (time_key) REFERENCES dim_time (time_key)
)
USING DELTA
COMMENT 'Employee shift fact; one row per employee shift';

CREATE TABLE IF NOT EXISTS fact_inventory_waste (
    waste_key         INT NOT NULL,
    waste_id          STRING NOT NULL,
    date_key          INT NOT NULL,
    store_key         INT NOT NULL,
    ingredient_key    INT NOT NULL,
    quantity_wasted   DECIMAL(12,4) NOT NULL,
    waste_reason      STRING,
    unit_cost         DECIMAL(12,4),
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,
    CONSTRAINT pk_fact_inventory_waste PRIMARY KEY (waste_key),
    CONSTRAINT fk_waste_date
        FOREIGN KEY (date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_waste_store
        FOREIGN KEY (store_key) REFERENCES dim_store (store_key),
    CONSTRAINT fk_waste_ingredient
        FOREIGN KEY (ingredient_key) REFERENCES dim_ingredient (ingredient_key)
)
USING DELTA
COMMENT 'Inventory waste fact; one row per waste event';

CREATE TABLE IF NOT EXISTS fact_ingredient_cost_history (
    ingredient_cost_key  INT NOT NULL,
    ingredient_key       INT NOT NULL,
    effective_date       DATE NOT NULL,
    end_date             DATE,
    unit_cost            DECIMAL(12,4) NOT NULL,
    created_at           TIMESTAMP,
    updated_at           TIMESTAMP,
    CONSTRAINT pk_fact_ingredient_cost_history PRIMARY KEY (ingredient_cost_key),
    CONSTRAINT fk_ingredient_cost_ingredient
        FOREIGN KEY (ingredient_key) REFERENCES dim_ingredient (ingredient_key)
)
USING DELTA
COMMENT 'Ingredient cost history; one row per ingredient effective-cost period';

CREATE TABLE IF NOT EXISTS fact_product_price_history (
    product_price_key  INT NOT NULL,
    product_key        INT NOT NULL,
    effective_date     DATE NOT NULL,
    end_date           DATE,
    base_price         DECIMAL(12,2) NOT NULL,
    created_at         TIMESTAMP,
    updated_at         TIMESTAMP,
    CONSTRAINT pk_fact_product_price_history PRIMARY KEY (product_price_key),
    CONSTRAINT fk_product_price_product
        FOREIGN KEY (product_key) REFERENCES dim_product (product_key)
)
USING DELTA
COMMENT 'Product price history; one row per product effective-price period';

-- =============================================================================
-- 4. POST-CREATION CHECKS
-- =============================================================================

SHOW TABLES IN gold;

-- Inspect the structure of an individual table:
DESCRIBE TABLE dim_date;
DESCRIBE TABLE dim_time;
DESCRIBE TABLE Orders_fact;
DESCRIBE TABLE fact_sales;

-- Display the generated DDL for review:
SHOW CREATE TABLE fact_sales;

