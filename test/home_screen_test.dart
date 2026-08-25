import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livejury/core/theme/live_jury_theme.dart';
import 'package:livejury/core/widgets/app_frame.dart';
import 'package:livejury/features/home/home_screen.dart';
import 'package:livejury/features/navigation/main_shell.dart';

void main() {
  Widget homeHarness({Widget child = const HomeScreen()}) {
    return MaterialApp(
      theme: LiveJuryTheme.dark(),
      darkTheme: LiveJuryTheme.dark(),
      themeMode: ThemeMode.dark,
      home: AppFrame(child: child),
    );
  }

  testWidgets('home preserves public and private jury entry points', (
    tester,
  ) async {
    await tester.pumpWidget(homeHarness());

    await tester.tap(find.text('Find my jury'));
    await tester.pumpAndSettle();
    expect(find.text('Finding your jury'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('home-scroll-view')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create room'));
    await tester.pumpAndSettle();
    expect(find.text('Private jury'), findsOneWidget);
  });

  testWidgets('home opens code entry and notifications', (tester) async {
    await tester.pumpWidget(homeHarness());

    await tester.drag(
      find.byKey(const Key('home-scroll-view')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Join by code'));
    await tester.pumpAndSettle();
    expect(find.text('Join a private jury'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('home-scroll-view')),
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('view profile changes the selected shell destination', (
    tester,
  ) async {
    await tester.pumpWidget(homeHarness(child: const MainShell()));

    await tester.drag(
      find.byKey(const Key('home-scroll-view')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();
    expect(find.text('Considered Juror • Level 7'), findsOneWidget);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(390, 844),
    const Size(560, 900),
  ]) {
    testWidgets('home lays out without overflow at ${size.width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(homeHarness());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byKey(const Key('home-scroll-view')),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
      expect(find.text('The Last Message'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
