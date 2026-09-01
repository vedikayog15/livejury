import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/live_jury_widgets.dart';

enum _CasebookFilter { all, thisMonth, matchedLaw }

class _CaseRecord {
  const _CaseRecord({
    required this.title,
    required this.category,
    required this.verdict,
    required this.score,
    required this.date,
    required this.isThisMonth,
    required this.matchedLaw,
  });

  final String title;
  final String category;
  final String verdict;
  final int score;
  final String date;
  final bool isThisMonth;
  final bool matchedLaw;
}

const _cases = [
  _CaseRecord(
    title: 'The Silent Witness',
    category: 'Criminal',
    verdict: 'Not Guilty',
    score: 91,
    date: 'Yesterday',
    isThisMonth: true,
    matchedLaw: true,
  ),
  _CaseRecord(
    title: 'Terms & Conditions',
    category: 'Technology',
    verdict: 'Liable',
    score: 84,
    date: '8 Aug',
    isThisMonth: true,
    matchedLaw: false,
  ),
  _CaseRecord(
    title: 'A Question of Care',
    category: 'Civil',
    verdict: 'Not Liable',
    score: 79,
    date: '2 Aug',
    isThisMonth: true,
    matchedLaw: true,
  ),
  _CaseRecord(
    title: 'The Last Delivery',
    category: 'Ethics',
    verdict: 'Guilty',
    score: 86,
    date: '29 Jul',
    isThisMonth: false,
    matchedLaw: true,
  ),
];

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _CasebookFilter _filter = _CasebookFilter.all;

  List<_CaseRecord> get _filtered => switch (_filter) {
    _CasebookFilter.all => _cases,
    _CasebookFilter.thisMonth => _cases.where((c) => c.isThisMonth).toList(),
    _CasebookFilter.matchedLaw => _cases.where((c) => c.matchedLaw).toList(),
  };

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your casebook',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Decisions, discussions, and what you learned.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All cases'),
                selected: _filter == _CasebookFilter.all,
                onSelected: (_) =>
                    setState(() => _filter = _CasebookFilter.all),
              ),
              FilterChip(
                label: const Text('This month'),
                selected: _filter == _CasebookFilter.thisMonth,
                onSelected: (_) =>
                    setState(() => _filter = _CasebookFilter.thisMonth),
              ),
              FilterChip(
                label: const Text('Matched law'),
                selected: _filter == _CasebookFilter.matchedLaw,
                onSelected: (_) =>
                    setState(() => _filter = _CasebookFilter.matchedLaw),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No cases here yet',
              message: _filter == _CasebookFilter.matchedLaw
                  ? 'Cases where your verdict matched the legal outcome will show up here.'
                  : 'Cases from this month will show up here once you deliberate one.',
              actionLabel: 'Show all cases',
              onAction: () => setState(() => _filter = _CasebookFilter.all),
            )
          else
            for (var i = 0; i < filtered.length; i++)
              StaggeredEntrance(
                index: i,
                child: HistoryCard(
                  title: filtered[i].title,
                  category: filtered[i].category,
                  verdict: filtered[i].verdict,
                  score: filtered[i].score,
                  date: filtered[i].date,
                  matchedLaw: filtered[i].matchedLaw,
                  onTap: () => _openSummary(context, filtered[i]),
                ),
              ),
        ],
      ),
    );
  }

  void _openSummary(BuildContext context, _CaseRecord record) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.category.toUpperCase(),
              style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                color: AppColors.gold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              record.title,
              style: Theme.of(sheetContext).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Verdict: ${record.verdict}',
              style: Theme.of(sheetContext).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Reasoning score: ${record.score} · Deliberated ${record.date}',
              style: Theme.of(
                sheetContext,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  record.matchedLaw
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: record.matchedLaw ? AppColors.teal : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.matchedLaw
                        ? 'Your jury’s verdict matched the legal outcome.'
                        : 'Your jury’s verdict differed from the legal outcome.',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
