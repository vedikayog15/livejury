import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/app/jury_app.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/models/models.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';

void main() {
  for (final (width, scale) in [
    (320.0, 1.0),
    (390.0, 1.0),
    (560.0, 1.0),
    (320.0, 1.6),
  ]) {
    testWidgets('all feature layouts ${width.toInt()}dp at ${scale}x text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final repo = DemoRepository(latency: Duration.zero);
      final state = JuryController(
        demoRepository: repo,
        simulationInterval: const Duration(days: 1),
      );
      await tester.runAsync(() async {
        await state.signIn(demo: true);
        await state.openRoom(state.cases.first);
        for (var i = 0; i < 5; i++) {
          await repo.addSimulatedJuror(state.room!.id);
        }
        await state.startCase();
      });
      await tester.pumpWidget(JuryApp(controller: state));
      await tester.pumpAndSettle();
      Future<void> visit(String route, {Object? arguments}) async {
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushNamedAndRemoveUntil(route, (_) => false, arguments: arguments);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$route top at $width/$scale',
        );
        final scroll = find.byType(SingleChildScrollView);
        if (scroll.evaluate().isNotEmpty) {
          await tester.drag(scroll.first, const Offset(0, -1500));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$route bottom at $width/$scale',
          );
        }
      }

      for (final route in [
        '/room',
        '/case',
        '/evidence',
        '/initial-vote',
        '/matchmaking',
        '/history',
        '/profile',
        '/profile-edit',
        '/notifications',
        '/leaderboard',
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
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'discussion keyboard at $width/$scale',
      );
      tester.view.resetViewInsets();
      await tester.runAsync(() => state.beginFinal());
      await visit('/vote');
      await tester.runAsync(
        () => state.castVote(
          Decision.notResponsible,
          finalVote: true,
          reason:
              'The access record identifies a key and cannot identify the person using it. The witness has uncertainty.',
        ),
      );
      await visit('/result');
      await visit('/history');
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }
}
