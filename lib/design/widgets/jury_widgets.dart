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
    this.wide = false,
    this.wideActions = false,
  });
  final Widget child;
  final String? title, eyebrow;
  final Widget? bottom;
  final int? tab;
  final List<Widget> actions;
  final bool dark, back, scroll, padding;

  /// Opt in to the full desktop canvas. Screens holding a single column of
  /// reading copy leave this false so the measure stays legible on a laptop.
  final bool wide;

  /// Let the action bar span the content measure instead of capping at
  /// [JSpace.actionWidth]. For bars that are a control rather than a button,
  /// such as the discussion composer.
  final bool wideActions;
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
    if (JSpace.isExpanded(context)) {
      return _buildExpanded(context, state, color, content);
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: dark ? JColors.ink : JColors.canvas,
        // The backdrop continues beneath the capsule and the action bar, so no
        // seam appears where the scaffold's own background would otherwise sit.
        extendBody: true,
        bottomNavigationBar: bottom == null && tab == null
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  bottom: bottom != null
                      ? MediaQuery.viewInsetsOf(context).bottom
                      : 0,
                ),
                // Content scrolling past the bar ramps into blur rather than
                // meeting a hard edge, across the whole strip and not only
                // inside the capsule.
                child: ProgressiveBlur(
                  maxSigma: 20,
                  child: DecoratedBox(
                    // An action bar sits over scrolling content, so it also fades
                    // into the page rather than drawing a hard edge across it.
                    decoration: bottom == null
                        ? const BoxDecoration()
                        : BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (dark ? JColors.ink : JColors.canvas)
                                    .withValues(alpha: 0),
                                dark ? JColors.ink : JColors.canvas,
                              ],
                              stops: const [0, .5],
                            ),
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
                                Padding(
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
                              // Content now passes beneath the capsule, so the
                              // last of it needs clearance to stay reachable.
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom:
                                    28 +
                                    (tab != null ? 92 : 0) +
                                    (bottom != null ? 86 : 0),
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

  /// Laptop and desktop layout: the tab bar becomes a persistent side rail and
  /// the content sits in a centred column, so a wide window reads as a desktop
  /// application rather than a stretched phone screen.
  Widget _buildExpanded(
    BuildContext context,
    JuryController state,
    Color color,
    Widget content,
  ) {
    final gutter = JSpace.gutter(context);
    final maxW = wide ? JSpace.wideMaxWidth : JSpace.maxWidth;
    // Header, content and action bar each span the full area beside the rail,
    // while their contents align to one shared measure. Constraining the whole
    // column instead would float the action bar as a narrow slab.
    Widget measure(Widget child) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          measure(
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 12),
              child: Row(
                children: [
                  if (back && Navigator.canPop(context))
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_rounded, color: color),
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
                              fontSize: 11,
                              letterSpacing: .8,
                              color: dark ? JColors.onDarkMuted : JColors.muted,
                            ),
                          ),
                        Text(title!, style: JType.display(28, color)),
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
        if (state.error != null)
          measure(
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 8),
              child: ErrorNotice(
                message: state.error!,
                onDismiss: state.clearError,
              ),
            ),
          ),
        Expanded(
          child: scroll
              // A short screen centres in the window instead of hugging the top
              // of a tall laptop display; a long one scrolls as usual.
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    key: PageStorageKey(title ?? 'invitation'),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: title == null ? 28 : 4,
                            bottom: 40,
                          ),
                          child: measure(content),
                        ),
                      ),
                    ),
                  ),
                )
              : measure(content),
        ),
        if (bottom != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: wideActions ? maxW : JSpace.actionWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: bottom,
                ),
              ),
            ),
          ),
      ],
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: dark ? JColors.ink : JColors.canvas,
        body: AmbientBackdrop(
          dark: dark,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (tab != null) JuryTopNav(selected: tab!, dark: dark),
                Expanded(child: column),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop two-column body: a reading column that scrolls on its own beside a
/// sidebar that carries the metadata and the primary action.
///
/// Pair it with `scroll: false` and `bottom: null` on [JuryPage] at expanded
/// widths. The action then sits with the material it acts on instead of in a
/// bar stretched across the foot of the window.
class SplitLayout extends StatelessWidget {
  const SplitLayout({
    super.key,
    required this.main,
    required this.aside,
    this.mainHeader = const [],
    this.mainFlex = 6,
    this.asideFlex = 5,
  });
  final List<Widget> main, aside;

  /// Pinned above the scrolling column. A title left in place gives the reader
  /// something to hold on to while the material beneath it moves.
  final List<Widget> mainHeader;
  final int mainFlex, asideFlex;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        flex: mainFlex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mainHeader.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...mainHeader,
              const SizedBox(height: 20),
            ],
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: mainHeader.isEmpty ? 4 : 0,
                  bottom: 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: main,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 40),
      Expanded(
        flex: asideFlex,
        // Scrolls too, so a tall sidebar on a short window stays reachable.
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 22, bottom: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: aside,
          ),
        ),
      ),
    ],
  );
}

