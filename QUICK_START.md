# 🚀 QUICK START - AI Food Detection

## Langkah Cepat Testing (5 Menit)

### 1️⃣ Install Dependencies
```bash
flutter pub get
```

### 2️⃣ Run di Windows
```bash
flutter run -d windows
```

### 3️⃣ Testing Fitur AI
1. Login ke aplikasi
2. Di Home Screen, tap card **"AI Deteksi Makanan"** (icon kamera)
3. Tap tombol **"Pilih Gambar"**
4. Pilih foto makanan Indonesia (Nasi Goreng, Rendang, Sate, dll)
5. Lihat hasil prediksi!

---

## 📱 Run di Android

### Setup Android Device/Emulator
```bash
# Cek devices
flutter devices

# Run di device
flutter run -d <device-id>
```

---

## 🎯 Apa yang Baru?

### File Baru:
- ✅ `lib/page/food_detection_screen.dart` - UI untuk AI detection
- ✅ `lib/services/food_classifier.dart` - AI service
- ✅ `assets/models/eatwise_float16.tflite` - Model AI
- ✅ `assets/models/labels.txt` - 13 kategori makanan

### File yang Diupdate:
- ✅ `pubspec.yaml` - Tambah `tflite_flutter` & `image`
- ✅ `lib/page/home_integrated.dart` - Tambah card baru

### TIDAK ADA yang Diubah:
- ✅ Login/Sign up flow tetap sama
- ✅ Scan barcode tetap berfungsi
- ✅ Profile & history tetap sama
- ✅ Semua fitur existing tetap jalan

---

## 🍽️ 13 Makanan yang Bisa Dideteksi

1. Ayam Goreng
2. Burger
3. French Fries
4. Gado-Gado
5. Ikan Goreng
6. Mie Goreng
7. Nasi Goreng
8. Nasi Padang
9. Pizza
10. Rawon
11. Rendang
12. Sate
13. Soto

---

## 🐛 Jika Ada Error

### Error: Model tidak dimuat
```bash
# Rebuild dari awal
flutter clean
flutter pub get
flutter run
```

### Error: Camera permission
- **Windows**: Cek Settings → Privacy → Camera
- **Android**: App akan auto-request permission

---

## 📚 Dokumentasi Lengkap

Lihat file: `AI_FOOD_DETECTION_GUIDE.md`

---

**Happy Testing! 🎉**
