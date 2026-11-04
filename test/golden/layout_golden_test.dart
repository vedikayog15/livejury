@Tags(['golden'])
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/app/jury_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:live_jury_room/core/data/admin_repository.dart';
import 'package:live_jury_room/core/data/demo_cases.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/models/models.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';
import 'package:live_jury_room/features/admin/case_editor_screen.dart';

/// Renders every screen at phone and laptop sizes and writes PNGs with
/// `flutter test --tags golden --run-skipped --update-goldens`, so the adaptive
/// layout can be reviewed as images. Excluded from the default run because
/// golden output depends on the host's font rasterisation.

/// Icons live in the SDK rather than the project, so the golden renderer needs
/// them loaded explicitly or every icon draws as a placeholder box.
String? _materialIconsPath() {
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final path =
      '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  return File(path).existsSync() ? path : null;
}

Future<void> _loadFonts() async {
  final icons = _materialIconsPath();
  for (final (family, path) in [
    ('DM Sans', 'assets/fonts/DMSans-Variable.ttf'),
    ('Fraunces', 'assets/fonts/Fraunces-Variable.ttf'),
    if (icons != null) ('MaterialIcons', icons),
  ]) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final loader = FontLoader(family)
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await loader.load();
  }
}

/// How far through a round the controller should be before rendering.
enum Seed { signedOut, lobby, seated, reviewed, finished, admin }

/// Stands in for a signed-in cloud account so the admin area can be rendered.
class _CloudLikeRepository extends DemoRepository {
  _CloudLikeRepository() : super(latency: Duration.zero);
  @override
  bool get isDemo => false;
}

/// Canned admin data, so the dashboard renders populated rather than as an
/// error. The client is never used: every call is overridden.
class _FakeAdminRepository extends AdminRepository {
  _FakeAdminRepository()
    : super(SupabaseClient('https://example.supabase.co', 'public-anon-key'));

  @override
  Future<AdminOverview> overview() async => AdminOverview.fromJson({
    'jurors': 7,
    'admins': 1,
    'suspended': 0,
    'cases': 3,
    'rooms_open': 1,
    'rooms_complete': 1,
    'ballots': 12,
    'messages': 6,
    'reports': 0,
  });

  @override
  Future<List<AdminProfile>> profiles() async => [
    const AdminProfile(
      id: 'a',
      email: 'vaibhav.katendra@athenaeducation.co.in',
      name: 'Vaibhav Katendra',
      points: 0,
      isAdmin: true,
      suspended: false,
      cases: 0,
    ),
    const AdminProfile(
      id: 'b',
      email: 'juror1@livejury.test',
      name: 'Ada Whitlock',
      points: 120,
      isAdmin: false,
      suspended: false,
      cases: 1,
    ),
    const AdminProfile(
      id: 'c',
      email: 'juror2@livejury.test',
      name: 'Ben Okafor',
      points: 120,
      isAdmin: false,
      suspended: true,
      cases: 1,
    ),
  ];

  @override
  Future<List<AdminCase>> cases() async => [
    for (final (i, f) in demoCases.indexed)
      AdminCase(file: f, rounds: i == 0 ? 1 : 0),
  ];
}

Future<JuryController> _seed(Seed stage) async {
  final repo = stage == Seed.admin
      ? _CloudLikeRepository()
      : DemoRepository(latency: Duration.zero);
  final state = JuryController(
    demoRepository: repo,
    adminRepository: stage == Seed.admin ? _FakeAdminRepository() : null,
    simulationInterval: const Duration(days: 1),
  );
  if (stage == Seed.signedOut) return state;
  if (stage == Seed.admin) {
    await state.signIn(demo: true);
    state.player = PlayerData(
      id: state.player!.id,
      name: 'Vaibhav Katendra',
      isAdmin: true,
    );
    return state;
  }

  await state.signIn(demo: true);
  if (stage == Seed.lobby) return state;

  await state.openRoom(state.cases.first);
  for (var i = 0; i < 5; i++) {
    await repo.addSimulatedJuror(state.room!.id);
  }
  if (stage == Seed.seated) return state;

  await state.startCase();
  for (final e in state.currentCase.evidence) {
    await state.markReviewed(e);
  }
  if (stage == Seed.reviewed) return state;

  await state.castVote(Decision.notResponsible);
  await state.beginFinal();
  await state.castVote(
    Decision.notResponsible,
    finalVote: true,
    reason:
        'The access record identifies a key and cannot identify the person who '
        'carried it, and the witness account is uncertain at that distance.',
  );
  return state;
}

