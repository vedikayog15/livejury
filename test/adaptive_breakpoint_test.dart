import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/app/jury_app.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';
import 'package:live_jury_room/design/widgets/jury_widgets.dart';

/// Which layout each real device size resolves to. The app and a mobile browser
/// both report the viewport in logical pixels, and `web/index.html` sets
/// `width=device-width`, so a phone reports its narrow width either way and
/// these cases cover both.
Future<JuryController> _seed() async {
  final state = JuryController(
    demoRepository: DemoRepository(latency: Duration.zero),
    simulationInterval: const Duration(days: 1),
  );
  await state.signIn(demo: true);
  return state;
}

void main() {
  Future<void> expectLayout(
    WidgetTester tester, {
    required Size size,
    required bool desktop,
    required String device,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    late JuryController state;
    await tester.runAsync(() async => state = await _seed());
    await tester.pumpWidget(JuryApp(controller: state));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamedAndRemoveUntil('/home', (_) => false);
    await tester.pumpAndSettle();

    expect(
      find.byType(JurySideNav),
      desktop ? findsOneWidget : findsNothing,
      reason: '$device (${size.width}x${size.height}) side rail',
    );
    expect(
      find.byType(JuryNavigation),
      desktop ? findsNothing : findsOneWidget,
      reason: '$device (${size.width}x${size.height}) bottom tab bar',
    );
    expect(tester.takeException(), isNull, reason: device);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  }

  // Phones and small tablets keep the touch layout, portrait and landscape.
  for (final (device, size) in [
    ('Galaxy S21 portrait', Size(360, 800)),
    ('iPhone SE portrait', Size(375, 667)),
    ('iPhone 14 portrait', Size(390, 844)),
    ('Pixel 7 portrait', Size(412, 915)),
    ('iPhone 14 Pro Max portrait', Size(430, 932)),
    ('iPhone 14 landscape', Size(844, 390)),
    // Wider than the 900 width test but far too short for a rail.
    ('iPhone 14 Pro Max landscape', Size(932, 430)),
    ('iPad mini portrait', Size(744, 1133)),
    ('iPad Pro 11 portrait', Size(834, 1194)),
  ]) {
    testWidgets('$device uses the touch layout', (tester) async {
      await expectLayout(tester, size: size, desktop: false, device: device);
    });
  }

  // Laptops, desktops and landscape tablets get the desktop layout.
  for (final (device, size) in [
    ('iPad Pro 11 landscape', Size(1194, 834)),
    ('small laptop', Size(1024, 768)),
    ('MacBook Air', Size(1440, 900)),
    ('large desktop', Size(1920, 1080)),
    // A deliberately narrowed browser window on a desktop.
    ('narrow browser window', Size(1000, 700)),
  ]) {
    testWidgets('$device uses the desktop layout', (tester) async {
      await expectLayout(tester, size: size, desktop: true, device: device);
    });
  }
}
