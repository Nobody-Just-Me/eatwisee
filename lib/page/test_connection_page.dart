import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eatwise2/util/config.dart';

class TestConnectionPage extends StatefulWidget {
  @override
  _TestConnectionPageState createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String _connectionStatus = 'Belum ditest';
  String _usersCount = '-';
  bool _isLoading = false;
  Color _statusColor = Colors.grey;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
      _statusColor = Colors.orange;
    });

    try {
      // Test connection
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/test_connection.php'),
        headers: {"Content-Type": "application/json"},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          // Get users count
          final usersResponse = await http.get(
            Uri.parse('${AppConfig.baseUrl}/test_users.php'),
            headers: {"Content-Type": "application/json"},
          ).timeout(Duration(seconds: 10));

          if (usersResponse.statusCode == 200) {
            final usersData = json.decode(usersResponse.body);
            
            setState(() {
              _connectionStatus = 'Koneksi Berhasil! ✅';
              _usersCount = usersData['total_users'].toString();
              _statusColor = Colors.green;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _connectionStatus = 'Koneksi Gagal: ${data['message']}';
            _statusColor = Colors.red;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _connectionStatus = 'HTTP Error: ${response.statusCode}';
          _statusColor = Colors.red;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error: $e';
        _statusColor = Colors.red;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Koneksi Database'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfigurasi Database',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Base URL: ${AppConfig.baseUrl}'),
                    Text('Database: eatwise2'),
                    Text('User: eatwise'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              color: _statusColor.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Koneksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _connectionStatus,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_usersCount != '-') ...[
                      SizedBox(height: 10),
                      Text(
                        'Total Users: $_usersCount',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Test Koneksi',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
