import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/app_frame.dart';
import '../../core/widgets/live_jury_widgets.dart';
import '../jury/jury_experience.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  int players = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Finding your jury'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;
            final orbitSize = compact ? 190.0 : 260.0;
            final orbitRadius = compact ? 80.0 : 110.0;
            final sideOffset = compact ? 69.0 : 95.0;
            final diagonalOffset = compact ? 40.0 : 55.0;
            return Padding(
              padding: EdgeInsets.all(compact ? 16 : 24),
              child: Column(
                children: [
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: orbitSize,
                        height: orbitSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: .18),
                          ),
                          color: AppColors.gold.withValues(alpha: .03),
                        ),
                      ),
                      const BrandMark(size: 72),
                      ...List.generate(6, (i) {
                        final angle = i * 1.047;
                        final offsets = [
                          (0.0, -orbitRadius),
                          (sideOffset, -diagonalOffset),
                          (sideOffset, diagonalOffset),
                          (0.0, orbitRadius),
                          (-sideOffset, diagonalOffset),
                          (-sideOffset, -diagonalOffset),
                        ];
                        final o = offsets[i];
                        return Transform.translate(
                          offset: Offset(o.$1, o.$2),
                          child: JurorAvatar(
                            initials: i < players
                                ? ['VK', 'AM', 'SK', 'RN', 'JT', 'LP'][i]
                                : '${i + 1}',
                            size: 48,
                            color: i < players
                                ? AppColors.teal
                                : AppColors.muted,
                            empty: i >= players,
                            semantics: '$angle',
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: compact ? 20 : 38),
                  Text(
                    '$players of 6 jurors ready',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    players == 6
                        ? 'Your case is ready.'
                        : 'Building a balanced room…',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(height: compact ? 14 : 24),
                  SurfaceCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Criminal law • Intermediate\nEstimated session: 12–15 min',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (players < 6) ...[
                    FilledButton.tonal(
                      onPressed: () =>
                          setState(() => players = (players + 1).clamp(1, 6)),
                      child: const Text('SIMULATE JUROR JOINING'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL SEARCH'),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AppFrame(child: JuryExperience()),
                        ),
                      ),
                      child: const Text('ENTER THE JURY ROOM'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PrivateRoomScreen extends StatefulWidget {
  const PrivateRoomScreen({super.key});

  @override
  State<PrivateRoomScreen> createState() => _PrivateRoomScreenState();
}

class _PrivateRoomScreenState extends State<PrivateRoomScreen> {
  int players = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private jury'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text(
              'Invite your jury',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Share this code with up to five people.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: .28),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'ROOM CODE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SelectableText(
                    'JURY26',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite link copied')),
                    ),
                    icon: const Icon(Icons.ios_share),
                    label: const Text('SHARE INVITE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text('Jurors', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text(
                  '$players / 6',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.gold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...List.generate(
              6,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  child: Row(
                    children: [
                      JurorAvatar(
                        initials: i < players
                            ? ['VK', 'AM', 'SK', 'RN', 'JT', 'LP'][i]
                            : '?',
                        color: i < players ? AppColors.teal : AppColors.muted,
                        empty: i >= players,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          i < players
                              ? [
                                  'Vaibhav (Host)',
                                  'Aarav Mehta',
                                  'Sara Khan',
                                  'Rohan Nair',
                                  'Jia Thomas',
                                  'Leena Patel',
                                ][i]
                              : 'Open seat',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: i < players
                                    ? AppColors.cream
                                    : AppColors.muted,
                              ),
                        ),
                      ),
                      Icon(
                        i < players
                            ? Icons.check_circle
                            : Icons.hourglass_empty,
                        color: i < players ? AppColors.teal : AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (players < 6)
              OutlinedButton(
                onPressed: () => setState(() => players++),
                child: const Text('SIMULATE FRIEND JOINING'),
              )
            else
              FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppFrame(child: JuryExperience()),
                  ),
                ),
                child: const Text('START SESSION'),
              ),
          ],
        ),
      ),
    );
  }
}
