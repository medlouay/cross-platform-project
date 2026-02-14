import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScheduleApi {
  static String get baseUrl => dotenv.env['ENDPOINT'] ?? '';

  // Create a new schedule
  static Future<Map<String, dynamic>> createSchedule({
    required int workoutId,
    required String scheduledDate,
    required String scheduledTime,
    int? userId,
    int? duration,
    String? difficulty,
    int? repetitions,
    String? weights,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/schedules'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'workout_id': workoutId,
        'scheduled_date': scheduledDate,
        'scheduled_time': scheduledTime,
        'duration': duration,
        'difficulty': difficulty,
        'repetitions': repetitions,
        'weights': weights,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create schedule');
    }
  }

  // Get all schedules
  static Future<List<dynamic>> fetchSchedules({
    int? userId,
    String? startDate,
    String? endDate,
  }) async {
    var url = '$baseUrl/schedules?';
    if (userId != null) url += 'user_id=$userId&';
    if (startDate != null) url += 'start_date=$startDate&';
    if (endDate != null) url += 'end_date=$endDate';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  // Get schedules for a specific date
  static Future<List<dynamic>> fetchSchedulesByDate(
    String date, {
    int? userId,
  }) async {
    var url = '$baseUrl/schedules/date/$date';
    if (userId != null) url += '?user_id=$userId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load schedules for date');
    }
  }

  // Get single schedule by ID
  static Future<Map<String, dynamic>> fetchScheduleById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/schedules/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load schedule details');
    }
  }

  // Update schedule
  static Future<Map<String, dynamic>> updateSchedule(
    String id, {
    String? scheduledDate,
    String? scheduledTime,
    int? duration,
    String? difficulty,
    int? repetitions,
    String? weights,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (scheduledDate != null) body['scheduled_date'] = scheduledDate;
    if (scheduledTime != null) body['scheduled_time'] = scheduledTime;
    if (duration != null) body['duration'] = duration;
    if (difficulty != null) body['difficulty'] = difficulty;
    if (repetitions != null) body['repetitions'] = repetitions;
    if (weights != null) body['weights'] = weights;
    if (status != null) body['status'] = status;

    final response = await http.put(
      Uri.parse('$baseUrl/schedules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update schedule');
    }
  }

  // Mark schedule as completed
  static Future<Map<String, dynamic>> markAsCompleted(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/schedules/$id/complete'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark schedule as completed');
    }
  }

  // Delete schedule
  static Future<Map<String, dynamic>> deleteSchedule(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/schedules/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete schedule');
    }
  }
}