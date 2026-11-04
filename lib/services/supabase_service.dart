import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-public-key';
  static const String tasksTable = 'student_tasks';

  static bool _isInitialized = false;

  static bool get isConfigured =>
      supabaseUrl != 'https://your-project-id.supabase.co' &&
      supabaseAnonKey != 'your-anon-public-key' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
