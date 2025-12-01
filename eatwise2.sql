-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 01 Des 2025 pada 07.51
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `eatwise2`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `food_history`
--

CREATE TABLE `food_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `food_product_id` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `waktu` time NOT NULL,
  `jenis_waktu_makan` enum('sarapan','siang','malam','snack') DEFAULT 'snack',
  `jumlah_porsi` decimal(4,2) DEFAULT 1.00,
  `kalori_dikonsumsi` int(11) DEFAULT 0,
  `status_aman` tinyint(1) DEFAULT 1 COMMENT '1=Aman, 0=Berisiko',
  `peringatan_alergi` text DEFAULT NULL COMMENT 'JSON array peringatan',
  `peringatan_penyakit` text DEFAULT NULL COMMENT 'JSON array peringatan',
  `catatan_user` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `food_history`
--

INSERT INTO `food_history` (`id`, `user_id`, `food_product_id`, `tanggal`, `waktu`, `jenis_waktu_makan`, `jumlah_porsi`, `kalori_dikonsumsi`, `status_aman`, `peringatan_alergi`, `peringatan_penyakit`, `catatan_user`, `created_at`) VALUES
(1, 4, 9, '2025-12-01', '07:28:55', 'sarapan', 1.00, 130, 1, '[]', '[]', NULL, '2025-12-01 06:28:55');

-- --------------------------------------------------------

--
-- Struktur dari tabel `food_products`
--

CREATE TABLE `food_products` (
  `id` int(11) NOT NULL,
  `barcode` varchar(50) DEFAULT NULL,
  `nama_produk` varchar(200) NOT NULL,
  `merek` varchar(100) DEFAULT NULL,
  `kategori` varchar(50) DEFAULT NULL,
  `komposisi_bahan` text DEFAULT NULL,
  `serving_size` varchar(20) DEFAULT '100g',
  `kalori` int(11) DEFAULT 0,
  `karbohidrat` decimal(6,2) DEFAULT 0.00,
  `protein` decimal(6,2) DEFAULT 0.00,
  `lemak_total` decimal(6,2) DEFAULT 0.00,
  `lemak_jenuh` decimal(6,2) DEFAULT 0.00,
  `gula` decimal(6,2) DEFAULT 0.00,
  `garam` decimal(6,2) DEFAULT 0.00,
  `serat` decimal(6,2) DEFAULT 0.00,
  `mengandung_gluten` tinyint(1) DEFAULT 0,
  `mengandung_kacang` tinyint(1) DEFAULT 0,
  `mengandung_telur` tinyint(1) DEFAULT 0,
  `mengandung_susu` tinyint(1) DEFAULT 0,
  `mengandung_seafood` tinyint(1) DEFAULT 0,
  `tingkat_gula` enum('rendah','sedang','tinggi') DEFAULT 'sedang',
  `tingkat_garam` enum('rendah','sedang','tinggi') DEFAULT 'sedang',
  `tingkat_lemak` enum('rendah','sedang','tinggi') DEFAULT 'sedang',
  `image_url` text DEFAULT NULL,
  `status_verifikasi` enum('terverifikasi','pending','user_input') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `food_products`
--

INSERT INTO `food_products` (`id`, `barcode`, `nama_produk`, `merek`, `kategori`, `komposisi_bahan`, `serving_size`, `kalori`, `karbohidrat`, `protein`, `lemak_total`, `lemak_jenuh`, `gula`, `garam`, `serat`, `mengandung_gluten`, `mengandung_kacang`, `mengandung_telur`, `mengandung_susu`, `mengandung_seafood`, `tingkat_gula`, `tingkat_garam`, `tingkat_lemak`, `image_url`, `status_verifikasi`, `created_at`, `updated_at`) VALUES
(1, '8992761111111', 'Susu UHT Full Cream', 'Ultra Milk', 'Minuman', '[\"Susu Segar\", \"Vitamin D\", \"Vitamin B2\"]', '200ml', 130, 9.60, 6.40, 6.80, 4.20, 9.60, 0.10, 0.00, 0, 0, 0, 1, 0, 'sedang', 'rendah', 'sedang', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400', 'terverifikasi', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(2, '8992761222222', 'Mie Goreng Instan Pedas', 'Indomie', 'Makanan Berat', '[\"Tepung Terigu\", \"Minyak Sawit\", \"Garam\", \"MSG\", \"Bumbu Cabai\"]', '85g', 390, 54.00, 8.50, 16.00, 7.50, 3.20, 1.80, 2.00, 1, 0, 0, 0, 0, 'sedang', 'tinggi', 'tinggi', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400', 'terverifikasi', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(3, '8992761333333', 'Biskuit Cokelat', 'Oreo', 'Makanan Ringan', '[\"Tepung Terigu\", \"Gula\", \"Minyak Sawit\", \"Cokelat\", \"Pengembang Kue\"]', '100g', 480, 68.00, 5.50, 20.00, 9.00, 38.00, 0.60, 2.50, 1, 0, 1, 1, 0, 'tinggi', 'rendah', 'tinggi', 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400', 'terverifikasi', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(4, '8992761444444', 'Jus Jeruk 100%', 'Minute Maid', 'Minuman', '[\"Air\", \"Konsentrat Jeruk\", \"Vitamin C\"]', '250ml', 110, 26.00, 1.50, 0.00, 0.00, 24.00, 0.05, 0.50, 0, 0, 0, 0, 0, 'tinggi', 'rendah', 'rendah', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400', 'terverifikasi', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(5, '8992761555555', 'Keripik Kentang Original', 'Lays', 'Makanan Ringan', '[\"Kentang\", \"Minyak Sawit\", \"Garam\", \"Bumbu\"]', '100g', 536, 50.00, 6.50, 35.00, 3.50, 2.00, 1.50, 4.00, 0, 0, 0, 0, 0, 'rendah', 'tinggi', 'tinggi', 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400', 'terverifikasi', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(6, 'CUSTOM001', 'Nasi Padang Rendang', 'Custom', 'Makanan Berat', '[\"Nasi\", \"Daging Sapi\", \"Santan\", \"Cabai\", \"Bumbu Rempah\"]', '1 Porsi', 650, 75.00, 28.00, 25.00, 15.00, 8.00, 2.50, 3.00, 0, 0, 0, 0, 0, 'sedang', 'tinggi', 'tinggi', 'https://images.unsplash.com/photo-1596040033229-a0b2b4b1f4b2?w=400', 'user_input', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(7, '8992761666666', 'Teh Manis Kemasan', 'Teh Pucuk', 'Minuman', '[\"Air\", \"Teh\", \"Gula\"]', '350ml', 140, 35.00, 0.00, 0.00, 0.00, 35.00, 0.05, 0.00, 0, 0, 0, 0, 0, 'tinggi', 'rendah', 'rendah', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400', 'terverifikasi', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(8, '8992761777777', 'Yogurt Greek Plain', 'Heavenly Blush', 'Minuman', '[\"Susu\", \"Culture Yogurt\", \"Protein\"]', '200ml', 140, 8.00, 15.00, 5.00, 3.00, 7.00, 0.10, 0.00, 0, 0, 0, 1, 0, 'sedang', 'rendah', 'rendah', 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400', 'terverifikasi', '2025-11-26 16:40:37', '2025-11-26 16:40:37'),
(9, '7622300442507', 'Oreo Ice Cream', 'Mondelez', 'Makanan Ringan', '[\"Tepung Terigu\", \"Gula\", \"Minyak Nabati\", \"Bubuk Coklat\", \"Pati jagung\",\"Perisa Sintetik\",\"Perisa Alami\"]', '110g', 130, 20.00, 1.00, 5.00, 2.50, 11.00, 140.00, 1.00, 0, 0, 0, 0, 0, 'tinggi', 'sedang', 'rendah', 'https://solvent-production.s3.amazonaws.com/media/images/products/2022/11/DSC_0725.JPG', 'pending', '2025-12-01 06:24:02', '2025-12-01 06:24:02'),
(10, '9556001051509', 'Milo UHT Activ-Go', 'Nestle', 'Minuman', '[\"Air\", \"Padatan Susu\", \"Ekstrak Malt (Barli)\", \"Gula\", \"Kakao Bubuk\", \"Minyak Nabati\", \"Maltodekstrin\", \"Penstabil\", \"Mineral\", \"Premiks Vitamin\", \"Pengemulsi Lesitin Kedelai\", \"Pemanis Alami Glikosida Steviol\", \"Perisa Sintetik Vanila\"]', '220ml', 160, 23.00, 5.00, 6.00, 3.00, 16.00, 100.00, 0.00, 1, 0, 0, 1, 0, 'tinggi', 'rendah', 'sedang', '', 'pending', '2025-12-01 06:49:33', '2025-12-01 06:49:33'),
(11, '8990800100012', 'Mentos Mint Chewy Dragees', 'Mentos', 'Permen', '[\"Gula\", \"Sirup Glukosa\", \"Lemak Nabati\", \"Tepung Beras\", \"Pengental (Gum Arab, Gom Gelan)\", \"Perisa Alami Mint\", \"Pengemulsi Nabati (Ester Sukrosa Asam Lemak)\", \"Pelapis (Lilin Karnauba, Lilin Lebah)\"]', '2.7g (1 butir)', 10, 2.00, 0.00, 0.00, 0.00, 2.00, 0.00, 0.00, 0, 0, 0, 0, 0, 'tinggi', 'rendah', 'rendah', '', 'pending', '2025-12-01 06:50:01', '2025-12-01 06:50:01');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`) VALUES
(1, 'Zelcy', '$2y$10$KiW5XKsPFHsRPP8OEflBJelJa7/a2Mw0CvX51EmNbaugfETuvsOui', NULL),
(2, 'agus', '$2y$10$g3Iiy3EYh61S6wDawSCJD.ZofU8DZ0PSUwaHzh4K/MiuWPYDTSNhu', 'op'),
(3, 'Prabowo', '$2y$10$Y2VXRppsK7.3sp9JxYeQge3qCqTJQgVEEtMR5JlHpIxUy34UWf9mS', 'Prabowowaw@gmail.com'),
(4, 'jingga', '$2y$10$Fgu1c/DLZEpuukqzJM2fxeG.oOP82lByuIJfg0Gs5iAhevOGJkPPm', 'jingga@gmail.com'),
(5, 'jinggoy', '$2y$10$yWdzgL3faK6J/ZRhw.m.A.O0QYX.RkKVryE9S//wWNLJMFzAtOQp6', 'pp');

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_profile`
--

CREATE TABLE `user_profile` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `nama_lengkap` varchar(100) DEFAULT NULL,
  `usia` int(11) DEFAULT NULL,
  `berat_badan` decimal(5,2) DEFAULT NULL COMMENT 'dalam kg',
  `tinggi_badan` decimal(5,2) DEFAULT NULL COMMENT 'dalam cm',
  `riwayat_diabetes` tinyint(1) DEFAULT 0,
  `riwayat_kolesterol` tinyint(1) DEFAULT 0,
  `riwayat_hipertensi` tinyint(1) DEFAULT 0,
  `riwayat_jantung` tinyint(1) DEFAULT 0,
  `alergi_gluten` tinyint(1) DEFAULT 0,
  `alergi_kacang` tinyint(1) DEFAULT 0,
  `alergi_telur` tinyint(1) DEFAULT 0,
  `alergi_susu` tinyint(1) DEFAULT 0,
  `alergi_seafood` tinyint(1) DEFAULT 0,
  `notif_sarapan_aktif` tinyint(1) DEFAULT 1,
  `waktu_sarapan` time DEFAULT '07:00:00',
  `notif_siang_aktif` tinyint(1) DEFAULT 1,
  `waktu_siang` time DEFAULT '12:30:00',
  `notif_malam_aktif` tinyint(1) DEFAULT 1,
  `waktu_malam` time DEFAULT '19:00:00',
  `target_kalori_harian` int(11) DEFAULT 2000,
  `kalori_terkonsumsi_hari_ini` int(11) DEFAULT 0,
  `tanggal_reset_kalori` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user_profile`
