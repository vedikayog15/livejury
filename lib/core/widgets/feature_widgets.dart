import 'package:flutter/material.dart';
import '../theme/live_jury_theme.dart';
import 'primitives.dart';
import 'state_widgets.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.title,
    required this.category,
    required this.verdict,
    required this.score,
    required this.date,
    this.matchedLaw = true,
    this.onTap,
  });
  final String title;
  final String category;
  final String verdict;
  final int score;
  final String date;
  final bool matchedLaw;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final card = SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.gold,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                verdict.contains('Not')
                    ? Icons.shield_outlined
                    : Icons.gavel_outlined,
                size: 18,
                color: verdict.contains('Not')
                    ? AppColors.teal
                    : AppColors.burgundy,
              ),
              const SizedBox(width: 7),
              Text(verdict, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Text(
                '$score reasoning',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gold),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                matchedLaw
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                size: 14,
                color: matchedLaw ? AppColors.teal : AppColors.warning,
              ),
              const SizedBox(width: 5),
              Text(
                matchedLaw
                    ? 'Matched the legal outcome'
                    : 'Differed from the legal outcome',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11.5,
                  color: matchedLaw ? AppColors.teal : AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: onTap == null
          ? card
          : Pressable(
              onTap: onTap,
              semanticLabel: '$title, $verdict, reasoning score $score',
              child: card,
            ),
    );
  }
}

class Podium extends StatelessWidget {
  const Podium({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    required this.height,
  });
  final int rank;
  final String name;
  final String points;
  final double height;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      JurorAvatar(
        initials: name.substring(0, 1),
        size: rank == 1 ? 62 : 50,
        color: rank == 1 ? AppColors.gold : AppColors.teal,
      ),
      const SizedBox(height: 7),
      Text(name, style: Theme.of(context).textTheme.titleMedium),
      Text(
        points,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.gold),
      ),
      const SizedBox(height: 8),
      Container(
        width: 90,
        height: height,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (rank == 1 ? AppColors.gold : AppColors.teal).withValues(
                alpha: .28,
              ),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: rank == 1 ? AppColors.gold : AppColors.teal),
          ),
        ),
        child: Text(
          '$rank',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: rank == 1 ? AppColors.gold : AppColors.teal,
          ),
        ),
      ),
    ],
  );
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    onTap: onTap,
    leading: Icon(icon, color: AppColors.gold),
    title: Text(title),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing.isNotEmpty)
          Text(
            trailing,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.muted),
      ],
    ),
  );
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap ?? () {},
    semanticLabel: '${unread ? 'Unread. ' : ''}$title. $body. $time ago.',
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: unread
            ? AppColors.gold.withValues(alpha: .07)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unread
              ? AppColors.gold.withValues(alpha: .2)
              : AppColors.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
