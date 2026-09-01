import 'package:flutter/material.dart';

import '../../../core/design/design_tokens.dart';
import '../../../core/theme/live_jury_theme.dart';

class EmeraldBackground extends StatelessWidget {
  const EmeraldBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-.55, -.85),
          radius: 1.35,
          colors: [Color(0xFF1B2723), AppColors.canvas],
          stops: [0, .72],
        ),
      ),
      child: child,
    );
  }
}

class JuryRoomHeader extends StatelessWidget {
  const JuryRoomHeader({
    super.key,
    required this.title,
    this.onNotifications,
    this.onProfile,
    this.compact = false,
  });

  final String title;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 64 : 76,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: .88),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: .12)),
        ),
        borderRadius: compact
            ? BorderRadius.zero
            : const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const BrandSeal(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.editorialTitle.copyWith(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
                fontSize: compact ? 23 : 26,
              ),
            ),
          ),
          IconButton(
            onPressed: onNotifications,
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Semantics(
            button: true,
            label: 'Open profile',
            excludeSemantics: true,
            child: InkResponse(
              onTap: onProfile,
              radius: 28,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceHigh,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .55),
                  ),
                  boxShadow: AppElevation.glowPrimary,
                ),
                child: Text(
                  'VK',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandSeal extends StatelessWidget {
  const BrandSeal({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB0F0D6), Color(0xFF2B6954)],
        ),
        boxShadow: AppElevation.glowPrimary,
      ),
      child: Icon(
        Icons.gavel_rounded,
        size: size * .48,
        color: AppColors.surfaceLowest,
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadii.xl,
    this.color,
    this.borderColor,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color ?? AppColors.surfaceHigh.withValues(alpha: .78),
            (color ?? AppColors.surfaceLow).withValues(alpha: .88),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? AppColors.primary.withValues(alpha: .16),
        ),
        boxShadow: glow ? AppElevation.glowPrimary : AppElevation.level1,
      ),
      child: child,
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, this.color = AppColors.primary, this.size = 9});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: .55), blurRadius: 9),
        ],
      ),
    );
  }
}

class ExhibitTag extends StatelessWidget {
  const ExhibitTag({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withValues(alpha: .26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class JuryAvatar extends StatelessWidget {
  const JuryAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.active = true,
  });

  final String initials;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: active ? 'Juror $initials assembled' : 'Open juror seat',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.surfaceHighest : AppColors.surfaceLow,
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: .55)
                : AppColors.outline,
            width: 1.5,
          ),
        ),
        child: Text(
          active ? initials : '·',
          style: AppTypography.caption.copyWith(
            color: active ? AppColors.textPrimary : AppColors.outlineStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class JuryRoomBottomDock extends StatelessWidget {
  const JuryRoomBottomDock({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const labels = ['Lobby', 'Evidence', 'Deliberate', 'History'];
  static const icons = [
    Icons.dashboard_outlined,
    Icons.folder_copy_outlined,
    Icons.groups_2_outlined,
    Icons.auto_stories_outlined,
  ];
  static const selectedIcons = [
    Icons.dashboard_rounded,
    Icons.folder_copy_rounded,
    Icons.groups_2_rounded,
    Icons.auto_stories_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.surfaceLow.withValues(alpha: .97),
          borderRadius: BorderRadius.circular(AppRadii.dock),
          border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
          boxShadow: AppElevation.level2,
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final selected = i == index;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: labels[i],
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? selectedIcons[i] : icons[i],
                          size: 23,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: .62),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary.withValues(
                                    alpha: .62,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

void showDemoFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
