import 'package:flutter/material.dart';
import '../theme/live_jury_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * .28),
      color: AppColors.gold.withValues(alpha: .12),
      border: Border.all(color: AppColors.gold.withValues(alpha: .5)),
    ),
    child: Icon(Icons.balance, color: AppColors.gold, size: size * .56),
  );
}

class JurorAvatar extends StatelessWidget {
  const JurorAvatar({
    super.key,
    required this.initials,
    this.size = 42,
    this.color = AppColors.teal,
    this.empty = false,
    this.semantics,
  });
  final String initials;
  final double size;
  final Color color;
  final bool empty;
  final String? semantics;
  @override
  Widget build(BuildContext context) => Semantics(
    label: semantics,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        color: color.withValues(alpha: empty ? .06 : .16),
        border: Border.all(
          color: color.withValues(alpha: empty ? .25 : .8),
          width: 1.5,
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Manrope',
          color: empty ? AppColors.muted : color,
          fontWeight: FontWeight.w800,
          fontSize: size * .29,
        ),
      ),
    ),
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(17),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.outline),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.outline),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.gold),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: .7,
          ),
        ),
      ],
    ),
  );
}

class TimerPill extends StatelessWidget {
  const TimerPill({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.gold.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.gold.withValues(alpha: .22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 16, color: AppColors.gold),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score});
  final int score;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 66,
    height: 66,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 5,
            color: AppColors.gold,
            backgroundColor: AppColors.outline,
          ),
        ),
        Text('$score', style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}

class MiniStat extends StatelessWidget {
  const MiniStat({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.gold),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.muted, fontSize: 12),
      ),
    ],
  );
}
