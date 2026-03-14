import 'package:eatwise2/database/local_database.dart';

/// Local Profile Service - Menggunakan SQLite (tidak perlu backend)
class ProfileServiceLocal {
  static final LocalDatabase _db = LocalDatabase();

  // ============================================
  // GET USER PROFILE
  // ============================================
  static Future<Map<String, dynamic>?> getProfile(int userId) async {
    try {
      final profile = await _db.getUserProfile(userId);
      
      if (profile != null) {
        // Parse data dengan type conversion yang aman
        return {
          'user_id': userId,
          'nama_lengkap': profile['nama_lengkap']?.toString(),
          'tanggal_lahir': profile['tanggal_lahir']?.toString(),
          'usia': _parseInt(profile['usia']),
          'berat_badan': _parseDouble(profile['berat_badan']),
          'tinggi_badan': _parseDouble(profile['tinggi_badan']),
          'riwayat_diabetes': _parseInt(profile['riwayat_diabetes']),
          'riwayat_kolesterol': _parseInt(profile['riwayat_kolesterol']),
          'riwayat_hipertensi': _parseInt(profile['riwayat_hipertensi']),
          'riwayat_jantung': _parseInt(profile['riwayat_jantung']),
          'alergi_gluten': _parseInt(profile['alergi_gluten']),
          'alergi_kacang': _parseInt(profile['alergi_kacang']),
          'alergi_telur': _parseInt(profile['alergi_telur']),
          'alergi_susu': _parseInt(profile['alergi_susu']),
          'alergi_seafood': _parseInt(profile['alergi_seafood']),
          'notif_sarapan_aktif': _parseInt(profile['notif_sarapan_aktif']),
          'waktu_sarapan': profile['waktu_sarapan']?.toString() ?? '07:00:00',
          'notif_siang_aktif': _parseInt(profile['notif_siang_aktif']),
          'waktu_siang': profile['waktu_siang']?.toString() ?? '12:30:00',
          'notif_malam_aktif': _parseInt(profile['notif_malam_aktif']),
          'waktu_malam': profile['waktu_malam']?.toString() ?? '19:00:00',
          'target_kalori_harian': _parseInt(profile['target_kalori_harian']),
          'kalori_terkonsumsi_hari_ini': _parseInt(profile['kalori_terkonsumsi_hari_ini']),
        };
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }

  // ============================================
  // SAVE PROFILE (Create atau Update)
  // ============================================
  static Future<bool> saveProfile(
      int userId, Map<String, dynamic> profileData) async {
    try {
      // Update profile di database lokal
      final success = await _db.updateUserProfile(userId, profileData);
      
      if (success) {
        print('✅ Profile berhasil disimpan ke local database');
      } else {
        print('❌ Gagal menyimpan profile');
      }
      
      return success;
    } catch (e) {
      print('❌ Error saving profile: $e');
      return false;
    }
  }

  // ============================================
  // HELPER FUNCTIONS
  // ============================================

  /// Parse integer dengan aman (handle String/int/null)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// Parse double dengan aman (handle String/double/int/null)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Convert TimeOfDay ke String format HH:MM:SS
  static String timeOfDayToString(int hour, int minute) {
    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr:00';
  }

  /// Parse String waktu ke Map (untuk TimeOfDay)
  static Map<String, int> parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      return {
        'hour': int.parse(parts[0]),
        'minute': int.parse(parts[1]),
      };
    } catch (e) {
      print("⚠️ Gagal parse waktu '$timeString', gunakan default");
      return {
        'hour': 7,
        'minute': 0,
      };
    }
  }

  /// Hitung usia dari tanggal lahir
  static int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Parse tanggal lahir dari String
  static DateTime? parseBirthDate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String) {
        if (dateValue.isEmpty) return null;
        return DateTime.parse(dateValue);
      }
      if (dateValue is DateTime) {
        return dateValue;
      }
      return null;
    } catch (e) {
      print("⚠️ Gagal parse tanggal: $dateValue");
      return null;
    }
  }
}
