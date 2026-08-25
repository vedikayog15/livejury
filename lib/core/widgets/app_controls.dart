import 'package:flutter/material.dart';

import '../design/design_tokens.dart';
import '../theme/live_jury_theme.dart';

class AdaptiveScreenPadding extends StatelessWidget {
  const AdaptiveScreenPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < AppSizes.compactBreakpoint
        ? AppSpacing.md
        : AppSpacing.lg;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        AppSpacing.md,
        horizontal,
        AppSpacing.xxl,
      ),
      child: child,
    );
  }
}

class AppIconAction extends StatelessWidget {
  const AppIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount,
    this.showBadgeDot = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int? badgeCount;
  final bool showBadgeDot;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 21);
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(
        width: AppSizes.minTouchTarget,
        height: AppSizes.minTouchTarget,
      ),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      icon: badgeCount != null
          ? Badge.count(
              count: badgeCount!,
              backgroundColor: AppColors.negative,
              textColor: Colors.white,
              child: iconWidget,
            )
          : showBadgeDot
          ? Badge(backgroundColor: AppColors.negative, child: iconWidget)
          : iconWidget,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.editorialTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 28,
            ),
          ),
        ),
        if (actionLabel != null)
          onAction == null
              ? Text(
                  actionLabel!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, AppSizes.minTouchTarget),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    foregroundColor: AppColors.primary,
                    textStyle: AppTypography.label,
                  ),
                  child: Text(actionLabel!),
                ),
      ],
    );
  }
}
