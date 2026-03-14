import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eatwise2/util/config.dart';

Future<void> testDatabaseConnection() async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔍 TESTING DATABASE CONNECTION');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📍 Base URL: ${AppConfig.baseUrl}');
  
  try {
    // Test 1: Test connection file
    print('\n📡 Test 1: Testing connection...');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/test_connection.php'),
      headers: {"Content-Type": "application/json"},
    ).timeout(Duration(seconds: 10));
    
    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        print('✅ Database connection successful!');
      } else {
        print('❌ Database connection failed: ${data['message']}');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
    }
    
    // Test 2: Get users count
    print('\n📡 Test 2: Getting users count...');
    final usersResponse = await http.get(
      Uri.parse('${AppConfig.baseUrl}/test_users.php'),
      headers: {"Content-Type": "application/json"},
    ).timeout(Duration(seconds: 10));
    
    print('📥 Users Response: ${usersResponse.body}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}
