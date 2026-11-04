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
    final expanded = JSpace.isExpanded(context);
    return JuryPage(
      dark: true,
      wide: expanded,
      // On a laptop the invitation reads as a landing page, so the call to
      // action sits beside the copy rather than in a pinned bar.
      bottom: expanded ? null : _cta(context, s),
      child: EntryReveal(
        child: expanded ? _wide(context, s) : _narrow(context, s),
      ),
    );
  }

  Widget _cta(BuildContext context, JuryController s) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
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
        textAlign: TextAlign.center,
        style: TextStyle(color: JColors.onDarkMuted, fontSize: 11),
      ),
    ],
  );

  /// Laptop and desktop: the chamber sits beside the invitation copy so the
  /// whole proposition is one screen rather than a tall scroll.
  Widget _wide(BuildContext context, JuryController s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      _brand(),
      const SizedBox(height: 44),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 6, child: _art(height: 330)),
          const SizedBox(width: 52),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._pitch(context, display: 46),
                const SizedBox(height: 28),
                _steps(),
                const SizedBox(height: 30),
                _cta(context, s),
                const SizedBox(height: 18),
                _footnote(),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
    ],
  );

  Widget _narrow(BuildContext context, JuryController s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 18),
      _brand(),
      const SizedBox(height: 26),
      _art(height: 270),
      const SizedBox(height: 18),
      ..._pitch(
        context,
        display: MediaQuery.sizeOf(context).width < 360 ? 34 : 41,
      ),
      const SizedBox(height: 24),
      _steps(),
      const SizedBox(height: 22),
      _footnote(),
    ],
  );

  Widget _art({required double height}) => Stack(
    children: [
      ChamberArt(height: height, seated: 5),
      const Positioned(
        left: 0,
        top: 12,
        child: _Tilted(
          angle: -.08,
          child: _FloatingNote(
            icon: Icons.fingerprint_rounded,
            label: 'YOUR VOTE',
            value: 'Privately yours.',
          ),
        ),
      ),
      const Positioned(
        right: 0,
        bottom: 8,
        child: _Tilted(
          angle: .04,
          child: _FloatingNote(
            icon: Icons.forum_outlined,
            label: 'THE DISCUSSION',
            value: 'Better together.',
          ),
        ),
      ),
    ],
  );

  List<Widget> _pitch(BuildContext context, {required double display}) => [
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
      style: JType.display(display, JColors.surface),
    ),
    const SizedBox(height: 16),
    const Text(
      'An intriguing case. A room of other minds.\nAnd a verdict that starts with you.',
      style: TextStyle(color: JColors.onDarkMuted, fontSize: 14, height: 1.65),
    ),
  ];

  Widget _steps() => const Row(
    children: [
      _Step('01', Icons.search_rounded, 'Examine'),
      SizedBox(width: 10),
      _Step('02', Icons.forum_outlined, 'Discuss'),
      SizedBox(width: 10),
      _Step('03', Icons.how_to_vote_outlined, 'Decide'),
    ],
  );

  Widget _footnote() => const Text(
    'All cases are fictional. The perspectives are yours.',
    style: TextStyle(color: JColors.onDarkMuted, fontSize: 11, height: 1.5),
  );

  Widget _brand() => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [JColors.glow.withValues(alpha: .4), JColors.raised],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: JColors.glow.withValues(alpha: .4)),
        ),
        padding: const EdgeInsets.all(5),
        child: Image.asset('assets/brand/logo-mark.png'),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: JColors.glow.withValues(alpha: .25)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          'FICTIONAL CASES',
          style: TextStyle(
            color: JColors.onDarkMuted,
            fontSize: 9,
            letterSpacing: 1.3,
          ),
        ),
      ),
    ],
  );
}

/// Kept separate so the hero art can stay a const widget.
class _Tilted extends StatelessWidget {
  const _Tilted({required this.angle, required this.child});
  final double angle;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Transform.rotate(angle: angle, child: child);
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
