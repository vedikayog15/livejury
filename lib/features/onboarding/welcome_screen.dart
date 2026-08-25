import 'package:flutter/material.dart';
import '../../core/design/design_tokens.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/app_frame.dart';
import '../../core/widgets/live_jury_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onEnter});
  final VoidCallback onEnter;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int page = 0;
  final controller = PageController();
  final pages = const [
    (
      Icons.article_outlined,
      'Examine the evidence',
      'Read case facts, witness statements, and exhibits at your own pace.',
    ),
    (
      Icons.forum_outlined,
      'Deliberate together',
      'Challenge perspectives in a live room with five fellow jurors.',
    ),
    (
      Icons.balance_outlined,
      'Reach your verdict',
      'Vote, explain your reasoning, and discover how the law views the case.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    const BrandMark(size: 42),
                    const SizedBox(width: 12),
                    Text(
                      'Live Jury',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onEnter,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    onPageChanged: (value) => setState(() => page = value),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final item = pages[index];
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxHeight < 450;
                          final artworkSize = compact ? 150.0 : 210.0;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _OnboardingArtwork(
                                icon: item.$1,
                                size: artworkSize,
                                index: index,
                              ),
                              SizedBox(height: compact ? 22 : 48),
                              Text(
                                item.$2,
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                item.$3,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.muted),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: index == page ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: index == page
                            ? AppColors.gold
                            : AppColors.outline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (page < 2) {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    } else {
                      widget.onEnter();
                    }
                  },
                  child: Text(page == 2 ? 'Enter Live Jury' : 'Continue'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hypothetical cases • Educational experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingArtwork extends StatelessWidget {
  const _OnboardingArtwork({
    required this.icon,
    required this.size,
    required this.index,
  });

  final IconData icon;
  final double size;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accents = [AppColors.primary, AppColors.positive, AppColors.negative];
    return Container(
      width: size + 72,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadii.xxl + 8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: Text(
              '0${index + 1}',
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF899198),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            width: size * .56,
            height: size * .56,
            decoration: BoxDecoration(
              color: accents[index].withValues(alpha: .2),
              borderRadius: BorderRadius.circular(AppRadii.xxl),
              border: Border.all(color: accents[index].withValues(alpha: .7)),
            ),
            child: Icon(icon, size: size * .27, color: Colors.white),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: Container(width: 46, height: 3, color: accents[index]),
          ),
        ],
      ),
    );
  }
}
