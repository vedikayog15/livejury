import 'package:flutter/material.dart';

import '../../core/widgets/app_frame.dart';
import '../history/history_screen.dart';
import '../jury_room/screens/deliberation_room_screen.dart';
import '../jury_room/screens/evidence_locker_screen.dart';
import '../jury_room/screens/final_verdict_screen.dart';
import '../jury_room/screens/jury_lobby_screen.dart';
import '../jury_room/widgets/jury_room_components.dart';
import '../matchmaking/matchmaking_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      JuryLobbyScreen(
        onFindJury: () => _push(const MatchmakingScreen()),
        onCreateRoom: () => _push(const PrivateRoomScreen()),
        onNotifications: _openNotifications,
        onProfile: _openProfile,
      ),
      EvidenceLockerScreen(
        onNotifications: _openNotifications,
        onProfile: _openProfile,
      ),
      DeliberationRoomScreen(
        onNotifications: _openNotifications,
        onProfile: _openProfile,
        onOpenEvidence: () => setState(() => _index = 1),
        onVerdictSubmitted: () => setState(() => _index = 3),
      ),
      FinalVerdictScreen(
        onNotifications: _openNotifications,
        onProfile: _openProfile,
        onOpenCasebook: () => _push(const HistoryScreen()),
      ),
    ];

    return AppFrame(
      child: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: JuryRoomBottomDock(
          index: _index,
          onChanged: (value) => setState(() => _index = value),
        ),
      ),
    );
  }

  void _openNotifications() => _push(const NotificationsScreen());

  void _openProfile() => _push(const ProfileScreen());

  void _push(Widget screen) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AppFrame(child: screen)));
  }
}
