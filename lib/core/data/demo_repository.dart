import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'demo_cases.dart';
import 'jury_repository.dart';

class DemoRepository implements JuryRepository {
  DemoRepository({
    this.preferences,
    this.latency = const Duration(milliseconds: 350),
  });
  final SharedPreferences? preferences;
  final Duration latency;
  PlayerData? _player;
  final _events = StreamController<void>.broadcast();
  static const storageKey = 'sixth_seat_demo_v1';
  @override
  bool get isDemo => true;
  @override
  Stream<void> get passwordRecoveryEvents => const Stream<void>.empty();
  @override
  Future<void> updatePassword(String password) async =>
      throw const JuryException('Demo profiles do not have passwords.');
  @override
  String? get currentUserId => _player?.id;
  Future<void> _pause() => Future<void>.delayed(latency);
  @override
  Future<PlayerData> signIn({
    String? email,
    String? password,
    String? name,
    bool create = false,
  }) async {
    await _pause();
    final raw = preferences?.getString(storageKey);
    try {
      if (raw != null) _player = PlayerData.fromJson(jsonDecode(raw));
    } catch (_) {
      /* Recover an obsolete/corrupted local snapshot. */
    }
    _player ??= PlayerData(
      id: 'demo-you',
      name: 'Alex Morgan',
      notices: [
        JuryNotice(
          id: 'welcome',
          title: 'Your seat is waiting',
          body:
              'Welcome to the room. Start with The Glass Hour and make your first considered call.',
        ),
      ],
    );
    return _player!;
  }

  @override
  Future<void> resetPassword(String email) async => throw const JuryException(
    'Account recovery is available after Supabase is configured. You can continue with a demo profile.',
  );
  @override
  Future<PlayerData> loadPlayer() async => _player!;
  @override
  Future<void> savePlayer(PlayerData player) async {
    _player = player;
    await preferences?.setString(storageKey, jsonEncode(player.toJson()));
  }

  @override
  Future<List<CaseFile>> loadCases() async => demoCases;
  @override
  Future<JuryRound> openRoom(
    String caseId, {
    bool private = false,
    String? code,
  }) async {
    await _pause();
    if (code != null && code != 'JURY06') {
      throw const JuryException(
        'That demo room was not found. Try JURY06, or create a new room.',
      );
    }
    if (_player!.round != null &&
        _player!.round!.stage != RoundStage.complete) {
      throw const JuryException(
        'You already have a seat. Resume your room or leave it first.',
      );
    }
    final r = JuryRound(
      id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      code: code ?? _code(),
      caseId: code == null ? caseId : demoCases.first.id,
      hostId: _player!.id,
      isPrivate: private || code != null,
      jurors: [Juror(_player!.id, _player!.name)],
    );
    _player!.round = r;
    await savePlayer(_player!);
    return r;
  }

  String _code() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  JuryRound _room(String id) {
    final r = _player?.round;
    if (r == null || r.id != id) {
      throw const JuryException('This room has ended. Return to the lobby.');
    }
    return r;
  }

  @override
  Future<JuryRound> refreshRoom(String id) async => _room(id);
  Future<void> addSimulatedJuror(String id) async {
    final r = _room(id);
    if (r.stage != RoundStage.waiting || r.jurors.length >= 6) return;
    const names = [
      'Maya Reed',
      'Theo Brooks',
      'Imani Gray',
      'Sam Rivera',
      'Noor Patel',
    ];
    final i = r.jurors.length - 1;
    r.jurors.add(Juror('sim-$i', names[i], isDemo: true));
    await _save();
  }

  Future<void> _save() async {
    await savePlayer(_player!);
    if (!_events.isClosed) _events.add(null);
  }

  @override
  Future<void> leaveRoom(String id) async {
    _room(id);
    _player!.round = null;
    await _save();
  }

  @override
  Future<void> startRoom(String id) async {
    final r = _room(id);
    if (r.jurors.length != 6) {
      throw const JuryException(
        'The room needs six jurors before the case begins.',
      );
    }
    if (r.stage != RoundStage.waiting) return;
    r.stage = RoundStage.briefing;
    await _save();
  }

  @override
  Future<void> review(String roomId, String exhibitId) async {
    final r = _room(roomId);
    final c = demoCases.firstWhere((c) => c.id == r.caseId);
    if (r.stage == RoundStage.waiting ||
        r.stage == RoundStage.complete ||
        r.stage == RoundStage.cancelled) {
      throw const JuryException('Evidence review is not open for this room.');
    }
    if (!c.evidence.any((e) => e.id == exhibitId)) {
      throw const JuryException('Exhibit not found.');
    }
    r.reviewed.add(exhibitId);
    await _save();
  }

