import 'package:flutter/material.dart';
import '../../core/state/jury_controller.dart';
import '../../design/tokens.dart';
import '../../design/widgets/chamber_art.dart';
import '../../design/widgets/ambient_backdrop.dart';
import '../../design/widgets/jury_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = JuryScope.of(context);
    return JuryPage(
      dark: true,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            'Take your seat',
            citron: true,
            loading: s.busy,
            onPressed: () async {
              if (await s.signIn(demo: true) && context.mounted) home(context);
            },
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: () => go(context, '/auth'),
            style: TextButton.styleFrom(foregroundColor: JColors.surface),
            child: const Text('Sign in or create an account'),
          ),
          const Text(
            'Free demo · No account needed',
            style: TextStyle(color: JColors.onDarkMuted, fontSize: 11),
          ),
        ],
      ),
      child: EntryReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        JColors.glow.withValues(alpha: .4),
                        JColors.raised,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: JColors.glow.withValues(alpha: .4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text('VI', style: JType.display(23, JColors.accent)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'LIVE\nJURY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: JColors.surface,
                      letterSpacing: 2,
                      height: 1.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: JColors.glow.withValues(alpha: .25),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    '6 SEATS',
                    style: TextStyle(
                      color: JColors.onDarkMuted,
                      fontSize: 9,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Stack(
              children: [
                const ChamberArt(height: 270, seated: 5),
                Positioned(
                  left: 0,
                  top: 12,
                  child: Transform.rotate(
                    angle: -.08,
                    child: const _FloatingNote(
                      icon: Icons.fingerprint_rounded,
                      label: 'YOUR VOTE',
                      value: 'Privately yours.',
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 8,
                  child: Transform.rotate(
                    angle: .04,
                    child: const _FloatingNote(
                      icon: Icons.forum_outlined,
                      label: 'THE DISCUSSION',
                      value: 'Better together.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'A SOCIAL GAME OF PERSPECTIVE',
              style: TextStyle(
                color: JColors.accent,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Enter the room.\nChange your mind.',
              style: JType.display(
                MediaQuery.sizeOf(context).width < 360 ? 34 : 41,
                JColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'An intriguing case. Five other minds.\nAnd a verdict that starts with you.',
              style: TextStyle(
                color: JColors.onDarkMuted,
                fontSize: 14,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                _Step('01', Icons.search_rounded, 'Examine'),
                SizedBox(width: 10),
                _Step('02', Icons.forum_outlined, 'Discuss'),
                SizedBox(width: 10),
                _Step('03', Icons.how_to_vote_outlined, 'Decide'),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'All cases are fictional. The perspectives are yours.',
              style: TextStyle(
                color: JColors.onDarkMuted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNote extends StatelessWidget {
  const _FloatingNote({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: JColors.raised.withValues(alpha: .91),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: JColors.glow.withValues(alpha: .25)),
      boxShadow: [
        BoxShadow(
          color: JColors.ink.withValues(alpha: .3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: JColors.accent),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: JColors.onDarkMuted,
                fontSize: 7,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: JColors.surface,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.icon, this.label);
  final String number, label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: JColors.surface.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: JColors.surface.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: JColors.accent),
              const Spacer(),
              Text(
                number,
                style: const TextStyle(fontSize: 8, color: JColors.onDarkMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: JColors.surface,
            ),
          ),
        ],
      ),
    ),
  );
}
