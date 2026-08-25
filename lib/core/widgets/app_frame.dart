import 'package:flutter/material.dart';

import '../design/design_tokens.dart';
import '../theme/live_jury_theme.dart';

class AppFrame extends StatelessWidget {
  const AppFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF05080C),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.canvas),
            child: child,
          ),
        ),
      ),
    );
  }
}
