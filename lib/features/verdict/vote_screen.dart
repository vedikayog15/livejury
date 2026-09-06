import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key, this.finalVote = false});
  final bool finalVote;
  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  Decision? choice;
  TextEditingController? reason;
  final form = GlobalKey<FormState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reason ??= TextEditingController(text: JuryScope.of(context).reasonDraft);
  }

  @override
  void dispose() {
    reason?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final r = s.room!;
    final c = s.currentCase;
    final voted = widget.finalVote
        ? r.finalDecision != null
        : r.initial != null;
    if (voted) {
      return JuryPage(
        title: widget.finalVote ? 'Ballot sealed' : 'First impression saved',
        child: Column(
          children: [
            const SizedBox(height: 44),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: JColors.accent,
              ),
              child: const Icon(Icons.lock_outline, size: 40),
            ),
            const SizedBox(height: 28),
            Text(
              'Your voice is\nin the room.',
              textAlign: TextAlign.center,
              style: JType.display(40),
            ),
            const SizedBox(height: 18),
            Text(
              widget.finalVote && r.stage != RoundStage.complete
                  ? '${r.finalCount} of 6 final ballots received. Results appear after every juror has voted.'
                  : 'Your ballot has been saved. Continue when you’re ready.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: JColors.muted, height: 1.7),
            ),
            const SizedBox(height: 28),
            if (widget.finalVote && r.stage != RoundStage.complete) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: s.refresh,
                child: const Text('Refresh ballot status'),
              ),
            ] else
              PrimaryButton(
                widget.finalVote ? 'Reveal the verdict' : 'Enter deliberation',
                onPressed: () => go(
                  context,
                  widget.finalVote ? '/result' : '/discussion',
                  replace: true,
                ),
              ),
          ],
        ),
      );
    }
    return JuryPage(
      title: widget.finalVote ? 'The final ballot' : 'Your first impression',
      eyebrow: c.title,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 14, color: JColors.muted),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Anonymous to the room. Account-linked for integrity.',
                  style: TextStyle(fontSize: 10, color: JColors.muted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            widget.finalVote
                ? 'Seal my final verdict'
                : 'Seal my first impression',
            loading: s.busy,
            icon: Icons.lock_outline,
            onPressed: choice == null
                ? null
                : () async {
                    if (widget.finalVote && !form.currentState!.validate()) {
                      return;
                    }
                    final ok = await s.castVote(
                      choice!,
                      finalVote: widget.finalVote,
                      reason: reason!.text,
                    );
                    if (ok && context.mounted) {
                      go(
                        context,
                        widget.finalVote
                            ? (s.room!.stage == RoundStage.complete
                                  ? '/result'
                                  : '/vote')
                            : '/discussion',
                        replace: true,
                      );
                    }
                  },
          ),
        ],
      ),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            StageStrip(active: widget.finalVote ? 3 : 1),
            const SizedBox(height: 14),
            Icon(
              widget.finalVote
                  ? Icons.how_to_vote_outlined
                  : Icons.fingerprint_rounded,
              size: 38,
            ),
            const SizedBox(height: 24),
            Text(
              widget.finalVote
                  ? 'You’ve heard the room.\nWhat do you believe?'
                  : 'Before the room speaks,\nwhat do you think?',
              style: JType.display(38),
            ),
            const SizedBox(height: 18),
            Text(
              widget.finalVote
                  ? 'A strong verdict has a reason. Explain what mattered, including any uncertainty.'
                  : 'This is a starting point, not a commitment. Your vote stays private, and it is okay to change your mind.',
              style: const TextStyle(color: JColors.muted, height: 1.7),
            ),
            const SizedBox(height: 28),
            for (final d in Decision.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Semantics(
                  selected: choice == d,
                  button: true,
                  child: InkWell(
                    key: Key('vote-${d.name}'),
                    onTap: () => setState(() => choice = d),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: choice == d ? JColors.ink : JColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: choice == d ? JColors.ink : JColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.label(d),
                                  style: JType.display(
                                    29,
                                    choice == d ? JColors.surface : JColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  d == Decision.responsible
                                      ? 'The evidence meets the game’s standard.'
                                      : 'The case has not met the game’s standard.',
                                  style: TextStyle(
                                    color: choice == d
                                        ? JColors.onDarkMuted
                                        : JColors.muted,
                                    fontSize: 12,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            choice == d
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: choice == d ? JColors.accent : JColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (widget.finalVote) ...[
              const Eyebrow('Your reasoning · required'),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('final-reason'),
                controller: reason,
                onChanged: (v) => s.reasonDraft = v,
                maxLength: 2000,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'What evidence shaped your decision?',
                  alignLabelWithHint: true,
                  helperText:
                      '20–2,000 characters. Address evidence and uncertainty.',
                  helperMaxLines: 2,
                ),
                validator: (v) => (v?.trim().length ?? 0) < 20
                    ? 'Add at least 20 characters of reasoning.'
                    : null,
              ),
              const SizedBox(height: 18),
            ] else
              Panel(
                color: JColors.secondary,
                child: Text(
                  c.standard,
                  style: const TextStyle(fontSize: 13, height: 1.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
