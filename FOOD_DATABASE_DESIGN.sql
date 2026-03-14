-- ===============================================
-- DESAIN DATABASE EATWISE - FOOD MANAGEMENT
-- ===============================================
-- Database yang dinormalisasi untuk mengelola data makanan,
-- nutrisi, dan breakdown nutrisi secara detail
-- ===============================================

-- -----------------------------------------------
-- 1. TABEL UTAMA: FOODS
-- -----------------------------------------------
-- Menyimpan informasi dasar makanan
CREATE TABLE foods (
    id_food INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    serving_size VARCHAR(50) NOT NULL,
    
    -- Informasi nutrisi utama (per porsi)
    calories DECIMAL(6,1) NOT NULL,
    protein DECIMAL(5,1) NOT NULL,
    carbs DECIMAL(5,1) NOT NULL,
    fat DECIMAL(5,1) NOT NULL,
    fiber DECIMAL(5,1) NOT NULL,
    
    -- Informasi tambahan
    ingredients TEXT NOT NULL,
    preparation_time VARCHAR(50),
    health_benefits TEXT,
    tips TEXT,
    allergens VARCHAR(255),
    recommended_for VARCHAR(255),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Index untuk performa search
    INDEX idx_name (name),
    INDEX idx_calories (calories),
    INDEX idx_protein (protein)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 2. TABEL: NUTRIENT_TYPES
-- -----------------------------------------------
-- Master data jenis nutrisi (kalori, protein, karbo, lemak, serat)
CREATE TABLE nutrient_types (
    id_nutrient_type INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(50) NOT NULL,
    unit VARCHAR(10) NOT NULL,
    description TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 3. TABEL: NUTRITION_BREAKDOWN
-- -----------------------------------------------
-- Detail breakdown nutrisi per makanan per jenis nutrisi
-- Contoh: Nasi Goreng memiliki breakdown Kalori dengan total 450
CREATE TABLE nutrition_breakdown (
    id_breakdown INT AUTO_INCREMENT PRIMARY KEY,
    id_food INT NOT NULL,
    id_nutrient_type INT NOT NULL,
    total_amount DECIMAL(6,1) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_food) REFERENCES foods(id_food) ON DELETE CASCADE,
    FOREIGN KEY (id_nutrient_type) REFERENCES nutrient_types(id_nutrient_type) ON DELETE CASCADE,
    
    -- Satu makanan hanya punya 1 breakdown per nutrient type
    UNIQUE KEY unique_food_nutrient (id_food, id_nutrient_type),
    
    INDEX idx_food (id_food),
    INDEX idx_nutrient (id_nutrient_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 4. TABEL: NUTRITION_SOURCES
-- -----------------------------------------------
-- Sumber-sumber spesifik dari setiap breakdown
-- Contoh: Kalori Nasi Goreng berasal dari "Nasi Putih" 250 cal (55.6%)
CREATE TABLE nutrition_sources (
    id_source INT AUTO_INCREMENT PRIMARY KEY,
    id_breakdown INT NOT NULL,
    source_name VARCHAR(100) NOT NULL,
    amount DECIMAL(6,1) NOT NULL,
    percentage DECIMAL(5,1) NOT NULL,
    sort_order INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_breakdown) REFERENCES nutrition_breakdown(id_breakdown) ON DELETE CASCADE,
    
    INDEX idx_breakdown (id_breakdown),
    INDEX idx_source_name (source_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 5. TABEL: FOOD_CATEGORIES (OPTIONAL - FUTURE)
-- -----------------------------------------------
-- Kategori makanan: Nasi, Lauk, Sayur, Snack, dll
CREATE TABLE food_categories (
    id_category INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_name (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 6. TABEL: FOOD_CATEGORY_MAPPING (OPTIONAL - FUTURE)
-- -----------------------------------------------
-- Many-to-many relationship: Satu makanan bisa punya banyak kategori
CREATE TABLE food_category_mapping (
    id_mapping INT AUTO_INCREMENT PRIMARY KEY,
    id_food INT NOT NULL,
    id_category INT NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_food) REFERENCES foods(id_food) ON DELETE CASCADE,
    FOREIGN KEY (id_category) REFERENCES food_categories(id_category) ON DELETE CASCADE,
    
    UNIQUE KEY unique_food_category (id_food, id_category),
    
    INDEX idx_food (id_food),
    INDEX idx_category (id_category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===============================================
-- INSERT MASTER DATA
-- ===============================================

-- Insert nutrient types
INSERT INTO nutrient_types (name, display_name, unit, description) VALUES
('calories', 'Kalori', 'kcal', 'Total energi yang dihasilkan dari makanan'),
('protein', 'Protein', 'g', 'Zat pembangun untuk otot dan jaringan tubuh'),
('carbs', 'Karbohidrat', 'g', 'Sumber energi utama untuk aktivitas'),
('fat', 'Lemak', 'g', 'Sumber energi cadangan dan komponen sel'),
('fiber', 'Serat', 'g', 'Membantu pencernaan dan kesehatan usus');

-- Insert sample categories (optional untuk future development)
INSERT INTO food_categories (category_name, description, icon) VALUES
('Makanan Utama', 'Nasi, mie, dan hidangan pokok lainnya', '🍚'),
('Lauk Pauk', 'Protein hewani dan nabati', '🍗'),
('Sayuran', 'Sayur-sayuran dan salad', '🥗'),
('Makanan Cepat Saji', 'Fast food dan makanan siap saji', '🍔'),
('Sup & Kuah', 'Makanan berkuah seperti soto dan rawon', '🍲'),
('Tradisional Indonesia', 'Makanan khas nusantara', '🇮🇩');

-- ===============================================
-- CONTOH DATA INSERT: NASI GORENG
-- ===============================================

-- 1. Insert makanan
INSERT INTO foods (name, description, calories, protein, carbs, fat, fiber, serving_size, 
                   health_benefits, ingredients, preparation_time, tips, allergens, recommended_for) 
VALUES (
    'Nasi Goreng',
    'Nasi goreng khas Indonesia dengan bumbu rempah, telur, ayam, dan sayuran. Makanan favorit yang kaya rasa dan mengenyangkan.',
    450, 18.5, 62.0, 14.0, 3.5,
    '1 piring (300g)',
    'Sumber karbohidrat untuk energi, protein dari telur dan ayam membantu pembentukan otot, mengandung vitamin B kompleks dari nasi dan telur.',
    'Nasi putih, telur, ayam, bawang merah, bawang putih, kecap manis, cabai, sayuran (wortel, kol, sawi), minyak goreng, garam, merica',
    '20-25 menit',
    'Pilih nasi goreng dengan lebih banyak sayuran dan protein tanpa lemak. Kurangi penggunaan minyak dan kecap manis. Tambahkan irisan mentimun dan tomat untuk serat tambahan.',
    'Telur, Kedelai (kecap), Monosodium Glutamat (MSG) - jika ditambahkan',
    'Atlet, pekerja aktif, diet tinggi energi'
);

-- 2. Insert breakdown kalori untuk Nasi Goreng
INSERT INTO nutrition_breakdown (id_food, id_nutrient_type, total_amount)
VALUES (
    (SELECT id_food FROM foods WHERE name = 'Nasi Goreng'),
    (SELECT id_nutrient_type FROM nutrient_types WHERE name = 'calories'),
    450
);

-- 3. Insert sumber-sumber kalori Nasi Goreng
INSERT INTO nutrition_sources (id_breakdown, source_name, amount, percentage, sort_order) VALUES
(LAST_INSERT_ID(), 'Nasi Putih', 250, 55.6, 1),
(LAST_INSERT_ID(), 'Ayam & Telur', 120, 26.7, 2),
(LAST_INSERT_ID(), 'Minyak Goreng', 60, 13.3, 3),
(LAST_INSERT_ID(), 'Sayuran', 20, 4.4, 4);

-- 4. Insert breakdown protein untuk Nasi Goreng
INSERT INTO nutrition_breakdown (id_food, id_nutrient_type, total_amount)
VALUES (
    (SELECT id_food FROM foods WHERE name = 'Nasi Goreng'),
    (SELECT id_nutrient_type FROM nutrient_types WHERE name = 'protein'),
    18.5
);

-- 5. Insert sumber-sumber protein Nasi Goreng
INSERT INTO nutrition_sources (id_breakdown, source_name, amount, percentage, sort_order) VALUES
(LAST_INSERT_ID(), 'Ayam', 12.0, 64.9, 1),
(LAST_INSERT_ID(), 'Telur', 6.0, 32.4, 2),
(LAST_INSERT_ID(), 'Nasi', 0.5, 2.7, 3);

-- (Lanjutkan untuk carbs, fat, fiber dengan pattern yang sama)

-- ===============================================
-- USEFUL QUERIES
-- ===============================================

-- Query untuk mendapatkan makanan dengan full breakdown
DELIMITER $$
CREATE PROCEDURE GetFoodWithBreakdown(IN food_name VARCHAR(100))
BEGIN
    -- Data makanan utama
    SELECT 
        f.id_food,
        f.name,
        f.description,
        f.calories,
        f.protein,
        f.carbs,
        f.fat,
        f.fiber,
        f.serving_size,
        f.health_benefits,
        f.ingredients,
        f.preparation_time,
        f.tips,
        f.allergens,
        f.recommended_for
    FROM foods f
    WHERE f.name = food_name;
    
    -- Breakdown nutrisi dengan sources
    SELECT 
        nt.name as nutrient_name,
        nt.display_name,
        nt.unit,
        nb.total_amount,
        ns.source_name,
        ns.amount as source_amount,
        ns.percentage
    FROM foods f
    JOIN nutrition_breakdown nb ON f.id_food = nb.id_food
    JOIN nutrient_types nt ON nb.id_nutrient_type = nt.id_nutrient_type
    LEFT JOIN nutrition_sources ns ON nb.id_breakdown = ns.id_breakdown
    WHERE f.name = food_name
    ORDER BY nt.id_nutrient_type, ns.sort_order;
END$$
DELIMITER ;

-- Query untuk search makanan berdasarkan nutrisi
CREATE VIEW v_food_summary AS
SELECT 
    f.id_food,
    f.name,
    f.description,
    f.calories,
    f.protein,
    f.carbs,
    f.fat,
    f.fiber,
    f.serving_size,
    f.recommended_for,
    -- Hitung jumlah breakdown yang tersedia
    COUNT(DISTINCT nb.id_breakdown) as breakdown_count,
    -- Hitung total sources
    COUNT(DISTINCT ns.id_source) as total_sources
FROM foods f
LEFT JOIN nutrition_breakdown nb ON f.id_food = nb.id_food
LEFT JOIN nutrition_sources ns ON nb.id_breakdown = ns.id_breakdown
GROUP BY f.id_food;

-- Query untuk mencari makanan high protein
SELECT * FROM v_food_summary
WHERE protein >= 25
ORDER BY protein DESC;

-- Query untuk mencari makanan rendah kalori
SELECT * FROM v_food_summary
WHERE calories <= 350
ORDER BY calories ASC;

-- ===============================================
-- INDEXES UNTUK PERFORMA
-- ===============================================

-- Full text search untuk nama dan deskripsi
ALTER TABLE foods ADD FULLTEXT INDEX idx_fulltext_search (name, description, ingredients);

-- Composite index untuk filter kombinasi
CREATE INDEX idx_nutrition_filter ON foods(calories, protein, carbs, fat);

-- ===============================================
-- VIEWS UNTUK KEMUDAHAN QUERY
-- ===============================================

-- View untuk breakdown lengkap semua makanan
CREATE VIEW v_nutrition_breakdown_detail AS
SELECT 
    f.name as food_name,
    nt.display_name as nutrient,
    nb.total_amount as total,
    nt.unit,
    ns.source_name,
    ns.amount as source_amount,
    ns.percentage,
    CONCAT(ns.source_name, ' ', ns.amount, ' ', nt.unit, ' (', ns.percentage, '%)') as formatted_source
FROM foods f
JOIN nutrition_breakdown nb ON f.id_food = nb.id_food
JOIN nutrient_types nt ON nb.id_nutrient_type = nt.id_nutrient_type
JOIN nutrition_sources ns ON nb.id_breakdown = ns.id_breakdown
ORDER BY f.name, nt.id_nutrient_type, ns.sort_order;

-- ===============================================
-- DATABASE DIAGRAM (ERD)
-- ===============================================
/*
┌─────────────────────────────────────────────┐
│              FOODS (Main)                   │
├─────────────────────────────────────────────┤
│ PK │ id_food                                │
│    │ name (UNIQUE)                          │
│    │ description                            │
│    │ calories, protein, carbs, fat, fiber   │
│    │ serving_size                           │
│    │ health_benefits, ingredients, tips     │
│    │ allergens, recommended_for             │
└─────────────────┬───────────────────────────┘
                  │
                  │ 1:N
                  ▼
┌─────────────────────────────────────────────┐
│        NUTRITION_BREAKDOWN                  │
├─────────────────────────────────────────────┤
│ PK │ id_breakdown                           │
│ FK │ id_food ────────────┐                  │
│ FK │ id_nutrient_type    │                  │
│    │ total_amount        │                  │
└─────────────────┬───────┬─────────────────┘
                  │       │
       ┌──────────┘       └──────────┐
       │ N:1                      N:1 │
       ▼                              ▼
┌──────────────────┐      ┌────────────────────────┐
│ NUTRIENT_TYPES   │      │  NUTRITION_SOURCES     │
├──────────────────┤      ├────────────────────────┤
│ PK │id_nutrient │      │ PK │ id_source         │
│    │name        │      │ FK │ id_breakdown      │
│    │display_name│      │    │ source_name       │
│    │unit        │      │    │ amount            │
│    │description │      │    │ percentage        │
└──────────────────┘      │    │ sort_order        │
                          └────────────────────────┘

OPTIONAL FUTURE:
┌──────────────────────┐      ┌────────────────────────┐
│  FOOD_CATEGORIES     │◄─N:M─┤ FOOD_CATEGORY_MAPPING │
├──────────────────────┤      ├────────────────────────┤
│ PK │ id_category     │      │ FK │ id_food            │
│    │ category_name   │      │ FK │ id_category        │
│    │ description     │      └────────────────────────┘
│    │ icon            │
└──────────────────────┘
*/

-- ===============================================
-- NOTES & BEST PRACTICES
-- ===============================================
/*
1. NORMALISASI:
   - Data nutrisi breakdown dipisah ke 3 tabel terpisah
   - Menghindari redundancy dan memudahkan update
   - Nutrient types bisa ditambah tanpa alter table foods

2. SCALABILITY:
   - Mudah menambah jenis nutrisi baru (vitamin, mineral)
   - Support untuk multiple sources per breakdown
   - Support untuk kategori makanan (future)

3. PERFORMA:
   - Index pada kolom yang sering di-query
   - Views untuk query kompleks yang sering digunakan
   - Stored procedure untuk data retrieval yang cepat

4. DATA INTEGRITY:
   - Foreign keys dengan ON DELETE CASCADE
   - Unique constraints untuk mencegah duplikat
   - DECIMAL untuk nilai nutrisi (lebih presisi dari FLOAT)

5. MIGRATION DARI JSON:
   - Buat script PHP/Python untuk import dari foods_data.json
   - Loop setiap food → insert ke foods, breakdown, sources
   - Bisa pakai transaction untuk rollback jika error
*/