/// Vertical navigation for laptop and desktop windows. Mirrors the destinations
/// of [JuryNavigation] so the two layouts stay in step.
/// Horizontal navigation for laptop, desktop and web, where a bar across the
/// top is the convention. Mirrors the destinations of [JuryNavigation] so the
/// two layouts stay in step, and surfaces the admin area only to an admin.
class JuryTopNav extends StatelessWidget {
  const JuryTopNav({super.key, required this.selected, this.dark = false});
  final int selected;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final state = JuryScope.of(context);
    final onSurface = dark ? JColors.surface : JColors.ink;
    final muted = dark ? JColors.onDarkMuted : JColors.muted;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dark ? JColors.raised : JColors.border),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: JSpace.gutter(context),
        vertical: 12,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: JSpace.wideMaxWidth),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (selected != 0) go(context, '/home', replace: true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: JColors.ink,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Image.asset('assets/brand/logo-mark.png'),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'The Jury Room',
                        style: JType.display(17, onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 28),
              for (final (i, label, route) in _destinations)
                _NavLink(
                  label: label,
                  active: selected == i,
                  dark: dark,
                  onTap: () {
                    if (selected != i) go(context, route, replace: true);
                  },
                ),
              const Spacer(),
              if (state.isAdmin)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _NavLink(
                    label: 'Admin',
                    active: selected == 4,
                    dark: dark,
                    icon: Icons.shield_outlined,
                    onTap: () {
                      if (selected != 4) go(context, '/admin', replace: true);
                    },
                  ),
                ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => go(context, '/notifications'),
                icon: Badge(
                  isLabelVisible: state.unread > 0,
                  smallSize: 6,
                  backgroundColor: JColors.brand,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (state.player != null)
                Tooltip(
                  message: state.player!.name,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      if (selected != 3) go(context, '/profile', replace: true);
                    },
                    child: Avatar(state.player!.name, size: 34),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const _destinations = [
    (0, 'Lobby', '/home'),
    (1, 'Journal', '/history'),
    (2, 'Rankings', '/leaderboard'),
    (3, 'You', '/profile'),
  ];
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.dark,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool active, dark;
  final VoidCallback onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: active,
    button: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? JColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: active
                    ? JColors.brand
                    : (dark ? JColors.onDarkMuted : JColors.muted),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? JColors.brand
                    : (dark ? JColors.surface : JColors.ink),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The touch tab bar: a floating pill whose selected destination carries a
/// sliding indicator, a lifted icon and a label that fades in.
class JuryNavigation extends StatefulWidget {
  const JuryNavigation({super.key, required this.selected});
  final int selected;
  @override
  State<JuryNavigation> createState() => _JuryNavigationState();
}

class _JuryNavigationState extends State<JuryNavigation> {
  static const _destinations = [
    (Icons.chair_alt_outlined, Icons.chair_alt_rounded, 'Lobby', '/home'),
    (
      Icons.auto_stories_outlined,
      Icons.auto_stories_rounded,
      'Journal',
      '/history',
    ),
    (
      Icons.leaderboard_outlined,
      Icons.leaderboard_rounded,
      'Rankings',
      '/leaderboard',
    ),
    (Icons.person_outline_rounded, Icons.person_rounded, 'You', '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : const Duration(milliseconds: 380);
    return Padding(
      // Sits as low as the safe area allows; SafeArea above already clears the
      // home indicator, so only a hairline is kept beneath the capsule.
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
      child: FrostedSurface(
        // A true pill rather than a rounded rectangle.
        radius: 999,
        // Content scrolls beneath the capsule, so it carries a lighter tint and
        // a stronger blur than the small utility surfaces.
        tint: .62,
        blur: 30,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: LayoutBuilder(
            builder: (context, c) {
              final slot = c.maxWidth / _destinations.length;
              return Stack(
                children: [
                  // The indicator slides between destinations rather than
                  // blinking from one to the next.
                  AnimatedPositioned(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    left: slot * widget.selected,
                    top: 0,
                    bottom: 0,
                    width: slot,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: DecoratedBox(
                        // Tinted with the brand rather than the pale secondary,
                        // which all but disappeared against the frosted glass.
                        decoration: BoxDecoration(
                          color: JColors.brand.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: JColors.brand.withValues(alpha: .16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final (i, d) in _destinations.indexed)
                        Expanded(
                          child: _NavDestination(
                            icon: d.$1,
                            activeIcon: d.$2,
                            label: d.$3,
                            active: widget.selected == i,
                            duration: duration,
                            onTap: () {
                              if (widget.selected == i) return;
                              HapticFeedback.selectionClick();
                              go(context, d.$4, replace: true);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.duration,
    required this.onTap,
  });
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: active,
    button: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The chosen icon lifts and fills; the others stay quiet.
            AnimatedSlide(
              duration: duration,
              curve: Curves.easeOutBack,
              offset: active ? const Offset(0, -.06) : Offset.zero,
              child: AnimatedScale(
                duration: duration,
                curve: Curves.easeOutBack,
                scale: active ? 1.12 : 1,
                child: Icon(
                  active ? activeIcon : icon,
                  size: 22,
                  color: active ? JColors.brand : JColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Built from the ambient style: AnimatedDefaultTextStyle replaces
            // rather than merges, so a bare TextStyle here would drop the
            // family and fall back to the platform font.
            AnimatedDefaultTextStyle(
              duration: duration,
              curve: Curves.easeOut,
              style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? JColors.brand : JColors.muted,
              ),
              child: Text(label),
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
