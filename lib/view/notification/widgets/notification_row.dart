import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Displays a single notification (from backend API)
class NotificationRow extends StatelessWidget {
  final Map<String, dynamic> nObj;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationRow({
    Key? key,
    required this.nObj,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);

  /// Map notification type to asset image
  String get _imagePath {
    final type = nObj['type']?.toString() ?? 'system';
    switch (type) {
      case 'workout':
        return 'assets/images/Workout1.png';
      case 'achievement':
        return 'assets/images/Workout2.png';
      case 'follow':
      case 'like':
        return 'assets/images/Workout3.png';
      default:
        return 'assets/images/Workout1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = nObj['isRead'] == 1 || nObj['isRead'] == true;
    final title = nObj['title']?.toString() ?? '';
    final message = nObj['message']?.toString() ?? '';
    final time = nObj['time']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              _imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Opacity(
              opacity: isRead ? 0.7 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.isNotEmpty && message != title)
                    Text(
                      message,
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    time,
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Image.asset(
              "assets/icons/sub_menu_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
            onSelected: (value) {
              if (value == 'read') {
                onMarkAsRead?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              if (!isRead)
                const PopupMenuItem(
                  value: 'read',
                  child: Text('Mark as read'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
