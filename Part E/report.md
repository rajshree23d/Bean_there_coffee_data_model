# Part E – Design-decision Answers
## Bean There, Modeled That

### 1. Data Model Selection

A dimensional data model was selected for the Gold layer to support business intelligence, reporting, and analytical requirements for the coffee shop business. The model organizes data into dimension tables, fact tables, and supporting tables. This structure separates descriptive business attributes from measurable business transactions and allows users to analyze sales, customer behavior, product performance, employee productivity, and inventory operations. Shared dimensions such as date, time, store, employee, and customer provide consistency across different business processes.

### 2. Dimension Table Design

The model includes eight dimension tables: `dim_date`, `dim_time`, `dim_store`, `dim_employee`, `dim_customer`, `dim_customer_tier`, `dim_product`, and `dim_ingredient`. These tables store descriptive attributes that provide context for analyzing business transactions. For example, `dim_store` contains store location and operational details, while `dim_product` contains product names, categories, and lifecycle information. Separate dimensions for customers and customer tiers allow customer-related information and loyalty-tier history to be analyzed independently.

### 3. Fact Table Grain

Each fact table was designed with a clearly defined grain to ensure that measures are aggregated consistently and double counting is minimized. `Orders_fact` stores one record per customer order, while `fact_sales` stores one record per POS order item. `fact_loyalty_transactions` represents one loyalty transaction, `fact_employee_shifts` represents one employee shift, and `fact_inventory_waste` represents one inventory waste event. The historical fact tables store one record per ingredient-cost or product-price effective period. Defining the grain separately for each business process allows the model to support both detailed and summarized reporting.

### 4. Surrogate Keys and Business Keys

Integer surrogate keys, such as `store_key`, `product_key`, `employee_key`, and `customer_key`, are used as primary keys in the dimension and fact tables. These keys provide consistent identifiers for relationships between tables and reduce dependency on source-system identifiers. Original business identifiers, such as `store_id`, `product_id`, and `employee_id`, are retained as attributes to preserve traceability to the Bronze source data. This design also provides flexibility when source-system business identifiers change.

### 5. Date and Time Dimensions

Separate `dim_date` and `dim_time` tables were introduced to support flexible time-based analysis. The date dimension contains attributes such as day, day name, week number, month, quarter, year, and weekend indicator. The time dimension contains hour, minute, AM/PM, and day-period attributes. This separation supports reporting on daily and seasonal sales trends, peak business hours, customer purchasing patterns, and employee staffing requirements without repeatedly deriving these attributes from transaction timestamps.

### 6. Supporting Tables and Relationships

The model includes `recipes` and `promo_codes` as supporting tables. The `recipes` table connects products and ingredients through their respective surrogate keys and includes product size and ingredient quantity information. This structure supports recipe-level ingredient analysis and theoretical cost calculations. The `promo_codes` table stores promotion reference attributes such as discount type, discount value, and effective dates. Keeping these attributes in a separate reference table avoids repeating promotion descriptions and rules across individual sales transactions.

### 7. Historical Data Management

Historical tracking was included to support analysis of changes in product prices, ingredient costs, and customer loyalty tiers over time. The `fact_product_price_history` and `fact_ingredient_cost_history` tables maintain effective dates, end dates, and historical values. The `dim_customer_tier` table maintains customer tier information across effective periods. This design allows historical reporting to use the values applicable during the relevant business period instead of relying exclusively on current master-data values.

### 8. Data Types and Constraints

Appropriate data types were selected based on the nature of each attribute. Integer data types are used for surrogate keys and count-based attributes, while `DECIMAL` is used for financial values and ingredient quantities to preserve numeric precision. `DATE` and `TIMESTAMP` are used for calendar dates and transaction timestamps, while `BOOLEAN` is used for indicators such as `is_weekend`, `is_guest`, and `has_drive_thru`. Primary key and foreign key constraints document the intended relationships between tables, while `NOT NULL` constraints identify attributes that are required for the model to function correctly.

### 9. Audit Columns

The Gold tables include `created_at` and `updated_at` audit columns to support data lineage and operational monitoring. These fields capture when records are initially created and subsequently updated during data loading or transformation. They provide useful information for troubleshooting, tracking data changes, and monitoring the Gold layer loading process.

### 10. Technology Selection

Databricks Delta Lake was selected for the Gold layer because it integrates with the existing Databricks data-processing environment and supports reliable analytical data storage. Delta tables provide transactional capabilities and schema management, making them suitable for structured data transformation and reporting workloads. The Gold layer can therefore serve as a consistent source for downstream analytics and visualization tools such as Power BI, Tableau, and Databricks SQL.

### 11. Data Quality and Referential Integrity

Data quality is considered an important part of the physical model design. The model establishes primary and foreign key relationships to define how business entities and transactions are connected. During transformation and validation, source records will be checked for duplicates, missing values, inconsistent formats, invalid numeric values, and orphaned references. Data-quality issues will be handled according to the defect log documented in Part B. Additional validation queries will be used to verify record counts, financial totals, and relationships between Bronze and Gold data.

---

## Design Assumptions

The following assumptions are considered as part of the physical model design and should be validated against the available source data:

1. Date and time dimension records will be generated for the required reporting period and time granularity.
2. Guest transactions may have a NULL customer identifier, which is why `customer_key` is nullable in the order and sales fact tables.
3. Historical ingredient costs and product prices require effective-dated source records. Current values alone are insufficient to reconstruct historical changes.
4. Promotion descriptions, discount types, discount values, and effective dates require a promotion reference source.
5. Customer tier history will be matched to loyalty transactions using the tier effective period.
6. Dimension surrogate keys will be generated during Gold-layer loading, and source business identifiers will be retained for traceability.
