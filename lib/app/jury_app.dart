import 'package:flutter/material.dart';
import '../core/models/models.dart';
import '../core/state/jury_controller.dart';
import '../design/theme/jury_theme.dart';
import '../design/widgets/jury_widgets.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/recovery_screen.dart';
import '../features/home/home_screen.dart';
import '../features/matchmaking/matchmaking_screen.dart';
import '../features/jury_room/room_screen.dart';
import '../features/jury_room/case_screen.dart';
import '../features/evidence/evidence_screen.dart';
import '../features/evidence/exhibit_screen.dart';
import '../features/deliberation/deliberation_screen.dart';
import '../features/verdict/vote_screen.dart';
import '../features/verdict/result_screen.dart';
import '../features/history/history_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/admin/admin_screen.dart';

class JuryApp extends StatelessWidget {
  const JuryApp({super.key, required this.controller});
  final JuryController controller;
  @override
  Widget build(BuildContext context) => JuryScope(
    controller: controller,
    child: MaterialApp(
      title: 'The Jury Room',
      debugShowCheckedModeBanner: false,
      theme: JuryTheme.light,
      initialRoute: controller.signedIn ? '/home' : '/',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        Widget screen;
        final requiresRoom = {
          '/room',
          '/case',
          '/evidence',
          '/exhibit',
          '/initial-vote',
          '/discussion',
          '/vote',
          '/result',
        };
        if (!controller.signedIn && name != '/' && name != '/auth') {
          screen = const OnboardingScreen();
        } else if (requiresRoom.contains(name) && controller.room == null) {
          screen = const HomeScreen();
        } else {
          screen = switch (name) {
            '/' => const OnboardingScreen(),
            '/auth' => const AuthScreen(),
            '/home' => const HomeScreen(),
            '/matchmaking' => MatchmakingScreen(
              join: settings.arguments == 'join',
            ),
            '/room' => const RoomScreen(),
            '/case' => const CaseScreen(),
            '/case-preview' =>
              settings.arguments is CaseFile
                  ? CaseScreen(preview: settings.arguments! as CaseFile)
                  : const HomeScreen(),
            '/evidence' => const EvidenceScreen(),
            '/exhibit' =>
              settings.arguments is Exhibit
                  ? ExhibitScreen(exhibit: settings.arguments! as Exhibit)
                  : const EvidenceScreen(),
            '/initial-vote' => const VoteScreen(),
            '/discussion' => const DeliberationScreen(),
            '/vote' => const VoteScreen(finalVote: true),
            '/result' => const ResultScreen(),
            '/history' => const HistoryScreen(),
            '/history-detail' =>
              settings.arguments is CaseRecord
                  ? HistoryDetailScreen(
                      record: settings.arguments! as CaseRecord,
                    )
                  : const HistoryScreen(),
            '/profile' => const ProfileScreen(),
            '/profile-edit' => const ProfileEditScreen(),
            '/notifications' => const NotificationsScreen(),
            '/leaderboard' => const LeaderboardScreen(),
            '/admin' => const AdminScreen(),
            _ =>
              controller.signedIn
                  ? const HomeScreen()
                  : const OnboardingScreen(),
          };
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              if (controller.recoveryRequired) return const RecoveryScreen();
              if (!controller.signedIn && name != '/' && name != '/auth') {
                return const OnboardingScreen();
              }
              if (requiresRoom.contains(name)) {
                if (controller.room == null) return const HomeScreen();
                if (controller.room!.stage == RoundStage.cancelled) {
                  return JuryPage(
                    title: 'This room has closed',
                    child: EmptyState(
                      title: 'A seat became empty.',
                      body:
                          'A juror left before the verdict. No result or points were recorded. You can begin again with a new room.',
                      action: PrimaryButton(
                        'Return to the lobby',
                        onPressed: () async {
                          await controller.leave();
                          if (context.mounted) home(context);
                        },
                      ),
                    ),
                  );
                }
              }
              return child!;
            },
            child: screen,
          ),
        );
      },
    ),
  );
}
