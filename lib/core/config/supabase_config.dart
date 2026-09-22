/// Connection details for the hosted project.
///
/// These are the *publishable* client credentials. They are compiled into every
/// released client by design, exactly like a web page's public API key, and they
/// grant nothing on their own: every read and write is still gated by the user's
/// JWT, row-level security, the narrow table grants, and the checked `jury_*`
/// functions. A service-role or secret key must never appear here.
///
/// Defaults let `flutter run` and an IDE Run button connect with no extra
/// arguments. Point a build at a different project by overriding them:
///
/// ```sh
/// flutter run --dart-define-from-file=config/supabase.json
/// ```
abstract final class SupabaseConfig {
  static const _defaultUrl = 'https://aicehnhintjymrojyggx.supabase.co';
  static const _defaultKey = 'sb_publishable_Z4ZF7Daq6HhnLaqYk0_KPA_tu4UJ1QY';

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultUrl,
  );

  /// `SUPABASE_ANON_KEY` stays accepted so older build scripts keep working.
  static const key = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: _defaultKey,
    ),
  );
}
