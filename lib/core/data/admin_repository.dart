import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// One juror as an administrator sees them. Includes the email, which no other
/// part of the app can read.
class AdminProfile {
  const AdminProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.points,
    required this.isAdmin,
    required this.suspended,
    required this.cases,
  });
  final String id, email, name;
  final int points, cases;
  final bool isAdmin, suspended;

  factory AdminProfile.fromJson(Map<String, dynamic> j) => AdminProfile(
    id: j['id'] as String,
    email: (j['email'] ?? '') as String,
    name: (j['display_name'] ?? '') as String,
    points: (j['points'] ?? 0) as int,
    isAdmin: (j['is_admin'] ?? false) as bool,
    suspended: (j['suspended'] ?? false) as bool,
    cases: (j['cases'] ?? 0) as int,
  );
}

/// Counts across the whole project, for the dashboard.
class AdminOverview {
  const AdminOverview(this.values);
  final Map<String, int> values;
  int operator [](String key) => values[key] ?? 0;

  factory AdminOverview.fromJson(Map<String, dynamic> j) => AdminOverview({
    for (final entry in j.entries) entry.key: (entry.value as num).toInt(),
  });
}

/// A case with the number of rounds played on it, which decides whether it can
/// still be deleted.
class AdminCase {
  const AdminCase({required this.file, required this.rounds});
  final CaseFile file;
  final int rounds;
  bool get deletable => rounds == 0;
}

/// Administration is a cloud-only capability, so it is a separate contract from
/// [JuryRepository] rather than a set of methods the demo repository would have
/// to stub out.
///
/// Every call here is a checked database function. The client never decides who
/// is an administrator; it only asks, and the database refuses when the answer
/// is no.
class AdminRepository {
  AdminRepository(this.client);
  final SupabaseClient client;

  Future<AdminOverview> overview() async => AdminOverview.fromJson(
    Map<String, dynamic>.from(await client.rpc('admin_overview')),
  );

  Future<List<AdminProfile>> profiles() async {
    final rows = await client.rpc('admin_list_profiles') as List;
    return rows
        .map((r) => AdminProfile.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<List<AdminCase>> cases() async {
    final rows = await client.rpc('admin_list_cases') as List;
    return rows.map((r) {
      final row = Map<String, dynamic>.from(r);
      return AdminCase(
        file: CaseFile.fromJson(Map<String, dynamic>.from(row['payload'])),
        rounds: (row['rounds'] ?? 0) as int,
      );
    }).toList();
  }

  Future<void> updateProfile(
    String userId, {
    String? name,
    int? points,
    bool? suspended,
    bool? isAdmin,
  }) => client.rpc(
    'admin_update_profile',
    params: {
      'p_user': userId,
      'p_name': name,
      'p_points': points,
      'p_suspended': suspended,
      'p_is_admin': isAdmin,
    },
  );

  Future<void> deleteUser(String userId) =>
      client.rpc('admin_delete_user', params: {'p_user': userId});

  Future<void> saveCase(String id, Map<String, dynamic> payload) =>
      client.rpc('admin_save_case', params: {'p_id': id, 'p_payload': payload});

  Future<void> deleteCase(String id) =>
      client.rpc('admin_delete_case', params: {'p_id': id});
}
