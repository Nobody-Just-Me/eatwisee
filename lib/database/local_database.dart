import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Local SQLite database untuk aplikasi standalone (tanpa backend)
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'eatwise_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        email TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel User Profile
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nama_lengkap TEXT,
        tanggal_lahir TEXT,
        usia INTEGER,
        berat_badan REAL,
        tinggi_badan REAL,
        riwayat_diabetes INTEGER DEFAULT 0,
        riwayat_kolesterol INTEGER DEFAULT 0,
        riwayat_hipertensi INTEGER DEFAULT 0,
        riwayat_jantung INTEGER DEFAULT 0,
        alergi_gluten INTEGER DEFAULT 0,
        alergi_kacang INTEGER DEFAULT 0,
        alergi_telur INTEGER DEFAULT 0,
        alergi_susu INTEGER DEFAULT 0,
        alergi_seafood INTEGER DEFAULT 0,
        notif_sarapan_aktif INTEGER DEFAULT 1,
        waktu_sarapan TEXT DEFAULT '07:00:00',
        notif_siang_aktif INTEGER DEFAULT 1,
        waktu_siang TEXT DEFAULT '12:30:00',
        notif_malam_aktif INTEGER DEFAULT 1,
        waktu_malam TEXT DEFAULT '19:00:00',
        target_kalori_harian INTEGER DEFAULT 2000,
        kalori_terkonsumsi_hari_ini INTEGER DEFAULT 0,
        tanggal_reset_kalori TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id)
      )
    ''');

    // Tabel Food Products
    await db.execute('''
      CREATE TABLE food_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT,
        nama_produk TEXT NOT NULL,
        merek TEXT,
        kategori TEXT,
        komposisi_bahan TEXT,
        serving_size TEXT DEFAULT '100g',
        kalori INTEGER DEFAULT 0,
        karbohidrat REAL DEFAULT 0,
        protein REAL DEFAULT 0,
        lemak_total REAL DEFAULT 0,
        lemak_jenuh REAL DEFAULT 0,
        gula REAL DEFAULT 0,
        garam REAL DEFAULT 0,
        serat REAL DEFAULT 0,
        mengandung_gluten INTEGER DEFAULT 0,
        mengandung_kacang INTEGER DEFAULT 0,
        mengandung_telur INTEGER DEFAULT 0,
        mengandung_susu INTEGER DEFAULT 0,
        mengandung_seafood INTEGER DEFAULT 0,
        tingkat_gula TEXT DEFAULT 'sedang',
        tingkat_garam TEXT DEFAULT 'sedang',
        tingkat_lemak TEXT DEFAULT 'sedang',
        image_url TEXT,
        status_verifikasi TEXT DEFAULT 'user_input',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel Food History
    await db.execute('''
      CREATE TABLE food_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        food_product_id INTEGER NOT NULL,
        tanggal TEXT NOT NULL,
        waktu TEXT NOT NULL,
        jenis_waktu_makan TEXT DEFAULT 'snack',
        jumlah_porsi REAL DEFAULT 1.0,
        kalori_dikonsumsi INTEGER DEFAULT 0,
        status_aman INTEGER DEFAULT 1,
        peringatan_alergi TEXT,
        peringatan_penyakit TEXT,
        catatan_user TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (food_product_id) REFERENCES food_products(id) ON DELETE CASCADE
      )
    ''');

    print('✅ Local database tables created');
    
    // Seed data produk makanan default
    await _seedDefaultProducts(db);
  }

  Future<void> _seedDefaultProducts(Database db) async {
    final products = [
      // ========== MINUMAN KEMASAN (INDOMARET/ALFAMART) ==========
      {
        'barcode': '8992761111001',
        'nama_produk': 'Ultra Milk Full Cream',
        'merek': 'Ultra Milk',
        'kategori': 'Minuman',
        'serving_size': '200ml',
        'kalori': 130,
        'karbohidrat': 9.6,
        'protein': 6.4,
        'lemak_total': 6.8,
        'gula': 9.6,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992761111002',
        'nama_produk': 'Ultra Milk Cokelat',
        'merek': 'Ultra Milk',
        'kategori': 'Minuman',
        'serving_size': '200ml',
        'kalori': 150,
        'karbohidrat': 22.0,
        'protein': 6.0,
        'lemak_total': 4.5,
        'gula': 18.0,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992753200001',
        'nama_produk': 'Indomilk Susu Kental Manis',
        'merek': 'Indomilk',
        'kategori': 'Minuman',
        'serving_size': '1 sachet (40g)',
        'kalori': 130,
        'karbohidrat': 22.0,
        'protein': 3.2,
        'lemak_total': 3.0,
        'gula': 20.0,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388100001',
        'nama_produk': 'Teh Botol Sosro',
        'merek': 'Sosro',
        'kategori': 'Minuman',
        'serving_size': '450ml',
        'kalori': 135,
        'karbohidrat': 33.0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 30.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388100002',
        'nama_produk': 'Teh Pucuk Harum',
        'merek': 'Mayora',
        'kategori': 'Minuman',
        'serving_size': '350ml',
        'kalori': 105,
        'karbohidrat': 26.0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 24.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8991002100001',
        'nama_produk': 'Coca Cola',
        'merek': 'Coca Cola',
        'kategori': 'Minuman',
        'serving_size': '330ml',
        'kalori': 139,
        'karbohidrat': 35.0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 35.0,
        'tingkat_gula': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8991002100002',
        'nama_produk': 'Sprite',
        'merek': 'Coca Cola',
        'kategori': 'Minuman',
        'serving_size': '330ml',
        'kalori': 132,
        'karbohidrat': 33.0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 33.0,
        'tingkat_gula': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8991002100003',
        'nama_produk': 'Fanta Jeruk',
        'merek': 'Coca Cola',
        'kategori': 'Minuman',
        'serving_size': '330ml',
        'kalori': 145,
        'karbohidrat': 36.0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 36.0,
        'tingkat_gula': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8996001300001',
        'nama_produk': 'Aqua Botol',
        'merek': 'Aqua',
        'kategori': 'Minuman',
        'serving_size': '600ml',
        'kalori': 0,
        'karbohidrat': 0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992745100001',
        'nama_produk': 'Pocari Sweat',
        'merek': 'Pocari Sweat',
        'kategori': 'Minuman',
        'serving_size': '500ml',
        'kalori': 135,
        'karbohidrat': 33.5,
        'protein': 0,
        'lemak_total': 0,
        'gula': 33.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992745100002',
        'nama_produk': 'Mizone',
        'merek': 'Mizone',
        'kategori': 'Minuman',
        'serving_size': '500ml',
        'kalori': 80,
        'karbohidrat': 20.0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 18.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8996006800001',
        'nama_produk': 'Yakult',
        'merek': 'Yakult',
        'kategori': 'Minuman',
        'serving_size': '65ml',
        'kalori': 50,
        'karbohidrat': 11.5,
        'protein': 0.8,
        'lemak_total': 0,
        'gula': 11.0,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388200001',
        'nama_produk': 'Fruit Tea Blackcurrant',
        'merek': 'Sosro',
        'kategori': 'Minuman',
        'serving_size': '350ml',
        'kalori': 112,
        'karbohidrat': 28.0,
        'protein': 0,
        'lemak_total': 0,
        'gula': 26.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992753300001',
        'nama_produk': 'Good Day Cappuccino',
        'merek': 'Good Day',
        'kategori': 'Minuman',
        'serving_size': '1 sachet (20g)',
        'kalori': 80,
        'karbohidrat': 14.0,
        'protein': 1.5,
        'lemak_total': 2.0,
        'gula': 12.0,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992753300002',
        'nama_produk': 'Kapal Api Special Mix',
        'merek': 'Kapal Api',
        'kategori': 'Minuman',
        'serving_size': '1 sachet (25g)',
        'kalori': 100,
        'karbohidrat': 18.0,
        'protein': 1.0,
        'lemak_total': 2.5,
        'gula': 16.0,
        'status_verifikasi': 'terverifikasi'
      },
      
      // ========== MIE INSTAN (INDOMARET/ALFAMART) ==========
      {
        'barcode': '8992761222001',
        'nama_produk': 'Indomie Goreng',
        'merek': 'Indomie',
        'kategori': 'Makanan Instan',
        'serving_size': '85g',
        'kalori': 390,
        'karbohidrat': 54.0,
        'protein': 8.5,
        'lemak_total': 16.0,
        'garam': 1.8,
        'mengandung_gluten': 1,
        'tingkat_garam': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992761222002',
        'nama_produk': 'Indomie Soto',
        'merek': 'Indomie',
        'kategori': 'Makanan Instan',
        'serving_size': '70g',
        'kalori': 330,
        'karbohidrat': 48.0,
        'protein': 7.0,
        'lemak_total': 12.0,
        'garam': 1.6,
        'mengandung_gluten': 1,
        'tingkat_garam': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992761222003',
        'nama_produk': 'Indomie Ayam Bawang',
        'merek': 'Indomie',
        'kategori': 'Makanan Instan',
        'serving_size': '70g',
        'kalori': 340,
        'karbohidrat': 50.0,
        'protein': 7.5,
        'lemak_total': 12.5,
        'garam': 1.7,
        'mengandung_gluten': 1,
        'tingkat_garam': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992761222004',
        'nama_produk': 'Indomie Kari Ayam',
        'merek': 'Indomie',
        'kategori': 'Makanan Instan',
        'serving_size': '80g',
        'kalori': 370,
        'karbohidrat': 52.0,
        'protein': 8.0,
        'lemak_total': 14.0,
        'garam': 1.8,
        'mengandung_gluten': 1,
        'tingkat_garam': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388300001',
        'nama_produk': 'Mie Sedaap Goreng',
        'merek': 'Mie Sedaap',
        'kategori': 'Makanan Instan',
        'serving_size': '90g',
        'kalori': 400,
        'karbohidrat': 56.0,
        'protein': 9.0,
        'lemak_total': 16.5,
        'garam': 1.9,
        'mengandung_gluten': 1,
        'tingkat_garam': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388300002',
        'nama_produk': 'Mie Sedaap Kari Spesial',
        'merek': 'Mie Sedaap',
        'kategori': 'Makanan Instan',
        'serving_size': '75g',
        'kalori': 350,
        'karbohidrat': 51.0,
        'protein': 7.5,
        'lemak_total': 13.0,
        'garam': 1.7,
        'mengandung_gluten': 1,
        'tingkat_garam': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8996001400001',
        'nama_produk': 'Pop Mie Rasa Ayam',
        'merek': 'Pop Mie',
        'kategori': 'Makanan Instan',
        'serving_size': '75g',
        'kalori': 360,
        'karbohidrat': 50.0,
        'protein': 7.0,
        'lemak_total': 14.0,
        'garam': 1.8,
        'mengandung_gluten': 1,
        'tingkat_garam': 'tinggi',
        'status_verifikasi': 'terverifikasi'
      },
      
      // ========== SNACK & BISKUIT (INDOMARET/ALFAMART) ==========
      {
        'barcode': '8992775100001',
        'nama_produk': 'Chitato Rasa Sapi Panggang',
        'merek': 'Chitato',
        'kategori': 'Snack',
        'serving_size': '68g',
        'kalori': 340,
        'karbohidrat': 38.0,
        'protein': 4.0,
        'lemak_total': 19.0,
        'garam': 0.8,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992775100002',
        'nama_produk': 'Chitato Rasa Keju',
        'merek': 'Chitato',
        'kategori': 'Snack',
        'serving_size': '68g',
        'kalori': 350,
        'karbohidrat': 39.0,
        'protein': 4.5,
        'lemak_total': 19.5,
        'garam': 0.9,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992775200001',
        'nama_produk': 'Lays Rumput Laut',
        'merek': 'Lays',
        'kategori': 'Snack',
        'serving_size': '68g',
        'kalori': 345,
        'karbohidrat': 40.0,
        'protein': 4.0,
        'lemak_total': 18.0,
        'garam': 0.7,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8996001500001',
        'nama_produk': 'Oreo Original',
        'merek': 'Oreo',
        'kategori': 'Biskuit',
        'serving_size': '3 keping (34g)',
        'kalori': 160,
        'karbohidrat': 25.0,
        'protein': 2.0,
        'lemak_total': 7.0,
        'gula': 14.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8996001500002',
        'nama_produk': 'Oreo Vanilla',
        'merek': 'Oreo',
        'kategori': 'Biskuit',
        'serving_size': '3 keping (34g)',
        'kalori': 165,
        'karbohidrat': 26.0,
        'protein': 2.0,
        'lemak_total': 7.0,
        'gula': 15.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992753400001',
        'nama_produk': 'Roma Kelapa',
        'merek': 'Roma',
        'kategori': 'Biskuit',
        'serving_size': '10 keping (120g)',
        'kalori': 580,
        'karbohidrat': 72.0,
        'protein': 8.0,
        'lemak_total': 28.0,
        'gula': 24.0,
        'mengandung_gluten': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992753400002',
        'nama_produk': 'Roma Malkist Crackers',
        'merek': 'Roma',
        'kategori': 'Biskuit',
        'serving_size': '10 keping (135g)',
        'kalori': 650,
        'karbohidrat': 85.0,
        'protein': 10.0,
        'lemak_total': 30.0,
        'gula': 18.0,
        'mengandung_gluten': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388400001',
        'nama_produk': 'Tango Wafer Cokelat',
        'merek': 'Tango',
        'kategori': 'Biskuit',
        'serving_size': '1 pack (47g)',
        'kalori': 240,
        'karbohidrat': 30.0,
        'protein': 3.0,
        'lemak_total': 12.0,
        'gula': 18.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388400002',
        'nama_produk': 'Beng Beng',
        'merek': 'Beng Beng',
        'kategori': 'Cokelat',
        'serving_size': '1 bar (26.5g)',
        'kalori': 130,
        'karbohidrat': 17.0,
        'protein': 2.0,
        'lemak_total': 6.0,
        'gula': 13.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'mengandung_kacang': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8992388400003',
        'nama_produk': 'SilverQueen Chunky Bar',
        'merek': 'SilverQueen',
        'kategori': 'Cokelat',
        'serving_size': '1 bar (45g)',
        'kalori': 240,
        'karbohidrat': 26.0,
        'protein': 3.5,
        'lemak_total': 14.0,
        'gula': 24.0,
        'mengandung_susu': 1,
        'mengandung_kacang': 1,
        'status_verifikasi': 'terverifikasi'
      },
      
      // ========== ROTI & BAKERY (INDOMARET/ALFAMART) ==========
      {
        'barcode': '8996006900001',
        'nama_produk': 'Roti Tawar Sari Roti',
        'merek': 'Sari Roti',
        'kategori': 'Roti',
        'serving_size': '2 lembar (60g)',
        'kalori': 160,
        'karbohidrat': 30.0,
        'protein': 5.0,
        'lemak_total': 2.5,
        'gula': 4.0,
        'mengandung_gluten': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8996006900002',
        'nama_produk': 'Roti Sobek Cokelat Sari Roti',
        'merek': 'Sari Roti',
        'kategori': 'Roti',
        'serving_size': '1 pack (70g)',
        'kalori': 240,
        'karbohidrat': 38.0,
        'protein': 6.0,
        'lemak_total': 7.0,
        'gula': 12.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'barcode': '8996006900003',
        'nama_produk': 'Roti Sandwich Keju Sari Roti',
        'merek': 'Sari Roti',
        'kategori': 'Roti',
        'serving_size': '1 pack (80g)',
        'kalori': 260,
        'karbohidrat': 40.0,
        'protein': 8.0,
        'lemak_total': 8.0,
        'gula': 8.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      
      // ========== MAKANAN CAFE ==========
      {
        'nama_produk': 'Nasi Goreng',
        'kategori': 'Makanan Berat',
        'serving_size': '1 piring (300g)',
        'kalori': 450,
        'karbohidrat': 62.0,
        'protein': 18.5,
        'lemak_total': 14.0,
        'serat': 3.5,
        'mengandung_telur': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Mie Goreng',
        'kategori': 'Makanan Berat',
        'serving_size': '1 piring (350g)',
        'kalori': 520,
        'karbohidrat': 68.0,
        'protein': 20.0,
        'lemak_total': 18.0,
        'serat': 4.0,
        'mengandung_gluten': 1,
        'mengandung_telur': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Nasi Padang',
        'kategori': 'Makanan Berat',
        'serving_size': '1 porsi (400g)',
        'kalori': 650,
        'karbohidrat': 70.0,
        'protein': 35.0,
        'lemak_total': 28.0,
        'serat': 5.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Gado-Gado',
        'kategori': 'Makanan Berat',
        'serving_size': '1 piring (300g)',
        'kalori': 350,
        'karbohidrat': 35.0,
        'protein': 15.0,
        'lemak_total': 18.0,
        'serat': 8.0,
        'mengandung_kacang': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Bakso',
        'kategori': 'Makanan Berkuah',
        'serving_size': '1 mangkuk (400ml)',
        'kalori': 350,
        'karbohidrat': 40.0,
        'protein': 18.0,
        'lemak_total': 12.0,
        'serat': 2.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Mie Ayam',
        'kategori': 'Makanan Berat',
        'serving_size': '1 mangkuk (350g)',
        'kalori': 420,
        'karbohidrat': 55.0,
        'protein': 22.0,
        'lemak_total': 14.0,
        'serat': 3.0,
        'mengandung_gluten': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Bubur Ayam',
        'kategori': 'Makanan Berat',
        'serving_size': '1 mangkuk (350g)',
        'kalori': 280,
        'karbohidrat': 42.0,
        'protein': 16.0,
        'lemak_total': 6.0,
        'serat': 1.5,
        'status_verifikasi': 'terverifikasi'
      },
      // Lauk Pauk
      {
        'nama_produk': 'Rendang',
        'kategori': 'Lauk Pauk',
        'serving_size': '1 potong (150g)',
        'kalori': 380,
        'karbohidrat': 8.0,
        'protein': 28.0,
        'lemak_total': 26.0,
        'serat': 2.5,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Sate',
        'kategori': 'Lauk Pauk',
        'serving_size': '10 tusuk (200g)',
        'kalori': 320,
        'karbohidrat': 12.0,
        'protein': 32.0,
        'lemak_total': 16.0,
        'serat': 2.0,
        'mengandung_kacang': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Ayam Goreng',
        'kategori': 'Lauk Pauk',
        'serving_size': '1 potong (150g)',
        'kalori': 420,
        'karbohidrat': 8.0,
        'protein': 35.0,
        'lemak_total': 28.0,
        'serat': 1.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Ayam Bakar',
        'kategori': 'Lauk Pauk',
        'serving_size': '1 potong (160g)',
        'kalori': 380,
        'karbohidrat': 10.0,
        'protein': 36.0,
        'lemak_total': 22.0,
        'serat': 1.5,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Ikan Goreng',
        'kategori': 'Lauk Pauk',
        'serving_size': '1 ekor (180g)',
        'kalori': 280,
        'karbohidrat': 5.0,
        'protein': 30.0,
        'lemak_total': 15.0,
        'serat': 1.0,
        'mengandung_seafood': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Pecel Lele',
        'kategori': 'Lauk Pauk',
        'serving_size': '1 porsi (200g)',
        'kalori': 320,
        'karbohidrat': 12.0,
        'protein': 28.0,
        'lemak_total': 18.0,
        'serat': 3.0,
        'mengandung_seafood': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Opor Ayam',
        'kategori': 'Lauk Pauk',
        'serving_size': '1 potong + kuah (200g)',
        'kalori': 380,
        'karbohidrat': 12.0,
        'protein': 28.0,
        'lemak_total': 26.0,
        'serat': 2.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Tempe Goreng',
        'kategori': 'Lauk Pauk',
        'serving_size': '5 potong (100g)',
        'kalori': 180,
        'karbohidrat': 10.0,
        'protein': 12.0,
        'lemak_total': 11.0,
        'serat': 4.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Tahu Goreng',
        'kategori': 'Lauk Pauk',
        'serving_size': '5 potong (100g)',
        'kalori': 150,
        'karbohidrat': 8.0,
        'protein': 10.0,
        'lemak_total': 9.0,
        'serat': 2.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Telur Dadar',
        'kategori': 'Lauk Pauk',
        'serving_size': '1 porsi (80g)',
        'kalori': 140,
        'karbohidrat': 1.0,
        'protein': 10.0,
        'lemak_total': 11.0,
        'serat': 0.0,
        'mengandung_telur': 1,
        'status_verifikasi': 'terverifikasi'
      },
      // Makanan Berkuah
      {
        'nama_produk': 'Soto',
        'kategori': 'Makanan Berkuah',
        'serving_size': '1 mangkuk (350ml)',
        'kalori': 280,
        'karbohidrat': 32.0,
        'protein': 22.0,
        'lemak_total': 8.0,
        'serat': 3.0,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Rawon',
        'kategori': 'Makanan Berkuah',
        'serving_size': '1 mangkuk (350ml)',
        'kalori': 320,
        'karbohidrat': 18.0,
        'protein': 26.0,
        'lemak_total': 16.0,
        'serat': 3.5,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Sop Buntut',
        'kategori': 'Makanan Berkuah',
        'serving_size': '1 mangkuk (400ml)',
        'kalori': 380,
        'karbohidrat': 18.0,
        'protein': 24.0,
        'lemak_total': 24.0,
        'serat': 3.0,
        'status_verifikasi': 'terverifikasi'
      },
      // Fast Food
      {
        'nama_produk': 'Burger',
        'kategori': 'Fast Food',
        'serving_size': '1 burger (250g)',
        'kalori': 540,
        'karbohidrat': 45.0,
        'protein': 28.0,
        'lemak_total': 26.0,
        'serat': 3.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Pizza',
        'kategori': 'Fast Food',
        'serving_size': '2 slice (200g)',
        'kalori': 620,
        'karbohidrat': 68.0,
        'protein': 24.0,
        'lemak_total': 28.0,
        'serat': 4.0,
        'mengandung_gluten': 1,
        'mengandung_susu': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'French Fries',
        'kategori': 'Snack',
        'serving_size': '1 porsi (150g)',
        'kalori': 365,
        'karbohidrat': 48.0,
        'protein': 4.0,
        'lemak_total': 17.0,
        'serat': 4.5,
        'status_verifikasi': 'terverifikasi'
      },
      // Snack
      {
        'nama_produk': 'Pisang Goreng',
        'kategori': 'Snack',
        'serving_size': '3 potong (120g)',
        'kalori': 220,
        'karbohidrat': 38.0,
        'protein': 3.0,
        'lemak_total': 8.0,
        'serat': 3.0,
        'mengandung_gluten': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Bakwan',
        'kategori': 'Snack',
        'serving_size': '3 buah (100g)',
        'kalori': 180,
        'karbohidrat': 22.0,
        'protein': 4.0,
        'lemak_total': 9.0,
        'serat': 2.5,
        'mengandung_gluten': 1,
        'status_verifikasi': 'terverifikasi'
      },
      {
        'nama_produk': 'Pempek',
        'kategori': 'Snack',
        'serving_size': '3 potong (180g)',
        'kalori': 280,
        'karbohidrat': 38.0,
        'protein': 14.0,
        'lemak_total': 8.0,
        'serat': 1.5,
        'mengandung_seafood': 1,
        'status_verifikasi': 'terverifikasi'
      },
    ];

    for (var product in products) {
      await db.insert('food_products', product);
    }

    print('✅ Seeded ${products.length} default products');
  }

  // ==================== USER METHODS ====================

  Future<Map<String, dynamic>?> registerUser(String username, String password, String? email) async {
    final db = await database;
    
    try {
      // Hash password
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      
      final userId = await db.insert('users', {
        'username': username,
        'password': hashedPassword,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Create default profile
      await db.insert('user_profile', {
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return {
        'id': userId,
        'username': username,
        'email': email,
      };
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    
    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, hashedPassword],
      );

      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // ==================== PROFILE METHODS ====================

  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    final db = await database;
    
    try {
      final result = await db.query(
        'user_profile',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(int userId, Map<String, dynamic> profileData) async {
    final db = await database;
    
    try {
      profileData['updated_at'] = DateTime.now().toIso8601String();
      
      final count = await db.update(
        'user_profile',
        profileData,
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      return count > 0;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // ==================== FOOD PRODUCT METHODS ====================

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await database;
    
    try {
      final result = await db.query(
        'food_products',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );

      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  Future<int> addProduct(Map<String, dynamic> productData) async {
    final db = await database;
    
    try {
      productData['created_at'] = DateTime.now().toIso8601String();
      productData['updated_at'] = DateTime.now().toIso8601String();
      
      return await db.insert('food_products', productData);
    } catch (e) {
      print('Error adding product: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllProducts({int limit = 50, int offset = 0}) async {
    final db = await database;
    
    try {
      return await db.query(
        'food_products',
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  // ==================== FOOD HISTORY METHODS ====================

  Future<int> addFoodHistory(Map<String, dynamic> historyData) async {
    final db = await database;
    
    try {
      historyData['created_at'] = DateTime.now().toIso8601String();
      
      return await db.insert('food_history', historyData);
    } catch (e) {
      print('Error adding food history: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getTodayHistory(int userId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    try {
      return await db.rawQuery('''
        SELECT fh.*, fp.nama_produk, fp.merek, fp.kalori as product_kalori
        FROM food_history fh
        JOIN food_products fp ON fh.food_product_id = fp.id
        WHERE fh.user_id = ? AND fh.tanggal = ?
        ORDER BY fh.waktu DESC
      ''', [userId, today]);
    } catch (e) {
      print('Error getting today history: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryByDateRange(
    int userId, {
    String? startDate,
    String? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    
    try {
      String whereClause = 'fh.user_id = ?';
      List<dynamic> whereArgs = [userId];

      if (startDate != null) {
        whereClause += ' AND fh.tanggal >= ?';
        whereArgs.add(startDate);
      }

      if (endDate != null) {
        whereClause += ' AND fh.tanggal <= ?';
        whereArgs.add(endDate);
      }

      return await db.rawQuery('''
        SELECT fh.*, fp.nama_produk, fp.merek, fp.kalori as product_kalori
        FROM food_history fh
        JOIN food_products fp ON fh.food_product_id = fp.id
        WHERE $whereClause
        ORDER BY fh.tanggal DESC, fh.waktu DESC
        LIMIT ? OFFSET ?
      ''', [...whereArgs, limit, offset]);
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }

  Future<bool> deleteHistory(int historyId) async {
    final db = await database;
    
    try {
      final count = await db.delete(
        'food_history',
        where: 'id = ?',
        whereArgs: [historyId],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting history: $e');
      return false;
    }
  }

  // ==================== UTILITY METHODS ====================

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'eatwise_local.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
