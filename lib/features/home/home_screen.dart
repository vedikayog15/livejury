import 'package:flutter/material.dart';

import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/app_controls.dart';
import '../../core/widgets/app_frame.dart';
import '../../core/widgets/live_jury_widgets.dart';
import '../matchmaking/matchmaking_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenProfile});

  final VoidCallback? onOpenProfile;

  void _start(BuildContext context, {bool private = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppFrame(
          child: private
              ? const PrivateRoomScreen()
              : const MatchmakingScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const Key('home-scroll-view'),
          padding: EdgeInsets.zero,
          children: [
            AdaptiveScreenPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(
                    onNotifications: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AppFrame(child: NotificationsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryJuryPanel(onJoin: () => _start(context)),
                  const SizedBox(height: AppSpacing.sm),
                  HomeQuickActions(
                    onCreateRoom: () => _start(context, private: true),
                    onJoinByCode: () => _showJoinDialog(context),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  const AppSectionHeader(title: 'Tonight’s case'),
                  const SizedBox(height: AppSpacing.sm),
                  const FeaturedCaseCard(),
                  const SizedBox(height: AppSpacing.section),
                  AppSectionHeader(
                    title: 'Your standing',
                    actionLabel: onOpenProfile == null ? null : 'View profile',
                    onAction: onOpenProfile,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const JurorStandingCard(score: 82),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      builder: (sheetContext) => _JoinRoomSheet(
        onJoin: () {
          Navigator.pop(sheetContext);
          _start(context, private: true);
        },
      ),
    );
  }
}

class _JoinRoomSheet extends StatefulWidget {
  const _JoinRoomSheet({required this.onJoin});

  final VoidCallback onJoin;

  @override
  State<_JoinRoomSheet> createState() => _JoinRoomSheetState();
}

class _JoinRoomSheetState extends State<_JoinRoomSheet> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Join a private jury',
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter the six-character room code shared by the host.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(
              letterSpacing: 8,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              labelText: 'Room code',
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: widget.onJoin,
            child: const Text('Join room'),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          label: 'Vaibhav profile avatar',
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.outline),
            ),
            child: const Text(
              'VK',
              style: TextStyle(
                fontFamily: 'SourceSerif4',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good evening',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Vaibhav',
                style: AppTypography.editorialTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
        AppIconAction(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          showBadgeDot: true,
          onPressed: onNotifications,
        ),
      ],
    );
  }
}
