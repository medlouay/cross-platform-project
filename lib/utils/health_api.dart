import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API client for health ingest endpoint
/// Sends step count and other health data to the backend
class HealthApi {
  static String get baseUrl =>
      dotenv.env['ENDPOINT'] ?? 'http://10.0.2.2:3000';

  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  /// Ingest health data (steps, calories, etc.) to the backend
  /// Called when syncing from device / smartwatch
  static Future<void> ingest({
    required int userId,
    required String deviceUuid,
    required String source,
    String? platform,
    String? model,
    String? date,
    String? timezone,
    int? steps,
    double? calories,
    double? distanceM,
    int? activeMinutes,
    int? sleepMinutes,
  }) async {
    final aggregates = <String, dynamic>{};
    if (steps != null) aggregates['steps'] = steps;
    if (calories != null) aggregates['calories'] = calories;
    if (distanceM != null) aggregates['distance_m'] = distanceM;
    if (activeMinutes != null) aggregates['active_minutes'] = activeMinutes;
    if (sleepMinutes != null) aggregates['sleep_minutes'] = sleepMinutes;

    final body = {
      'user_id': userId,
      'device_uuid': deviceUuid,
      'source': source,
      'platform': platform ?? (Platform.isAndroid ? 'android' : 'ios'),
      'model': model,
      'date': date,
      'timezone': timezone,
      'aggregates': aggregates,
      'samples': [],
    };

    final response = await http.post(
      Uri.parse('$baseUrl/health/ingest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'Failed to sync health data');
    }
  }

  /// Convenience: ingest steps for today
  /// Pass userId from Session.userId (caller should ensure user is logged in)
  static Future<void> syncSteps(int steps, {int? userId}) async {
    final uid = userId ?? await _getUserId();
    if (uid == null) throw Exception('User not logged in');

    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Device UUID: use a stable identifier (e.g. from device_info_plus, or app-install id)
    final prefs = await SharedPreferences.getInstance();
    var deviceUuid = prefs.getString('health_device_uuid');
    if (deviceUuid == null || deviceUuid.isEmpty) {
      deviceUuid = 'app_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('health_device_uuid', deviceUuid);
    }

    const source = 'other'; // healthkit / health_connect handled by health package; we send as 'other'
    await ingest(
      userId: uid,
      deviceUuid: deviceUuid,
      source: source,
      platform: Platform.isAndroid ? 'android' : 'ios',
      model: 'health_sync',
      date: date,
      steps: steps,
    );
  }
}
