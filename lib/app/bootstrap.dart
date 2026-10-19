import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:moneyideas/core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pre-run initialization for storage, services and logging.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline local cache
  await Hive.initFlutter();

  // Initialize Supabase if credentials are provided in env/dev.json
  if (Env.isConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        // Supabase Flutter marks anonKey deprecated in favor of publishableKey.
        // ignore: deprecated_member_use
        anonKey: Env.supabaseAnonKey,
      );
      developer.log('Supabase successfully initialized');
    } on Exception catch (e, stack) {
      developer.log('Supabase initialization failed', error: e, stackTrace: stack);
    }
  } else {
    developer.log(
      'Notice: Running without Supabase credentials. Add env/dev.json to connect to live backend.',
    );
  }
}
