# EatWise

Aplikasi pelacak nutrisi makanan Indonesia berbasis Flutter. Berjalan 100% offline menggunakan SQLite lokal.

## Fitur

- **Registrasi & Login** — autentikasi lokal dengan password SHA-256
- **AI Food Detection** — deteksi makanan via kamera/galeri menggunakan TFLite (13 kategori)
- **Color-Based Detection** — fallback otomatis berbasis analisis warna dominan (15+ pola)
- **Dual Detection** — AI dan color detection berjalan paralel, sistem pilih hasil terbaik
- **Manual Selection** — pilih dari 47 makanan Indonesia jika deteksi otomatis kurang akurat
- **Barcode Scanner** — scan produk kemasan (35+ produk Indomaret/Alfamart)
- **Detail Nutrisi** — kalori, protein, karbohidrat, lemak, serat, gula, sodium
- **Riwayat Makan** — log makanan harian (breakfast/lunch/dinner/snack)
- **Profil Pengguna** — data BMI dan target kalori harian

## Teknologi

- Flutter (Dart)
- SQLite via `sqflite` — database lokal offline
- TensorFlow Lite via `tflite_flutter` — model klasifikasi makanan
- `image` package — preprocessing gambar & analisis warna
- `mobile_scanner` — barcode scanning
- `crypto` — hashing password SHA-256

## Struktur Proyek

```
lib/
├── database/
│   └── local_database.dart       # SQLite: users, profile, food, history
├── page/
│   ├── home_integrated.dart      # Home screen
│   ├── food_detection_screen.dart # AI + Color detection UI
│   └── ...
├── services/
│   ├── food_classifier.dart      # TFLite inference (13 kelas)
│   ├── color_based_detector.dart # Deteksi berbasis warna RGB
│   ├── food_mapping_service.dart # Mapping 13 AI → 47 makanan
│   ├── profile_service_local.dart
│   └── history_service_local.dart
├── models/
└── util/
assets/
├── models/
│   ├── eatwise_float16.tflite    # Model AI (13 kelas)
│   └── labels.txt
└── data/
    └── foods_data_extended.json  # Data nutrisi 47 makanan
```

## Cara Kerja Deteksi Makanan

```
Foto makanan
    ↓
AI Detection (TFLite) + Color Detection (RGB) — berjalan paralel
    ↓
Jika AI confidence ≥ 50%  → Gunakan AI
Jika AI confidence < 50%  → Gunakan Color (jika lebih baik)
    ↓
Tampilkan hasil + Similar Foods chips
    ↓
Manual Selection tersedia jika keduanya kurang akurat
```

### Akurasi Color Detection (per kategori warna):
| Makanan | Confidence |
|---------|-----------|
| Nasi Kuning | 72% |
| Rawon | 70% |
| Nasi Putih | 70% |
| Soto | 70% |
| Gado-Gado | 68% |
| Rendang | 68% |
| Nasi Goreng | 65% |
| French Fries | 65% |

## Setup & Build

```bash
flutter pub get
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Catatan AI Model

Model saat ini (`eatwise_float16.tflite`) terlatih untuk 13 kategori makanan. Akurasi AI masih rendah karena dataset training terbatas. Untuk meningkatkan akurasi, training ulang model diperlukan menggunakan `train_food_model.py` dengan dataset minimal 100 foto per kategori.

Sementara itu, color-based detection dan manual selection tersedia sebagai alternatif.

## APK Terbaru

`~/EatWise_v6.0_ColorDetection.apk` — v6.0 dengan dual detection (AI + Color)
