import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/live_jury_widgets.dart';

class _StandingRow {
  const _StandingRow(this.rank, this.name, this.points);
  final String rank;
  final String name;
  final String points;
}

class _Standings {
  const _Standings({required this.podium, required this.rows});
  final List<_StandingRow> podium;
  final List<_StandingRow> rows;
}

const _standingsByPeriod = {
  'week': _Standings(
    podium: [
      _StandingRow('2', 'Mira', '2,840'),
      _StandingRow('1', 'Arjun', '3,120'),
      _StandingRow('3', 'Noah', '2,610'),
    ],
    rows: [
      _StandingRow('4', 'Sara Khan', '2,480'),
      _StandingRow('5', 'Leena Patel', '2,320'),
      _StandingRow('6', 'Rohan Nair', '2,190'),
      _StandingRow('18', 'You', '1,420'),
    ],
  ),
  'month': _Standings(
    podium: [
      _StandingRow('2', 'Sara Khan', '9,760'),
      _StandingRow('1', 'Mira', '11,020'),
      _StandingRow('3', 'Arjun', '9,340'),
    ],
    rows: [
      _StandingRow('4', 'Noah', '8,910'),
      _StandingRow('5', 'Rohan Nair', '8,470'),
      _StandingRow('6', 'Jia Thomas', '7,980'),
      _StandingRow('12', 'You', '5,260'),
    ],
  ),
  'all': _Standings(
    podium: [
      _StandingRow('2', 'Arjun', '48,300'),
      _StandingRow('1', 'Mira', '52,900'),
      _StandingRow('3', 'Sara Khan', '44,150'),
    ],
    rows: [
      _StandingRow('4', 'Noah', '41,760'),
      _StandingRow('5', 'Leena Patel', '39,220'),
      _StandingRow('6', 'Rohan Nair', '36,880'),
      _StandingRow('27', 'You', '18,040'),
    ],
  ),
};

const _podiumHeights = {'1': 146.0, '2': 116.0, '3': 98.0};

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _period = 'week';

  @override
  Widget build(BuildContext context) {
    final standings = _standingsByPeriod[_period]!;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Reasoned voices',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Recognising thoughtful, respectful jurors.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'week', label: Text('WEEK')),
              ButtonSegment(value: 'month', label: Text('MONTH')),
              ButtonSegment(value: 'all', label: Text('ALL TIME')),
            ],
            selected: {_period},
            onSelectionChanged: (value) =>
                setState(() => _period = value.first),
          ),
          const SizedBox(height: 28),
          KeyedSubtree(
            key: ValueKey(_period),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final p in standings.podium)
                  StaggeredEntrance(
                    index: int.parse(p.rank) - 1,
                    child: Podium(
                      rank: int.parse(p.rank),
                      name: p.name,
                      points: p.points,
                      height: _podiumHeights[p.rank]!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < standings.rows.length; i++)
            StaggeredEntrance(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  child: Semantics(
                    label:
                        'Rank ${standings.rows[i].rank}, ${standings.rows[i].name}, '
                        '${standings.rows[i].points} points',
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            standings.rows[i].rank,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: standings.rows[i].name == 'You'
                                      ? AppColors.gold
                                      : AppColors.muted,
                                ),
                          ),
                        ),
                        JurorAvatar(
                          initials: standings.rows[i].name
                              .split(' ')
                              .map((e) => e[0])
                              .take(2)
                              .join(),
                          color: standings.rows[i].name == 'You'
                              ? AppColors.gold
                              : AppColors.teal,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            standings.rows[i].name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          standings.rows[i].points,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.gold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
