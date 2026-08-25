import 'package:flutter/material.dart';
import '../theme/live_jury_theme.dart';
import 'primitives.dart';

class EvidenceTile extends StatelessWidget {
  const EvidenceTile({
    super.key,
    required this.icon,
    required this.tag,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String tag;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.gold),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.gold,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.bookmark_border, size: 20, color: AppColors.muted),
        ],
      ),
    ),
  );
}

class TimelineItem extends StatelessWidget {
  const TimelineItem({super.key, required this.time, required this.text});
  final String time;
  final String text;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            time,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: Container(width: 1, color: AppColors.outline)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ],
    ),
  );
}
