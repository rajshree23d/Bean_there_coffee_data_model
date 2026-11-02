# Part A – Requirements Analysis & Bus Matrix

## 1. Introduction

### 1.1 Project Overview  
This phase's goal is to convert business requirements into an organized analytical framework that facilitates reporting and decision-making in a number of important business domains, such as workforce operations, inventory management, waste analysis, sales performance, product profitability, and customer loyalty.

### 1.2 Objectives
The primary objectives of the requirements analysis are to:
- Identify and organize the key business questions that stakeholders want to answer.
- Identify the business processes associated with each requirement.
- Define the measures and dimensions required to support business reporting.
- Map business questions to the relevant source datasets.
- Identify shared dimensions across business processes through a dimensional bus matrix.
- Document assumptions and data considerations that may influence the analytical model.


## 2. Requirements Analysis

The following requirements analysis maps the 14 business questions to their respective business processes, analytical measures, dimensions, and source datasets. This mapping establishes the data requirements needed to support business reporting and decision-making.

| ID | Business Question | Business Process | Measures | Dimensions | Source Tables |
|---|---|---|---|---|---|
| Q1 | What are total sales (revenue) by day, week, month, and year? | Sales | Gross sales, net sales, discounts, tax, total order value | Date, Store | `pos_orders`, `pos_order_items` |
| Q2 | Which products and product categories generate the most revenue and highest profit margin? | Sales & Product | Revenue, theoretical COGS, gross profit, profit margin | Product, Product Category, Date, Store, Ingredient | `pos_orders`, `pos_order_items`, `products`, `recipes`, `ingredients` |
| Q3 | How do sales compare across stores, cities, and regions? | Sales | Revenue, order count, units sold | Store, City, Region, Date | `pos_orders`, `pos_order_items`, `stores` |
| Q4 | What are the peak hours and days of the week for each store? | Sales | Order count, revenue, quantity sold | Date, Time, Store | `pos_orders`, `pos_order_items`, `stores` |
| Q5 | How effective are discounts and promotions? Do discounted orders have higher or lower average ticket sizes? | Sales & Promotions | Discount amount, order count, average order value, net sales | Date, Store, Promotion, Customer, Order Channel | `pos_orders`, `pos_order_items` |
| Q6 | What is the average order value for loyalty members vs. non-members? | Customer & Loyalty Analytics | Order count, total sales, average order value | Date, Customer, Store, Loyalty Status | `pos_orders`, `loyalty_members` |
| Q7 | How many new vs. returning customers do we get each month? | Customer Analytics | New customer count, returning customer count | Date, Customer, Store | `pos_orders`, `loyalty_members` |
| Q8 | Which loyalty tier produces the most revenue per customer? | Loyalty Analytics | Revenue, distinct customer count, revenue per customer | Date, Customer, Loyalty Tier, Store | `pos_orders`, `loyalty_members`, `loyalty_tier_history` |
| Q9 | What is the customer retention rate (customers who purchase again within 30 days)? | Customer Retention | Repeat customer count, eligible customer count, retention rate | Customer, Date, Store, Loyalty Tier | `pos_orders`, `loyalty_members`, `loyalty_tier_history` |
| Q10 | What is the sales per labor hour for each store, by shift? | Sales & Labor Analysis | Sales revenue, labor hours, sales per labor hour | Date, Store, Employee, Shift, Time | `pos_orders`, `pos_order_items`, `shifts`, `employees` |
| Q11 | Which employees (or roles) are on shift during the highest-volume periods? | Workforce & Operations | Employee count, order count, sales volume, labor hours | Date, Time, Store, Employee, Role, Shift | `pos_orders`, `pos_order_items`, `shifts`, `employees` |
| Q12 | What is the waste percentage by ingredient and by store? | Inventory & Waste Management | Quantity wasted, ingredient consumption, waste percentage | Date, Store, Ingredient, Waste Reason | `inventory_waste_log`, `inventory_snapshots`, `recipes`, `pos_order_items`, `ingredients` |
| Q13 | Which stores are most frequently running low on key ingredients? | Inventory Management | Low-stock event count, days below reorder threshold | Date, Store, Ingredient | `inventory_snapshots`, `ingredients`, `stores` |
| Q14 | What is the theoretical cost of goods sold (COGS) per drink, based on its recipe? | Product Costing | Ingredient quantity used, ingredient cost, theoretical COGS per drink | Product, Product Size, Ingredient, Date | `recipes`, `products`, `ingredients`, `pos_order_items` |

