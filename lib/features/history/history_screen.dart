import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/live_jury_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Your casebook', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          'Decisions, discussions, and what you learned.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text('All cases'),
              selected: true,
              onSelected: null,
            ),
            FilterChip(label: Text('This month'), onSelected: null),
            FilterChip(label: Text('Matched law'), onSelected: null),
          ],
        ),
        const SizedBox(height: 20),
        ...const [
          HistoryCard(
            title: 'The Silent Witness',
            category: 'Criminal',
            verdict: 'Not Guilty',
            score: 91,
            date: 'Yesterday',
          ),
          HistoryCard(
            title: 'Terms & Conditions',
            category: 'Technology',
            verdict: 'Liable',
            score: 84,
            date: '8 Aug',
          ),
          HistoryCard(
            title: 'A Question of Care',
            category: 'Civil',
            verdict: 'Not Liable',
            score: 79,
            date: '2 Aug',
          ),
          HistoryCard(
            title: 'The Last Delivery',
            category: 'Ethics',
            verdict: 'Guilty',
            score: 86,
            date: '29 Jul',
          ),
        ],
      ],
    ),
  );
}
