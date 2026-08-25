import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/app_frame.dart';
import '../../core/widgets/live_jury_widgets.dart';
import '../matchmaking/matchmaking_screen.dart';

enum JuryPhase {
  intro,
  evidence,
  initialVote,
  waiting,
  discussion,
  finalVote,
  result,
}

class JuryExperience extends StatefulWidget {
  const JuryExperience({super.key});

  @override
  State<JuryExperience> createState() => _JuryExperienceState();
}

class _JuryExperienceState extends State<JuryExperience> {
  JuryPhase phase = JuryPhase.intro;
  String? initialVerdict;
  String? finalVerdict;
  String? reason;
  final messages = <(String, String, bool)>[
    (
      'Aarav',
      'The camera places him nearby, but not inside the gallery.',
      false,
    ),
    (
      'Sara',
      'The broken watch feels planted. The timeline does not fit.',
      false,
    ),
    ('You', 'I want to revisit the guard’s statement before deciding.', true),
  ];

  @override
  Widget build(BuildContext context) {
    final body = switch (phase) {
      JuryPhase.intro => _intro(),
      JuryPhase.evidence => _evidence(),
      JuryPhase.initialVote => _vote(initial: true),
      JuryPhase.waiting => _waiting(),
      JuryPhase.discussion => _discussion(),
      JuryPhase.finalVote => _vote(initial: false),
      JuryPhase.result => _result(),
    };
    return Scaffold(body: SafeArea(child: body));
  }

