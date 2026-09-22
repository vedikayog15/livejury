import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class ExhibitScreen extends StatefulWidget {
  const ExhibitScreen({super.key, required this.exhibit});
  final Exhibit exhibit;
  @override
  State<ExhibitScreen> createState() => _ExhibitScreenState();
}

class _ExhibitScreenState extends State<ExhibitScreen> {
  bool playing = false;
  double progress = 0;
  Timer? timer;
  void play() {
    timer?.cancel();
    setState(() => playing = !playing);
    if (playing) {
      if (progress >= 1) progress = 0;
      timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted) return;
        setState(() {
          progress = (progress + 1 / 60).clamp(0, 1);
          if (progress >= 1) {
            playing = false;
            timer?.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final e = widget.exhibit;
    final reviewed = s.room!.reviewed.contains(e.id);
    final expanded = JSpace.isExpanded(context);
    final action = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrimaryButton(
          reviewed ? 'Reviewed · back to evidence' : 'Mark as reviewed',
          loading: s.busy,
          icon: reviewed ? Icons.check_rounded : Icons.done_all_rounded,
          onPressed: () async {
            if (!reviewed && !await s.markReviewed(e)) return;
            if (context.mounted) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                go(context, '/evidence', replace: true);
              }
            }
          },
        ),
        if (s.room!.stage == RoundStage.deliberation)
          TextButton(
            onPressed: () {
              s.attach(e.id);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/discussion',
                (route) => route.settings.name == '/home' || route.isFirst,
              );
            },
            child: const Text('Reference in discussion'),
          ),
      ],
    );
    return JuryPage(
      title: 'Exhibit ${e.id}',
      eyebrow: e.kind.name,
      bottom: expanded ? null : action,
      wide: expanded,
      scroll: !expanded,
      child: expanded
          // A flex-6 share of the wide canvas keeps the exhibit text near the
          // reading measure; provenance and the action sit beside it.
          ? SplitLayout(
              mainHeader: [
                _tags(e, reviewed),
                const SizedBox(height: 22),
                _title(e),
              ],
              main: [..._media(e), _record(e)],
              aside: [
                _source(e),
                const SizedBox(height: 24),
                _caution(e),
                const SizedBox(height: 28),
                action,
                const SizedBox(height: 20),
                _disclaimer(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                _tags(e, reviewed),
                const SizedBox(height: 24),
                _title(e),
                const SizedBox(height: 12),
                _source(e),
                const SizedBox(height: 24),
                ..._media(e),
                _record(e),
                const SizedBox(height: 24),
                _caution(e),
                const SizedBox(height: 20),
                _disclaimer(),
              ],
            ),
    );
  }

  Widget _tags(Exhibit e, bool reviewed) => Row(
    children: [
      StatusTag(e.id),
      const SizedBox(width: 8),
      StatusTag(e.kind.name.toUpperCase()),
      if (reviewed) ...[
        const Spacer(),
        const Icon(Icons.check_circle_outline, color: JColors.success),
      ],
    ],
  );

  Widget _title(Exhibit e) => Text(e.title, style: JType.display(42));

  Widget _source(Exhibit e) => Text(
    e.source,
    style: const TextStyle(color: JColors.muted, fontSize: 12, height: 1.6),
  );

  /// The diagram or audio panel, each followed by its own spacing so the
  /// narrow column keeps the order it always had.
  List<Widget> _media(Exhibit e) => [
    if (e.kind == EvidenceKind.diagram) ...[
      Panel(
        color: JColors.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Schematic · not to scale', dark: true),
            const SizedBox(height: 16),
            Semantics(
              label:
                  'Reconstructed scene diagram showing a main area, a service route, and an unobserved exit. Read the text below for complete details.',
              image: true,
              child: const SizedBox(
                height: 170,
                width: double.infinity,
                child: CustomPaint(painter: _PlanPainter()),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Solid outline: observed area\nDashed route: unobserved connection',
              style: TextStyle(
                color: JColors.onDarkMuted,
                fontSize: 11,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ],
    if (e.kind == EvidenceKind.audio) ...[
      Panel(
        color: JColors.ink,
        child: Column(
          children: [
            const Text(
              'TRANSCRIPT VISUALIZATION · NO AUDIO',
              style: TextStyle(
                color: JColors.onDarkMuted,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                IconButton.filled(
                  tooltip: playing
                      ? 'Pause visualization'
                      : 'Play visualization',
                  onPressed: play,
                  style: IconButton.styleFrom(
                    backgroundColor: JColors.accent,
                    foregroundColor: JColors.ink,
                  ),
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Semantics(
                    label:
                        'Transcript progress ${(progress * 100).round()} percent',
                    child: SizedBox(
                      height: 48,
                      child: CustomPaint(painter: _WavePainter(progress)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              color: JColors.accent,
              backgroundColor: JColors.raised,
            ),
            const SizedBox(height: 10),
            Text(
              '${(progress * 12).round()}s / 12s',
              style: const TextStyle(color: JColors.onDarkMuted, fontSize: 11),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ],
  ];

  Widget _record(Exhibit e) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(evidenceIcon(e.kind), size: 18, color: JColors.muted),
            const SizedBox(width: 10),
            const Expanded(child: Eyebrow('From the case record')),
          ],
        ),
        const SizedBox(height: 18),
        SelectableText(e.content, style: JType.body),
      ],
    ),
  );

  Widget _caution(Exhibit e) => Panel(
    color: JColors.secondary,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 20),
            SizedBox(width: 10),
            Expanded(child: Eyebrow('Consider the limitation')),
          ],
        ),
        const SizedBox(height: 14),
        Text(e.caution, style: const TextStyle(fontSize: 14, height: 1.7)),
      ],
    ),
  );

  Widget _disclaimer() => const Text(
    'All material is written for this fictional game.',
    style: TextStyle(color: JColors.muted, fontSize: 11),
  );
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.progress);
  final double progress;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 36; i++) {
      final h = 8 + (math.sin(i * 2.4).abs() * s.height * .8);
      p.color = i / 36 <= progress
          ? JColors.accent
          : JColors.onDarkMuted.withValues(alpha: .35);
      final x = i * s.width / 36;
      c.drawLine(
        Offset(x, (s.height - h) / 2),
        Offset(x, (s.height + h) / 2),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

class _PlanPainter extends CustomPainter {
  const _PlanPainter();
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = JColors.onDarkMuted;
    final a = Rect.fromLTWH(10, 10, s.width * .58, s.height - 30);
    c.drawRect(a, p);
    c.drawRect(Rect.fromLTWH(a.right, 10, s.width * .3, 60), p);
    c.drawRect(Rect.fromLTWH(a.right, 95, s.width * .3, 45), p);
    c.drawCircle(
      Offset(a.center.dx, a.center.dy),
      14,
      p..color = JColors.accent,
    );
    for (var x = a.center.dx; x < s.width - 12; x += 10) {
      c.drawLine(
        Offset(x, a.center.dy),
        Offset(x + 5, a.center.dy),
        p..color = JColors.accent,
      );
    }
    for (final (text, pos) in [
      ('MAIN AREA', Offset(22, s.height - 42)),
      ('EXIT A', Offset(a.right + 8, 30)),
      ('EXIT B', Offset(a.right + 8, 110)),
    ]) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 9,
            color: JColors.onDarkMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, pos);
    }
  }

  @override
  bool shouldRepaint(_PlanPainter old) => false;
}
