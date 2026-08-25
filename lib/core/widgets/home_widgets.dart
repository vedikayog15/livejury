import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/design_tokens.dart';
import '../theme/live_jury_theme.dart';

class PrimaryJuryPanel extends StatelessWidget {
  const PrimaryJuryPanel({super.key, required this.onJoin});

  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.feature,
            border: Border.all(color: AppColors.outline),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: const _JuryMapPainter(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? AppSpacing.lg : AppSpacing.xl,
                AppSpacing.lg,
                compact ? AppSpacing.lg : AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'New case available',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textPrimary,
                            letterSpacing: .15,
                          ),
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'CASE 024',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: compact ? 106 : 94),
                  Text(
                    'A difficult question.\nSix honest perspectives.',
                    style: AppTypography.display.copyWith(
                      fontSize: compact ? 34 : 38,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      'Review the evidence, vote privately, and reason toward a verdict together.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: onJoin,
                    child: const Text('Find my jury'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          'Usually ready in under a minute',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JuryMapPainter extends CustomPainter {
  const _JuryMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .74, 99);
    final rule = Paint()
      ..color = AppColors.outline.withValues(alpha: .72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final faint = Paint()
      ..color = AppColors.outline.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;

    canvas.drawCircle(center, 42, faint);
    canvas.drawCircle(center, 67, faint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 82),
      math.pi * .08,
      math.pi * 1.05,
      false,
      rule,
    );

    final table = Paint()..color = AppColors.surfaceRaised;
    canvas.drawCircle(center, 28, table);
    canvas.drawCircle(center, 28, rule);

    for (var index = 0; index < 6; index++) {
      final angle = -math.pi / 2 + index * math.pi / 3;
      final seat = Offset(
        center.dx + math.cos(angle) * 55,
        center.dy + math.sin(angle) * 55,
      );
      canvas.drawLine(center, seat, faint);
      final seatPaint = Paint()
        ..color = index == 0 ? AppColors.primary : AppColors.textSecondary;
      canvas.drawCircle(seat, index == 0 ? 7 : 5, seatPaint);
      canvas.drawCircle(
        seat,
        index == 0 ? 11 : 9,
        Paint()
          ..color = (index == 0 ? AppColors.primary : AppColors.outline)
              .withValues(alpha: .18),
      );
    }

    final accent = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height * .56),
      Offset(52, size.height * .56),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.onCreateRoom,
    required this.onJoinByCode,
  });

  final VoidCallback onCreateRoom;
  final VoidCallback onJoinByCode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330;
        final create = HomeQuickAction(
          icon: Icons.group_add_rounded,
          title: 'Create room',
          subtitle: 'Invite people you know',
          onTap: onCreateRoom,
        );
        final join = HomeQuickAction(
          icon: Icons.dialpad_rounded,
          title: 'Join by code',
          subtitle: 'Use a private invite',
          onTap: onJoinByCode,
        );

        if (compact) {
          return Column(
            children: [
              create,
              const SizedBox(height: AppSpacing.sm),
              join,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: create),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: join),
          ],
        );
      },
    );
  }
}

class HomeQuickAction extends StatelessWidget {
  const HomeQuickAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, size: 20, color: AppColors.primary),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 19,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedCaseCard extends StatelessWidget {
  const FeaturedCaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Featured mystery case, The Last Message, ten minutes',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.feature,
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: const _CaseCoverPainter(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'MYSTERY',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'CASE 024',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 72),
                Text(
                  'The Last Message',
                  style: AppTypography.editorialTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 31,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Can a deleted text prove intent?',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '10 min   ·   2,418 jurors',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CaseCoverPainter extends CustomPainter {
  const _CaseCoverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final coral = Paint()..color = AppColors.primary.withValues(alpha: .1);
    final line = Paint()
      ..color = AppColors.primary.withValues(alpha: .45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final neutral = Paint()..color = AppColors.outline.withValues(alpha: .5);

    final anchor = Offset(size.width - 72, 76);
    canvas.drawCircle(anchor, 64, coral);
    canvas.drawCircle(anchor, 42, line);

    final bubbleOne = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 145, 43, 86, 31),
      const Radius.circular(9),
    );
    final bubbleTwo = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 112, 84, 74, 29),
      const Radius.circular(9),
    );
    canvas.drawRRect(bubbleOne, neutral);
    canvas.drawRRect(bubbleOne, line);
    canvas.drawRRect(bubbleTwo, coral);
    canvas.drawRRect(bubbleTwo, line);

    final detail = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: .45)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width - 130, 57),
      Offset(size.width - 82, 57),
      detail,
    );
    canvas.drawLine(
      Offset(size.width - 97, 98),
      Offset(size.width - 54, 98),
      detail,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class JurorStandingCard extends StatelessWidget {
  const JurorStandingCard({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: AppRadii.card,
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Juror score $score out of 100',
            child: SizedBox.square(
              dimension: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 4,
                      color: AppColors.positive,
                      backgroundColor: AppColors.outline,
                    ),
                  ),
                  Text(
                    '$score',
                    style: AppTypography.title.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Considered juror', style: AppTypography.title),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Top 18% this month',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.positive,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
