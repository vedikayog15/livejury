import 'package:flutter/material.dart';
import '../../core/widgets/live_jury_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      backgroundColor: Colors.transparent,
      actions: [TextButton(onPressed: () {}, child: const Text('MARK READ'))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        NotificationTile(
          icon: Icons.groups_2_outlined,
          title: 'A new jury is forming',
          body: 'Criminal Law • Intermediate',
          time: '2m',
          unread: true,
        ),
        NotificationTile(
          icon: Icons.emoji_events_outlined,
          title: 'You moved up 4 places',
          body: 'You are now #18 on the weekly board.',
          time: '1h',
          unread: true,
        ),
        NotificationTile(
          icon: Icons.balance_outlined,
          title: 'Verdict available',
          body: 'See the outcome of The Silent Witness.',
          time: 'Yesterday',
          unread: true,
        ),
        NotificationTile(
          icon: Icons.workspace_premium_outlined,
          title: 'Achievement unlocked',
          body: 'Open Mind: changed position after new evidence.',
          time: '3d',
        ),
      ],
    ),
  );
}
