import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/demo_repository.dart';
import '../data/jury_repository.dart';
import '../data/demo_cases.dart';
import '../models/models.dart';

class JuryController extends ChangeNotifier {
  JuryController({
    required this.demoRepository,
    this.cloudRepository,
    this.configurationError,
    this.simulationInterval = const Duration(milliseconds: 850),
  }) {
    _recoverySubscription = cloudRepository?.passwordRecoveryEvents.listen((_) {
      recoveryRequired = true;
      _emit();
    });
  }
  bool recoveryRequired = false;
  StreamSubscription<void>? _recoverySubscription;
  Future<bool> updatePassword(String password) => perform(() async {
    if (cloudRepository == null || !recoveryRequired) {
      throw const JuryException(
        'Open the recovery link from your email first.',
      );
    }
    if (password.length < 8) {
      throw const JuryException('Use at least 8 characters.');
    }
    await cloudRepository!.updatePassword(password);
    await cloudRepository!.signOut();
    recoveryRequired = false;
    player = null;
    _repository = null;
    _simulation?.cancel();
    _reply?.cancel();
    _poll?.cancel();
    await _roomSubscription?.cancel();
  });
  final DemoRepository demoRepository;
  final JuryRepository? cloudRepository;
  final String? configurationError;
  final Duration simulationInterval;
  JuryRepository? _repository;
  PlayerData? player;
  List<CaseFile> cases = demoCases;
  List<RankingEntry> leaders = [];
  bool busy = false;
  String? error;
  bool _disposed = false;
  bool _refreshing = false;
  Timer? _simulation, _reply, _poll;
  StreamSubscription<void>? _roomSubscription;
  final Set<String> mutedJurors = {};
  String chatDraft = '', reasonDraft = '';
  String? attachedExhibit;
  bool get signedIn => player != null;
  bool get isDemo => _repository?.isDemo ?? true;
  bool get cloudAvailable => cloudRepository != null;
  JuryRound? get room => player?.round;
  CaseFile get currentCase =>
      cases.firstWhere((c) => c.id == room?.caseId, orElse: () => cases.first);
  int get unread => player?.notices.where((n) => !n.read).length ?? 0;
  String get resumeRoute => switch (room?.stage) {
    RoundStage.waiting => '/room',
    RoundStage.briefing ||
    RoundStage.initialVote => room?.initial == null ? '/case' : '/discussion',
    RoundStage.deliberation => '/discussion',
    RoundStage.finalVote => '/vote',
    RoundStage.complete => '/result',
    RoundStage.cancelled => '/room',
    null => '/home',
  };
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void clearError() {
    error = null;
    _emit();
  }

