import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/notification_api.dart';
import 'package:fitnessapp/utils/schedule_api.dart';
import 'package:fitnessapp/utils/schedule_notification_service.dart';
import 'package:fitnessapp/utils/session.dart';
import 'package:fitnessapp/view/notification/widgets/notification_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = "/NotificationScreen";

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _scheduleNotifications = [];
  bool _isLoading = true;
  String? _errorMsg;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _fetchScheduleNotifications();
  }

  /// Format ISO date to "About X ago" style
  static String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '';
    DateTime? date;
    if (createdAt is String) {
      date = DateTime.tryParse(createdAt);
    }
    if (date == null) return createdAt.toString();

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return 'About ${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return 'About ${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day} ${_monthName(date.month)}';
  }

  static String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m - 1];
  }

  Future<void> _fetchNotifications({bool refresh = false}) async {
    final pageToFetch = refresh ? 1 : _page;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    if (pageToFetch == 1) {
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final data = await NotificationApi.fetchNotifications(
        page: pageToFetch,
        limit: 20,
      );
      final list = List<Map<String, dynamic>>.from(
        (data['notifications'] as List? ?? []).map((n) {
          final map = Map<String, dynamic>.from(n as Map);
          map['time'] = _formatTime(map['createdAt']);
          return map;
        }),
      );
      final pagination = data['pagination'] as Map? ?? {};
      final totalPages = pagination['totalPages'] as int? ?? 1;

      setState(() {
        if (refresh || pageToFetch == 1) {
          _notifications = list;
        } else {
          _notifications.addAll(list);
        }
        _page = pageToFetch + 1;
        _hasMore = pageToFetch < totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchScheduleNotifications() async {
    final userId = Session.userId;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      final startDate = DateFormat('yyyy-MM-dd').format(now);
      final endDate =
          DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 7)));

      final schedules = await ScheduleApi.fetchSchedules(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      for (final s in schedules) {
        if (s is! Map) continue;
        if ((s['status'] ?? 'scheduled') != 'scheduled') continue;
        await ScheduleNotificationService.scheduleFromSchedule(s);
      }

      final list = schedules
          .where((s) => s is Map && (s['status'] ?? 'scheduled') == 'scheduled')
          .map<Map<String, dynamic>>((s) {
        final map = Map<String, dynamic>.from(s as Map);
        final dateStr = map['scheduled_date']?.toString() ?? '';
        final timeStr = map['scheduled_time']?.toString() ?? '';
        final scheduledAt = _parseScheduleDateTime(dateStr, timeStr);
        final workoutName = map['workout_name']?.toString() ?? 'Workout';
        final timeLabel = scheduledAt != null
            ? _formatScheduleLabel(scheduledAt)
            : '$dateStr $timeStr';
        return {
          'local': true,
          'type': 'workout',
          'title': 'Workout scheduled',
          'message': '$workoutName at $timeLabel',
          'time': timeLabel,
          'isRead': true,
        };
      }).toList();

      if (mounted) {
        setState(() => _scheduleNotifications = list);
      }
    } catch (_) {
      // Best-effort: avoid blocking the notifications screen.
    }
  }

  static DateTime? _parseScheduleDateTime(String date, String time) {
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

  static String _formatScheduleLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dt.year, dt.month, dt.day);
    final time = DateFormat('hh:mm a').format(dt);
    if (dateOnly == today) return 'Today $time';
    if (dateOnly == tomorrow) return 'Tomorrow $time';
    return DateFormat('MMM d, hh:mm a').format(dt);
  }

  Future<void> _onMarkAsRead(int id) async {
    try {
      await NotificationApi.markAsRead(id);
      setState(() {
        final idx = _notifications.indexWhere((n) => n['id'] == id);
        if (idx >= 0) _notifications[idx]['isRead'] = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _onDelete(int id) async {
    try {
      await NotificationApi.deleteNotification(id);
      setState(() {
        _notifications.removeWhere((n) => n['id'] == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightGrayColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: _isLoading ? null : () => _fetchNotifications(refresh: true),
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Image.asset(
                      "assets/icons/more_icon.png",
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchNotifications(refresh: true);
          await _fetchScheduleNotifications();
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty && _scheduleNotifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMsg != null &&
        _notifications.isEmpty &&
        _scheduleNotifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchNotifications(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_notifications.isEmpty) {
      if (_scheduleNotifications.isNotEmpty) {
        return _buildList();
      }
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return _buildList();
  }

  Widget _buildList() {
    final combined = [
      ..._scheduleNotifications,
      ..._notifications,
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      itemCount: combined.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == combined.length) {
          if (_hasMore && !_isLoadingMore) {
            _fetchNotifications(); // load next page
          }
          return _isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }
        final nObj = combined[index];
        final isLocal = nObj['local'] == true;
        return NotificationRow(
          nObj: nObj,
          onMarkAsRead: isLocal ||
                  (nObj['isRead'] == true || nObj['isRead'] == 1)
              ? null
              : () => _onMarkAsRead(nObj['id'] as int),
          onDelete: isLocal ? null : () => _onDelete(nObj['id'] as int),
        );
      },
      separatorBuilder: (context, index) {
        if (index >= combined.length) return const SizedBox.shrink();
        return Divider(
          color: AppColors.grayColor.withOpacity(0.5),
          height: 1,
        );
      },
    );
  }
}
