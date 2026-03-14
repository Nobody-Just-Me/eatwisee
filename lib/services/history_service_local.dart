import 'package:eatwise2/database/local_database.dart';

/// Local History Service - Menggunakan SQLite (tidak perlu backend)
class HistoryServiceLocal {
  static final LocalDatabase _db = LocalDatabase();

  // ============================================
  // GET TODAY'S HISTORY
  // ============================================
  static Future<Map<String, dynamic>?> getTodayHistory(int userId) async {
    try {
      final historyItems = await _db.getTodayHistory(userId);
      
      // Hitung total kalori
      int totalKalori = 0;
      for (var item in historyItems) {
        totalKalori += (item['kalori_dikonsumsi'] as int?) ?? 0;
      }
      
      return {
        'success': true,
        'data': historyItems,
        'summary': {
          'total_kalori': totalKalori,
          'total_items': historyItems.length,
        },
      };
    } catch (e) {
      print('❌ Error getting today history: $e');
      return null;
    }
  }

  // ============================================
  // GET HISTORY BY DATE RANGE
  // ============================================
  static Future<List<Map<String, dynamic>>> getHistoryByDateRange(
    int userId, {
    String? startDate,
    String? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _db.getHistoryByDateRange(
        userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('❌ Error getting history by date range: $e');
      return [];
    }
  }

  // ============================================
  // ADD FOOD TO HISTORY
  // ============================================
  static Future<bool> addFoodHistory(Map<String, dynamic> historyData) async {
    try {
      final id = await _db.addFoodHistory(historyData);
      return id > 0;
    } catch (e) {
      print('❌ Error adding food history: $e');
      return false;
    }
  }

  // ============================================
  // DELETE HISTORY ITEM
  // ============================================
  static Future<bool> deleteHistoryItem(int historyId, int userId) async {
    try {
      return await _db.deleteHistory(historyId);
    } catch (e) {
      print('❌ Error deleting history: $e');
      return false;
    }
  }
}
