import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final r = s.room!;
    final c = s.currentCase;
    if (r.stage != RoundStage.complete || r.responsibleCount == null) {
      return JuryPage(
        title: 'The verdict',
        child: EmptyState(
          title: 'The room is still deciding.',
          body: 'Results stay sealed until all six final ballots are received.',
          action: PrimaryButton(
            'Return to the room',
            onPressed: () => go(context, s.resumeRoute, replace: true),
          ),
        ),
      );
    }
    final yes = r.responsibleCount!;
    final no = 6 - yes;
    final tied = yes == no;
    final outcome = tied
        ? 'A hung jury.'
        : c.label(yes > no ? Decision.responsible : Decision.notResponsible);
    final records = s.player!.history.where((h) => h.roomId == r.id);
    final record = records.isEmpty ? null : records.first;
    return JuryPage(
      title: 'The room has spoken',
      eyebrow: 'Case ${c.number} · closed',
      bottom: PrimaryButton(
        'Return to the lobby',
        onPressed: () => home(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: JColors.ink,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusTag(
                  'FINAL VERDICT',
                  dark: true,
                  icon: Icons.lock_open_outlined,
                ),
                const SizedBox(height: 26),
                Text(outcome, style: JType.display(43, JColors.surface)),
                const SizedBox(height: 12),
                Text(
                  tied
                      ? 'Two equally held views. An honest disagreement.'
                      : 'A shared decision, reached one perspective at a time.',
                  style: const TextStyle(
                    color: JColors.onDarkMuted,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    for (var i = 0; i < 6; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(
                              color: i < yes
                                  ? JColors.accent
                                  : JColors.secondary,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              i < yes
                                  ? Icons.check_rounded
                                  : Icons.remove_rounded,
                              size: 16,
                              color: JColors.ink,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    Text(
                      '$yes ${c.label(Decision.responsible)}',
                      style: const TextStyle(
                        color: JColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$no ${c.label(Decision.notResponsible)}',
                      style: const TextStyle(
                        color: JColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${tied ? 50 : ((yes > no ? yes : no) / 6 * 100).round()}% consensus · 6 anonymous ballots',
                  style: const TextStyle(
                    color: JColors.onDarkMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SectionHeading('Your contribution'),
          const SizedBox(height: 16),
          Panel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('+${record?.points ?? 0}', style: JType.display(44)),
                      const Text(
                        'points earned',
                        style: TextStyle(color: JColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 66, color: JColors.border),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${r.reviewed.length}/${c.evidence.length}',
                        style: JType.display(36),
                      ),
                      const Text(
                        'exhibits examined',
                        style: TextStyle(color: JColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (r.reviewed.length == c.evidence.length)
                const StatusTag(
                  'CLOSE READER',
                  icon: Icons.auto_stories_outlined,
                ),
              if ((record?.citations ?? 0) > 0)
                const StatusTag('EVIDENCE ADVOCATE', icon: Icons.attach_file),
              if (record?.changedMind ?? false)
                const StatusTag('OPEN MIND', icon: Icons.psychology_outlined),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '60 participation points + 10 per reviewed exhibit + 20 for citing evidence. Agreement with the majority earns no extra points.',
            style: TextStyle(color: JColors.muted, fontSize: 12, height: 1.7),
          ),
          const SizedBox(height: 28),
          SectionHeading('Beyond the verdict'),
          const SizedBox(height: 14),
          Text(c.debrief, style: const TextStyle(height: 1.8, fontSize: 15)),
          const SizedBox(height: 26),
          Panel(
            color: JColors.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Your final reasoning'),
                const SizedBox(height: 14),
                Text(
                  r.reason,
                  style: const TextStyle(fontSize: 14, height: 1.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your call: ${c.label(r.finalDecision!)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => go(context, '/history'),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories_outlined, size: 18),
                SizedBox(width: 10),
                Flexible(child: Text('View your case journal')),
              ],
            ),
          ),
          if (s.isDemo) ...[
            const SizedBox(height: 18),
            const Text(
              'Demo result: five scripted ballots plus your real choice. Your reasoning and points are saved on this device.',
              style: TextStyle(color: JColors.muted, fontSize: 11, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}
