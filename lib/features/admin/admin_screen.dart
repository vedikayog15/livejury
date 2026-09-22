import 'package:flutter/material.dart';
import '../../core/data/admin_repository.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';
import 'case_editor_screen.dart';

/// The administration area. Everything here is a request the database is free
/// to refuse: the screens show what an admin may do, they do not grant it.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int section = 0;
  AdminOverview? overview;
  List<AdminProfile> people = [];
  List<AdminCase> cases = [];
  bool loading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final admin = JuryScope.of(context).admin;
    if (admin == null) {
      setState(() {
        loading = false;
        loadError = 'Administrator access required.';
      });
      return;
    }
    setState(() => loading = true);
    try {
      final results = await Future.wait([
        admin.overview(),
        admin.profiles(),
        admin.cases(),
      ]);
      if (!mounted) return;
      setState(() {
        overview = results[0] as AdminOverview;
        people = results[1] as List<AdminProfile>;
        cases = results[2] as List<AdminCase>;
        loading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final expanded = JSpace.isExpanded(context);
    if (!s.isAdmin) {
      return JuryPage(
        title: 'Administration',
        child: EmptyState(
          title: 'Not your door.',
          body:
              'This area is limited to administrators. If you believe that is wrong, ask an administrator to grant your account access.',
          action: PrimaryButton(
            'Back to the lobby',
            onPressed: () => home(context),
          ),
        ),
      );
    }
    return JuryPage(
      title: 'Administration',
      eyebrow: 'Signed in as ${s.player!.name}',
      // The top bar marks this destination on desktop. On a phone it is a page
      // reached from the profile, so it needs a way back instead.
      back: !expanded,
      tab: expanded ? 4 : null,
      wide: expanded,
      actions: [
        IconButton(
          tooltip: 'Reload',
          onPressed: loading ? null : _load,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _sectionPicker(expanded),
          const SizedBox(height: 24),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (loadError != null)
            ErrorNotice(message: loadError!, onDismiss: _load)
          else if (section == 0)
            _Overview(overview: overview, people: people, cases: cases)
          else if (section == 1)
            _People(people: people, onChanged: _load)
          else
            _Cases(cases: cases, onChanged: _load),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Icons are dropped on a phone: with them the labels no longer fit and
  /// "Overview" breaks across two lines mid-word.
  Widget _sectionPicker(bool expanded) => SegmentedButton<int>(
    showSelectedIcon: expanded,
    segments: [
      ButtonSegment(
        value: 0,
        label: const Text('Overview'),
        icon: expanded ? const Icon(Icons.insights_outlined) : null,
      ),
      ButtonSegment(
        value: 1,
        label: const Text('Jurors'),
        icon: expanded ? const Icon(Icons.group_outlined) : null,
      ),
      ButtonSegment(
        value: 2,
        label: const Text('Cases'),
        icon: expanded ? const Icon(Icons.folder_outlined) : null,
      ),
    ],
    selected: {section},
    onSelectionChanged: (v) => setState(() => section = v.first),
  );
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.overview,
    required this.people,
    required this.cases,
  });
  final AdminOverview? overview;
  final List<AdminProfile> people;
  final List<AdminCase> cases;
  @override
  Widget build(BuildContext context) {
    final o = overview;
    if (o == null) return const SizedBox.shrink();
    final tiles = [
      ('Jurors', o['jurors'], Icons.group_outlined),
      ('Administrators', o['admins'], Icons.shield_outlined),
      ('Suspended', o['suspended'], Icons.block_outlined),
      ('Cases', o['cases'], Icons.folder_outlined),
      ('Rooms open', o['rooms_open'], Icons.meeting_room_outlined),
      ('Rooms complete', o['rooms_complete'], Icons.check_circle_outline),
      ('Ballots cast', o['ballots'], Icons.how_to_vote_outlined),
      ('Messages', o['messages'], Icons.forum_outlined),
      ('Reports', o['reports'], Icons.flag_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('The room at a glance', style: JType.display(30)),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            // Two across even on the narrowest phone: nine full-width rows
            // would be a very long scroll for nine short numbers.
            final columns = c.maxWidth > 900
                ? 3
                : c.maxWidth > 520
                ? 2
                : 2;
            final gap = columns == 2 && c.maxWidth < 520 ? 10.0 : 12.0;
            final width = (c.maxWidth - (columns - 1) * gap) / columns;
            final tight = width < 190;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final (label, value, icon) in tiles)
                  SizedBox(
                    width: width,
                    child: Panel(
                      padding: tight ? 14 : 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            size: tight ? 18 : 22,
                            color: JColors.brand,
                          ),
                          SizedBox(height: tight ? 10 : 12),
                          Text('$value', style: JType.display(tight ? 24 : 26)),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: JColors.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (o['reports'] > 0) ...[
          const SizedBox(height: 20),
          Panel(
            color: JColors.secondary,
            child: Text(
              '${o['reports']} reported ${o['reports'] == 1 ? 'message needs' : 'messages need'} a human decision. Reports are recorded for review; acting on them is a moderation step outside this dashboard.',
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ],
    );
  }
}

class _People extends StatelessWidget {
  const _People({required this.people, required this.onChanged});
  final List<AdminProfile> people;
  final Future<void> Function() onChanged;
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Jurors', style: JType.display(30))),
            Text(
              '${people.length} accounts',
              style: const TextStyle(fontSize: 12, color: JColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final p in people)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              padding: 16,
              color: p.suspended ? JColors.secondary : JColors.surface,
              child: Row(
                children: [
                  Avatar(p.name, size: 42),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (p.isAdmin) ...[
                              const SizedBox(width: 8),
                              const StatusTag(
                                'ADMIN',
                                icon: Icons.shield_outlined,
                              ),
                            ],
                            if (p.suspended) ...[
                              const SizedBox(width: 8),
                              const StatusTag(
                                'SUSPENDED',
                                icon: Icons.block_outlined,
                              ),
                            ],
                            if (p.id == s.player!.id) ...[
                              const SizedBox(width: 8),
                              const StatusTag('YOU'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${p.email} · ${p.points} points · ${p.cases} ${p.cases == 1 ? 'case' : 'cases'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: JColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit ${p.name}',
                    onPressed: () => _editPerson(context, p, onChanged),
                    icon: const Icon(Icons.tune_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> _editPerson(
  BuildContext context,
  AdminProfile p,
  Future<void> Function() onChanged,
) async {
  final s = JuryScope.of(context);
  final name = TextEditingController(text: p.name);
  final points = TextEditingController(text: '${p.points}');
  var suspended = p.suspended;
  var isAdmin = p.isAdmin;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            24 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: JSpace.maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: JType.display(28)),
                const SizedBox(height: 4),
                Text(
                  p.email,
                  style: const TextStyle(fontSize: 12, color: JColors.muted),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    helperText: 'Between 2 and 30 characters.',
                  ),
                  maxLength: 30,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: points,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Points'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isAdmin,
                  onChanged: (v) => setSheet(() => isAdmin = v),
                  title: const Text('Administrator'),
                  subtitle: const Text('Full access to this dashboard.'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: suspended,
                  onChanged: p.id == s.player!.id
                      ? null
                      : (v) => setSheet(() => suspended = v),
                  title: const Text('Suspended'),
                  subtitle: Text(
                    p.id == s.player!.id
                        ? 'You cannot suspend your own account.'
                        : 'Keeps the account and its history, but blocks play.',
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  'Save changes',
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.pop(ctx, true),
                ),
                const SizedBox(height: 10),
                if (p.id != s.player!.id)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: JColors.error),
                    onPressed: () => Navigator.pop(ctx, false),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete this account permanently'),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  if (!context.mounted || saved == null) return;
  if (saved) {
    final parsed = int.tryParse(points.text.trim());
    final ok = await s.adminAction(
      (a) => a.updateProfile(
        p.id,
        name: name.text.trim(),
        points: parsed,
        suspended: suspended,
        isAdmin: isAdmin,
      ),
    );
    if (ok) await onChanged();
    if (context.mounted && ok) toast(context, 'Saved ${name.text.trim()}.');
  } else {
    final confirmed = await _confirmByTyping(
      context,
      title: 'Delete ${p.name}?',
      body:
          'This permanently removes the account, its ballots, messages, points and case history. It cannot be undone.',
      phrase: p.name,
    );
    if (!context.mounted || !confirmed) return;
    final ok = await s.adminAction((a) => a.deleteUser(p.id));
    if (ok) await onChanged();
    if (context.mounted && ok) toast(context, 'Deleted ${p.name}.');
  }
}

/// Destructive actions ask for the name to be typed, so a misclick cannot
/// remove an account.
Future<bool> _confirmByTyping(
  BuildContext context, {
  required String title,
  required String body,
  required String phrase,
}) async {
  final input = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) => AlertDialog(
        title: Text(title, style: JType.display(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 18),
            Text(
              'Type “$phrase” to confirm.',
              style: const TextStyle(fontSize: 12, color: JColors.muted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: input,
              autofocus: true,
              onChanged: (_) => setDialog(() {}),
              decoration: const InputDecoration(isDense: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep the account'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: JColors.error),
            onPressed: input.text.trim() == phrase
                ? () => Navigator.pop(ctx, true)
                : null,
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    ),
  );
  input.dispose();
  return result ?? false;
}

class _Cases extends StatelessWidget {
  const _Cases({required this.cases, required this.onChanged});
  final List<AdminCase> cases;
  final Future<void> Function() onChanged;
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Cases', style: JType.display(30))),
            TextButton.icon(
              onPressed: () => _editCase(context, null, onChanged),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add case'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Cases are stored as JSON and shared by every juror. A case that has been played is kept for those records.',
          style: TextStyle(fontSize: 12, color: JColors.muted, height: 1.6),
        ),
        const SizedBox(height: 18),
        for (final c in cases)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              padding: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.file.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${c.file.id} · ${c.file.category} · ${c.file.evidence.length} exhibits · ${c.rounds} ${c.rounds == 1 ? 'round' : 'rounds'} played',
                          style: const TextStyle(
                            fontSize: 11,
                            color: JColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit ${c.file.title}',
                    onPressed: () => _editCase(context, c, onChanged),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                  IconButton(
                    tooltip: c.deletable
                        ? 'Delete ${c.file.title}'
                        : 'Played cases are kept',
                    onPressed: c.deletable
                        ? () async {
                            final ok = await confirmAction(
                              context,
                              title: 'Delete ${c.file.title}?',
                              body:
                                  'No round has been played on this case, so nothing else is affected. This cannot be undone.',
                              confirm: 'Delete case',
                            );
                            if (!context.mounted || !ok) return;
                            final done = await s.adminAction(
                              (a) => a.deleteCase(c.file.id),
                            );
                            if (done) await onChanged();
                          }
                        : null,
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Opens the form editor. Returns once the case has been saved so the list can
/// reload.
Future<void> _editCase(
  BuildContext context,
  AdminCase? existing,
  Future<void> Function() onChanged,
) async {
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => CaseEditorScreen(existing: existing?.file),
    ),
  );
  if (saved == true) await onChanged();
}
