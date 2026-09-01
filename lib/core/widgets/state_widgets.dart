import 'package:flutter/material.dart';

import '../design/design_tokens.dart';
import '../theme/live_jury_theme.dart';

/// Friendly placeholder for a list/section with no content yet.
/// Always pairs a message with guidance or an action — never a blank screen.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Icon(icon, size: 30, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Failure state with a clear cause and a recovery path — never a dead end.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.negative.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: AppColors.negative,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xxs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rounded shimmer block for skeleton loading placeholders.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: widget.borderRadius,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.surfaceAlt,
              AppColors.outline,
              _controller.value,
            ),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Wraps a tappable child with a subtle press-scale that respects
/// reduced-motion. Use for cards/rows that navigate or select on tap.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final scale = interactive && !reduceMotion && _pressed
        ? AppMotion.pressScale
        : 1.0;
    return Semantics(
      button: interactive,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: interactive ? (_) => _setPressed(true) : null,
        onTapCancel: interactive ? () => _setPressed(false) : null,
        onTapUp: interactive ? (_) => _setPressed(false) : null,
        child: AnimatedScale(
          scale: scale,
          duration: AppMotion.micro,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Staggers the entrance of list/grid children with a fade + rise.
/// Disabled automatically when the platform requests reduced motion.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.standard + AppMotion.staggerStep * index,
      curve: AppMotion.enterCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
