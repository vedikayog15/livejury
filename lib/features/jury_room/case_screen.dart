import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/chamber_art.dart';
import '../../design/widgets/jury_widgets.dart';

class CaseScreen extends StatefulWidget {
  const CaseScreen({super.key, this.preview});
  final CaseFile? preview;
  @override
  State<CaseScreen> createState() => _CaseScreenState();
}

class _CaseScreenState extends State<CaseScreen> {
  bool timeline = false;
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final c = widget.preview ?? s.currentCase;
    return JuryPage(
      title: 'The case file',
      eyebrow: 'Docket ${c.number}',
      bottom: PrimaryButton(
        widget.preview != null
            ? 'Find a jury for this case'
            : 'Examine the evidence',
        loading: s.busy,
        onPressed: () async {
          if (widget.preview != null) {
            if (await s.openRoom(c) && context.mounted) {
              go(context, '/room', replace: true);
            }
          } else {
            go(context, '/evidence');
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (widget.preview == null) const StageStrip(active: 0),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusTag('${c.category.toUpperCase()} CASE'),
              StatusTag('~${c.minutes} MIN'),
              const StatusTag('FICTIONAL'),
            ],
          ),
          const SizedBox(height: 20),
          Text(c.title, style: JType.display(46)),
          const SizedBox(height: 12),
          Text(
            c.subtitle,
            style: const TextStyle(
              color: JColors.muted,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: JColors.ink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DossierArt(
              variant: s.cases.indexWhere((e) => e.id == c.id),
              height: 170,
            ),
          ),
          const SizedBox(height: 24),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Briefing'),
                icon: Icon(Icons.subject_rounded),
              ),
              ButtonSegment(
                value: true,
                label: Text('Timeline'),
                icon: Icon(Icons.schedule_rounded),
              ),
            ],
            selected: {timeline},
            onSelectionChanged: (v) => setState(() => timeline = v.first),
          ),
          const SizedBox(height: 24),
          if (!timeline) ...[
            const Eyebrow('The matter before you'),
            const SizedBox(height: 14),
            Text(c.summary, style: JType.body),
            const SizedBox(height: 26),
            Panel(
              color: JColors.secondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Your question'),
                  const SizedBox(height: 12),
                  Text(c.question, style: JType.display(27)),
                  const SizedBox(height: 16),
                  Text(
                    c.standard,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: JColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              c.parties,
              style: const TextStyle(
                fontSize: 12,
                color: JColors.muted,
                height: 1.6,
              ),
            ),
          ] else ...[
            const Eyebrow('What happened, and when'),
            const SizedBox(height: 20),
            for (final event in c.timeline)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(
                        event['time']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: JColors.ink,
                          ),
                        ),
                        Expanded(
                          child: Container(width: 1, color: JColors.border),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event['body']!,
                              style: const TextStyle(
                                color: JColors.muted,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
