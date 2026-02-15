import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileApi {
  static String get baseUrl => '${dotenv.env['ENDPOINT']}/profile';

  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Get Profile Response: ${response.statusCode}');
    print('Get Profile Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int height,
    required int weight,
    required int age,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    print('Updating profile to: $baseUrl');
    print('Data: height=$height, weight=$weight, age=$age');

    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'height': height,
        'weight': weight,
        'age': age,
      }),
    );

    print('Update Profile Response: ${response.statusCode}');
    print('Update Profile Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Update failed');
    }
  }

  static Future<Map<String, dynamic>> updatePersonalData({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    print('Updating personal data to: $baseUrl/personal-data');
    print('Data: firstName=$firstName, lastName=$lastName, email=$email, phone=$phoneNumber');

    final response = await http.patch(
      Uri.parse('$baseUrl/personal-data'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
      }),
    );

    print('Update Personal Data Response: ${response.statusCode}');
    print('Update Personal Data Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Update failed');
    }
  }
}