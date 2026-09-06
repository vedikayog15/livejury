import 'package:flutter/material.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return JuryPage(
      title: 'Notes from the room',
      actions: [
        IconButton(
          tooltip: 'Mark all as read',
          onPressed: s.unread == 0 || s.busy
              ? null
              : () async {
                  if (await s.markNoticesRead() && context.mounted) {
                    toast(context, 'All caught up.');
                  }
                },
          icon: const Icon(Icons.done_all_rounded),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text('A little\ncorrespondence.', style: JType.display(40)),
          const SizedBox(height: 14),
          Text(
            '${s.unread} unread ${s.unread == 1 ? 'note' : 'notes'}',
            style: const TextStyle(color: JColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 28),
          if (s.player!.notices.isEmpty)
            const EmptyState(
              title: 'A quiet room.',
              body: 'New case notes will appear here after your next session.',
              icon: Icons.notifications_none_rounded,
            ),
          for (final n in s.player!.notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Panel(
                color: n.read ? JColors.surface : JColors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          n.id == 'welcome'
                              ? Icons.waving_hand_outlined
                              : Icons.mark_email_read_outlined,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            n.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!n.read)
                          const Icon(
                            Icons.circle,
                            size: 7,
                            color: JColors.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      n.body,
                      style: const TextStyle(
                        color: JColors.muted,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => n.id == 'welcome'
                          ? home(context)
                          : go(context, '/history'),
                      child: Text(
                        n.id == 'welcome'
                            ? 'Find your first case'
                            : 'Open your journal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
