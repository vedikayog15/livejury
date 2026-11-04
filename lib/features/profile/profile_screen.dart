import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/site_config.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/jury_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    final p = s.player!;
    final badges = [
      (
        'Close reader',
        Icons.auto_stories_outlined,
        p.history.any((h) => h.reviewed >= 4),
        'Review every exhibit in a completed case.',
      ),
      (
        'Evidence advocate',
        Icons.attach_file,
        p.history.any((h) => h.citations > 0),
        'Reference evidence during a completed discussion.',
      ),
      (
        'Open mind',
        Icons.psychology_outlined,
        p.history.any((h) => h.changedMind),
        'Revise your first impression after deliberating.',
      ),
      (
        'Regular at the table',
        Icons.chair_alt_outlined,
        p.history.length >= 5,
        'Complete five cases.',
      ),
    ];
    return JuryPage(
      title: 'Your juror profile',
      back: false,
      tab: 3,
      actions: [
        IconButton(
          tooltip: 'Edit profile',
          onPressed: () => go(context, '/profile-edit'),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
      wide: JSpace.isExpanded(context),
      child: JSpace.isExpanded(context)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _identity(s, p),
                      const SizedBox(height: 28),
                      _stats(p),
                      const SizedBox(height: 30),
                      ..._settings(context, s),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const SizedBox(height: 28), ..._badges(badges)],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _identity(s, p),
                const SizedBox(height: 28),
                _stats(p),
                const SizedBox(height: 30),
                ..._badges(badges),
                const SizedBox(height: 20),
                ..._settings(context, s),
              ],
            ),
    );
  }

  Widget _identity(JuryController s, PlayerData p) => Row(
    children: [
      Avatar(p.name, size: 72),
      const SizedBox(width: 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: JType.display(32)),
            const SizedBox(height: 8),
            StatusTag(
              s.isDemo ? 'DEMO JUROR' : 'CONNECTED JUROR',
              icon: s.isDemo
                  ? Icons.science_outlined
                  : Icons.verified_user_outlined,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _stats(PlayerData p) => Panel(
    color: JColors.ink,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('The thoughtful juror', dark: true),
        const SizedBox(height: 18),
        Text(
          p.history.isEmpty
              ? 'A fresh perspective.'
              : p.history.length >= 5
              ? 'A regular at the table.'
              : 'Finding your voice.',
          style: JType.display(32, JColors.surface),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.points}', style: JType.display(36, JColors.accent)),
                  const Text(
                    'TOTAL POINTS',
                    style: TextStyle(
                      color: JColors.onDarkMuted,
                      fontSize: 9,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.history.length}',
                    style: JType.display(36, JColors.surface),
                  ),
                  const Text(
                    'CASES CLOSED',
                    style: TextStyle(
                      color: JColors.onDarkMuted,
                      fontSize: 9,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  List<Widget> _badges(List<(String, IconData, bool, String)> badges) => [
    SectionHeading('Earned through thought'),
    const SizedBox(height: 16),
    for (final (name, icon, earned, description) in badges)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Panel(
          padding: 16,
          color: earned ? JColors.secondary : JColors.surface,
          child: Row(
            children: [
              earned
                  ? DepthIcon(icon, tone: DepthTone.apricot, size: 44)
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: JColors.border),
                      ),
                      child: Icon(icon, size: 22, color: JColors.muted),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: JColors.muted,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                earned ? Icons.check_circle_outline : Icons.lock_outline,
                size: 18,
                color: earned ? JColors.success : JColors.muted,
              ),
            ],
          ),
        ),
      ),
  ];

  List<Widget> _settings(BuildContext context, JuryController s) => [
    // The desktop top bar carries this too, but that bar does not exist on a
    // phone, so the profile is the way in on every layout.
    if (s.isAdmin) ...[
      InfoRow(
        icon: Icons.shield_outlined,
        tone: DepthTone.night,
        title: 'Administration',
        subtitle: 'Jurors, cases and room statistics',
        onTap: () => go(context, '/admin'),
      ),
      const Divider(),
    ],
    InfoRow(
      icon: Icons.settings_outlined,
      tone: DepthTone.violet,
      title: 'Your preferences',
      subtitle: 'Name, haptics, and in-app notifications',
      onTap: () => go(context, '/profile-edit'),
    ),
    const Divider(),
    InfoRow(
      icon: Icons.info_outline,
      title: 'About this experience',
      subtitle: 'Fictional cases. Respectful conversation.',
      onTap: () => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('The Jury Room', style: JType.display(28)),
          content: const SingleChildScrollView(
            child: Text(
              'Version 1.0.0\n\nA social deliberation game for curious minds. Every case, character, document, and statement is fictional.\n\nYour score reflects participation and evidence review, not legal expertise.\n\nDemo data is stored on this device. Connected accounts store profile and game records in the configured Supabase project. Ballots are account-linked and visible only to their owner; other jurors see only the final aggregate.\n\nRespect other jurors. Challenge ideas, avoid personal data, and use mute or report when needed.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Back to the room'),
            ),
          ],
        ),
      ),
    ),
    const Divider(),
    InfoRow(
      icon: Icons.privacy_tip_outlined,
      tone: DepthTone.forest,
      title: 'Privacy policy',
      subtitle: 'What we store and how to remove it',
      onTap: () => launchUrl(Uri.parse(SiteConfig.privacyUrl)),
    ),
    const SizedBox(height: 20),
    SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: s.busy
            ? null
            : () async {
                if (await s.signOut() && context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (_) => false);
                }
              },
        child: const Text('Sign out'),
      ),
    ),
    const SizedBox(height: 8),
    SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(foregroundColor: JColors.error),
        onPressed: s.busy
            ? null
            : () async {
                final confirmed = await confirmAction(
                  context,
                  title: 'Delete your account?',
                  body: s.isDemo
                      ? 'This erases your demo profile, points and case journal from this device.'
                      : 'This permanently deletes your account, profile, points, ballots, messages and case journal. It cannot be undone.',
                  confirm: 'Delete permanently',
                );
                if (confirmed && await s.deleteAccount() && context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (_) => false);
                  toast(context, 'Your account has been deleted.');
                }
              },
        child: const Text('Delete account'),
      ),
    ),
    const SizedBox(height: 20),
    const Center(
      child: Text(
        'LIVE JURY · 1.0.0',
        style: TextStyle(
          fontSize: 10,
          color: JColors.muted,
          letterSpacing: 1.2,
        ),
      ),
    ),
  ];
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  TextEditingController? name;
  bool haptics = true, notifications = true;
  final form = GlobalKey<FormState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (name == null) {
      final p = JuryScope.of(context).player!;
      name = TextEditingController(text: p.name);
      haptics = p.haptics;
      notifications = p.notifications;
    }
  }

  @override
  void dispose() {
    name?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return JuryPage(
      title: 'Make yourself at home',
      bottom: PrimaryButton(
        'Save preferences',
        loading: s.busy,
        icon: Icons.check_rounded,
        onPressed: () async {
          if (!form.currentState!.validate()) return;
          if (await s.updateProfile(name!.text, haptics, notifications) &&
              context.mounted) {
            toast(context, 'Your preferences are saved.');
            Navigator.pop(context);
          }
        },
      ),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Text('Your presence\nin the room.', style: JType.display(40)),
            const SizedBox(height: 28),
            TextFormField(
              controller: name,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: 'Display name',
                helperText: 'Other jurors see this name.',
              ),
              validator: (v) => (v?.trim().length ?? 0) < 2
                  ? 'Use at least two characters.'
                  : null,
            ),
            const SizedBox(height: 28),
            const Eyebrow('Small things, your way'),
            const SizedBox(height: 18),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tactile feedback'),
              subtitle: const Text('A subtle haptic when you cast a vote.'),
              value: haptics,
              onChanged: (v) => setState(() => haptics = v),
            ),
            const Divider(),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Case notifications'),
              subtitle: const Text('Receive in-app case completion notices.'),
              value: notifications,
              onChanged: (v) => setState(() => notifications = v),
            ),
            const SizedBox(height: 26),
            Panel(
              color: JColors.secondary,
              child: Text(
                s.isDemo
                    ? 'Your demo preferences and journal stay on this device. Signing out does not erase them.'
                    : 'Your preferences are saved to your Supabase account. Push notifications are not enabled in this version.',
                style: const TextStyle(fontSize: 13, height: 1.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
