import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final entries = s.player!.history;
    // An empty journal is a single centred message, so it keeps the reading
    // measure rather than stretching across the desktop canvas.
    final wide = JSpace.isExpanded(context) && entries.isNotEmpty;
    return JuryPage(
      title: 'Your case journal',
      back: false,
      tab: 1,
      wide: wide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: wide ? 14 : 28),
          ..._intro(s),
          const SizedBox(height: 26),
          if (entries.isEmpty)
            EmptyState(
              title: 'Your first chapter awaits.',
              body:
                  'Completed cases, your reasoning, and earned achievements will live here.',
              action: PrimaryButton(
                'Find my first jury',
                onPressed: () => home(context),
              ),
            )
          else if (wide)
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final h in entries)
                    SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: _entry(context, h),
                    ),
                ],
              ),
            )
          else
            for (final h in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _entry(context, h),
              ),
        ],
      ),
    );
  }

  List<Widget> _intro(JuryController s) => [
    const Eyebrow('A record of considered calls'),
    const SizedBox(height: 14),
    Text('Every case leaves\na perspective.', style: JType.display(39)),
    const SizedBox(height: 14),
    Text(
      '${s.player!.history.length} cases completed · ${s.player!.points} points earned',
      style: const TextStyle(color: JColors.muted, fontSize: 13),
    ),
  ];

  Widget _entry(BuildContext context, CaseRecord h) => Material(
    color: JColors.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: () => go(context, '/history-detail', arguments: h),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Eyebrow(
                    '${h.date.day.toString().padLeft(2, '0')} / ${h.date.month.toString().padLeft(2, '0')} / ${h.date.year}',
                  ),
                ),
                Text(
                  '+${h.points} pts',
                  style: const TextStyle(
                    color: JColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(h.title, style: JType.display(31)),
            const SizedBox(height: 14),
            Row(
              children: [
                StatusTag(h.outcome),
                const Spacer(),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.record});
  final CaseRecord record;
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final c = s.cases.firstWhere((c) => c.id == record.caseId);
    final expanded = JSpace.isExpanded(context);
    final action = PrimaryButton(
      'Revisit the case briefing',
      onPressed: () => go(context, '/case-preview', arguments: c),
    );
    return JuryPage(
      title: 'From your journal',
      wide: expanded,
      scroll: !expanded,
      child: expanded
          // The outcome and your own words hold the reading column; the
          // debrief, the tally and the action sit beside them.
          ? SplitLayout(
              mainHeader: [
                StatusTag(record.outcome),
                const SizedBox(height: 20),
                _title(),
              ],
              main: [_reasoning()],
              aside: [
                ..._metrics(),
                const SizedBox(height: 24),
                ..._perspective(c),
                const SizedBox(height: 28),
                action,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                StatusTag(record.outcome),
                const SizedBox(height: 22),
                _title(),
                const SizedBox(height: 24),
                _reasoning(),
                const SizedBox(height: 24),
                ..._metrics(),
                const SizedBox(height: 24),
                ..._perspective(c),
                const SizedBox(height: 28),
                action,
              ],
            ),
    );
  }

  Widget _title() => Text(record.title, style: JType.display(42));

  Widget _reasoning() => Panel(
    color: JColors.secondary,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Your reasoning, preserved'),
        const SizedBox(height: 16),
        Text(record.reason, style: JType.body),
      ],
    ),
  );

  List<Widget> _metrics() => [
    InfoRow(
      icon: Icons.stars_outlined,
      title: '${record.points} points earned',
      subtitle:
          '${record.reviewed} exhibits reviewed · ${record.citations} evidence references',
    ),
    if (record.changedMind)
      const InfoRow(
        icon: Icons.psychology_outlined,
        title: 'A mind open to change',
        subtitle: 'Your final call differed from your first impression.',
      ),
  ];

  List<Widget> _perspective(CaseFile c) => [
    SectionHeading('The case in perspective'),
    const SizedBox(height: 16),
    Text(c.debrief, style: JType.body),
  ];
}
