import '../models/models.dart';

abstract class JuryRepository {
  bool get isDemo;
  Stream<void> get passwordRecoveryEvents;
  Future<void> updatePassword(String password);
  String? get currentUserId;
  Future<PlayerData> signIn({
    String? email,
    String? password,
    String? name,
    bool create = false,
  });
  Future<void> resetPassword(String email);
  Future<PlayerData> loadPlayer();
  Future<void> savePlayer(PlayerData player);
  Future<List<CaseFile>> loadCases();
  Future<JuryRound> openRoom(
    String caseId, {
    bool private = false,
    String? code,
  });
  Future<JuryRound> refreshRoom(String id);
  Future<void> leaveRoom(String id);
  Future<void> startRoom(String id);
  Future<void> review(String roomId, String exhibitId);
  Future<void> vote(
    String roomId,
    Decision decision, {
    bool finalVote = false,
    String reason = '',
  });
  Future<void> beginFinalVote(String roomId);
  Future<void> sendMessage(String roomId, String body, String? exhibitId);
  Future<void> reportMessage(String roomId, String messageId);
  Future<List<RankingEntry>> rankings();
  Stream<void> watchRoom(String id);
  Future<void> signOut();
  Future<void> deleteAccount();
  void dispose();
}
