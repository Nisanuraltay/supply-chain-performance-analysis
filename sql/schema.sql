-- SUPPLY CHAIN DATABASE SCHEMA
-- Created: 2026-02-12


CREATE TABLE IF NOT EXISTS orders (
    order_id TEXT PRIMARY KEY,
    order_date DATE NOT NULL,
    shipping_date DATE,
    customer_country TEXT,
    customer_city TEXT,
    customer_state TEXT,
    order_country TEXT,
    order_region TEXT,
    shipping_mode TEXT,
    delivery_status TEXT,
    actual_shipping_days INTEGER,
    scheduled_shipping_days INTEGER,
    delay_days REAL,
    is_delayed INTEGER,
    on_time INTEGER,
    late_delivery_risk INTEGER,
    quantity INTEGER,
    sales REAL,
    order_total REAL,
    product_name TEXT,
    category TEXT,
    department TEXT,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    day_of_week INTEGER
);


-- INDEXES
CREATE INDEX IF NOT EXISTS idx_order_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_country ON orders(customer_country);
CREATE INDEX IF NOT EXISTS idx_region ON orders(order_region);
CREATE INDEX IF NOT EXISTS idx_shipping_mode ON orders(shipping_mode);
CREATE INDEX IF NOT EXISTS idx_category ON orders(category);
CREATE INDEX IF NOT EXISTS idx_is_delayed ON orders(is_delayed);
