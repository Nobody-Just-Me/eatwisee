import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:eatwise2/util/config.dart';

class User {
  String? idUser;
  String? username;
  String? password;
  String? email;

  User({this.idUser, this.username, this.password, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        idUser: json['id']?.toString(),
        username: json['username'],
        password: json['password'],
        email: json['email']);
  }
}

Future<Response?> userCreate(User user) async {
  try {
    final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/register.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': user.username,
          'password': user.password,
          'email': user.email
        }));
    print('Register URL: ${AppConfig.baseUrl}/register.php');
    print('Register response: ${response.statusCode} - ${response.body}');
    return response;
  } catch (e) {
    print('Register error: $e');
    return null;
  }
}

Future<Response?> login(User user) async {
  try {
    print('Login URL: ${AppConfig.baseUrl}/login.php');
    print('Login data: username=${user.username}');
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/login.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'username': user.username, 'password': user.password}),
    );
    print('Login response: ${response.statusCode} - ${response.body}');
    return response;
  } catch (e) {
    print('Login error: $e');
    return null;
  }
}
