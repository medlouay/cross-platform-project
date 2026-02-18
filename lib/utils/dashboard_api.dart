import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardApi {
  static String get baseUrl => '${dotenv.env['ENDPOINT']}/dashboard';

  static Future<Map<String, dynamic>> fetchSummary({
    required int userId,
    String? date,
  }) async {
    var url = '$baseUrl/summary?user_id=$userId';
    if (date != null && date.isNotEmpty) {
      url += '&date=$date';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic>) return body;
      return {};
    } else {
      throw Exception('Failed to load dashboard summary');
    }
  }
}