  Future<bool> perform(Future<void> Function() action) async {
    if (busy || _disposed) return false;
    busy = true;
    error = null;
    _emit();
    try {
      await action().timeout(const Duration(seconds: 20));
      return true;
    } catch (e) {
      error = switch (e) {
        JuryException() => e.message,
        AuthException() => e.message,
        PostgrestException() => e.message,
        TimeoutException() =>
          'The connection took too long. Check your connection and try again.',
        _ =>
          'We could not complete that action. Check your connection and try again.',
      };
      return false;
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<bool> signIn({
    bool demo = false,
    String? email,
    String? password,
    String? name,
    bool create = false,
  }) => perform(() async {
    final repo = demo ? demoRepository : cloudRepository;
    if (repo == null) {
      throw const JuryException(
        'Cloud accounts are not connected yet. Continue with a demo profile to explore the full experience.',
      );
    }
    final p = await repo.signIn(
      email: email,
      password: password,
      name: name,
      create: create,
    );
    final files = await repo.loadCases();
    if (files.isEmpty) {
      throw const JuryException(
        'The case library is empty. Apply the Supabase seed migration, then sign in again.',
      );
    }
    _repository = repo;
    player = p;
    cases = files;
    _watch();
    leaders = await repo.rankings();
  });
  Future<void> restoreCloud() async {
    if (cloudRepository?.currentUserId == null) return;
    await perform(() async {
      final p = await cloudRepository!.loadPlayer();
      final files = await cloudRepository!.loadCases();
      if (files.isEmpty) return;
      _repository = cloudRepository;
      player = p;
      cases = files;
      _watch();
    });
  }

  Future<bool> resetPassword(String email) => perform(() async {
    if (cloudRepository == null) {
      throw const JuryException(
        'Cloud accounts are not configured. Demo mode needs no password.',
      );
    }
    await cloudRepository!.resetPassword(email);
  });
  Future<bool> openRoom(CaseFile file, {bool private = false, String? code}) =>
      perform(() async {
        if (code != null && !RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) {
          throw const JuryException('Enter a six-character room code.');
        }
        player!.round = await _repository!.openRoom(
          file.id,
          private: private,
          code: code,
        );
        chatDraft = '';
        reasonDraft = '';
        attachedExhibit = null;
        mutedJurors.clear();
        _watch();
      });
  void _watch() {
    _simulation?.cancel();
    _poll?.cancel();
    _roomSubscription?.cancel();
    final r = room;
    if (r == null) return;
    _roomSubscription = _repository!
        .watchRoom(r.id)
        .listen(
          (_) => refreshQuietly(),
          onError: (Object _) {
            error = 'Live updates paused. Reconnecting; you can also retry.';
            _emit();
          },
        );
    if (isDemo && r.stage == RoundStage.waiting) {
      _simulation = Timer.periodic(simulationInterval, (timer) async {
        if (_disposed ||
            room?.id != r.id ||
            room!.jurors.length >= 6 ||
            room!.stage != RoundStage.waiting) {
          timer.cancel();
          return;
        }
        await demoRepository.addSimulatedJuror(r.id);
        _emit();
      });
    }
    if (!isDemo) {
      _poll = Timer.periodic(
        const Duration(seconds: 5),
        (_) => refreshQuietly(),
      );
    }
  }

  Future<void> refreshQuietly() async {
    if (_disposed || room == null || _refreshing || busy) return;
    _refreshing = true;
    final id = room!.id;
    try {
      final updated = await _repository!.refreshRoom(id);
      if (!_disposed && room?.id == id) {
        player!.round = updated;
        if (updated.stage == RoundStage.complete) {
          player = await _repository!.loadPlayer();
        }
        _emit();
      }
    } catch (_) {
      error = 'Room updates are unavailable. Check your connection and retry.';
      _emit();
    } finally {
      _refreshing = false;
    }
  }

  Future<bool> refresh() => perform(() async {
    if (room != null) player!.round = await _repository!.refreshRoom(room!.id);
    player = await _repository!.loadPlayer();
  });
  Future<void> _refreshRound() async {
    player!.round = await _repository!.refreshRoom(room!.id);
  }

  Future<bool> startCase() => perform(() async {
    await _repository!.startRoom(room!.id);
    await _refreshRound();
  });
  Future<bool> markReviewed(Exhibit exhibit) => perform(() async {
    await _repository!.review(room!.id, exhibit.id);
    await _refreshRound();
  });
  Future<bool> castVote(
    Decision choice, {
    bool finalVote = false,
    String reason = '',
  }) => perform(() async {
    await _repository!.vote(
      room!.id,
      choice,
      finalVote: finalVote,
      reason: reason,
    );
    await _refreshRound();
    if (player!.haptics) {
      unawaited(HapticFeedback.selectionClick().catchError((Object _) {}));
    }
    if (finalVote && room!.stage == RoundStage.complete) {
      player = await _repository!.loadPlayer();
      leaders = await _repository!.rankings();
    }
  });
  Future<bool> beginFinal() => perform(() async {
    await _repository!.beginFinalVote(room!.id);
    await _refreshRound();
  });
  Future<bool> sendMessage() => perform(() async {
    final id = room!.id;
    await _repository!.sendMessage(id, chatDraft, attachedExhibit);
    chatDraft = '';
    attachedExhibit = null;
    await _refreshRound();
    if (isDemo) {
      _reply?.cancel();
      _reply = Timer(const Duration(seconds: 2), () async {
        if (!_disposed &&
            room?.id == id &&
            room?.stage == RoundStage.deliberation) {
          await demoRepository.addReply(id);
          _emit();
        }
      });
    }
  });
  void attach(String? id) {
    attachedExhibit = id;
    _emit();
  }

  void toggleMute(String id) {
    if (!mutedJurors.add(id)) mutedJurors.remove(id);
    _emit();
  }

  Future<bool> report(String messageId) => perform(() async {
    await _repository!.reportMessage(room!.id, messageId);
  });
  Future<bool> leave() => perform(() async {
    await _repository!.leaveRoom(room!.id);
    player!.round = null;
    _simulation?.cancel();
    _reply?.cancel();
    _poll?.cancel();
    await _roomSubscription?.cancel();
  });
  Future<bool> updateProfile(String name, bool haptics, bool notifications) =>
      perform(() async {
        if (name.trim().length < 2 || name.trim().length > 30) {
          throw const JuryException(
            'Choose a display name of 2–30 characters.',
          );
        }
        final old = player!.toJson();
        player!.name = name.trim();
        player!.haptics = haptics;
        player!.notifications = notifications;
        try {
          await _repository!.savePlayer(player!);
        } catch (_) {
          player = PlayerData.fromJson(old);
          rethrow;
        }
      });
  Future<bool> markNoticesRead() => perform(() async {
    final old = player!.notices.map((n) => n.read).toList();
    for (final n in player!.notices) {
      n.read = true;
    }
    try {
      await _repository!.savePlayer(player!);
    } catch (_) {
      for (var i = 0; i < old.length; i++) {
        player!.notices[i].read = old[i];
      }
      rethrow;
    }
  });
  Future<bool> loadRankings() => perform(() async {
    leaders = await _repository!.rankings();
  });
  Future<bool> signOut() => perform(() async {
    _simulation?.cancel();
    _reply?.cancel();
    _poll?.cancel();
    await _roomSubscription?.cancel();
    await _repository!.signOut();
    player = null;
    _repository = null;
    chatDraft = '';
    reasonDraft = '';
  });
  @override
  void dispose() {
    _disposed = true;
    _recoverySubscription?.cancel();
    _simulation?.cancel();
    _reply?.cancel();
    _poll?.cancel();
    _roomSubscription?.cancel();
    demoRepository.dispose();
    cloudRepository?.dispose();
    super.dispose();
  }
}

class JuryScope extends InheritedNotifier<JuryController> {
  const JuryScope({
    super.key,
    required JuryController controller,
    required super.child,
  }) : super(notifier: controller);
  static JuryController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JuryScope>()!.notifier!;
}
