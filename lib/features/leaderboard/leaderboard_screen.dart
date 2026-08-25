import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/live_jury_widgets.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Reasoned voices',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Recognising thoughtful, respectful jurors.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'week', label: Text('WEEK')),
            ButtonSegment(value: 'month', label: Text('MONTH')),
            ButtonSegment(value: 'all', label: Text('ALL TIME')),
          ],
          selected: const {'week'},
          onSelectionChanged: (_) {},
        ),
        const SizedBox(height: 28),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Podium(rank: 2, name: 'Mira', points: '2,840', height: 116),
            Podium(rank: 1, name: 'Arjun', points: '3,120', height: 146),
            Podium(rank: 3, name: 'Noah', points: '2,610', height: 98),
          ],
        ),
        const SizedBox(height: 24),
        ...[
          ('4', 'Sara Khan', '2,480'),
          ('5', 'Leena Patel', '2,320'),
          ('6', 'Rohan Nair', '2,190'),
          ('18', 'You', '1,420'),
        ].map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      p.$1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: p.$1 == '18' ? AppColors.gold : AppColors.muted,
                      ),
                    ),
                  ),
                  JurorAvatar(
                    initials: p.$2.split(' ').map((e) => e[0]).take(2).join(),
                    color: p.$1 == '18' ? AppColors.gold : AppColors.teal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.$2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    p.$3,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
