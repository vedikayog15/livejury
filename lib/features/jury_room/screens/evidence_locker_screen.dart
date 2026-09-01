import 'package:flutter/material.dart';

import '../../../core/design/design_tokens.dart';
import '../../../core/theme/live_jury_theme.dart';
import '../widgets/jury_room_components.dart';

class EvidenceLockerScreen extends StatefulWidget {
  const EvidenceLockerScreen({
    super.key,
    required this.onNotifications,
    required this.onProfile,
  });

  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  State<EvidenceLockerScreen> createState() => _EvidenceLockerScreenState();
}

class _EvidenceLockerScreenState extends State<EvidenceLockerScreen> {
  bool _videoReviewed = true;
  bool _reportReviewed = false;

  double get _progress =>
      (_videoReviewed ? .5 : 0) + (_reportReviewed ? .5 : 0);

  @override
  Widget build(BuildContext context) {
    return EmeraldBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            JuryRoomHeader(
              title: 'Evidence',
              onNotifications: widget.onNotifications,
              onProfile: widget.onProfile,
            ),
            Expanded(
              child: ListView(
                key: const Key('evidence-scroll-view'),
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
                children: [
                  Text(
                    'Evidence Locker',
                    style: AppTypography.display.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A secure repository for verified exhibits and related documentation.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _ExhibitHeading(
                    title: 'Exhibit 12-A',
                    badge: 'FLAGGED',
                    badgeColor: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _VideoExhibit(
                    reviewed: _videoReviewed,
                    onPressed: () {
                      setState(() => _videoReviewed = true);
                      showDemoFeedback(
                        context,
                        'CCTV playback is ready for backend media integration.',
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _ExhibitHeading(
                    title: 'Exhibit 4-C',
                    badge: _reportReviewed ? 'REVIEWED' : 'NEW',
                    badgeColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassPanel(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighest.withValues(
                                  alpha: .58,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Initial Incident Report',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Officer K. Reynolds · Oct 14, 2023',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          '“Upon arriving at approximately 23:45, I noted forced entry through the rear service door. No immediate signs of a struggle were present…”',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _openReport,
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('View full PDF'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  GlassPanel(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'REVIEW PROGRESS',
                              style: AppTypography.overline.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(_progress * 100).round()}%',
                              style: AppTypography.title.copyWith(
                                color: AppColors.primary,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Semantics(
                          label:
                              'Evidence review ${(_progress * 100).round()} percent complete',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: _progress,
                              minHeight: 10,
                            ),
                          ),
                        ),
                      ],
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

  void _openReport() {
    setState(() => _reportReviewed = true);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        maxChildSize: .92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
          children: [
            Text(
              'Initial Incident Report',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'EXHIBIT 4-C · VERIFIED DOCUMENT',
              style: AppTypography.overline.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Upon arriving at the scene at approximately 23:45, I noted forced entry through the rear service door. No immediate signs of a struggle were present in the primary foyer. Inventory reconciliation identified three missing high-value electronics. The loading-bay camera was offline between 23:31 and 23:52. Chain-of-custody documentation was initiated at 00:18.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                showDemoFeedback(
                  context,
                  'Download queued. File storage will connect with the backend.',
                );
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download document'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExhibitHeading extends StatelessWidget {
  const _ExhibitHeading({
    required this.title,
    required this.badge,
    required this.badgeColor,
  });

  final String title;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.title.copyWith(
              color: AppColors.primary,
              fontSize: 24,
            ),
          ),
        ),
        ExhibitTag(label: badge, color: badgeColor),
      ],
    );
  }
}

class _VideoExhibit extends StatelessWidget {
  const _VideoExhibit({required this.reviewed, required this.onPressed});

  final bool reviewed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play CCTV Alley North video',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          child: Container(
            height: 245,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xxl),
              border: Border.all(color: AppColors.outline),
              color: AppColors.surfaceLowest,
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _AlleyPainter()),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: StatusDot(
                    color: reviewed ? AppColors.primary : AppColors.error,
                    size: 8,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLowest.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'CCTV_Alley_North.mp4',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
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

class _AlleyPainter extends CustomPainter {
  const _AlleyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF27302D), Color(0xFF090C0B)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final line = Paint()
      ..color = AppColors.outlineStrong.withValues(alpha: .28)
      ..strokeWidth = 1;
    final strong = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: .14)
      ..strokeWidth = 2;

    final vanishing = Offset(size.width * .59, size.height * .48);
    for (final y in [0.0, size.height * .18, size.height * .36, size.height]) {
      canvas.drawLine(Offset(0, y), vanishing, line);
      canvas.drawLine(Offset(size.width, y), vanishing, line);
    }
    for (var i = 0; i < 6; i++) {
      final x = i * size.width / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * .72), line);
    }
    canvas.drawLine(
      Offset(0, size.height * .78),
      Offset(size.width, size.height * .7),
      strong,
    );
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .18),
      13,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                AppColors.textPrimary.withValues(alpha: .65),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * .78, size.height * .18),
                radius: 13,
              ),
            ),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .42, size.height * .61),
        width: 22,
        height: 55,
      ),
      Paint()..color = const Color(0xFF070908),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
