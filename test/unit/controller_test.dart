import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/models/models.dart';
import 'package:live_jury_room/core/state/jury_controller.dart';

class UnavailableRepository extends DemoRepository {
  UnavailableRepository() : super(latency: Duration.zero);
  bool fail = true;
  @override
  Future<JuryRound> openRoom(
    String caseId, {
    bool private = false,
    String? code,
  }) async {
    if (fail) throw const JuryException('Connection interrupted. Try again.');
    return super.openRoom(caseId, private: private, code: code);
  }
}

void main() {
  test('a failed room action preserves state and is retryable', () async {
    final repo = UnavailableRepository();
    final s = JuryController(
      demoRepository: repo,
      simulationInterval: const Duration(days: 1),
    );
    await s.signIn(demo: true);
    expect(await s.openRoom(s.cases.first), isFalse);
    expect(s.error, contains('Try again'));
    expect(s.room, isNull);
    expect(s.busy, isFalse);
    repo.fail = false;
    expect(await s.openRoom(s.cases.first), isTrue);
    expect(s.error, isNull);
    expect(s.resumeRoute, '/room');
    s.dispose();
  });
  test(
    'missing cloud configuration does not fabricate a signed-in account',
    () async {
      final s = JuryController(
        demoRepository: DemoRepository(latency: Duration.zero),
      );
      expect(
        await s.signIn(email: 'juror@example.com', password: 'password123'),
        isFalse,
      );
      expect(s.signedIn, isFalse);
      expect(s.error, contains('not connected'));
      expect(await s.signIn(demo: true), isTrue);
      expect(s.isDemo, isTrue);
      s.dispose();
    },
  );
  test('concurrent taps cannot start duplicate operations', () async {
    final s = JuryController(
      demoRepository: DemoRepository(latency: const Duration(milliseconds: 20)),
    );
    final first = s.signIn(demo: true);
    expect(s.busy, isTrue);
    expect(await s.signIn(demo: true), isFalse);
    expect(await first, isTrue);
    expect(s.busy, isFalse);
    s.dispose();
  });
}
