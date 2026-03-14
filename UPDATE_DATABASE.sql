-- ========================================
-- UPDATE DATABASE: Tambah Kolom Baru ke user_profile
-- ========================================
-- Jalankan SQL ini di phpMyAdmin atau MySQL client
-- Database: eatwise2
-- Tabel: user_profile
-- ========================================

USE eatwise2;

-- 1. Tambah kolom tanggal_lahir (setelah nama_lengkap, sebelum usia)
ALTER TABLE `user_profile` 
ADD COLUMN `tanggal_lahir` DATE NULL 
COMMENT 'Tanggal lahir untuk hitung usia otomatis' 
AFTER `nama_lengkap`;

-- 2. Tambah kolom bahan_dihindari (setelah riwayat_jantung, sebelum alergi_gluten)
ALTER TABLE `user_profile` 
ADD COLUMN `bahan_dihindari` TEXT NULL 
COMMENT 'Bahan yang dihindari user, format CSV (comma separated)' 
AFTER `riwayat_jantung`;

-- ========================================
-- VERIFIKASI: Cek struktur tabel setelah update
-- ========================================
DESCRIBE `user_profile`;

-- ========================================
-- SELESAI
-- ========================================
-- Sekarang tabel user_profile sudah punya:
-- 1. tanggal_lahir (DATE) - untuk simpan tanggal lahir user
-- 2. bahan_dihindari (TEXT) - untuk simpan bahan yang dihindari (gula, garam, dll)
-- ========================================
