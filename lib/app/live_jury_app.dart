import 'package:flutter/material.dart';
import '../core/theme/live_jury_theme.dart';
import '../features/auth/auth_screen.dart';
import '../features/navigation/main_shell.dart';
import '../features/onboarding/welcome_screen.dart';

class LiveJuryApp extends StatefulWidget {
  const LiveJuryApp({super.key});

  @override
  State<LiveJuryApp> createState() => _LiveJuryAppState();
}

class _LiveJuryAppState extends State<LiveJuryApp> {
  bool _introComplete = false;
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Jury',
      themeMode: ThemeMode.dark,
      theme: LiveJuryTheme.dark(),
      darkTheme: LiveJuryTheme.dark(),
      home: !_introComplete
          ? WelcomeScreen(onEnter: () => setState(() => _introComplete = true))
          : _signedIn
          ? const MainShell()
          : AuthScreen(onAuthenticated: () => setState(() => _signedIn = true)),
    );
  }
}
