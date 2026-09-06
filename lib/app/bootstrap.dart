import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/data/demo_repository.dart';
import '../core/data/supabase_repository.dart';
import '../core/state/jury_controller.dart';
import 'jury_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (_) {
    /* Demo remains available if device storage is unavailable. */
  }
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  SupabaseRepository? cloud;
  String? configurationError;
  if (url.isNotEmpty && key.isNotEmpty) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !uri.hasAuthority ||
          (uri.scheme != 'https' &&
              !(uri.scheme == 'http' &&
                  (uri.host == 'localhost' || uri.host == '127.0.0.1')))) {
        throw const FormatException('Invalid Supabase URL');
      }
      await Supabase.initialize(url: url, publishableKey: key);
      cloud = SupabaseRepository(Supabase.instance.client);
    } catch (_) {
      configurationError =
          'The cloud configuration could not be loaded. Demo mode is available.';
    }
  }
  final controller = JuryController(
    demoRepository: DemoRepository(preferences: preferences),
    cloudRepository: cloud,
    configurationError: configurationError,
  );
  await controller.restoreCloud();
  if (cloud?.currentUserId != null &&
      (Uri.base.queryParameters['recovery'] == '1' ||
          Uri.base.fragment.contains('type=recovery'))) {
    controller.recoveryRequired = true;
  }
  runApp(JuryApp(controller: controller));
}
