import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eatwise2/util/config.dart';

class ProfileService {
  // ============================================
  // GET USER PROFILE
  // ============================================
  static Future<Map<String, dynamic>?> getProfile(int userId) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📡 GET PROFILE - User ID: $userId");
      print("🔗 URL: ${AppConfig.baseUrl}/api/get_profile.php?user_id=$userId");

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/get_profile.php?user_id=$userId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server tidak merespon');
        },
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          print("✅ Profile berhasil dimuat");
          print("📋 Data: ${jsonData['data']}");

          // Parse data dengan type conversion yang aman
          Map<String, dynamic> profileData =
              _parseProfileData(jsonData['data']);

          print("✅ Data setelah parsing: $profileData");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

          return profileData;
        } else {
          print("⚠️ Profile tidak ditemukan atau data kosong");
          print("📋 Response: $jsonData");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          return null;
        }
      } else if (response.statusCode == 404) {
        print("⚠️ Profile belum ada (404)");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        return null;
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        print("📦 Body: ${response.body}");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        return null;
      }
    } catch (e, stackTrace) {
      print("❌ EXCEPTION di getProfile: $e");
      print("📍 Stack trace: $stackTrace");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      return null;
    }
  }

  // ============================================
  // PARSE PROFILE DATA (Handle String/Int/Double)
  // ============================================
  static Map<String, dynamic> _parseProfileData(Map<String, dynamic> rawData) {
    return {
      'user_id': _parseInt(rawData['user_id']),
      'nama_lengkap': rawData['nama_lengkap']?.toString(),
      'tanggal_lahir': rawData['tanggal_lahir']?.toString(),
      'berat_badan': _parseDouble(rawData['berat_badan']),
      'tinggi_badan': _parseDouble(rawData['tinggi_badan']),
      'riwayat_diabetes': _parseInt(rawData['riwayat_diabetes']),
      'riwayat_kolesterol': _parseInt(rawData['riwayat_kolesterol']),
      'riwayat_hipertensi': _parseInt(rawData['riwayat_hipertensi']),
      'bahan_dihindari': rawData['bahan_dihindari']?.toString() ?? '',
      'waktu_sarapan': rawData['waktu_sarapan']?.toString() ?? '07:00:00',
      'waktu_siang': rawData['waktu_siang']?.toString() ?? '12:30:00',
      'waktu_malam': rawData['waktu_malam']?.toString() ?? '19:00:00',
      'notif_sarapan_aktif': _parseInt(rawData['notif_sarapan_aktif']),
      'notif_siang_aktif': _parseInt(rawData['notif_siang_aktif']),
      'notif_malam_aktif': _parseInt(rawData['notif_malam_aktif']),
    };
  }

  // ============================================
  // SAVE PROFILE (Create atau Update)
  // ============================================
  static Future<bool> saveProfile(
      int userId, Map<String, dynamic> profileData) async {
    try {
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      print("📡 SAVE PROFILE - User ID: $userId");
      print("🔗 URL: ${AppConfig.baseUrl}/api/update_profile.php");

      // Prepare body request
      Map<String, String> body = {
        'user_id': userId.toString(),
      };

      // Tambahkan semua data profile
      profileData.forEach((key, value) {
        if (value != null) {
          body[key] = value.toString();
        }
      });

      print("📤 Data yang dikirim:");
      body.forEach((key, value) {
        print("   $key: $value");
      });

      final response = await http
          .post(
        Uri.parse('${AppConfig.baseUrl}/api/update_profile.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server tidak merespon');
        },
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          print("✅ Profile berhasil disimpan");
          print("💬 Message: ${jsonData['message']}");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          return true;
        } else {
          print("❌ Server return success=false");
          print("💬 Message: ${jsonData['message']}");
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          return false;
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        print("📦 Body: ${response.body}");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        return false;
      }
    } catch (e, stackTrace) {
      print("❌ EXCEPTION di saveProfile: $e");
      print("📍 Stack trace: $stackTrace");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
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