void main() {
  setUpAll(_loadFonts);

  Future<void> shoot(
    WidgetTester tester, {
    required String name,
    required Size size,
    required Seed stage,
    String? route,
    Object? Function(JuryController state)? argumentsFrom,
    double dpr = 1,
  }) async {
    tester.view.physicalSize = size * dpr;
    tester.view.devicePixelRatio = dpr;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    // flutter_test flattens every shadow to a hard offset copy by default. The
    // design relies on soft, layered shadows for depth, so render them for
    // real, and restore the flag before the test's invariant check.
    debugDisableShadows = false;
    late JuryController state;
    await tester.runAsync(() async => state = await _seed(stage));
    await tester.pumpWidget(JuryApp(controller: state));
    await tester.pumpAndSettle();

    if (route != null) {
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamedAndRemoveUntil(
            route,
            (_) => false,
            arguments: argumentsFrom?.call(state),
          );
      await tester.pumpAndSettle();
    }

    await expectLater(
      find.byType(JuryApp),
      matchesGoldenFile('images/$name.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    debugDisableShadows = true;
  }

  const laptop = Size(1440, 900);
  const phone = Size(390, 844);

  // Every screen at laptop width.
  final screens = <(String, Seed, String?)>[
    ('invitation', Seed.signedOut, null),
    ('auth', Seed.signedOut, '/auth'),
    ('lobby', Seed.lobby, '/home'),
    ('history', Seed.lobby, '/history'),
    ('leaderboard', Seed.lobby, '/leaderboard'),
    ('profile', Seed.lobby, '/profile'),
    ('profile_edit', Seed.lobby, '/profile-edit'),
    ('notifications', Seed.lobby, '/notifications'),
    ('matchmaking', Seed.lobby, '/matchmaking'),
    ('room', Seed.seated, '/room'),
    ('case', Seed.reviewed, '/case'),
    ('evidence', Seed.reviewed, '/evidence'),
    ('vote', Seed.reviewed, '/initial-vote'),
    ('discussion', Seed.reviewed, '/discussion'),
    ('result', Seed.finished, '/result'),
    ('admin', Seed.admin, '/admin'),
    ('journal', Seed.finished, '/history'),
  ];

  for (final (name, stage, route) in screens) {
    testWidgets('$name at laptop', (tester) async {
      await shoot(
        tester,
        name: '${name}_laptop',
        size: laptop,
        stage: stage,
        route: route,
      );
    });
  }

  // The case editor is pushed directly rather than by name.
  for (final (label, size) in [('laptop', laptop), ('phone', phone)]) {
    testWidgets('case editor at $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      debugDisableShadows = false;
      late JuryController state;
      await tester.runAsync(() async => state = await _seed(Seed.admin));
      await tester.pumpWidget(JuryApp(controller: state));
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => CaseEditorScreen(existing: demoCases.first),
            ),
          );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(JuryApp),
        matchesGoldenFile('images/case_editor_$label.png'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
      debugDisableShadows = true;
    });
  }

  // Routes that need an argument, so they cannot go in the table above.
  testWidgets('exhibit at laptop', (tester) async {
    await shoot(
      tester,
      name: 'exhibit_laptop',
      size: laptop,
      stage: Seed.reviewed,
      route: '/exhibit',
      argumentsFrom: (state) => state.currentCase.evidence.first,
    );
  });

  testWidgets('history detail at laptop', (tester) async {
    await shoot(
      tester,
      name: 'history_detail_laptop',
      size: laptop,
      stage: Seed.finished,
      route: '/history-detail',
      argumentsFrom: (state) => state.player!.history.first,
    );
  });

  // Spot-check that the touch layout is unchanged.
  for (final (name, stage, route) in [
    ('invitation', Seed.signedOut, null),
    ('lobby', Seed.lobby, '/home'),
    ('room', Seed.seated, '/room'),
    ('admin', Seed.admin, '/admin'),
  ]) {
    testWidgets('$name at phone', (tester) async {
      await shoot(
        tester,
        name: '${name}_phone',
        size: phone,
        stage: stage,
        route: route,
        // Rendered at 2x so small labels stay legible when reviewing.
        dpr: 2,
      );
    });
  }
}
