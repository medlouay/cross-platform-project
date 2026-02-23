import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API client for notifications backend
class NotificationApi {
  static String get baseUrl =>
      dotenv.env['ENDPOINT'] ?? 'http://10.0.2.2:3000';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Fetch notifications for the authenticated user (paginated)
  static Future<Map<String, dynamic>> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('$baseUrl/notifications')
        .replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to load notifications');
    }
  }

  /// Mark a notification as read
  static Future<Map<String, dynamic>> markAsRead(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to mark as read');
    }
  }

  /// Delete a notification
  static Future<void> deleteNotification(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to delete notification');
    }
  }
}
