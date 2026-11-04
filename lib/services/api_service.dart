import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Mengambil data hari libur nasional Indonesia via HTTP GET dari REST API Publik
  Future<List<dynamic>> fetchHolidays({int? year}) async {
    final targetYear = year ?? DateTime.now().year;

    // Endpoint 1: Nager.Date API (Global standard public holidays API, 100% uptime & CORS open)
    final nagerUrl = 'https://date.nager.at/api/v3/PublicHolidays/$targetYear/ID';

    // Endpoint 2: Api-harilibur Vercel (Alternatif)
    final vercelUrl = 'https://api-harilibur.vercel.app/api?year=$targetYear';

    // Coba Endpoint 1 (Nager.Date)
    try {
      debugPrint('[REST API] Melakukan HTTP GET ke: $nagerUrl');
      final response = await client.get(
        Uri.parse(nagerUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      debugPrint('[REST API] Respon status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          debugPrint('[REST API] ✅ Sukses mengunduh ${decoded.length} hari libur nasional dari Nager.Date API.');
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('[REST API] Percobaan Endpoint 1 gagal ($e). Mencoba Endpoint 2...');
    }

    // Coba Endpoint 2 (Vercel)
    try {
      debugPrint('[REST API] Melakukan HTTP GET ke: $vercelUrl');
      final response = await client.get(
        Uri.parse(vercelUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      debugPrint('[REST API] Respon status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          debugPrint('[REST API] ✅ Sukses mengunduh ${decoded.length} hari libur dari Vercel API.');
          return decoded;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final list = decoded['data'] as List<dynamic>;
          debugPrint('[REST API] ✅ Sukses mengunduh ${list.length} hari libur dari Vercel API.');
          return list;
        }
      }
    } catch (e) {
      debugPrint('[REST API] Percobaan Endpoint 2 gagal: $e');
    }

    throw Exception('Gagal menghubungi seluruh endpoint REST API Hari Libur Nasional.');
  }
}
