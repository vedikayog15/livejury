@Tags(['live'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:live_jury_room/core/config/supabase_config.dart';
import 'package:live_jury_room/core/data/supabase_repository.dart';

/// Drives the real [SupabaseRepository] against the hosted project, so a failure
/// here is one the app would hit too. Needs network and a confirmed account, and
/// is therefore excluded from the default run:
///
///   flutter test --tags live --run-skipped
void main() {
  const email = 'juror1@livejury.test';
  const password = 'JuryRoom!2026';

  late SupabaseClient client;
  late SupabaseRepository repo;

  setUp(() {
    client = SupabaseClient(SupabaseConfig.url, SupabaseConfig.key);
    repo = SupabaseRepository(client);
  });

  tearDown(() async {
    await client.auth.signOut();
    repo.dispose();
  });

  test('the compiled-in credentials reach the hosted project', () async {
    final player = await repo.signIn(email: email, password: password);

    expect(player.name, isNotEmpty);
    expect(player.notices, isNotEmpty);
    expect(repo.currentUserId, isNotNull);
    expect(repo.isDemo, isFalse);

    final cases = await repo.loadCases();
    expect(cases, hasLength(3));
    expect(cases.every((c) => c.evidence.length == 4), isTrue);
    expect(cases.every((c) => c.title.isNotEmpty), isTrue);

    final rankings = await repo.rankings();
    expect(rankings, isNotEmpty);
  });

  test('a wrong password is rejected with a usable error', () async {
    await expectLater(
      repo.signIn(email: email, password: 'not-the-password'),
      throwsA(isA<AuthException>()),
    );
  });
}
