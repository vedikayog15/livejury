import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/chamber_art.dart';
import '../../design/widgets/ambient_backdrop.dart';
import '../../design/widgets/jury_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filter = 'All cases';
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final featured = s.cases.first;
    final files = s.cases
        .where((c) => filter == 'All cases' || c.category == filter)
        .toList();
    final resume =
        s.room != null &&
        s.room!.stage != RoundStage.complete &&
        s.room!.stage != RoundStage.cancelled;
    return JuryPage(
      tab: 0,
      child: EntryReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                InkWell(
                  onTap: () => go(context, '/profile'),
                  borderRadius: BorderRadius.circular(16),
                  child: Avatar(s.player!.name, size: 48),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LIVE JURY',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.4,
                          color: JColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Welcome back, ${s.player!.name.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                FrostedSurface(
                  radius: 18,
                  child: IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => go(context, '/notifications'),
                    icon: Badge(
                      isLabelVisible: s.unread > 0,
                      smallSize: 6,
                      backgroundColor: JColors.brand,
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 23,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Your next\nplot twist awaits.', style: JType.display(37)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: JColors.brand,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.isDemo
                        ? 'A room for curious minds. Try the full demo.'
                        : 'A room for curious minds. Find your people.',
                    style: const TextStyle(
                      color: JColors.muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(child: Eyebrow('Tonight’s featured case')),
                Text(
                  '01 / 03',
                  style: JType.caption.copyWith(
                    fontSize: 10,
                    color: JColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: JColors.ink,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: JColors.ink.withValues(alpha: .2),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      const DossierArt(height: 206),
                      Positioned(
                        top: 18,
                        left: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: JColors.ink.withValues(alpha: .64),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: JColors.surface.withValues(alpha: .15),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_outlined,
                                size: 12,
                                color: JColors.accent,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'THE STARTER CASE',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: JColors.surface,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 18,
                        right: 18,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: JColors.ink.withValues(alpha: .5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: JColors.surface.withValues(alpha: .15),
                            ),
                          ),
                          child: const Icon(
                            Icons.north_east,
                            size: 15,
                            color: JColors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featured.title,
                          style: JType.display(32, JColors.surface),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          featured.subtitle,
                          style: const TextStyle(
                            color: JColors.onDarkMuted,
                            fontSize: 12,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: [
                            _Meta(Icons.balance_outlined, featured.category),
                            const _Meta(Icons.group_outlined, '6 jurors'),
                            _Meta(
                              Icons.schedule_rounded,
                              '${featured.minutes} min',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          resume ? 'Resume your room' : 'Find my jury',
                          citron: true,
                          loading: s.busy,
                          onPressed: () async {
                            if (resume) {
                              go(context, s.resumeRoute);
                              return;
                            }
                            if (await s.openRoom(featured) && context.mounted) {
                              go(context, '/room');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _RoomAction(
                    icon: Icons.group_add_outlined,
                    title: 'Private room',
                    detail: 'Make it your circle.',
                    tone: JColors.brand,
                    onTap: () =>
                        go(context, '/matchmaking', arguments: 'create'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoomAction(
                    icon: Icons.dialpad_rounded,
                    title: 'Join with code',
                    detail: 'An invitation is waiting.',
                    tone: JColors.success,
                    onTap: () => go(context, '/matchmaking', arguments: 'join'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SectionHeading(
              'The case collection',
              action: 'How to play',
              onAction: () => _showGuide(context),
            ),
            const SizedBox(height: 8),
            const Text(
              'Small details. Entirely different stories.',
              style: TextStyle(color: JColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in ['All cases', 'Criminal', 'Civil'])
                  ChoiceChip(
                    label: Text(f),
                    selected: filter == f,
                    onSelected: (_) => setState(() => filter = f),
                    showCheckmark: false,
                    selectedColor: JColors.ink,
                    backgroundColor: JColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: filter == f ? JColors.surface : JColors.muted,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide.none,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            for (final file in files)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CaseRow(file: file, index: s.cases.indexOf(file)),
              ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    JColors.secondary,
                    Color.lerp(JColors.accent, JColors.surface, .72)!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -14,
                    child: Transform.rotate(
                      angle: .3,
                      child: Icon(
                        Icons.format_quote_rounded,
                        size: 150,
                        color: JColors.brand.withValues(alpha: .08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('A note before you enter'),
                        const SizedBox(height: 15),
                        Text(
                          'Be willing to\nbe persuaded.',
                          style: JType.display(29),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A changed mind is a sign of thought,\nnot defeat.',
                          style: TextStyle(
                            color: JColors.muted,
                            fontSize: 12,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                s.isDemo
                    ? 'DEMO EXPERIENCE · FICTIONAL CASES'
                    : 'FICTIONAL CASES · REAL PERSPECTIVES',
                style: const TextStyle(
                  color: JColors.muted,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuide(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A little curiosity\ngoes a long way.',
              style: JType.display(32),
            ),
            const SizedBox(height: 20),
            const InfoRow(
              icon: Icons.search_rounded,
              title: '01 · Examine the evidence',
              subtitle:
                  'Read every exhibit. Notice what it establishes and what it leaves open.',
            ),
            const InfoRow(
              icon: Icons.forum_outlined,
              title: '02 · Hear another perspective',
              subtitle:
                  'Seal a private first impression. Compare arguments with five other jurors.',
            ),
            const InfoRow(
              icon: Icons.how_to_vote_outlined,
              title: '03 · Make a considered call',
              subtitle:
                  'Vote with a reason. Earn points for reviewing, explaining, and citing evidence.',
            ),
            const SizedBox(height: 20),
            PrimaryButton('I’m ready', onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: JColors.accent),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(color: JColors.onDarkMuted, fontSize: 11),
      ),
    ],
  );
}

class _RoomAction extends StatelessWidget {
  const _RoomAction({
    required this.icon,
    required this.title,
    required this.detail,
    required this.tone,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final Color tone;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: JColors.surface,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: JColors.surface),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [JColors.surface, tone.withValues(alpha: .035)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tone.withValues(alpha: .15),
                    tone.withValues(alpha: .04),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: tone),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 7),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 11,
                color: JColors.muted,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CaseRow extends StatelessWidget {
  const _CaseRow({required this.file, required this.index});
  final CaseFile file;
  final int index;
  @override
  Widget build(BuildContext context) => Material(
    color: JColors.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: () => go(context, '/case-preview', arguments: file),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 86,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: JColors.ink,
                borderRadius: BorderRadius.circular(13),
              ),
              child: DossierArt(variant: index, height: 100),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${file.category.toUpperCase()} · FILE ${file.number}',
                    style: const TextStyle(
                      fontSize: 8,
                      color: JColors.brand,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(file.title, style: JType.display(22)),
                  const SizedBox(height: 8),
                  Text(
                    '${file.minutes} min · 4 exhibits',
                    style: const TextStyle(color: JColors.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: JColors.muted,
            ),
          ],
        ),
      ),
    ),
  );
}
