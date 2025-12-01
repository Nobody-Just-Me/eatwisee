# 🍽️ Panduan Integrasi AI Food Detection - EatWise2

## ✅ Instalasi Selesai!

Model AI TensorFlow Lite untuk deteksi makanan Indonesia telah berhasil diintegrasikan ke aplikasi Flutter Anda.

---

## 📁 Struktur File yang Ditambahkan

```
eatwise2/
├── assets/
│   └── models/
│       ├── eatwise_float16.tflite  ✅ (5.8 MB)
│       └── labels.txt               ✅ (13 kategori makanan)
├── lib/
│   ├── page/
│   │   └── food_detection_screen.dart  ✅ (UI screen baru)
│   └── services/
│       └── food_classifier.dart        ✅ (Service AI)
└── pubspec.yaml                        ✅ (Updated)
```

---

## 🎯 13 Kategori Makanan yang Didukung

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

## 🚀 Cara Testing

### Step 1: Install Dependencies

```bash
flutter pub get
```

**Catatan:** Jika muncul error saat `flutter pub get`, pastikan Anda sudah menambahkan repository TFLite:

Di file `pubspec.yaml`, dependencies `tflite_flutter` dan `image` sudah ditambahkan.

### Step 2: Build untuk Windows (Desktop)

```bash
flutter build windows
```

atau langsung run:

```bash
flutter run -d windows
```

### Step 3: Build untuk Android

```bash
flutter build apk
```

atau untuk testing langsung:

```bash
flutter run -d <device-id>
```

Cek device yang tersedia:
```bash
flutter devices
```

---

## 📱 Cara Menggunakan Fitur AI

### Di Home Screen:

1. **Buka aplikasi** → Login jika belum
2. **Di Home Screen**, Anda akan melihat **card baru** dengan icon kamera berlabel **"AI Deteksi Makanan"**
3. **Tap card tersebut** untuk membuka AI Food Detection Screen

### Di AI Food Detection Screen:

1. **Tap tombol "Pilih Gambar"** (floating action button di bawah)
2. **Pilih sumber gambar:**
   - 📷 **Kamera** - Ambil foto langsung
   - 🖼️ **Galeri** - Pilih dari galeri
3. **Setelah memilih gambar**, AI akan **otomatis menganalisis**
4. **Lihat hasil deteksi:**
   - Nama makanan yang terdeteksi
   - Tingkat keyakinan (confidence score)
   - Top 3 prediksi alternatif
   - Waktu inferensi (dalam milliseconds)

---

## 🧪 Testing Scenarios

### Test 1: Basic Functionality
- [ ] Buka app dan login
- [ ] Tap card "AI Deteksi Makanan"
- [ ] Verifikasi model dimuat dengan muncul snackbar "Model AI siap!"
- [ ] Tap "Pilih Gambar"
- [ ] Pilih gambar dari galeri
- [ ] Verifikasi hasil prediksi muncul

### Test 2: Camera Integration
- [ ] Tap "Pilih Gambar"
- [ ] Pilih "Kamera"
- [ ] Ambil foto makanan
- [ ] Verifikasi foto ter-preview
- [ ] Verifikasi hasil prediksi muncul

### Test 3: Multiple Images
- [ ] Test dengan berbagai jenis makanan
- [ ] Verifikasi confidence score bervariasi
- [ ] Cek top 3 predictions untuk setiap gambar

### Test 4: Error Handling
- [ ] Test dengan gambar bukan makanan
- [ ] Test dengan gambar blur/gelap
- [ ] Verifikasi app tidak crash

---

## ⚙️ Konfigurasi Platform

### Windows (Desktop)
Tidak perlu konfigurasi tambahan. Sudah siap digunakan!

### Android

#### 1. Pastikan minSdkVersion minimal 21

File: `android/app/build.gradle.kts`

```kotlin
android {
    defaultConfig {
        minSdk = 21  // Minimal SDK 21
        targetSdk = 34
    }
}
```

#### 2. Tambahkan permissions di AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions untuk camera dan storage -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <!-- Permission untuk Android 13+ -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

---

## 🐛 Troubleshooting

### Problem 1: "Model tidak bisa dimuat"
**Solusi:**
- Pastikan file `eatwise_float16.tflite` dan `labels.txt` ada di folder `assets/models/`
- Run `flutter pub get`
- Rebuild project: `flutter clean && flutter pub get && flutter run`

