import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GalleryApi {
  static String get baseUrl => '${dotenv.env['ENDPOINT']}/gallery';

  static Future<Map<String, dynamic>> fetchGallery({int? userId}) async {
    var url = baseUrl;
    if (userId != null) {
      url += '?user_id=$userId';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    }

    throw Exception('Failed to load gallery');
  }

  static Future<Map<String, dynamic>> uploadPhoto({
    required File imageFile,
    int? userId,
    String? takenAt,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final encoded = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mime = (ext == 'png') ? 'image/png' : 'image/jpeg';

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'taken_at': takenAt,
        'photo_base64': 'data:$mime;base64,$encoded',
      }),
    );

    final decoded = json.decode(response.body);
    if (response.statusCode == 201) {
      return decoded is Map<String, dynamic> ? decoded : {};
    }

    if (decoded is Map<String, dynamic> && decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }
    throw Exception('Failed to upload photo');
  }
}
