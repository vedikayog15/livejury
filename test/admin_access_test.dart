import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/app/jury_app.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/models/models.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';
import 'package:live_jury_room/design/widgets/jury_widgets.dart';

/// The client half of the admin gate. The database re-checks admin status on
/// every call, so these assertions are about what the app offers, not about
/// what it is able to do — a tampered client still gets refused server-side.
/// Stands in for a signed-in cloud account: same local data, but not demo, so
/// the admin flag is honoured the way it is against Supabase.
class _CloudLikeRepository extends DemoRepository {
  _CloudLikeRepository() : super(latency: Duration.zero);
  @override
  bool get isDemo => false;
}

void main() {
  Future<JuryController> adminUser() async {
    final state = JuryController(
      demoRepository: _CloudLikeRepository(),
      simulationInterval: const Duration(days: 1),
    );
    await state.signIn(demo: true);
    state.player = PlayerData(
      id: state.player!.id,
      name: 'Vaibhav Katendra',
      isAdmin: true,
    );
    return state;
  }

  Future<void> pumpAt(WidgetTester tester, Size size, JuryController s) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(JuryApp(controller: s));
    await tester.pumpAndSettle();
  }

  // The admin area must be reachable on both layouts. It was once only in the
  // desktop bar, which left no way in on a phone.
  testWidgets('an admin reaches the dashboard from the desktop bar', (
    tester,
  ) async {
    late JuryController state;
    await tester.runAsync(() async => state = await adminUser());
    await pumpAt(tester, const Size(1440, 900), state);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamedAndRemoveUntil('/home', (_) => false);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(JuryTopNav, 'Admin'), findsOneWidget);
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    expect(find.text('Administration'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('an admin reaches the dashboard from the profile on a phone', (
    tester,
  ) async {
    late JuryController state;
    await tester.runAsync(() async => state = await adminUser());
    await pumpAt(tester, const Size(390, 844), state);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamedAndRemoveUntil('/profile', (_) => false);
    await tester.pumpAndSettle();

    expect(find.text('Administration'), findsOneWidget);
    // The settings list sits below the fold on a phone.
    await tester.ensureVisible(find.text('Administration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Administration'));
    await tester.pumpAndSettle();
    // Reached the page, and it offers a way back rather than stranding you.
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  Future<JuryController> demoUser() async {
    final state = JuryController(
      demoRepository: DemoRepository(latency: Duration.zero),
      simulationInterval: const Duration(days: 1),
    );
    await state.signIn(demo: true);
    return state;
  }

  test('a demo player is never an admin', () async {
    final state = await demoUser();
    expect(state.isDemo, isTrue);
    expect(state.isAdmin, isFalse);
    expect(state.admin, isNull, reason: 'no admin repository in demo mode');
    state.dispose();
  });

  test('an is_admin payload alone does not grant admin in demo mode', () async {
    final state = await demoUser();
    // Even if a profile claims the flag, demo mode has no server to honour it.
    state.player = PlayerData(
      id: state.player!.id,
      name: state.player!.name,
      isAdmin: true,
    );
    expect(state.isAdmin, isFalse);
    expect(state.admin, isNull);
    state.dispose();
  });

  test('adminAction refuses without an admin repository', () async {
    final state = await demoUser();
    final ok = await state.adminAction((a) async {
      fail('the action must not run');
    });
    expect(ok, isFalse);
    expect(state.error, contains('Administrator'));
    state.dispose();
  });

  testWidgets('the admin route shows a refusal to a non-admin', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late JuryController state;
    await tester.runAsync(() async => state = await demoUser());
    await tester.pumpWidget(JuryApp(controller: state));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamedAndRemoveUntil('/admin', (_) => false);
    await tester.pumpAndSettle();

    expect(find.text('Not your door.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('the top nav hides the admin link from a non-admin', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late JuryController state;
    await tester.runAsync(() async => state = await demoUser());
    await tester.pumpWidget(JuryApp(controller: state));
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamedAndRemoveUntil('/home', (_) => false);
    await tester.pumpAndSettle();

    expect(find.byType(JuryTopNav), findsOneWidget);
    expect(find.text('Admin'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