  @override
  Future<void> vote(
    String roomId,
    Decision decision, {
    bool finalVote = false,
    String reason = '',
  }) async {
    await _pause();
    final r = _room(roomId);
    final c = demoCases.firstWhere((c) => c.id == r.caseId);
    if (r.reviewed.length < c.evidence.length) {
      throw const JuryException(
        'Review every exhibit before casting your vote.',
      );
    }
    if (!finalVote) {
      if (r.stage != RoundStage.briefing && r.stage != RoundStage.initialVote) {
        throw const JuryException('Your initial ballot is already sealed.');
      }
      r.initial = decision;
      r.stage = RoundStage.deliberation;
      r.messages = [
        RoomMessage(
          id: 'intro',
          senderId: 'system',
          name: 'The room',
          body:
              'Your first impressions are sealed. Discuss the evidence, not the person.',
          system: true,
        ),
        RoomMessage(
          id: 'sim-message-1',
          senderId: 'sim-0',
          name: 'Maya Reed',
          body:
              'I keep coming back to the distinction between what this exhibit records and what we assume it means.',
          exhibitId: 'E1',
        ),
        RoomMessage(
          id: 'sim-message-2',
          senderId: 'sim-1',
          name: 'Theo Brooks',
          body:
              'Agreed. What is the strongest alternative explanation for the sequence of events?',
        ),
      ];
    } else {
      if (r.stage != RoundStage.finalVote) {
        throw const JuryException('Final voting is not open.');
      }
      if (reason.trim().length < 20 || reason.trim().length > 2000) {
        throw const JuryException(
          'Explain your decision in 20–2,000 characters.',
        );
      }
      r.finalDecision = decision;
      r.reason = reason.trim();
      r.finalCount = 6;
      r.responsibleCount = 2 + (decision == Decision.responsible ? 1 : 0);
      r.stage = RoundStage.complete;
      if (!_player!.history.any((h) => h.roomId == r.id)) {
        final citations = r.messages
            .where((m) => m.senderId == _player!.id && m.exhibitId != null)
            .length;
        final points = 60 + r.reviewed.length * 10 + (citations > 0 ? 20 : 0);
        _player!.history.insert(
          0,
          CaseRecord(
            roomId: r.id,
            caseId: c.id,
            title: c.title,
            outcome: r.responsibleCount == 3
                ? 'Hung jury'
                : c.label(
                    r.responsibleCount! > 3
                        ? Decision.responsible
                        : Decision.notResponsible,
                  ),
            reason: r.reason,
            points: points,
            reviewed: r.reviewed.length,
            citations: citations,
            date: DateTime.now(),
            changedMind: r.initial != r.finalDecision,
          ),
        );
        if (_player!.notifications) {
          _player!.notices.insert(
            0,
            JuryNotice(
              id: r.id,
              title: 'Case closed · ${c.title}',
              body:
                  'Your analysis is ready. You earned $points points for participating thoughtfully.',
            ),
          );
        }
      }
    }
    await _save();
  }

  @override
  Future<void> beginFinalVote(String roomId) async {
    final r = _room(roomId);
    if (r.stage != RoundStage.deliberation) {
      throw const JuryException('Deliberation has not started.');
    }
    r.stage = RoundStage.finalVote;
    await _save();
  }

  @override
  Future<void> sendMessage(
    String roomId,
    String body,
    String? exhibitId,
  ) async {
    final r = _room(roomId);
    if (r.stage != RoundStage.deliberation) {
      throw const JuryException('Discussion is closed for this round.');
    }
    if (body.trim().isEmpty || body.length > 2000) {
      throw const JuryException('Write a message of up to 2,000 characters.');
    }
    if (exhibitId != null &&
        !demoCases
            .firstWhere((c) => c.id == r.caseId)
            .evidence
            .any((e) => e.id == exhibitId)) {
      throw const JuryException('Choose an exhibit from this case.');
    }
    r.messages.add(
      RoomMessage(
        id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
        senderId: _player!.id,
        name: _player!.name,
        body: body.trim(),
        exhibitId: exhibitId,
      ),
    );
    await _save();
  }

  Future<void> addReply(String roomId) async {
    final r = _room(roomId);
    if (r.stage != RoundStage.deliberation) return;
    r.messages.add(
      RoomMessage(
        id: 'reply-${DateTime.now().microsecondsSinceEpoch}',
        senderId: 'sim-3',
        name: 'Sam Rivera',
        body:
            'That is a useful distinction. Does your explanation also account for the limitation noted in the witness statement?',
        exhibitId: 'E2',
      ),
    );
    await _save();
  }

  @override
  Future<void> reportMessage(String roomId, String messageId) async {
    _room(roomId);
    await _pause();
  }

  @override
  Future<List<RankingEntry>> rankings() async => [
    const RankingEntry('Maya Reed', 1840, 16),
    const RankingEntry('Noor Patel', 1620, 14),
    const RankingEntry('Theo Brooks', 1480, 13),
    RankingEntry(_player!.name, _player!.points, _player!.history.length),
  ]..sort((a, b) => b.points.compareTo(a.points));
  @override
  Stream<void> watchRoom(String id) => _events.stream;
  @override
  Future<void> signOut() async {
    await savePlayer(_player!);
    _player = null;
  }

  @override
  Future<void> deleteAccount() async {
    await preferences?.remove(storageKey);
    _player = null;
  }

  @override
  void dispose() {
    _events.close();
  }
}