  Widget _phaseHeader(String title, String step, {bool timer = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _confirmExit(),
            icon: const Icon(Icons.close),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.gold,
                    fontSize: 11,
                    letterSpacing: 1.4,
                  ),
                ),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          if (timer) const TimerPill(text: '04:38'),
        ],
      ),
    );
  }

  Widget _intro() => ListView(
    padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
    children: [
      Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          const TimerPill(text: 'CASE #1042'),
        ],
      ),
      const SizedBox(height: 20),
      const Icon(
        Icons.account_balance_outlined,
        size: 48,
        color: AppColors.gold,
      ),
      const SizedBox(height: 20),
      Text(
        'The Midnight Gallery',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 10),
      Text(
        'A priceless painting vanished from a locked gallery. One employee had access—but the evidence tells two stories.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
      ),
      const SizedBox(height: 28),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: const [
          InfoChip(icon: Icons.gavel_outlined, text: 'Criminal'),
          InfoChip(icon: Icons.signal_cellular_alt, text: 'Intermediate'),
          InfoChip(icon: Icons.schedule, text: '12–15 min'),
        ],
      ),
      const SizedBox(height: 32),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your duty', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Decide whether the prosecution has proved guilt beyond a reasonable doubt. Keep an open mind until all evidence is heard.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 18, color: AppColors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your private votes remain anonymous.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: AppColors.teal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      FilledButton(
        onPressed: () => setState(() => phase = JuryPhase.evidence),
        child: const Text('EXAMINE THE CASE'),
      ),
      const SizedBox(height: 12),
      Text(
        'This is a fictional case created for educational discussion.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontSize: 12, color: AppColors.muted),
      ),
    ],
  );

  Widget _evidence() => Column(
    children: [
      _phaseHeader('Review the evidence', 'Phase 1 of 4'),
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: LinearProgressIndicator(
          value: .25,
          minHeight: 4,
          color: AppColors.gold,
          backgroundColor: AppColors.outline,
        ),
      ),
      Expanded(
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.gold,
                indicatorColor: AppColors.gold,
                tabs: [
                  Tab(text: 'OVERVIEW'),
                  Tab(text: 'TIMELINE'),
                  Tab(text: 'EVIDENCE  3'),
                  Tab(text: 'WITNESSES'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _overviewTab(),
                    _timelineTab(),
                    _evidenceTab(),
                    _witnessTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: FilledButton(
          onPressed: () => setState(() => phase = JuryPhase.initialVote),
          child: const Text('I’M READY TO VOTE'),
        ),
      ),
    ],
  );

  Widget _overviewTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('The charge', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      Text(
        'Daniel Cross, the gallery’s night conservator, is charged with stealing “Nocturne in Blue,” valued at ₹4.2 crore.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 22),
      const EvidenceTile(
        icon: Icons.key_outlined,
        tag: 'UNDISPUTED',
        title: 'Exclusive access',
        detail:
            'Daniel’s keycard was used at 11:42 PM. Only three employees had after-hours access.',
      ),
      const EvidenceTile(
        icon: Icons.videocam_outlined,
        tag: 'PROSECUTION',
        title: 'Street camera',
        detail: 'Footage shows Daniel’s car two blocks away at 11:31 PM.',
      ),
      const EvidenceTile(
        icon: Icons.watch_later_outlined,
        tag: 'DEFENCE',
        title: 'A broken timeline',
        detail:
            'Daniel appears on a live video call from home at 11:49 PM, seventeen minutes away.',
      ),
    ],
  );

  Widget _timelineTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      TimelineItem(
        time: '10:55 PM',
        text: 'Gallery closes; security sweep completed.',
      ),
      TimelineItem(
        time: '11:31 PM',
        text: 'Daniel’s car captured near the gallery.',
      ),
      TimelineItem(
        time: '11:42 PM',
        text: 'Daniel’s keycard opens the archive corridor.',
      ),
      TimelineItem(
        time: '11:49 PM',
        text: 'Daniel joins a verified video call from home.',
      ),
      TimelineItem(
        time: '12:10 AM',
        text: 'Motion alarm triggers; painting discovered missing.',
      ),
    ],
  );

  Widget _evidenceTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      EvidenceTile(
        icon: Icons.credit_card,
        tag: 'EXHIBIT A',
        title: 'Keycard access log',
        detail:
            'Archive corridor opened using Daniel’s assigned card at 11:42 PM.',
      ),
      EvidenceTile(
        icon: Icons.photo_camera_outlined,
        tag: 'EXHIBIT B',
        title: 'Traffic camera still',
        detail: 'A dark sedan matching Daniel’s vehicle passes Mercer Street.',
      ),
      EvidenceTile(
        icon: Icons.fingerprint,
        tag: 'EXHIBIT C',
        title: 'Partial fingerprint',
        detail:
            'A partial print on the display latch cannot exclude Daniel or two other employees.',
      ),
    ],
  );

  Widget _witnessTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      EvidenceTile(
        icon: Icons.person_outline,
        tag: 'SECURITY GUARD',
        title: 'Marcus Lee',
        detail:
            '“I heard a metal door close around 11:45, but saw nobody leave through the lobby.”',
      ),
      EvidenceTile(
        icon: Icons.person_outline,
        tag: 'COLLEAGUE',
        title: 'Priya Raman',
        detail:
            '“Daniel joined our video call at 11:49. I spoke with him directly; it was not a recording.”',
      ),
    ],
  );

  Widget _vote({required bool initial}) {
    final selected = initial ? initialVerdict : finalVerdict;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _phaseHeader(
          initial ? 'Your first impression' : 'Deliver your verdict',
          initial ? 'Phase 2 of 4' : 'Phase 4 of 4',
        ),
        const SizedBox(height: 26),
        Icon(
          initial ? Icons.visibility_off_outlined : Icons.how_to_vote_outlined,
          size: 42,
          color: AppColors.gold,
        ),
        const SizedBox(height: 16),
        Text(
          initial ? 'Where do you stand?' : 'Has guilt been proven?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          initial
              ? 'Your initial vote is private and can change after deliberation.'
              : 'Your final choice cannot be changed after submission.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 26),
        VerdictCard(
          label: 'GUILTY',
          description:
              'The evidence proves the charge beyond reasonable doubt.',
          icon: Icons.gavel,
          color: AppColors.burgundy,
          selected: selected == 'Guilty',
          onTap: () => setState(
            () => initial ? initialVerdict = 'Guilty' : finalVerdict = 'Guilty',
          ),
        ),
        const SizedBox(height: 12),
        VerdictCard(
          label: 'NOT GUILTY',
          description: 'The evidence leaves room for reasonable doubt.',
          icon: Icons.shield_outlined,
          color: AppColors.teal,
          selected: selected == 'Not Guilty',
          onTap: () => setState(
            () => initial
                ? initialVerdict = 'Not Guilty'
                : finalVerdict = 'Not Guilty',
          ),
        ),
        if (!initial && selected != null) ...[
          const SizedBox(height: 24),
          Text(
            'Choose your primary reason',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...[
            'Timeline inconsistency',
            'Reliability of physical evidence',
            'Witness credibility',
            'Access and opportunity',
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => reason = item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          reason == item
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: reason == item
                              ? AppColors.gold
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLength: 240,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Optional explanation',
              alignLabelWithHint: true,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: selected == null || (!initial && reason == null)
              ? null
              : () => _submitVote(initial),
          child: Text(initial ? 'SUBMIT PRIVATE VOTE' : 'SUBMIT FINAL VERDICT'),
        ),
      ],
    );
  }

  void _submitVote(bool initial) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.navySoft,
        icon: Icon(
          initial ? Icons.lock_outline : Icons.how_to_vote,
          color: AppColors.gold,
        ),
        title: Text(
          initial
              ? 'Lock in your first impression?'
              : 'Submit your final verdict?',
        ),
        content: Text(
          initial
              ? 'The other jurors will not see this vote.'
              : 'This final vote cannot be edited.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('REVIEW'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(
                () => phase = initial ? JuryPhase.waiting : JuryPhase.result,
              );
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  Widget _waiting() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        _phaseHeader('Votes are coming in', 'Private vote', timer: false),
        const Spacer(),
        const SizedBox(
          width: 94,
          height: 94,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.gold,
            backgroundColor: AppColors.outline,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '5 of 6 jurors voted',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'No choices will be revealed.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 30),
        const JurorStrip(voted: 5),
        const Spacer(),
        FilledButton(
          onPressed: () => setState(() => phase = JuryPhase.discussion),
          child: const Text('SIMULATE FINAL VOTE'),
        ),
      ],
    ),
  );

  Widget _discussion() {
    final input = TextEditingController();
    return Column(
      children: [
        _phaseHeader('Jury deliberation', 'Phase 3 of 4'),
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: JurorStrip(voted: 6, speaking: 1),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          color: AppColors.gold.withValues(alpha: .08),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: AppColors.gold),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Discuss the evidence, not the person.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: AppColors.gold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              return ChatBubble(name: m.$1, message: m.$2, mine: m.$3);
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['Exhibit A', 'Timeline', 'Guard statement']
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(e),
                      avatar: const Icon(Icons.link, size: 16),
                      onPressed: () {},
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Microphone toggled')),
                ),
                icon: const Icon(Icons.mic_none),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: input,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Make your case…',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  if (input.text.trim().isNotEmpty) {
                    setState(
                      () => messages.add(('You', input.text.trim(), true)),
                    );
                  }
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: OutlinedButton(
            onPressed: () => setState(() => phase = JuryPhase.finalVote),
            child: const Text('END DELIBERATION & VOTE'),
          ),
        ),
      ],
    );
  }

  Widget _result() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
    children: [
      Row(
        children: [
          const BrandMark(size: 38),
          const Spacer(),
          IconButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Text(
        'THE JURY FINDS',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.gold,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'NOT GUILTY',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: 40,
          color: AppColors.teal,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Reasonable doubt remained.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
      ),
      const SizedBox(height: 28),
      SurfaceCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Final vote',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '6 jurors',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const VoteBar(guilty: 2, notGuilty: 4),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LegendDot(color: AppColors.burgundy, text: 'Guilty  2'),
                LegendDot(color: AppColors.teal, text: 'Not guilty  4'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.change_circle_outlined, color: AppColors.gold),
                const SizedBox(width: 10),
                Text(
                  'The room evolved',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Two jurors changed their view after deliberation.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                  child: MiniStat(label: 'Initial', value: '3–3'),
                ),
                Icon(Icons.arrow_forward, color: AppColors.muted),
                Expanded(
                  child: MiniStat(label: 'Final', value: '2–4'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.teal.withValues(alpha: .3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_outlined, color: AppColors.teal),
                SizedBox(width: 9),
                Text(
                  'LEGAL OUTCOME',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Not Guilty', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'The keycard establishes access but not identity. Combined with the verified video call and inconclusive fingerprint, the prosecution cannot eliminate reasonable doubt.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SurfaceCard(
        child: Row(
          children: [
            const ScoreRing(score: 88),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+120 Jury Points',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Strong evidence references • Respectful participation',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      FilledButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AppFrame(child: MatchmakingScreen()),
          ),
        ),
        child: const Text('PLAY ANOTHER CASE'),
      ),
      const SizedBox(height: 10),
      OutlinedButton(
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        child: const Text('RETURN HOME'),
      ),
    ],
  );

  void _confirmExit() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.navySoft,
      title: const Text('Leave the jury room?'),
      content: const Text('Your current session progress will be lost.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('STAY'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          },
          child: const Text(
            'LEAVE',
            style: TextStyle(color: AppColors.burgundy),
          ),
        ),
      ],
    ),
  );
}
