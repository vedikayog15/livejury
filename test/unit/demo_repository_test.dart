import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_jury_room/core/data/demo_cases.dart';
import 'package:live_jury_room/core/data/demo_repository.dart';
import 'package:live_jury_room/core/models/models.dart';

void main() {
  late DemoRepository repo;
  setUp(() {
    repo = DemoRepository(latency: Duration.zero);
  });
  tearDown(() => repo.dispose());
  Future<JuryRound> seated() async {
    await repo.signIn();
    final room = await repo.openRoom(demoCases.first.id);
    for (var i = 0; i < 5; i++) {
      await repo.addSimulatedJuror(room.id);
    }
    await repo.startRoom(room.id);
    return room;
  }

  test(
    'room capacity, one active room, and evidence gate are enforced',
    () async {
      await repo.signIn();
      final r = await repo.openRoom(demoCases.first.id);
      await expectLater(repo.startRoom(r.id), throwsA(isA<JuryException>()));
      await expectLater(
        repo.openRoom(demoCases.last.id),
        throwsA(isA<JuryException>()),
      );
      for (var i = 0; i < 9; i++) {
        await repo.addSimulatedJuror(r.id);
      }
      expect(r.jurors.length, 6);
      await repo.startRoom(r.id);
      await expectLater(
        repo.vote(r.id, Decision.responsible),
        throwsA(isA<JuryException>()),
      );
      await expectLater(
        repo.review(r.id, 'missing'),
        throwsA(isA<JuryException>()),
      );
    },
  );
  test(
    'sealed ballots, reason requirement, tied outcome and idempotent score',
    () async {
      final r = await seated();
      for (final e in demoCases.first.evidence) {
        await repo.review(r.id, e.id);
      }
      await repo.vote(r.id, Decision.notResponsible);
      expect(r.stage, RoundStage.deliberation);
      expect(r.responsibleCount, isNull);
      await expectLater(
        repo.vote(r.id, Decision.responsible),
        throwsA(isA<JuryException>()),
      );
      await repo.sendMessage(
        r.id,
        'The log cannot identify the person with the key.',
        'E1',
      );
      await repo.beginFinalVote(r.id);
      await expectLater(
        repo.vote(
          r.id,
          Decision.responsible,
          finalVote: true,
          reason: 'Too short',
        ),
        throwsA(isA<JuryException>()),
      );
      await repo.vote(
        r.id,
        Decision.responsible,
        finalVote: true,
        reason:
            'The witness and access log together support my decision, despite their limitations.',
      );
      expect(r.stage, RoundStage.complete);
      expect(r.responsibleCount, 3);
      final p = await repo.loadPlayer();
      expect(p.history.single.outcome, 'Hung jury');
      expect(p.points, 120);
      expect(p.history.single.changedMind, isTrue);
      await expectLater(
        repo.vote(
          r.id,
          Decision.responsible,
          finalVote: true,
          reason: 'A sufficiently long second explanation.',
        ),
        throwsA(isA<JuryException>()),
      );
      expect(p.history.length, 1);
      expect(p.points, 120);
    },
  );
  test(
    'demo journal and in-progress evidence survive sign out and reload',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final durable = DemoRepository(
        preferences: prefs,
        latency: Duration.zero,
      );
      await durable.signIn();
      final r = await durable.openRoom(demoCases.first.id);
      for (var i = 0; i < 5; i++) {
        await durable.addSimulatedJuror(r.id);
      }
      await durable.startRoom(r.id);
      await durable.review(r.id, 'E1');
      final p = await durable.loadPlayer();
      p.name = 'Jordan Wells';
      await durable.savePlayer(p);
      await durable.signOut();
      durable.dispose();
      final restored = DemoRepository(
        preferences: prefs,
        latency: Duration.zero,
      );
      final next = await restored.signIn();
      expect(next.name, 'Jordan Wells');
      expect(next.round!.reviewed, {'E1'});
      expect(next.round!.jurors.length, 6);
      restored.dispose();
    },
  );
  test(
    'invalid join and out-of-phase discussion fail with recoverable errors',
    () async {
      await repo.signIn();
      await expectLater(
        repo.openRoom(demoCases.first.id, code: 'BAD123'),
        throwsA(isA<JuryException>()),
      );
      final r = await repo.openRoom(demoCases.first.id, code: 'JURY06');
      expect(r.isPrivate, isTrue);
      await expectLater(
        repo.sendMessage(r.id, 'Hello room', null),
        throwsA(isA<JuryException>()),
      );
      await repo.leaveRoom(r.id);
      expect((await repo.loadPlayer()).round, isNull);
    },
  );
  test('all fictional case payloads round trip without losing evidence', () {
    for (final c in demoCases) {
      final decoded = CaseFile.fromJson(c.toJson());
      expect(decoded.evidence.length, 4);
      expect(decoded.timeline.length, 4);
      expect(decoded.title, c.title);
      expect(decoded.evidence.map((e) => e.kind).toSet().length, 4);
    }
  });
}
