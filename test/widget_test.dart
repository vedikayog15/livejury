import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livejury/app/live_jury_app.dart';
import 'package:livejury/core/widgets/app_frame.dart';
import 'package:livejury/features/jury/jury_experience.dart';
import 'package:livejury/features/matchmaking/matchmaking_screen.dart';
import 'package:livejury/features/navigation/main_shell.dart';

void main() {
  testWidgets('onboarding enters the Live Jury home', (tester) async {
    await tester.pumpWidget(const LiveJuryApp());
    expect(find.text('Examine the evidence'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back.'), findsOneWidget);
    await tester.tap(find.text('Continue with demo profile'));
    await tester.pumpAndSettle();
    expect(find.text('Find my jury'), findsOneWidget);
    expect(find.text('Vaibhav'), findsOneWidget);
  });

  testWidgets('public matchmaking reaches the jury room', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppFrame(child: MatchmakingScreen())),
    );
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('SIMULATE JUROR JOINING'));
      await tester.pump();
    }
    expect(find.text('6 of 6 jurors ready'), findsOneWidget);
    await tester.tap(find.text('ENTER THE JURY ROOM'));
    await tester.pumpAndSettle();
    expect(find.text('The Midnight Gallery'), findsOneWidget);
  });

  testWidgets('bottom navigation opens history', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppFrame(child: MainShell())),
    );
    await tester.tap(find.text('Casebook'));
    await tester.pump();
    expect(find.text('Your casebook'), findsOneWidget);
  });

  testWidgets('juror can review evidence and enter deliberation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AppFrame(child: JuryExperience())),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EXAMINE THE CASE'));
    await tester.pumpAndSettle();
    expect(find.text('Review the evidence'), findsOneWidget);

    await tester.tap(find.text('I’M READY TO VOTE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NOT GUILTY'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('SUBMIT PRIVATE VOTE'), 260);
    await tester.tap(find.text('SUBMIT PRIVATE VOTE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIRM'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('5 of 6 jurors voted'), findsOneWidget);

    await tester.tap(find.text('SIMULATE FINAL VOTE'));
    await tester.pumpAndSettle();
    expect(find.text('Jury deliberation'), findsOneWidget);
  });
}
