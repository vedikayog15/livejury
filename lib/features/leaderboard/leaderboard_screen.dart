import 'package:flutter/material.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) JuryScope.of(context).loadRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return JuryPage(
      title: 'The considered company',
      back: false,
      tab: 2,
      actions: [
        IconButton(
          tooltip: 'Refresh rankings',
          onPressed: s.busy ? null : s.loadRankings,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      wide: JSpace.isExpanded(context),
      child: JSpace.isExpanded(context)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      ..._intro(s),
                      const SizedBox(height: 24),
                      _note(),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const SizedBox(height: 20), ..._rankings(s)],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                ..._intro(s),
                const SizedBox(height: 24),
                ..._rankings(s),
                const SizedBox(height: 24),
                _note(),
              ],
            ),
    );
  }

  List<Widget> _intro(JuryController s) => [
    const Eyebrow('A place for thoughtful minds'),
    const SizedBox(height: 14),
    Text('Good judgment\nis a practice.', style: JType.display(40)),
    const SizedBox(height: 16),
    const Text(
      'A little recognition for showing up, looking closer, and making the conversation better.',
      style: TextStyle(color: JColors.muted, height: 1.7),
    ),
    const SizedBox(height: 24),
    StatusTag(
      s.isDemo ? 'SAMPLE RANKINGS + YOUR SCORE' : 'ALL-TIME PARTICIPATION',
    ),
  ];

  List<Widget> _rankings(JuryController s) => [
    if (s.busy)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: LinearProgressIndicator(),
      ),
    if (!s.busy && s.leaders.isEmpty)
      const EmptyState(
        title: 'The first seat is open.',
        body: 'Complete a case to start the community rankings.',
        icon: Icons.leaderboard_outlined,
      ),
    for (final (i, entry) in s.leaders.indexed)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Panel(
          color: i == 0 ? JColors.ink : JColors.surface,
          padding: 18,
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '${i + 1}'.padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: i == 0 ? JColors.accent : JColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Avatar(entry.name, index: i, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: i == 0 ? JColors.surface : JColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.cases} cases',
                      style: TextStyle(
                        fontSize: 11,
                        color: i == 0 ? JColors.onDarkMuted : JColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.points}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: i == 0 ? JColors.accent : JColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
  ];

  Widget _note() => const Panel(
    color: JColors.secondary,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Thoughtfulness over conformity'),
        SizedBox(height: 12),
        Text(
          'You earn points for reviewing evidence, contributing a reference, and explaining your final call. You never earn more for following the majority.',
          style: TextStyle(fontSize: 13, height: 1.7),
        ),
      ],
    ),
  );
}
