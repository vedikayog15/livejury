import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livejury/core/theme/live_jury_theme.dart';
import 'package:livejury/features/navigation/main_shell.dart';

void main() {
  Widget harness({int initialIndex = 0}) {
    return MaterialApp(
      theme: LiveJuryTheme.dark(),
      home: MainShell(initialIndex: initialIndex),
    );
  }

  for (final size in <Size>[
    const Size(320, 568),
    const Size(390, 844),
    const Size(560, 900),
  ]) {
    testWidgets('jury room shell has no initial overflow at ${size.width}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('State v. Davis'), findsOneWidget);
    });
  }

  testWidgets('evidence report updates review progress', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(harness(initialIndex: 1));
    await tester.scrollUntilVisible(find.text('REVIEW PROGRESS'), 300);
    expect(find.text('50%'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('View full PDF'), 260);
    await tester.tap(find.text('View full PDF'));
    await tester.pumpAndSettle();
    expect(find.textContaining('VERIFIED DOCUMENT'), findsOneWidget);
    Navigator.of(
      tester.element(find.textContaining('VERIFIED DOCUMENT')),
    ).pop();
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('deliberation sends reasoning and submits a verdict', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(harness(initialIndex: 2));
    await tester.enterText(
      find.byType(TextField),
      'The timestamp creates reasonable doubt.',
    );
    await tester.tap(find.byTooltip('Send reasoning'));
    await tester.pump();
    expect(
      find.text('The timestamp creates reasonable doubt.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Call vote'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not guilty'));
    await tester.pump();
    await tester.tap(find.text('Submit final verdict'));
    await tester.pumpAndSettle();
    expect(find.text('OFFICIAL COURT RULING'), findsOneWidget);
  });
}
