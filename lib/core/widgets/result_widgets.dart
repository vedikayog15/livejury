import 'package:flutter/material.dart';
import '../theme/live_jury_theme.dart';

class VoteBar extends StatelessWidget {
  const VoteBar({super.key, required this.guilty, required this.notGuilty});
  final int guilty;
  final int notGuilty;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(
      height: 14,
      child: Row(
        children: [
          Expanded(
            flex: guilty,
            child: const ColoredBox(color: AppColors.burgundy),
          ),
          Expanded(
            flex: notGuilty,
            child: const ColoredBox(color: AppColors.teal),
          ),
        ],
      ),
    ),
  );
}

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.text});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(text, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}
