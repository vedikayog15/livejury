import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class DeliberationScreen extends StatefulWidget {
  const DeliberationScreen({super.key});
  @override
  State<DeliberationScreen> createState() => _DeliberationScreenState();
}

class _DeliberationScreenState extends State<DeliberationScreen> {
  TextEditingController? _text;
  final _scroll = ScrollController();
  int _count = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = JuryScope.of(context);
    _text ??= TextEditingController(text: s.chatDraft);
    if (_count != s.room!.messages.length) {
      _count = s.room!.messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) {
          if (MediaQuery.disableAnimationsOf(context)) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          } else {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _text?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _evidence(BuildContext context) async {
    final s = JuryScope.of(context);
    final exhibit = await showModalBottomSheet<Exhibit>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bring the evidence in.', style: JType.display(30)),
              const SizedBox(height: 8),
              const Text(
                'Attach an exhibit to your next message.',
                style: TextStyle(color: JColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              for (final e in s.currentCase.evidence)
                InfoRow(
                  icon: evidenceIcon(e.kind),
                  title: '${e.id} · ${e.title}',
                  subtitle: e.kind.name,
                  onTap: () => Navigator.pop(ctx, e),
                ),
            ],
          ),
        ),
      ),
    );
    if (exhibit != null) s.attach(exhibit.id);
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final r = s.room!;
    final active = r.stage == RoundStage.deliberation;
    final keyboardOpen =
        MediaQuery.viewInsetsOf(context).bottom > 0 ||
        MediaQuery.textScalerOf(context).scale(16) > 20;
    final visible = r.messages
        .where((m) => !s.mutedJurors.contains(m.senderId))
        .toList();
    final expanded = JSpace.isExpanded(context);
    return JuryPage(
      title: 'The deliberation',
      eyebrow: 'Room ${r.code}',
      scroll: false,
      wide: expanded,
      wideActions: true,
      actions: [
        // The desktop layout shows the roster permanently, so the sheet that
        // opens it is only offered on touch widths.
        if (!expanded)
          IconButton(
            tooltip: 'Jurors and room guidelines',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (ctx) => StatefulBuilder(
                builder: (ctx, setSheetState) => SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Around the table', style: JType.display(32)),
                        const SizedBox(height: 12),
                        Text(
                          s.isDemo
                              ? 'Simulated jurors, plus you.'
                              : 'Real jurors. Votes remain private.',
                          style: const TextStyle(
                            color: JColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final j in r.jurors)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Avatar(j.name),
                            title: Text(j.name),
                            subtitle: Text(
                              j.isDemo
                                  ? 'Simulated juror'
                                  : j.id == s.player!.id
                                  ? 'You'
                                  : 'Juror',
                            ),
                            trailing: j.id == s.player!.id
                                ? null
                                : IconButton(
                                    tooltip: s.mutedJurors.contains(j.id)
                                        ? 'Unmute ${j.name}'
                                        : 'Mute ${j.name}',
                                    onPressed: () {
                                      s.toggleMute(j.id);
                                      setSheetState(() {});
                                    },
                                    icon: Icon(
                                      s.mutedJurors.contains(j.id)
                                          ? Icons.volume_off_outlined
                                          : Icons.volume_up_outlined,
                                    ),
                                  ),
                          ),
                        const SizedBox(height: 16),
                        const Panel(
                          color: JColors.secondary,
                          child: Text(
                            'Challenge the argument, never the person. Avoid personal information. Report a message using its menu. Muting hides a juror’s messages on this device.',
                            style: TextStyle(fontSize: 13, height: 1.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.group_outlined),
          ),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (s.attachedExhibit != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: JColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${s.attachedExhibit} · ${s.currentCase.evidence.firstWhere((e) => e.id == s.attachedExhibit).title}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove evidence reference',
                      onPressed: () => s.attach(null),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (active)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Attach evidence',
                  onPressed: () => _evidence(context),
                  style: IconButton.styleFrom(
                    backgroundColor: JColors.secondary,
                  ),
                  icon: const Icon(Icons.add_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('chat-input'),
                    controller: _text,
                    onChanged: (v) => s.chatDraft = v,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      hintText: 'Make your case…',
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Send message',
                  onPressed: s.busy
                      ? null
                      : () async {
                          if (_text!.text.trim().isEmpty) {
                            toast(context, 'Write a thought before sending.');
                            return;
                          }
                          s.chatDraft = _text!.text;
                          if (await s.sendMessage() && mounted) _text!.clear();
                        },
                  icon: s.busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: JColors.surface,
                          ),
                        )
                      : const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          const SizedBox(height: 10),
          if (active && (s.isDemo || r.hostId == s.player!.id))
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: s.busy
                    ? null
                    : () async {
                        final ready = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              'Ready to make the final call?',
                              style: JType.display(28),
                            ),
                            content: const Text(
                              'Opening final voting closes the discussion for every juror. Each person must submit a choice and a reason.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Keep discussing'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Open voting'),
                              ),
                            ],
                          ),
                        );
                        if (ready == true &&
                            await s.beginFinal() &&
                            context.mounted) {
                          go(context, '/vote', replace: true);
                        }
                      },
                child: const Text('Move to final vote'),
              ),
            )
          else if (active)
            const Text(
              'The host will open final voting when the room is ready.',
              style: TextStyle(fontSize: 12, color: JColors.muted),
              textAlign: TextAlign.center,
            )
          else if (r.stage == RoundStage.briefing ||
              r.stage == RoundStage.initialVote)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Waiting for every first impression. Discussion opens automatically when every ballot is sealed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JColors.muted,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            )
          else
            PrimaryButton(
              'Continue to ${r.stage == RoundStage.complete ? 'verdict' : 'final vote'}',
              onPressed: () => go(
                context,
                r.stage == RoundStage.complete ? '/result' : '/vote',
                replace: true,
              ),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (!keyboardOpen) const StageStrip(active: 2),
                if (!keyboardOpen)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      const Text(
                        'Think out loud.',
                        style: TextStyle(
                          fontFamily: 'Fraunces',
                          fontSize: 31,
                          letterSpacing: -.6,
                        ),
                      ),
                      TextButton(
                        onPressed: () => go(context, '/evidence'),
                        child: const Text('Case evidence'),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                if (!keyboardOpen)
                  Text(
                    s.isDemo
                        ? 'DEMO DISCUSSION · SCRIPTED JURORS'
                        : 'LIVE DISCUSSION · VOTES ARE SEALED',
                    style: JType.caption.copyWith(
                      fontSize: 9,
                      color: JColors.muted,
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: 18),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final m = visible[index];
                      final mine = m.senderId == s.player!.id;
                      if (m.system) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Panel(
                            color: JColors.secondary,
                            padding: 16,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lock_outline, size: 17),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    m.body,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Avatar(m.name, size: 28, index: index),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    mine ? 'You' : m.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (!mine)
                                  SizedBox(
                                    height: 48,
                                    width: 48,
                                    child: PopupMenuButton<String>(
                                      tooltip: 'Message options',
                                      onSelected: (v) async {
                                        if (v == 'mute') {
                                          s.toggleMute(m.senderId);
                                        } else if (await s.report(m.id) &&
                                            context.mounted) {
                                          toast(
                                            context,
                                            s.isDemo
                                                ? 'Demo report recorded. No moderator is contacted.'
                                                : 'Report submitted for review.',
                                          );
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'report',
                                          child: Text('Report message'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'mute',
                                          child: Text('Mute juror'),
                                        ),
                                      ],
                                      icon: const Icon(
                                        Icons.more_horiz,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(17),
                              decoration: BoxDecoration(
                                color: mine ? JColors.ink : JColors.surface,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(mine ? 18 : 4),
                                  topRight: Radius.circular(mine ? 4 : 18),
                                  bottomLeft: const Radius.circular(18),
                                  bottomRight: const Radius.circular(18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (m.exhibitId != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: TextButton.icon(
                                        style: TextButton.styleFrom(
                                          foregroundColor: mine
                                              ? JColors.accent
                                              : JColors.ink,
                                          backgroundColor: mine
                                              ? JColors.raised
                                              : JColors.secondary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                        ),
                                        onPressed: () => go(
                                          context,
                                          '/exhibit',
                                          arguments: s.currentCase.evidence
                                              .firstWhere(
                                                (e) => e.id == m.exhibitId,
                                              ),
                                        ),
                                        icon: const Icon(
                                          Icons.attach_file,
                                          size: 14,
                                        ),
                                        label: Text(
                                          '${m.exhibitId} · View exhibit',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    m.body,
                                    style: TextStyle(
                                      color: mine
                                          ? JColors.surface
                                          : JColors.ink,
                                      fontSize: 14,
                                      height: 1.7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (expanded) const SizedBox(width: 32),
          if (expanded) SizedBox(width: 300, child: _roster(context, s, r)),
        ],
      ),
    );
  }

  /// Persistent roster for desktop windows. Holds the same jurors, mute
  /// controls and guidance the touch layout keeps behind a sheet.
  Widget _roster(
    BuildContext context,
    JuryController s,
    JuryRound r,
  ) => ListView(
    padding: const EdgeInsets.only(top: 12, bottom: 18),
    children: [
      Text('Around the table', style: JType.display(21)),
      const SizedBox(height: 6),
      Text(
        s.isDemo
            ? 'Simulated jurors, plus you.'
            : 'Real jurors. Votes remain private.',
        style: const TextStyle(color: JColors.muted, fontSize: 12),
      ),
      const SizedBox(height: 12),
      for (final j in r.jurors)
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          leading: Avatar(j.name, size: 34),
          title: Text(
            j.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            j.isDemo
                ? 'Simulated juror'
                : j.id == s.player!.id
                ? 'You'
                : 'Juror',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: j.id == s.player!.id
              ? null
              : IconButton(
                  tooltip: s.mutedJurors.contains(j.id)
                      ? 'Unmute ${j.name}'
                      : 'Mute ${j.name}',
                  onPressed: () => s.toggleMute(j.id),
                  icon: Icon(
                    s.mutedJurors.contains(j.id)
                        ? Icons.volume_off_outlined
                        : Icons.volume_up_outlined,
                    size: 19,
                  ),
                ),
        ),
      const SizedBox(height: 14),
      const Panel(
        color: JColors.secondary,
        child: Text(
          'Challenge the argument, never the person. Avoid personal information. Report a message using its menu. Muting hides a juror’s messages on this device.',
          style: TextStyle(fontSize: 12, height: 1.65),
        ),
      ),
    ],
  );
}
