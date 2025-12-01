import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
<<<<<<< HEAD
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
=======
  // ============================================
  // SETTING: Ganti ini sesuai device yang dipakai
  // ============================================
  static const bool usePhysicalDevice =
      true; // true = HP Fisik, false = Emulator/Simulator

  // IP Laptop kamu (untuk HP fisik)
  static const String laptopIP = '172.30.203.28'; // IP Hotspot HP (UPDATED!)

  // ============================================
  // BASE URL (Otomatis sesuai device)
  // =================================R==========
  static String get baseUrl {
    // Kalau pakai HP fisik
    if (usePhysicalDevice) {
      return 'http://172.30.203.28/eatwise2/eatwise2';
    }

    // Kalau Web (Chrome)
    if (kIsWeb) {
      return 'http://172.30.203.28/eatwise2/eatwise2';
    }

    // Kalau Android Emulator
    if (Platform.isAndroid) {
      return 'http://172.30.203.28/eatwise2/eatwise2';
    }

    // Kalau iOS Simulator
    if (Platform.isIOS) {
      return 'http://172.30.203.28/eatwise2/eatwise2';
    }

    // Default (fallback)
    return 'http://172.30.203.28/eatwise2/eatwise2';
  }
}
>>>>>>> af8bcff80bbb7862575f8457830e3e0a25a304cd
