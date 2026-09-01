import 'package:flutter/material.dart';
import '../../core/widgets/live_jury_widgets.dart';

class _NotificationRecord {
  _NotificationRecord({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  bool unread;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_NotificationRecord> _items = [
    _NotificationRecord(
      icon: Icons.groups_2_outlined,
      title: 'A new jury is forming',
      body: 'Criminal Law • Intermediate',
      time: '2m',
      unread: true,
    ),
    _NotificationRecord(
      icon: Icons.emoji_events_outlined,
      title: 'You moved up 4 places',
      body: 'You are now #18 on the weekly board.',
      time: '1h',
      unread: true,
    ),
    _NotificationRecord(
      icon: Icons.balance_outlined,
      title: 'Verdict available',
      body: 'See the outcome of The Silent Witness.',
      time: 'Yesterday',
      unread: true,
    ),
    _NotificationRecord(
      icon: Icons.workspace_premium_outlined,
      title: 'Achievement unlocked',
      body: 'Open Mind: changed position after new evidence.',
      time: '3d',
    ),
  ];

  bool get _hasUnread => _items.any((n) => n.unread);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _hasUnread
                ? () => setState(() {
                    for (final item in _items) {
                      item.unread = false;
                    }
                  })
                : null,
            child: const Text('MARK READ'),
          ),
        ],
      ),
      body: _items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'You’re all caught up',
              message:
                  'New jury invites, standings changes, and verdicts will appear here.',
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                for (var i = 0; i < _items.length; i++)
                  StaggeredEntrance(
                    index: i,
                    child: NotificationTile(
                      icon: _items[i].icon,
                      title: _items[i].title,
                      body: _items[i].body,
                      time: _items[i].time,
                      unread: _items[i].unread,
                      onTap: _items[i].unread
                          ? () => setState(() => _items[i].unread = false)
                          : null,
                    ),
                  ),
              ],
            ),
    );
  }
}
