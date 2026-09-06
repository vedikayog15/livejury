import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/chamber_art.dart';
import '../../design/widgets/jury_widgets.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final r = s.room!;
    final ready = r.jurors.length == 6;
    return JuryPage(
      title: r.isPrivate ? 'Private jury room' : 'Finding your jury',
      dark: true,
      actions: [
        IconButton(
          tooltip: 'Refresh room',
          onPressed: s.busy ? null : s.refresh,
          icon: const Icon(Icons.refresh, color: JColors.surface),
        ),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            r.stage != RoundStage.waiting
                ? 'Enter the case'
                : ready
                ? (r.hostId == s.player!.id
                      ? 'Open the case file'
                      : 'Waiting for the host')
                : 'Finding ${6 - r.jurors.length} more jurors',
            citron: true,
            loading: s.busy,
            onPressed: r.stage != RoundStage.waiting
                ? () => go(context, s.resumeRoute, replace: true)
                : ready && r.hostId == s.player!.id
                ? () async {
                    if (await s.startCase() && context.mounted) {
                      go(context, '/case', replace: true);
                    }
                  }
                : null,
          ),
          TextButton(
            onPressed: () async {
              if (await confirmAction(
                    context,
                    title: 'Leave this room?',
                    body: s.isDemo
                        ? 'Your completed cases stay in your journal. This unfinished round will be discarded.'
                        : 'During a case, leaving cancels the round for all jurors. A waiting room can continue without you.',
                    confirm: 'Leave room',
                  ) &&
                  context.mounted &&
                  await s.leave() &&
                  context.mounted) {
                home(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: JColors.onDarkMuted),
            child: const Text('Leave room'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          Eyebrow(
            s.isDemo ? 'Simulated room · local demo' : 'Live room · Supabase',
            dark: true,
          ),
          const SizedBox(height: 14),
          Text(
            ready
                ? 'The room\nis yours.'
                : 'Different minds.\nComing together.',
            style: JType.display(41, JColors.surface),
          ),
          ChamberArt(seated: r.jurors.length, height: 240),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: JColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${r.jurors.length} of 6 jurors seated',
                    style: const TextStyle(
                      color: JColors.surface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!ready)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: JColors.accent,
                      strokeWidth: 1.5,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < 6; i++)
                  SizedBox(
                    width: (constraints.maxWidth - 20) / 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: JColors.raised,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (i < r.jurors.length)
                            Avatar(r.jurors[i].name, index: i)
                          else
                            const SizedBox(
                              width: 42,
                              height: 42,
                              child: Icon(
                                Icons.person_add_alt_1_outlined,
                                color: JColors.onDarkMuted,
                                size: 22,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            i < r.jurors.length
                                ? (r.jurors[i].id == s.player!.id
                                      ? 'You'
                                      : r.jurors[i].name.split(' ').first)
                                : 'Open seat',
                            style: const TextStyle(
                              color: JColors.surface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            i < r.jurors.length
                                ? (r.jurors[i].isDemo
                                      ? 'Simulated'
                                      : r.jurors[i].id == r.hostId
                                      ? 'Host'
                                      : 'Juror')
                                : 'Joining…',
                            style: const TextStyle(
                              color: JColors.onDarkMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 8, 12),
            decoration: BoxDecoration(
              border: Border.all(color: JColors.raised),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Room code', dark: true),
                      const SizedBox(height: 5),
                      Text(
                        r.code,
                        style: const TextStyle(
                          color: JColors.accent,
                          fontSize: 23,
                          letterSpacing: 5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy room code',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: r.code));
                    if (context.mounted) {
                      toast(context, 'Room code copied: ${r.code}');
                    }
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: JColors.surface,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'On the table: ${s.currentCase.title}',
            style: const TextStyle(color: JColors.onDarkMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
