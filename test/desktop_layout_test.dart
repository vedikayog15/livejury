import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/app/jury_app.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/models/models.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';
import 'package:live_jury_room/design/widgets/jury_widgets.dart';

/// Laptop and desktop windows. Guards the adaptive shell: a wide window shows
/// the side rail instead of the bottom tab bar, and no layout overflows.
Future<JuryController> _seed() async {
  final repo = DemoRepository(latency: Duration.zero);
  final state = JuryController(
    demoRepository: repo,
    simulationInterval: const Duration(days: 1),
  );
  await state.signIn(demo: true);
  await state.openRoom(state.cases.first);
  for (var i = 0; i < 5; i++) {
    await repo.addSimulatedJuror(state.room!.id);
  }
  await state.startCase();
  return state;
}

void main() {
  for (final (width, height) in [
    (1024.0, 768.0),
    (1280.0, 800.0),
    (1600.0, 900.0),
  ]) {
    testWidgets('desktop layouts at ${width.toInt()}x${height.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, height);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      late JuryController state;
      await tester.runAsync(() async => state = await _seed());
      await tester.pumpWidget(JuryApp(controller: state));
      await tester.pumpAndSettle();

      Future<void> visit(String route, {Object? arguments}) async {
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushNamedAndRemoveUntil(route, (_) => false, arguments: arguments);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route at $width');
        final scroll = find.byType(SingleChildScrollView);
        if (scroll.evaluate().isNotEmpty) {
          await tester.drag(scroll.first, const Offset(0, -1500));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$route scrolled at $width',
          );
        }
      }

      // Tabbed destinations use the rail; the touch tab bar must not appear.
      for (final route in ['/home', '/history', '/leaderboard', '/profile']) {
        await visit(route);
        expect(
          find.byType(JurySideNav),
          findsOneWidget,
          reason: '$route should show the side rail at $width',
        );
        expect(
          find.byType(JuryNavigation),
          findsNothing,
          reason: '$route should not show the bottom tab bar at $width',
        );
      }

      // Screens without a tab keep a single column and no rail.
      for (final route in [
        '/room',
        '/case',
        '/evidence',
        '/initial-vote',
        '/matchmaking',
        '/notifications',
        '/profile-edit',
        '/auth',
      ]) {
        await visit(route);
      }
      await visit('/exhibit', arguments: state.currentCase.evidence.last);

      await tester.runAsync(() async {
        for (final e in state.currentCase.evidence) {
          await state.markReviewed(e);
        }
        await state.castVote(Decision.notResponsible);
      });
      await visit('/discussion');
      await tester.runAsync(() => state.beginFinal());
      await visit('/vote');
      await tester.runAsync(
        () => state.castVote(
          Decision.notResponsible,
          finalVote: true,
          reason:
              'The access record identifies a key and cannot identify the person '
              'who carried it, and the witness account is uncertain.',
        ),
      );
      await visit('/result');
      await visit('/history');

      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }

  testWidgets('narrow windows keep the bottom tab bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late JuryController state;
    await tester.runAsync(() async => state = await _seed());
    await tester.pumpWidget(JuryApp(controller: state));
    await tester.pumpAndSettle();

    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamedAndRemoveUntil('/home', (_) => false);
    await tester.pumpAndSettle();

    expect(find.byType(JuryNavigation), findsOneWidget);
    expect(find.byType(JurySideNav), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
