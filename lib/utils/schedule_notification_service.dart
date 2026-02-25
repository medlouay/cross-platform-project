import 'package:intl/intl.dart';

import 'local_notifications.dart';
import 'schedule_api.dart';
import 'session.dart';

class ScheduleNotificationService {
  static Future<void> syncUpcomingSchedules({int daysAhead = 7}) async {
    final userId = Session.userId;
    if (userId == null) return;

    final now = DateTime.now();
    final startDate = DateFormat('yyyy-MM-dd').format(now);
    final endDate =
        DateFormat('yyyy-MM-dd').format(now.add(Duration(days: daysAhead)));

    final schedules = await ScheduleApi.fetchSchedules(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    for (final s in schedules) {
      if (s is! Map) continue;
      if ((s['status'] ?? 'scheduled') != 'scheduled') continue;
      await scheduleFromSchedule(s);
    }
  }

  static Future<void> scheduleFromSchedule(Map schedule) async {
    final id = _parseInt(schedule['id']);
    if (id == null) return;

    final date = schedule['scheduled_date']?.toString();
    final time = schedule['scheduled_time']?.toString();
    if (date == null || time == null) return;

    final scheduledAt = _parseDateTime(date, time);
    if (scheduledAt == null) return;

    final workoutName =
        schedule['workout_name']?.toString() ?? 'Workout';

    await LocalNotifications.scheduleWorkoutReminder(
      id: id,
      scheduledAt: scheduledAt,
      title: 'Workout Reminder',
      body: '$workoutName starts in 1 hour',
    );
  }

  static Future<void> scheduleFromParts({
    required int scheduleId,
    required String scheduledDate,
    required String scheduledTime,
    required String workoutName,
  }) async {
    final scheduledAt = _parseDateTime(scheduledDate, scheduledTime);
    if (scheduledAt == null) return;

    await LocalNotifications.scheduleWorkoutReminder(
      id: scheduleId,
      scheduledAt: scheduledAt,
      title: 'Workout Reminder',
      body: '$workoutName starts in 1 hour',
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  static DateTime? _parseDateTime(String date, String time) {
    try {
      final d = date.split('-');
      final t = time.split(':');
      if (d.length < 3 || t.length < 2) return null;
      final year = int.parse(d[0]);
      final month = int.parse(d[1]);
      final day = int.parse(d[2]);
      final hour = int.parse(t[0]);
      final minute = int.parse(t[1]);
      final second = t.length > 2 ? int.parse(t[2]) : 0;
      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }
}
