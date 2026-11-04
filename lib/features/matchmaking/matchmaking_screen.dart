import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key, this.join = false});
  final bool join;
  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final _code = TextEditingController();
  final _form = GlobalKey<FormState>();
  String? _caseId;
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    // Joining is one six-character field: a focused, centred form is the right
    // desktop layout for it. Creating a room has a real case list to place
    // beside the explanation, so only that side splits.
    final expanded = JSpace.isExpanded(context) && !widget.join;
    final action = PrimaryButton(
      widget.join ? 'Find my seat' : 'Create private room',
      loading: s.busy,
      onPressed: () async {
        if (!_form.currentState!.validate()) return;
        final file = s.cases.firstWhere(
          (c) => c.id == _caseId,
          orElse: () => s.cases.first,
        );
        if (await s.openRoom(
              file,
              private: true,
              code: widget.join ? _code.text.trim().toUpperCase() : null,
            ) &&
            context.mounted) {
          go(context, '/room', replace: true);
        }
      },
    );
    return JuryPage(
      title: widget.join ? 'Join a room' : 'A room of your own',
      bottom: expanded ? null : action,
      wide: expanded,
      scroll: !expanded,
      child: Form(
        key: _form,
        child: expanded
            ? SplitLayout(
                main: _casePicker(s),
                aside: [
                  ..._intro(),
                  const SizedBox(height: 26),
                  _invitation(s),
                  const SizedBox(height: 28),
                  action,
                  ..._resume(context, s),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  ..._intro(),
                  const SizedBox(height: 32),
                  if (widget.join)
                    ..._codeEntry(s)
                  else ...[
                    ..._casePicker(s),
                    const SizedBox(height: 16),
                    _invitation(s),
                  ],
                  ..._resume(context, s),
                ],
              ),
      ),
    );
  }

  List<Widget> _intro() => [
    Eyebrow(
      widget.join
          ? 'An invitation, accepted'
          : 'Good company. Different opinions.',
    ),
    const SizedBox(height: 16),
    Text(
      widget.join
          ? 'Your people\nare in the room.'
          : 'Bring your people.\nFind a fresh view.',
      style: JType.display(40),
    ),
    const SizedBox(height: 20),
    Text(
      widget.join
          ? 'Enter the six-character code shared by your host.'
          : 'Choose a case, share your room code, and let the conversation unfold.',
      style: const TextStyle(color: JColors.muted, height: 1.7),
    ),
  ];

  List<Widget> _codeEntry(JuryController s) => [
    TextFormField(
      key: const Key('room-code'),
      controller: _code,
      textCapitalization: TextCapitalization.characters,
      maxLength: 6,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
      ],
      style: const TextStyle(
        fontSize: 26,
        letterSpacing: 8,
        fontWeight: FontWeight.w700,
      ),
      decoration: const InputDecoration(
        labelText: 'Room code',
        hintText: 'JURY06',
        counterText: '',
      ),
      validator: (v) =>
          v?.trim().length != 6 ? 'Enter all six characters.' : null,
    ),
    const SizedBox(height: 20),
    if (s.isDemo)
      const Panel(
        color: JColors.secondary,
        child: Text(
          'Try JURY06 to join the sample room. Demo room codes work on this device; connect Supabase for rooms with friends.',
          style: TextStyle(fontSize: 13, height: 1.7),
        ),
      ),
  ];

  List<Widget> _casePicker(JuryController s) => [
    const Eyebrow('Choose your case'),
    const SizedBox(height: 12),
    for (final c in s.cases)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Semantics(
          selected: (_caseId ?? s.cases.first.id) == c.id,
          child: InkWell(
            onTap: () => setState(() => _caseId = c.id),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: (_caseId ?? s.cases.first.id) == c.id
                    ? JColors.secondary
                    : JColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: (_caseId ?? s.cases.first.id) == c.id
                      ? JColors.ink
                      : JColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: JType.display(25)),
                        const SizedBox(height: 6),
                        Text(
                          '${c.category} · ${c.minutes} minutes',
                          style: const TextStyle(
                            color: JColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    (_caseId ?? s.cases.first.id) == c.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
  ];

  Widget _invitation(JuryController s) => InfoRow(
    icon: Icons.lock_outline,
    title: 'Invitation only',
    subtitle: s.isDemo
        ? 'Simulated jurors join your demo room.'
        : 'Only people with your code can join.',
  );

  List<Widget> _resume(BuildContext context, JuryController s) => [
    if (s.room != null && s.room!.stage != RoundStage.complete) ...[
      const SizedBox(height: 20),
      OutlinedButton(
        onPressed: () => go(context, s.resumeRoute),
        child: const Text('Resume my existing room'),
      ),
    ],
  ];
}
