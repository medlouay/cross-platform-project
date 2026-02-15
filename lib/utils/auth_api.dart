import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  static String get baseUrl => '${dotenv.env['ENDPOINT']}/auth';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode == 200) {
      return body;
    }

    throw Exception(body['error']?.toString() ?? 'Login failed');
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim(),
        'password': password,
        'confirmPassword': password,
      }),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode == 201) {
      return body;
    }

    throw Exception(body['error']?.toString() ?? 'Registration failed');
  }

  static Map<String, dynamic> _decodeBody(String responseBody) {
    try {
      final decoded = json.decode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}
