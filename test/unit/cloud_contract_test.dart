import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_jury_room/core/config/supabase_config.dart';
import 'package:live_jury_room/core/models/models.dart';

/// Parses payloads captured from the hosted `jury_player_snapshot` and `cases`
/// endpoints. Guards the client models against a drift in the SQL contract that
/// unit tests built from local fixtures would not catch.
void main() {
  final dir = Directory('test/fixtures');

  // Without usable defaults a plain `flutter run` or IDE Run button starts in
  // demo-only mode and the app reports that cloud accounts are not connected.
  group('cloud credentials are compiled in', () {
    test('url is a valid https project endpoint', () {
      expect(SupabaseConfig.url, isNotEmpty);
      final uri = Uri.tryParse(SupabaseConfig.url);
      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
      expect(uri.hasAuthority, isTrue);
    });

    test('key is present and is not a secret key', () {
      expect(SupabaseConfig.key, isNotEmpty);
      expect(
        SupabaseConfig.key.startsWith('sb_secret_'),
        isFalse,
        reason: 'a service-role/secret key must never ship in the client',
      );
      expect(SupabaseConfig.key.contains('service_role'), isFalse);
    });
  });

  test('player snapshot from the server parses into PlayerData', () {
    final file = File('${dir.path}/player_snapshot.json');
    final player = PlayerData.fromJson(
      Map<String, dynamic>.from(jsonDecode(file.readAsStringSync())),
    );

    expect(player.name, isNotEmpty);
    expect(player.notices, isNotEmpty);
    expect(player.history, isNotEmpty);

    final record = player.history.first;
    expect(record.points, greaterThan(0));
    expect(record.reviewed, greaterThan(0));
    expect(record.outcome, isNotEmpty);
    expect(record.reason, isNotEmpty);

    final round = player.round;
    expect(round, isNotNull);
    expect(round!.stage, RoundStage.complete);
    expect(round.code, hasLength(6));
    expect(round.jurors, hasLength(6));
    expect(round.messages, isNotEmpty);
    expect(round.finalDecision, isNotNull);
    // Aggregates are released only once the round closes.
    expect(round.responsibleCount, isNotNull);
  });

  test('case payloads from the server parse into CaseFile', () {
    final file = File('${dir.path}/cases.json');
    final rows = jsonDecode(file.readAsStringSync()) as List;
    final cases = rows
        .map((r) => CaseFile.fromJson(Map<String, dynamic>.from(r['payload'])))
        .toList();

    expect(cases, hasLength(3));
    for (final c in cases) {
      expect(c.title, isNotEmpty);
      expect(c.question, isNotEmpty);
      expect(c.debrief, isNotEmpty);
      expect(c.timeline, isNotEmpty);
      expect(c.evidence, hasLength(4));
      for (final e in c.evidence) {
        expect(e.id, isNotEmpty);
        expect(e.content, isNotEmpty);
        expect(e.caution, isNotEmpty);
      }
    }
  });
}
