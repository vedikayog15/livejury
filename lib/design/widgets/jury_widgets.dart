import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/models.dart';
import '../../core/state/jury_controller.dart';
import '../tokens.dart';
import 'ambient_backdrop.dart';

void go(
  BuildContext context,
  String route, {
  Object? arguments,
  bool replace = false,
}) {
  if (replace) {
    Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  } else {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }
}

void home(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
void toast(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

class JuryPage extends StatelessWidget {
  const JuryPage({
    super.key,
    required this.child,
    this.title,
    this.eyebrow,
    this.bottom,
    this.tab,
    this.actions = const [],
    this.dark = false,
    this.back = true,
    this.scroll = true,
    this.padding = true,
  });
  final Widget child;
  final String? title, eyebrow;
  final Widget? bottom;
  final int? tab;
  final List<Widget> actions;
  final bool dark, back, scroll, padding;
  @override
  Widget build(BuildContext context) {
    final state = JuryScope.of(context);
    final color = dark ? JColors.surface : JColors.ink;
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding ? JSpace.gutter(context) : 0,
      ),
      child: child,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: dark ? JColors.ink : JColors.canvas,
        bottomNavigationBar: bottom == null && tab == null
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  bottom: bottom != null
                      ? MediaQuery.viewInsetsOf(context).bottom
                      : 0,
                ),
                child: SafeArea(
                  top: false,
                  child: Align(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: JSpace.maxWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (bottom != null)
                            Container(
                              decoration: BoxDecoration(
                                color: dark ? JColors.ink : JColors.canvas,
                                border: Border(
                                  top: BorderSide(
                                    color: dark
                                        ? JColors.raised
                                        : JColors.border,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                JSpace.gutter(context),
                                14,
                                JSpace.gutter(context),
                                12,
                              ),
                              child: bottom,
                            ),
                          if (tab != null) JuryNavigation(selected: tab!),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        body: AmbientBackdrop(
          dark: dark,
          child: SafeArea(
            bottom: bottom == null && tab == null,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: JSpace.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          back ? 8 : JSpace.gutter(context),
                          8,
                          12,
                          8,
                        ),
                        child: Row(
                          children: [
                            if (back)
                              IconButton(
                                tooltip: 'Back',
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    home(context);
                                  }
                                },
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: color,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (eyebrow != null)
                                    Text(
                                      eyebrow!.toUpperCase(),
                                      style: JType.caption.copyWith(
                                        fontSize: 10,
                                        color: dark
                                            ? JColors.onDarkMuted
                                            : JColors.muted,
                                      ),
                                    ),
                                  Text(
                                    title!,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...actions,
                          ],
                        ),
                      ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: ErrorNotice(
                          message: state.error!,
                          onDismiss: state.clearError,
                        ),
                      ),
                    Expanded(
                      child: scroll
                          ? SingleChildScrollView(
                              key: PageStorageKey(title ?? 'invitation'),
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 28,
                              ),
                              child: content,
                            )
                          : content,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JuryNavigation extends StatelessWidget {
  const JuryNavigation({super.key, required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
    child: FrostedSurface(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            for (final (i, icon, activeIcon, label, route) in [
              (
                0,
                Icons.chair_alt_outlined,
                Icons.chair_alt_rounded,
                'Lobby',
                '/home',
              ),
              (
                1,
                Icons.auto_stories_outlined,
                Icons.auto_stories_rounded,
                'Journal',
                '/history',
              ),
              (
                2,
                Icons.leaderboard_outlined,
                Icons.leaderboard_rounded,
                'Rankings',
                '/leaderboard',
              ),
              (
                3,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                'You',
                '/profile',
              ),
            ])
              Expanded(
                child: Semantics(
                  selected: selected == i,
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(23),
                    onTap: () {
                      if (selected != i) go(context, route, replace: true);
                    },
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected == i
                            ? JColors.secondary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected == i ? activeIcon : icon,
                            size: 23,
                            color: selected == i
                                ? JColors.brand
                                : JColors.muted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected == i
                                  ? JColors.brand
                                  : JColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.loading = false,
    this.citron = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading, citron;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: citron
          ? FilledButton.styleFrom(
              backgroundColor: JColors.accent,
              foregroundColor: JColors.ink,
              disabledBackgroundColor: JColors.raised,
              disabledForegroundColor: JColors.onDarkMuted,
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Text(label, textAlign: TextAlign.center)),
          const SizedBox(width: 8),
          if (loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: citron ? JColors.ink : JColors.onDarkMuted,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 20),
        ],
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = JColors.surface,
    this.padding = 20,
    this.border = false,
  });
  final Widget child;
  final Color color;
  final double padding;
  final bool border;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: border
            ? JColors.border
            : (color == JColors.ink
                  ? JColors.onDarkMuted.withValues(alpha: .16)
                  : JColors.surface.withValues(alpha: .65)),
      ),
      boxShadow: [
        BoxShadow(
          color: JColors.ink.withValues(alpha: .025),
          blurRadius: 22,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.dark = false});
  final String text;
  final bool dark;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: JType.caption.copyWith(
      color: dark ? JColors.onDarkMuted : JColors.muted,
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: JType.display(25))),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

class StatusTag extends StatelessWidget {
  const StatusTag(this.label, {super.key, this.dark = false, this.icon});
  final String label;
  final bool dark;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: dark ? JColors.raised : JColors.secondary,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: dark ? JColors.accent : JColors.ink),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: dark ? JColors.surface : JColors.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.index = 0, this.size = 42});
  final String name;
  final int index;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: [JColors.secondary, JColors.accent, JColors.border][index % 3],
      borderRadius: BorderRadius.circular(size * .35),
    ),
    child: Text(
      name
          .split(' ')
          .where((e) => e.isNotEmpty)
          .take(2)
          .map((e) => e[0])
          .join()
          .toUpperCase(),
      style: TextStyle(
        fontSize: size * .3,
        color: JColors.ink,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: JColors.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: JColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.arrow_forward_rounded, size: 20)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    ),
  );
}

class ErrorNotice extends StatelessWidget {
  const ErrorNotice({super.key, required this.message, this.onDismiss});
  final String message;
  final VoidCallback? onDismiss;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      decoration: BoxDecoration(
        color: JColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JColors.error),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: JColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: JColors.error, fontSize: 13),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: 'Dismiss error',
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.auto_stories_outlined,
    this.action,
  });
  final String title, body;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: JColors.secondary,
          ),
          child: Icon(icon, size: 36),
        ),
        const SizedBox(height: 24),
        Text(title, textAlign: TextAlign.center, style: JType.display(32)),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: JColors.muted, height: 1.6),
        ),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    ),
  );
}

class StageStrip extends StatelessWidget {
  const StageStrip({super.key, required this.active});
  final int active;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= active ? JColors.ink : JColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['Review', 'First vote', 'Discuss', 'Final vote'][i],
                    style: TextStyle(
                      fontSize: 10,
                      color: i == active ? JColors.ink : JColors.muted,
                      fontWeight: i == active
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

IconData evidenceIcon(EvidenceKind kind) => switch (kind) {
  EvidenceKind.document => Icons.description_outlined,
  EvidenceKind.witness => Icons.record_voice_over_outlined,
  EvidenceKind.diagram => Icons.grid_view_rounded,
  EvidenceKind.audio => Icons.graphic_eq_rounded,
};

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirm,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: JType.display(28)),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep my seat'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ??
    false;
