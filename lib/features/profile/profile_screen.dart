import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/live_jury_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool push = true;
  bool voice = false;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
            const Spacer(),
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile editing coming with account integration',
                  ),
                ),
              ),
              tooltip: 'Edit profile',
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Center(
          child: JurorAvatar(initials: 'VK', size: 88, color: AppColors.gold),
        ),
        const SizedBox(height: 14),
        Text(
          'Vaibhav',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5),
        Text(
          'Considered Juror • Level 7',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: MiniStat(label: 'Cases', value: '34'),
            ),
            Expanded(
              child: MiniStat(label: 'Reasoning', value: '82'),
            ),
            Expanded(
              child: MiniStat(label: 'Reputation', value: '4.8'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          child: Column(
            children: [
              SettingTile(
                icon: Icons.workspace_premium_outlined,
                title: 'Achievements',
                trailing: '12 earned',
                onTap: () => _comingSoon(context, 'Achievements'),
              ),
              const Divider(),
              SettingTile(
                icon: Icons.block_outlined,
                title: 'Blocked jurors',
                trailing: 'Manage',
                onTap: () => _comingSoon(context, 'Blocked jurors'),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.gold,
                ),
                title: const Text('Push notifications'),
                value: push,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() => push = value),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.mic_none, color: AppColors.gold),
                title: const Text('Voice deliberation'),
                subtitle: const Text('Allow microphone in supported rooms'),
                value: voice,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() => voice = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SurfaceCard(
          child: Column(
            children: [
              SettingTile(
                icon: Icons.shield_outlined,
                title: 'Privacy & safety',
                trailing: '',
                onTap: () => _comingSoon(context, 'Privacy & safety'),
              ),
              const Divider(),
              SettingTile(
                icon: Icons.description_outlined,
                title: 'Community rules',
                trailing: '',
                onTap: () => _comingSoon(context, 'Community rules'),
              ),
              const Divider(),
              SettingTile(
                icon: Icons.help_outline,
                title: 'Help centre',
                trailing: '',
                onTap: () => _comingSoon(context, 'Help centre'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-out arrives with account integration'),
            ),
          ),
          child: const Text('SIGN OUT'),
        ),
      ],
    ),
  );

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }
}
