import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://afzfijkldarxwjkrbtuf.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_C8ZFMajboD07b2qoLrft1w_X4_io9KE';
  static const String tasksTable = 'student_tasks';

  static bool _isInitialized = false;

  // Cukup pastikan URL dan Key tidak kosong dan URL diawali http
  static bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty &&
      supabaseAnonKey.trim().isNotEmpty &&
      supabaseUrl.trim().startsWith('http');

  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('[Supabase] Credentials belum diisi. Menggunakan local fallback.');
      return;
    }
    try {
      debugPrint('[Supabase] Menghubungkan ke $supabaseUrl ...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('[Supabase] ✅ Berhasil terhubung ke Supabase Cloud!');
    } catch (e) {
      debugPrint('[Supabase] ❌ Gagal inisialisasi: $e');
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
