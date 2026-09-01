import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/design_tokens.dart';
import '../../../core/theme/live_jury_theme.dart';
import '../widgets/jury_room_components.dart';

class JuryLobbyScreen extends StatelessWidget {
  const JuryLobbyScreen({
    super.key,
    required this.onFindJury,
    required this.onCreateRoom,
    required this.onNotifications,
    required this.onProfile,
  });

  final VoidCallback onFindJury;
  final VoidCallback onCreateRoom;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return EmeraldBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            JuryRoomHeader(
              title: 'Lobby',
              onNotifications: onNotifications,
              onProfile: onProfile,
            ),
            Expanded(
              child: ListView(
                key: const Key('home-scroll-view'),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'State v. Davis',
                              style: AppTypography.editorialTitle.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.gavel_rounded,
                                  size: 18,
                                  color: AppColors.urgent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Case #CR-2024-8891',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showPreferences(context),
                        tooltip: 'Jury preferences',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceHigh,
                          side: const BorderSide(color: AppColors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const _AssemblyOrb(assembled: 4, total: 6),
                  const SizedBox(height: AppSpacing.xxl),
                  GlassPanel(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                'The Supermarket Theft',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const ExhibitTag(
                              label: 'Felony',
                              color: AppColors.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'A grand-larceny case built around disputed security footage, inventory logs, and three competing witness accounts.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ExhibitTag(
                              label: 'CCTV footage',
                              icon: Icons.videocam_outlined,
                            ),
                            ExhibitTag(
                              label: 'Inventory logs',
                              icon: Icons.receipt_long_outlined,
                            ),
                            ExhibitTag(
                              label: '3 testimonies',
                              icon: Icons.record_voice_over_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GlassPanel(
                    radius: AppRadii.lg,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const StatusDot(color: AppColors.urgent),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Judge requires a verdict by 17:00 EST',
                            style: AppTypography.body.copyWith(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    key: const Key('find-jury-button'),
                    onPressed: onFindJury,
                    icon: const Icon(Icons.groups_2_rounded),
                    label: const Text('Find my jury'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: onCreateRoom,
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('Create room'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreferences(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jury preferences',
              style: Theme.of(sheetContext).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Criminal law · Intermediate · 12–15 minutes',
              style: Theme.of(sheetContext).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: const Text('Keep these preferences'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssemblyOrb extends StatelessWidget {
  const _AssemblyOrb({required this.assembled, required this.total});

  final int assembled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = math.min(constraints.maxWidth, 340.0);
        return Center(
          child: SizedBox.square(
            dimension: dimension,
            child: CustomPaint(
              painter: _AssemblyRingPainter(progress: assembled / total),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-.35, -.55),
                      colors: [Color(0xFF22302B), AppColors.surfaceLow],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .16),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x50000000), blurRadius: 30),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$assembled',
                              style: AppTypography.display.copyWith(
                                color: AppColors.primary,
                                fontSize: 43,
                              ),
                            ),
                            TextSpan(
                              text: ' / $total',
                              style: AppTypography.title.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'JURORS ASSEMBLED',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _AvatarStack(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Awaiting final members…',
                        style: AppTypography.body.copyWith(
                          color: AppColors.primaryPressed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    const people = ['VK', 'AM', 'SK', 'RN'];
    return SizedBox(
      width: 126,
      height: 40,
      child: Stack(
        children: List.generate(
          people.length,
          (index) => Positioned(
            left: index * 28,
            child: JuryAvatar(initials: people[index]),
          ),
        ),
      ),
    );
  }
}

class _AssemblyRingPainter extends CustomPainter {
  const _AssemblyRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - 4;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.surfaceHighest,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5
        ..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _AssemblyRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
