import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_jury_room/app/jury_app.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/models/models.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';

void main() {
  late JuryController state;
  setUp(() {
    state = JuryController(
      demoRepository: DemoRepository(latency: Duration.zero),
      simulationInterval: const Duration(milliseconds: 10),
    );
  });
  tearDown(() => state.dispose());
  Future<void> launch(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: Size(width, 844),
          textScaler: TextScaler.linear(scale),
        ),
        child: JuryApp(controller: state),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final f = find.text(text).last;
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'after tapping $text');
  }

  // Demo mode has no button in the app any more; tests enter it directly so
  // every game screen can still run offline.
  Future<void> enterDemo(WidgetTester tester) async {
    final signedIn = state.signIn(demo: true);
    await tester.pumpAndSettle();
    expect(await signedIn, isTrue);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamedAndRemoveUntil('/home', (_) => false);
    await tester.pumpAndSettle();
  }

  Future<void> fillRoom(WidgetTester tester) async {
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
    'complete user journey: invitation, evidence, discussion, final reason, verdict and journal',
    (tester) async {
      await launch(tester);
      await enterDemo(tester);
      expect(find.text('Find my jury'), findsOneWidget);
      await tester.ensureVisible(find.text('Find my jury'));
      await tester.tap(find.text('Find my jury'));
      await tester.pump();
      await fillRoom(tester);
      expect(state.room!.jurors.length, 6);
      expect(find.text('6 jurors seated'), findsOneWidget);
      await tapText(tester, 'Open the case file');
      await tapText(tester, 'Examine the evidence');
      final firstButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Make my first call'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(firstButton.onPressed, isNull);
      for (final e in state.currentCase.evidence) {
        await tapText(tester, e.title);
        await tapText(tester, 'Mark as reviewed');
      }
      expect(state.room!.reviewed.length, 4);
      await tapText(tester, 'Make my first call');
      await tester.ensureVisible(find.byKey(const Key('vote-notResponsible')));
      await tester.tap(find.byKey(const Key('vote-notResponsible')));
      await tester.pumpAndSettle();
      await tapText(tester, 'Seal my first impression');
      expect(state.room!.stage, RoundStage.deliberation);
      await tester.tap(find.byTooltip('Attach evidence'));
      await tester.pumpAndSettle();
      await tapText(tester, 'E1 · The access log');
      await tester.enterText(
        find.byKey(const Key('chat-input')),
        'The key log establishes access, but cannot identify who used the shared key.',
      );
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(state.room!.messages.last.exhibitId, 'E1');
      await tapText(tester, 'Move to final vote');
      await tapText(tester, 'Open voting');
      await tester.ensureVisible(find.byKey(const Key('vote-notResponsible')));
      await tester.tap(find.byKey(const Key('vote-notResponsible')));
      await tester.pumpAndSettle();
      await tapText(tester, 'Seal my final verdict');
      expect(
        find.text('Add at least 20 characters of reasoning.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('final-reason')),
        'The access log does not identify Alex, and the witness did not see the face or the covered object. Reasonable doubt remains.',
      );
      await tapText(tester, 'Seal my final verdict');
      expect(state.room!.stage, RoundStage.complete);
      expect(find.text('Not guilty'), findsWidgets);
      expect(state.player!.points, 120);
      await tapText(tester, 'Return to the lobby');
      await tapText(tester, 'Journal');
      expect(find.text('The Glass Hour'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'join-code errors are actionable, demo room joins and can be cancelled',
    (tester) async {
      await launch(tester);
      await enterDemo(tester);
      await tapText(tester, 'Join with code');
      await tapText(tester, 'Find my seat');
      expect(find.text('Enter all six characters.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('room-code')), 'BAD123');
      await tapText(tester, 'Find my seat');
      expect(
        find.textContaining('That demo room was not found'),
        findsOneWidget,
      );
      await tester.enterText(find.byKey(const Key('room-code')), 'JURY06');
      await tester.tap(find.text('Find my seat'));
      await tester.pump();
      await fillRoom(tester);
      expect(state.room!.isPrivate, isTrue);
      await tapText(tester, 'Leave room');
      await tapText(tester, 'Leave room');
      expect(state.room, isNull);
      expect(find.text('Find my jury'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'private case selection, profile updates, notification read state and empty journal',
    (tester) async {
      await launch(tester);
      await enterDemo(tester);
      await tapText(tester, 'Journal');
      expect(find.text('Your first chapter awaits.'), findsOneWidget);
      await tapText(tester, 'You');
      await tester.tap(find.byTooltip('Edit profile'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Jordan Wells');
      await tapText(tester, 'Save preferences');
      expect(state.player!.name, 'Jordan Wells');
      await tapText(tester, 'Lobby');
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mark all as read'));
      await tester.pumpAndSettle();
      expect(state.unread, 0);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Private room');
      await tapText(tester, 'The Last Light');
      await tester.tap(find.text('Create private room'));
      await tester.pump();
      await fillRoom(tester);
      expect(state.room!.caseId, 'last-light');
      expect(state.room!.isPrivate, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [320.0, 390.0, 560.0]) {
    testWidgets('core layouts fit ${width.toInt()}dp without overflow', (
      tester,
    ) async {
      await launch(tester, width: width);
      expect(tester.takeException(), isNull);
      await enterDemo(tester);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tapText(tester, 'You');
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Rankings');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('cloud unavailable state and authentication validation work', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Take your seat');
    await tapText(tester, 'Sign in');
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.textContaining('Accounts are unavailable'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('deleting a demo account erases it and returns to the start', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    state.dispose();
    state = JuryController(
      demoRepository: DemoRepository(
        preferences: preferences,
        latency: Duration.zero,
      ),
    );
    await launch(tester);
    await enterDemo(tester);
    await tapText(tester, 'You');
    await tapText(tester, 'Delete account');
    await tapText(tester, 'Keep my seat');
    expect(state.signedIn, isTrue);
    await tapText(tester, 'Delete account');
    await tapText(tester, 'Delete permanently');
    expect(state.signedIn, isFalse);
    expect(preferences.getString(DemoRepository.storageKey), isNull);
    expect(find.text('Take your seat'), findsOneWidget);
  });
}
