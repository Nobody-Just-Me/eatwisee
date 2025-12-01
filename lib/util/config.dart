  import 'dart:io' show Platform;
  import 'package:flutter/foundation.dart' show kIsWeb;
  class AppConfig {



    static const String laptopIP = '172.24.121.82';

    // static const String API_ENDPOINT = "http://10.0.2.2/eatwise2/";
    static String get baseUrl {
      if (kIsWeb) {
        // Untuk Web (Chrome)
        return 'http://172.24.121.82/EatWise2.0'; 
      }
      if (Platform.isAndroid) {
        // Untuk Android Emulator
        return 'http://172.24.121.82/EatWise2.0';
      }
      if (Platform.isIOS) {
        // Untuk iOS Simulator
        return 'http://172.24.121.82/EatWise2.0';
      }
      // Default
      return 'http://172.24.121.82/EatWise2.0';
    }
  }
//   import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;

// class AppConfig {
//   // ============================================
//   // SETTING: Ganti ini sesuai device yang dipakai
//   // ============================================
//   static const bool usePhysicalDevice = true; // true = HP Fisik, false = Emulator/Simulator
  
//   // IP Laptop kamu (untuk HP fisik)
//   // static const String laptopIP = '10.252.145.7'; 
//   // // ← DIUBAH INI!

//   static const String laptopIP = '10.252.149.149';

//   // ============================================
//   // BASE URL (Otomatis sesuai device)
//   // ============================================
//   static String get baseUrl {
//     // Kalau pakai HP fisik
//     if (usePhysicalDevice) {
//       // return 'http://$laptopIP/eatwise2/EatWise2.0';
//       return 'http://10.0.2.2/eatwise2/EatWise2.0';
//     }
    
//     // Kalau Web (Chrome)
//     if (kIsWeb) {
//       return 'http://localhost/eatwise2/EatWise2.0';
//     }
    
//     // Kalau Android Emulator
//     if (Platform.isAndroid) {
//       return 'http://10.0.2.2/eatwise2/EatWise2.0';
//     }
    
//     // Kalau iOS Simulator
//     if (Platform.isIOS) {
//       return 'http://localhost/eatwise2/EatWise2.0';
//     }
    
//     // Default (fallback)
//     return 'http://localhost/eatwise2/EatWise2.0';
//   }
// }