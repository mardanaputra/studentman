import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api-harilibur.vercel.app/api';
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<dynamic>> fetchHolidays() async {
    try {
      final response = await client.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return decoded['data'] as List<dynamic>;
        }
        return [];
      } else {
        throw Exception('Gagal memuat API hari libur (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi REST API: ${e.toString()}');
    }
  }
}
