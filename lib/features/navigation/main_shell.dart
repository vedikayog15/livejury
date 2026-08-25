import 'package:flutter/material.dart';
import '../../core/theme/live_jury_theme.dart';
import '../../core/widgets/app_frame.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(onOpenProfile: () => setState(() => index = 3)),
      const HistoryScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      child: Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.outline)),
          ),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_rounded),
                label: 'Casebook',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_rounded),
                label: 'Standings',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
