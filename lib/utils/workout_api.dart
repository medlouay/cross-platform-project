import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WorkoutApi {
  static String get baseUrl => '${dotenv.env['ENDPOINT']}/workouts';

  // Fetch all workouts
  static Future<List<dynamic>> fetchWorkouts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load workouts');
    }
  }

  // Fetch workout by ID
  static Future<Map<String, dynamic>> fetchWorkoutById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load workout');
    }
  }
}
