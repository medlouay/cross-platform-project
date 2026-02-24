import 'package:health/health.dart';
import 'health_api.dart';

/// Service for reading steps from device/smartwatch (HealthKit / Google Fit)
/// and syncing to the backend. Uses health package ^3.0.6.
class HealthService {
  static final HealthFactory _health = HealthFactory();

  /// Get today's step count from HealthKit (iOS) or Google Fit (Android)
  /// Returns null if permission denied or data unavailable
  static Future<int?> getTodaySteps() async {
    try {
      final types = [HealthDataType.STEPS];
      final granted = await _health.requestAuthorization(types);
      if (!granted) return null;

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final data = await _health.getHealthDataFromTypes(
        midnight,
        now,
        types,
      );

      int total = 0;
      for (final point in data) {
        final v = (point as dynamic).value ?? (point as dynamic).numericValue;
        if (v is num) {
          total += v.round();
        } else if (v != null) {
          final n = num.tryParse(v.toString());
          if (n != null) total += n.round();
        }
      }
      return total > 0 ? total : null;
    } catch (e) {
      return null;
    }
  }

  /// Read steps and sync to backend
  /// Returns steps count on success, null on failure
  static Future<int?> syncStepsToBackend(int? userId) async {
    final steps = await getTodaySteps();
    if (steps == null || userId == null) return steps;
    try {
      await HealthApi.syncSteps(steps, userId: userId);
      return steps;
    } catch (_) {
      return null;
    }
  }
}
