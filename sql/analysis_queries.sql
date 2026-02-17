-- SUPPLY CHAIN ANALYSIS QUERIES
-- Created: 2026-02-12
-- Description: Key analytical queries for supply chain performance


================================================================================
-- QUERY 1: GENEL_PERFORMANS
================================================================================

-- SORGU 1: Genel Performans Özeti
SELECT 
    COUNT(*) as total_orders,
    COUNT(DISTINCT customer_country) as unique_countries,
    ROUND(AVG(delay_days), 2) as avg_delay_days,
    ROUND(AVG(is_delayed) * 100, 1) as delayed_pct,
    ROUND(AVG(on_time) * 100, 1) as on_time_pct,
    ROUND(SUM(sales), 2) as total_sales,
    ROUND(AVG(sales), 2) as avg_order_value,
    SUM(quantity) as total_products
FROM orders;



================================================================================
-- QUERY 2: SHIPPING_MODE
================================================================================

-- SORGU 2: Sevkiyat Moduna Göre Performans
SELECT 
    shipping_mode,
    COUNT(*) as order_count,
    ROUND(AVG(delay_days), 2) as avg_delay,
    ROUND(AVG(is_delayed) * 100, 1) as delayed_pct,
    ROUND(SUM(sales), 2) as total_sales,
    ROUND(AVG(sales), 2) as avg_sales
FROM orders
GROUP BY shipping_mode
ORDER BY avg_delay DESC;



================================================================================
-- QUERY 3: REGIONAL
================================================================================

-- SORGU 3: Bölgesel Performans Analizi
SELECT 
    order_region,
    COUNT(*) as order_count,
    ROUND(AVG(delay_days), 2) as avg_delay,
    ROUND(AVG(is_delayed) * 100, 1) as delayed_pct,
    ROUND(SUM(sales), 2) as total_sales,
    ROUND(SUM(sales) / SUM(SUM(sales)) OVER () * 100, 1) as sales_share_pct
FROM orders
GROUP BY order_region
ORDER BY avg_delay DESC;



================================================================================
-- QUERY 4: WORST_COUNTRIES
================================================================================

-- SORGU 4: En Çok Gecikme Yaşanan 10 Ülke (Min 100 sipariş)
SELECT 
    customer_country,
    COUNT(*) as order_count,
    ROUND(AVG(delay_days), 2) as avg_delay,
    ROUND(AVG(is_delayed) * 100, 1) as delayed_pct,
    ROUND(SUM(sales), 2) as total_sales
FROM orders
GROUP BY customer_country
HAVING order_count >= 100
ORDER BY avg_delay DESC
LIMIT 10;



================================================================================
-- QUERY 5: MONTHLY_TREND
================================================================================

-- SORGU 5: Aylık Performans Trendi
SELECT 
    strftime('%Y-%m', order_date) as year_month,
    COUNT(*) as order_count,
    ROUND(AVG(delay_days), 2) as avg_delay,
    ROUND(AVG(is_delayed) * 100, 1) as delayed_pct,
    ROUND(SUM(sales), 2) as monthly_sales
FROM orders
GROUP BY year_month
ORDER BY year_month;



================================================================================
-- QUERY 6: SEASONALITY
================================================================================

-- SORGU 6: Mevsimsel Pattern (Ay Bazlı Ortalama)
SELECT 
    month,
    CASE month
        WHEN 1 THEN 'Ocak'
        WHEN 2 THEN 'Şubat'
        WHEN 3 THEN 'Mart'
        WHEN 4 THEN 'Nisan'
        WHEN 5 THEN 'Mayıs'
        WHEN 6 THEN 'Haziran'
        WHEN 7 THEN 'Temmuz'
        WHEN 8 THEN 'Ağustos'
        WHEN 9 THEN 'Eylül'
        WHEN 10 THEN 'Ekim'
        WHEN 11 THEN 'Kasım'
        WHEN 12 THEN 'Aralık'
    END as month_name,
    COUNT(*) as order_count,
    ROUND(AVG(delay_days), 2) as avg_delay,
    ROUND(AVG(is_delayed) * 100, 1) as delayed_pct
FROM orders
GROUP BY month
ORDER BY month;



================================================================================
-- QUERY 7: CATEGORIES
================================================================================

-- SORGU 7: En Sorunlu Ürün Kategorileri (Top 10)
SELECT 
    category,
    COUNT(*) as order_count,
    ROUND(AVG(delay_days), 2) as avg_delay,
    ROUND(AVG(is_delayed) * 100, 1) as delayed_pct,
    ROUND(SUM(sales), 2) as total_sales
FROM orders
GROUP BY category
ORDER BY avg_delay DESC
LIMIT 10;



================================================================================
-- QUERY 8: DELAY_CATEGORIES
================================================================================

-- SORGU 8: Gecikme Kategorileri
SELECT 
    CASE 
        WHEN delay_days <= 0 THEN 'Zamanında'
        WHEN delay_days <= 3 THEN '1-3 Gün'
        WHEN delay_days <= 7 THEN '4-7 Gün'
        ELSE '7+ Gün'
    END as delay_category,
    COUNT(*) as order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
FROM orders
GROUP BY delay_category
ORDER BY 
    CASE delay_category
        WHEN 'Zamanında' THEN 1
        WHEN '1-3 Gün' THEN 2
        WHEN '4-7 Gün' THEN 3
        ELSE 4
    END;



================================================================================
-- QUERY 9: CRITICAL_DELAYS
================================================================================

-- SORGU 9: Kritik Gecikmeli Siparişler (Yüksek Değer + Uzun Gecikme)
SELECT 
    order_id,
    order_date,
    customer_country,
    shipping_mode,
    delay_days,
    sales,
    category
FROM orders
WHERE is_delayed = 1 
  AND sales > (SELECT AVG(sales) FROM orders)
  AND delay_days > 5
ORDER BY sales DESC
LIMIT 20;



================================================================================
-- QUERY 10: MODE_COMPARISON
================================================================================

-- SORGU 10: En İyi vs En Kötü Sevkiyat Modu Karşılaştırması (CTE)
WITH mode_performance AS (
    SELECT 
        shipping_mode,
        COUNT(*) as order_count,
        ROUND(AVG(delay_days), 2) as avg_delay,
        ROUND(AVG(is_delayed) * 100, 1) as delayed_pct
    FROM orders
    GROUP BY shipping_mode
),
ranked_modes AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY avg_delay) as best_rank,
        ROW_NUMBER() OVER (ORDER BY avg_delay DESC) as worst_rank
    FROM mode_performance
)
SELECT 
    shipping_mode,
    order_count,
    avg_delay,
    delayed_pct,
    CASE 
        WHEN best_rank = 1 THEN 'EN İYİ'
        WHEN worst_rank = 1 THEN 'EN KÖTÜ'
        ELSE 'ORTA'
    END as performance_tier
FROM ranked_modes
WHERE best_rank = 1 OR worst_rank = 1
ORDER BY avg_delay;