--

INSERT INTO `user_profile` (`id`, `user_id`, `nama_lengkap`, `usia`, `berat_badan`, `tinggi_badan`, `riwayat_diabetes`, `riwayat_kolesterol`, `riwayat_hipertensi`, `riwayat_jantung`, `alergi_gluten`, `alergi_kacang`, `alergi_telur`, `alergi_susu`, `alergi_seafood`, `notif_sarapan_aktif`, `waktu_sarapan`, `notif_siang_aktif`, `waktu_siang`, `notif_malam_aktif`, `waktu_malam`, `target_kalori_harian`, `kalori_terkonsumsi_hari_ini`, `tanggal_reset_kalori`, `created_at`, `updated_at`) VALUES
(1, 4, 'jingga', NULL, 65.50, 161.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '13:30:00', 0, '12:30:00', 0, '19:00:00', 2000, 130, '2025-12-01', '2025-11-29 07:58:04', '2025-12-01 06:32:06'),
(2, 5, 'jinggoy', NULL, 65.50, 175.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, '07:00:00', 1, '12:30:00', 1, '19:00:00', 2000, 0, '2025-12-01', '2025-12-01 06:38:23', '2025-12-01 06:38:23');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `food_history`
--
ALTER TABLE `food_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `food_product_id` (`food_product_id`),
  ADD KEY `tanggal` (`tanggal`);

--
-- Indeks untuk tabel `food_products`
--
ALTER TABLE `food_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `barcode_idx` (`barcode`),
  ADD KEY `kategori` (`kategori`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indeks untuk tabel `user_profile`
--
ALTER TABLE `user_profile`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `food_history`
--
ALTER TABLE `food_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `food_products`
--
ALTER TABLE `food_products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `user_profile`
--
ALTER TABLE `user_profile`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `food_history`
--
ALTER TABLE `food_history`
  ADD CONSTRAINT `food_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `food_history_ibfk_2` FOREIGN KEY (`food_product_id`) REFERENCES `food_products` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `user_profile`
--
ALTER TABLE `user_profile`
  ADD CONSTRAINT `user_profile_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
