// Run with: flutter test tool/render_previews.dart
// These are review artifacts, not golden baselines.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/app/jury_app.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';
import 'package:live_jury_room/core/models/models.dart';

void main() {
  testWidgets('render original Flutter screens for visual review', (
    tester,
  ) async {
    for (final family in ['Inter', 'Outfit']) {
      final loader = FontLoader(family);
      for (final weight in [400, 500, 600, 700, 800]) {
        loader.addFont(rootBundle.load('assets/fonts/$family-$weight.ttf'));
      }
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    debugDisableShadows = false;
    final repo = DemoRepository(latency: Duration.zero);
    final state = JuryController(
      demoRepository: repo,
      simulationInterval: const Duration(days: 1),
    );
    final boundary = GlobalKey();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: JuryApp(controller: state),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final img = await render.toImage(pixelRatio: 1);
        final data = await img.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts/previews').create(recursive: true);
        await File(
          'artifacts/previews/$name.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        img.dispose();
      });
      debugPrint('Rendered $name');
    }

    Future<void> route(String route, {Object? arguments}) async {
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamedAndRemoveUntil(route, (_) => false, arguments: arguments);
      await tester.pumpAndSettle();
    }

    await capture('01-invitation-390');
    await tester.runAsync(() => state.signIn(demo: true));
    await route('/home');
    await capture('02-lobby-390');
    await tester.runAsync(() => state.openRoom(state.cases.first));
    for (var i = 0; i < 5; i++) {
      await repo.addSimulatedJuror(state.room!.id);
    }
    await route('/room');
    await capture('03-room-390');
    await state.startCase();
    await route('/case');
    await capture('04-case-390');
    await route('/evidence');
    await capture('05-evidence-390');
    await route('/exhibit', arguments: state.currentCase.evidence[2]);
    await capture('06-exhibit-390');
    for (final e in state.currentCase.evidence) {
      await state.markReviewed(e);
    }
    await tester.runAsync(() => state.castVote(Decision.notResponsible));
    await route('/discussion');
    await capture('07-discussion-390');
    await state.beginFinal();
    await route('/vote');
    await capture('08-vote-390');
    await tester.runAsync(
      () => state.castVote(
        Decision.notResponsible,
        finalVote: true,
        reason:
            'The access log records the key rather than its holder. The witness could not identify the face or the object. A plausible alternative remains.',
      ),
    );
    await route('/result');
    await capture('09-result-390');
    await route('/profile');
    await capture('10-profile-390');
    for (final width in [320.0, 560.0]) {
      tester.view.physicalSize = Size(width, 844);
      await route('/home');
      await capture('lobby-${width.toInt()}');
    }
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
