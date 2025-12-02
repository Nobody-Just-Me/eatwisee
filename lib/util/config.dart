import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // ⚠️ PENTING: Sesuaikan dengan nama folder project di htdocs Anda
  // Apakah 'eatwise2', 'EatWise2.0', atau 'eatwise2/EatWise2.0'?
  // Saya ambil berdasarkan kode terakhir Anda:
  static const String _projectPath = 'EatWise2.0'; 

  static String get baseUrl {
    // 1. Jika dijalankan di Web (Chrome)
    if (kIsWeb) {
      return 'http://localhost/$_projectPath';
    }

    // 2. Jika dijalankan di Android (Emulator & Fisik)
    if (Platform.isAndroid) {
      // Deteksi apakah ini Emulator atau HP Fisik
      // Cara gampang: Asumsi default Emulator dulu untuk kasus Anda
      
      // KHUSUS EMULATOR ANDROID:
      // Emulator melihat "localhost" laptop Anda sebagai "10.0.2.2"
      return 'http://10.0.2.2/$_projectPath';
      
      /* CATATAN: Jika nanti pakai HP Fisik, ganti baris di atas jadi:
         return 'http://192.168.1.XX/$_projectPath'; (IP Laptop)
      */
    }

    // 3. Jika dijalankan di iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost/$_projectPath';
    }

    // Default Fallback
    return 'http://localhost/$_projectPath';
  }
}