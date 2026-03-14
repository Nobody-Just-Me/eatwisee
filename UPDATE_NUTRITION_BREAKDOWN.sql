-- ==========================================
-- SQL UPDATE: Add nutrition_breakdown column
-- For EatWise2 Database Enhancement
-- Date: December 5, 2025
-- ==========================================

USE eatwise2;

-- Add nutrition_breakdown column to food_products table if not exists
ALTER TABLE food_products 
ADD COLUMN IF NOT EXISTS nutrition_breakdown TEXT DEFAULT NULL 
COMMENT 'JSON detail breakdown sumber nutrisi';

-- Update Nasi Padang dengan breakdown detail
UPDATE food_products 
SET nutrition_breakdown = '{
  "calories": {
    "total": 650,
    "sources": [
      {"name": "Nasi Putih", "amount": 200, "percentage": 30.8},
      {"name": "Rendang Sapi", "amount": 280, "percentage": 43.1},
      {"name": "Ayam Pop", "amount": 80, "percentage": 12.3},
      {"name": "Gulai", "amount": 50, "percentage": 7.7},
      {"name": "Sambal & Sayur", "amount": 40, "percentage": 6.2}
    ]
  },
  "protein": {
    "total": 35.0,
    "sources": [
      {"name": "Rendang Sapi", "amount": 20.0, "percentage": 57.1},
      {"name": "Ayam Pop", "amount": 10.0, "percentage": 28.6},
      {"name": "Telur/Perkedel", "amount": 3.0, "percentage": 8.6},
      {"name": "Gulai", "amount": 2.0, "percentage": 5.7}
    ]
  },
  "carbs": {
    "total": 70.0,
    "sources": [
      {"name": "Nasi Putih", "amount": 60.0, "percentage": 85.7},
      {"name": "Perkedel", "amount": 8.0, "percentage": 11.4},
      {"name": "Sayur Nangka", "amount": 2.0, "percentage": 2.9}
    ]
  },
  "fat": {
    "total": 28.0,
    "sources": [
      {"name": "Rendang (Santan)", "amount": 18.0, "percentage": 64.3},
      {"name": "Gulai (Santan)", "amount": 6.0, "percentage": 21.4},
      {"name": "Ayam Pop", "amount": 3.0, "percentage": 10.7},
      {"name": "Sambal", "amount": 1.0, "percentage": 3.6}
    ]
  },
  "fiber": {
    "total": 5.0,
    "sources": [
      {"name": "Sayur Nangka", "amount": 2.5, "percentage": 50.0},
      {"name": "Daun Singkong", "amount": 1.5, "percentage": 30.0},
      {"name": "Nasi Putih", "amount": 0.5, "percentage": 10.0},
      {"name": "Sambal", "amount": 0.5, "percentage": 10.0}
    ]
  }
}'
WHERE nama_produk = 'Nasi Padang';

-- Verify update
SELECT 
    id,
    nama_produk,
    kalori,
    protein,
    karbohidrat,
    lemak_total,
    serat,
    SUBSTRING(nutrition_breakdown, 1, 100) as breakdown_preview
FROM food_products 
WHERE nutrition_breakdown IS NOT NULL;

-- ==========================================
-- INSTRUKSI PENGGUNAAN:
-- ==========================================
-- 1. Buka phpMyAdmin atau MySQL Workbench
-- 2. Pilih database 'eatwise2'
-- 3. Jalankan SQL script ini
-- 4. Refresh aplikasi Flutter
-- 5. Scan Nasi Padang untuk test breakdown
-- ==========================================

-- Contoh query untuk cek hasil:
-- SELECT nama_produk, nutrition_breakdown FROM food_products WHERE nama_produk = 'Nasi Padang';
