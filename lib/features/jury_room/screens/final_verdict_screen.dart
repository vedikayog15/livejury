import 'package:flutter/material.dart';

import '../../../core/design/design_tokens.dart';
import '../../../core/theme/live_jury_theme.dart';
import '../widgets/jury_room_components.dart';

class FinalVerdictScreen extends StatelessWidget {
  const FinalVerdictScreen({
    super.key,
    required this.onNotifications,
    required this.onProfile,
    required this.onOpenCasebook,
  });

  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onOpenCasebook;

  @override
  Widget build(BuildContext context) {
    return EmeraldBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            JuryRoomHeader(
              title: 'History',
              compact: true,
              onNotifications: onNotifications,
              onProfile: onProfile,
            ),
            Expanded(
              child: ListView(
                key: const Key('history-scroll-view'),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  GlassPanel(
                    glow: true,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceLow,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: .28),
                            ),
                            boxShadow: AppElevation.glowPrimary,
                          ),
                          child: const Icon(
                            Icons.balance_rounded,
                            size: 34,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'OFFICIAL COURT RULING',
                          style: AppTypography.overline.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'NOT GUILTY',
                          style: AppTypography.headline.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 34,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'The defense dismantled the prosecution’s central thesis. Reasonable doubt remains.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GlassPanel(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.how_to_vote_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Jury consensus',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '12 – 0',
                              style: AppTypography.title.copyWith(
                                color: AppColors.primary,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const _ConsensusLine(
                          label: 'Acquittal · Defense',
                          value: 1,
                          valueLabel: '100%',
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ConsensusLine(
                          label: 'Conviction · Prosecution',
                          value: 0,
                          valueLabel: '0%',
                          color: AppColors.urgent,
                          muted: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GlassPanel(
                    color: AppColors.surfaceHigh,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: .1),
                                boxShadow: AppElevation.glowPrimary,
                              ),
                              child: const Icon(
                                Icons.verified_outlined,
                                size: 21,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Judicial precedent',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'By systematically testing the timeline discrepancies in Exhibit C, the defense established undeniable reasonable doubt. This ruling reinforces rigorous chain-of-custody review.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton.icon(
                          onPressed: () => showDemoFeedback(
                            context,
                            'Case file prepared. Secure download will connect with the backend.',
                          ),
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download case file'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Row(
                    children: [
                      Expanded(
                        child: _AchievementCard(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Flawless Logic',
                          detail: 'Rare achievement',
                          color: AppColors.urgent,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _AchievementCard(
                          icon: Icons.gavel_rounded,
                          title: 'Master Orator',
                          detail: 'High persuasion',
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      color: AppColors.surfaceLow,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: .1),
                      ),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _ClosedPainter()),
                        ),
                        Text(
                          'C A S E   C L O S E D',
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontSize: 13,
                            letterSpacing: 3,
                            color: AppColors.outlineStrong,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: onOpenCasebook,
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: const Text('View full casebook'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsensusLine extends StatelessWidget {
  const _ConsensusLine({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
    this.muted = false,
  });

  final String label;
  final double value;
  final String valueLabel;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? .46 : 1,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(valueLabel),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: color.withValues(alpha: .12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .08),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: .22), blurRadius: 18),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ClosedPainter extends CustomPainter {
  const _ClosedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: .055);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.primary.withValues(alpha: .08);
    for (var i = 0; i < 9; i++) {
      final x = (i * 53.0) % size.width;
      final y = (i * 31.0) % size.height;
      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + 18, y + 6)
        ..lineTo(x + 8, y + 24)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, outline);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
