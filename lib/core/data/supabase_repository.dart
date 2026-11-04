import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'jury_repository.dart';

/// Cloud operations mirror DemoRepository. All authority-bearing mutations are
/// transactional Postgres functions, with membership and phase checks on server.
class SupabaseRepository implements JuryRepository {
  SupabaseRepository(this.client);
  final SupabaseClient client;
  final List<RealtimeChannel> _channels = [];
  @override
  bool get isDemo => false;
  @override
  Stream<void> get passwordRecoveryEvents => client.auth.onAuthStateChange
      .where((event) => event.event == AuthChangeEvent.passwordRecovery)
      .map((_) {});
  @override
  Future<void> updatePassword(String password) async {
    await client.auth.updateUser(UserAttributes(password: password));
  }

  String get _recoveryRedirect => kIsWeb
      ? Uri.base
            .replace(
              queryParameters: {...Uri.base.queryParameters, 'recovery': '1'},
              fragment: '',
            )
            .toString()
      : 'com.livejury.app://auth-callback?recovery=1';
  @override
  String? get currentUserId => client.auth.currentUser?.id;
  @override
  Future<PlayerData> signIn({
    String? email,
    String? password,
    String? name,
    bool create = false,
  }) async {
    if (create) {
      final response = await client.auth.signUp(
        email: email!,
        password: password!,
        data: {'display_name': name},
      );
      if (response.session == null) {
        throw const JuryException(
          'Account created. Confirm the link in your email, then sign in.',
        );
      }
    } else {
      await client.auth.signInWithPassword(email: email!, password: password!);
    }
    return loadPlayer();
  }

  @override
  Future<void> resetPassword(String email) =>
      client.auth.resetPasswordForEmail(email, redirectTo: _recoveryRedirect);
  @override
  Future<PlayerData> loadPlayer() async => PlayerData.fromJson(
    Map<String, dynamic>.from(await client.rpc('jury_player_snapshot')),
  );
  @override
  Future<void> savePlayer(PlayerData player) async {
    await client
        .from('profiles')
        .update({
          'display_name': player.name,
          'haptics': player.haptics,
          'notifications': player.notifications,
        })
        .eq('id', currentUserId!);
    final ids = player.notices.where((n) => n.read).map((n) => n.id).toList();
    if (ids.isNotEmpty) {
      await client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', currentUserId!)
          .inFilter('id', ids);
    }
  }

  @override
  Future<List<CaseFile>> loadCases() async {
    final rows = await client.from('cases').select('payload').order('id');
    return rows
        .map((r) => CaseFile.fromJson(Map<String, dynamic>.from(r['payload'])))
        .toList();
  }

  @override
  Future<JuryRound> openRoom(
    String caseId, {
    bool private = false,
    String? code,
  }) async {
    final id = await client.rpc(
      'jury_open_room',
      params: {'p_case_id': caseId, 'p_private': private, 'p_code': code},
    );
    return refreshRoom(id as String);
  }

  @override
  Future<JuryRound> refreshRoom(String id) async => JuryRound.fromJson(
    Map<String, dynamic>.from(
      await client.rpc('jury_room_snapshot', params: {'p_room': id}),
    ),
  );
  @override
  Future<void> leaveRoom(String id) async =>
      await client.rpc('jury_leave_room', params: {'p_room': id});
  @override
  Future<void> startRoom(String id) async =>
      await client.rpc('jury_start_room', params: {'p_room': id});
  @override
  Future<void> review(String roomId, String exhibitId) async => await client
      .rpc('jury_review', params: {'p_room': roomId, 'p_exhibit': exhibitId});
  @override
  Future<void> vote(
    String roomId,
    Decision decision, {
    bool finalVote = false,
    String reason = '',
  }) async => await client.rpc(
    'jury_vote',
    params: {
      'p_room': roomId,
      'p_choice': decision.name,
      'p_final': finalVote,
      'p_reason': reason,
    },
  );
  @override
  Future<void> beginFinalVote(String roomId) async =>
      await client.rpc('jury_begin_final', params: {'p_room': roomId});
  @override
  Future<void> sendMessage(
    String roomId,
    String body,
    String? exhibitId,
  ) async => await client.rpc(
    'jury_send_message',
    params: {'p_room': roomId, 'p_body': body, 'p_exhibit': exhibitId},
  );
  @override
  Future<void> reportMessage(String roomId, String messageId) async =>
      await client.rpc(
        'jury_report',
        params: {'p_room': roomId, 'p_message': messageId},
      );
  @override
  Future<List<RankingEntry>> rankings() async {
    final rows = await client.rpc('jury_rankings') as List;
    return rows
        .map((r) => RankingEntry(r['name'], r['points'], r['cases']))
        .toList();
  }

  @override
  Stream<void> watchRoom(String id) {
    late StreamController<void> stream;
    RealtimeChannel? channel;
    stream = StreamController<void>(
      onListen: () {
        channel = client
            .channel('jury-room-$id-${DateTime.now().microsecondsSinceEpoch}')
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'rooms',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'id',
                value: id,
              ),
              callback: (_) {
                if (!stream.isClosed) stream.add(null);
              },
            )
            .subscribe((status, error) {
              if (error != null && !stream.isClosed) stream.addError(error);
            });
        _channels.add(channel!);
      },
      onCancel: () async {
        if (channel != null) {
          _channels.remove(channel);
          await client.removeChannel(channel!);
        }
      },
    );
    return stream.stream;
  }

  @override
  Future<void> signOut() => client.auth.signOut();
  @override
  Future<void> deleteAccount() async {
    await client.rpc('jury_delete_my_account');
    // The session's user no longer exists; drop it locally only.
    await client.auth.signOut(scope: SignOutScope.local);
  }

  @override
  void dispose() {
    for (final channel in List<RealtimeChannel>.of(_channels)) {
      client.removeChannel(channel);
    }
    _channels.clear();
  }
}
