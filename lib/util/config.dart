import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
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
