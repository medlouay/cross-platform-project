import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ContactApi {
  static String get baseUrl => dotenv.env['ENDPOINT'] ?? 'http://10.0.2.2:3000';

  static Future<void> sendContactMessage({
    required String firstName,
    required String lastName,
    required String email,
    required String message,
  }) async {
    final url = '$baseUrl/contact/send';

    print('📧 Sending contact message to backend: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'message': message,
        }),
      );

      print('Contact Response: ${response.statusCode}');
      print('Contact Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Email sent successfully via backend');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to send email');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception(e.toString());
    }
  }
}