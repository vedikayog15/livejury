import 'package:flutter/material.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});
  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final c = s.currentCase;
    final r = s.room!;
    final exhibits = c.evidence
        .where(
          (e) =>
              filter == 'All' ||
              filter == 'Unread' && !r.reviewed.contains(e.id) ||
              filter == 'Reviewed' && r.reviewed.contains(e.id),
        )
        .toList();
    final firstVote = r.initial == null;
    return JuryPage(
      title: 'Evidence desk',
      eyebrow: c.title,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (firstVote && r.reviewed.length < c.evidence.length) ...[
            Text(
              'Review all ${c.evidence.length} exhibits to unlock your first vote.',
              style: const TextStyle(color: JColors.muted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
          PrimaryButton(
            firstVote ? 'Make my first call' : 'Return to the room',
            onPressed: firstVote && r.reviewed.length < c.evidence.length
                ? null
                : () => go(
                    context,
                    firstVote ? '/initial-vote' : s.resumeRoute,
                    replace: !firstVote,
                  ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const StageStrip(active: 0),
          Text('Look closer.', style: JType.display(42)),
          const SizedBox(height: 12),
          const Text(
            'Every detail has a story. Every story has a gap.',
            style: TextStyle(color: JColors.muted, height: 1.6),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${r.reviewed.length} OF ${c.evidence.length} EXHIBITS REVIEWED',
                  style: JType.caption.copyWith(
                    fontSize: 10,
                    color: JColors.muted,
                  ),
                ),
              ),
              Text(
                '${(r.reviewed.length / c.evidence.length * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: r.reviewed.length / c.evidence.length,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in ['All', 'Unread', 'Reviewed'])
                ChoiceChip(
                  label: Text(f),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                  showCheckmark: false,
                  selectedColor: JColors.secondary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (exhibits.isEmpty)
            EmptyState(
              title: filter == 'Reviewed'
                  ? 'A fresh pair of eyes.'
                  : 'All caught up.',
              body: filter == 'Reviewed'
                  ? 'Open an exhibit and mark it reviewed.'
                  : 'You’ve examined every exhibit. Your first impression is ready to take shape.',
              icon: Icons.fact_check_outlined,
            ),
          for (final e in exhibits)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: JColors.surface,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => go(context, '/exhibit', arguments: e),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: JColors.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(evidenceIcon(e.kind), size: 23),
                            ),
                            const Spacer(),
                            StatusTag(
                              r.reviewed.contains(e.id) ? 'REVIEWED' : e.id,
                              icon: r.reviewed.contains(e.id)
                                  ? Icons.check
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(e.title, style: JType.display(29)),
                        const SizedBox(height: 8),
                        Text(
                          e.summary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: JColors.muted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.kind.name.toUpperCase(),
                                style: JType.caption.copyWith(
                                  fontSize: 10,
                                  color: JColors.muted,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
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