### 2.1 Business Process Summary

The business questions can be grouped into the following analytical business processes:

| Business Area | Business Process | Related Questions |
|---|---|---|
| Sales & Revenue | Sales Performance and Revenue Analysis | Q1, Q3, Q4 |
| Sales & Revenue | Product Profitability and Costing | Q2, Q14 |
| Sales & Revenue | Discount and Promotion Effectiveness | Q5 |
| Customer & Loyalty | Loyalty Member Analysis | Q6, Q8 |
| Customer & Loyalty | Customer Acquisition and Retention | Q7, Q9 |
| Operations & Labor | Workforce and Labor Productivity | Q10, Q11 |
| Inventory & Waste | Inventory Monitoring and Availability | Q13 |
| Inventory & Waste | Waste and Ingredient Consumption Analysis | Q12 |


## 3. Bus Matrix

### 3.1 Purpose

The dimensional bus matrix provides a high-level overview of the business processes and the dimensions required to analyze each process.

It identifies common dimensions shared across multiple business processes, supporting consistent reporting and enabling cross-functional business analysis.

A check mark (✓) indicates that a dimension is relevant to the corresponding business process.

### 3.2 Bus Matrix

| Business Process | Date | Time | Store | Product | Customer | Loyalty Tier | Employee | Ingredient | Promotion | Channel / Payment |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Sales | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | ✓ | ✓ |
| Inventory Snapshots | ✓ | | ✓ | | | | | ✓ | | |
| Inventory Waste | ✓ | | ✓ | | | | | ✓ | | |
| Employee Shifts | ✓ | ✓ | ✓ | | | | ✓ | | | |
| Loyalty Transactions | ✓ | | | | ✓ | ✓ | | | | |
| Recipe / Product Costing | ✓ | | | ✓ | | | | ✓ | | |

### 3.3 Dimension Descriptions

| Dimension | Description | Example Attributes |
|---|---|---|
| Date | Calendar attributes used for time-based reporting | Date, day, week, month, quarter, year, day of week |
| Time | Time-of-day attributes used for hourly and shift analysis | Hour, minute, time period, daypart |
| Store | Descriptive information about coffee shop locations | Store name, city, state, region, opening date, drive-through availability |
| Product | Product and menu item attributes | Product name, category, subcategory, seasonal status |
| Customer | Customer profile and registration information | Customer name, signup date, birth date |
| Loyalty Tier | Customer loyalty classification over time | Tier name, effective date, end date |
| Employee | Employee information used for workforce analysis | Employee name, hire date, termination date, role, home store |
| Ingredient | Ingredient and supplier information | Ingredient name, ingredient type, unit of measure, supplier |
| Promotion | Promotional attributes used to evaluate discount effectiveness | Promo code, promotion type, discount details |
| Channel / Payment | Order channel and payment method attributes | Order channel, payment method |

### 3.4 Bus Matrix Observations

- **Date** is a shared dimension across sales, inventory, workforce, loyalty, and product costing analysis.
- **Store** enables comparisons across locations, cities, and regions.
- **Product** supports sales performance, product profitability, and recipe-based costing.
- **Customer and Loyalty Tier** enable customer segmentation, loyalty performance, and retention analysis.
- **Employee and Time** support workforce scheduling and labor productivity analysis.
- **Ingredient** connects inventory monitoring, waste analysis, and theoretical product costing.
- **Promotion and Channel / Payment** support analysis of promotional effectiveness and sales channels.