### Problem 2: "Gagal membuka kamera"
**Solusi:**
- Pastikan permissions sudah ditambahkan di AndroidManifest.xml
- Untuk Windows, pastikan aplikasi memiliki akses kamera di Windows Settings

### Problem 3: "Error saat pick image dari galeri"
**Solusi:**
- Pastikan dependency `image_picker` sudah terinstall
- Cek permissions READ_EXTERNAL_STORAGE sudah ada

### Problem 4: Build error di Android
**Solusi:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem 5: TFLite library tidak ditemukan
**Solusi:**
- Pastikan `tflite_flutter: ^0.10.4` ada di pubspec.yaml
- Run `flutter pub upgrade`

---

## 🎨 Customization

### Mengubah Warna/Style

Edit file: `lib/page/food_detection_screen.dart`

```dart
static const Color brandGreen = Color(0xFF13721C);  // Ganti warna brand
static const Color bgColor = Color.fromARGB(255, 170, 184, 171);  // Background
static const Color cardColor = Color.fromARGB(255, 230, 238, 230);  // Card color
```

### Mengubah Ukuran Gambar Input

Edit file: `lib/services/food_classifier.dart`

```dart
final XFile? image = await picker.pickImage(
  source: source,
  maxWidth: 1024,   // Ganti ukuran max
  maxHeight: 1024,
  imageQuality: 85,  // Quality 0-100
);
```

---

## 📊 Performance

### Model Specs:
- **Ukuran:** 5.8 MB (float16 quantized)
- **Input:** 224x224x3 RGB image
- **Output:** 13 class probabilities
- **Inference Time:** ~50-200ms (tergantung device)

### Optimizations:
- ✅ Model menggunakan float16 untuk ukuran lebih kecil
- ✅ Image otomatis di-resize ke 224x224
- ✅ Singleton pattern untuk FoodClassifier (load model sekali)
- ✅ Async/await untuk non-blocking UI

---

## 🔐 Best Practices yang Sudah Diterapkan

1. ✅ **Singleton Pattern** - FoodClassifier hanya load model 1x
2. ✅ **Error Handling** - Try-catch di semua operasi
3. ✅ **Loading States** - UI feedback untuk setiap state
4. ✅ **Mounted Check** - Cek `mounted` sebelum setState
5. ✅ **Clean Code** - Kode terorganisir dan mudah dibaca
6. ✅ **No Breaking Changes** - Tidak mengubah code existing Anda

---

## 📝 Notes Penting

### Permissions Runtime (Android 6.0+)
Plugin `image_picker` dan `permission_handler` sudah otomatis handle runtime permissions. Tidak perlu kode tambahan.

### iOS Support
Untuk iOS, tambahkan di `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses kamera untuk deteksi makanan</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi membutuhkan akses galeri untuk memilih foto makanan</string>
```

### Web Support
TensorFlow Lite belum sepenuhnya support Flutter Web. Fitur ini hanya untuk Mobile & Desktop.

---

## 🎓 Cara Kerja AI

1. **Load Model**: Model TFLite dimuat ke memory saat screen pertama kali dibuka
2. **Image Preprocessing**: 
   - Resize ke 224x224 pixels
   - Convert ke RGB Float32 array
   - Normalisasi nilai pixel
3. **Inference**: Model memproses gambar dan menghasilkan probabilitas untuk 13 kelas
4. **Postprocessing**: 
   - Sort hasil berdasarkan confidence
   - Ambil top 3 predictions
   - Format hasil untuk ditampilkan

---

## 🆘 Support

Jika ada masalah:
1. Cek error di console: `flutter run --verbose`
2. Pastikan semua dependencies terinstall
3. Verifikasi file model ada di assets/models/
4. Rebuild project dari scratch

---

## ✨ Fitur yang Sudah Terintegrasi

- ✅ UI Screen baru untuk AI detection
- ✅ Integration dengan Home Screen (card baru)
- ✅ Camera & Gallery picker
- ✅ Real-time image preview
- ✅ AI inference dengan TFLite
- ✅ Top 3 predictions display
- ✅ Confidence score visualization
- ✅ Loading & error states
- ✅ Cross-platform support (Windows + Android)

---

**Selamat mencoba! 🎉**

_Jangan lupa test dengan berbagai jenis makanan Indonesia!_
