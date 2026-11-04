import 'package:flutter/foundation.dart';
import '../models/academic_event_model.dart';
import '../services/api_service.dart';

class AcademicRepository {
  final ApiService apiService;

  AcademicRepository({ApiService? apiService}) : apiService = apiService ?? ApiService();

  Future<List<AcademicEventModel>> getAcademicEvents() async {
    final List<AcademicEventModel> events = [];

    // Agenda resmi kalender akademik kampus TRPL
    final academicMilestones = [
      AcademicEventModel(
        id: 'uts-semester-ganjil',
        title: 'Pekan Ujian Tengah Semester (UTS)',
        eventDate: '2026-11-10',
        category: 'Akademik',
        description: 'Pelaksanaan UTS Semester Ganjil TA 2026/2027 seluruh mata kuliah TRPL.',
      ),
      AcademicEventModel(
        id: 'batas-input-nilai',
        title: 'Batas Akhir Input Nilai UTS Dosen',
        eventDate: '2026-11-25',
        category: 'Akademik',
        description: 'Batas akhir dosen pengampu menginput nilai hasil UTS ke sistem akademik.',
      ),
    ];

    try {
      debugPrint('[AcademicRepository] Mengambil data hari libur dari REST API publik...');
      final rawHolidays = await apiService.fetchHolidays();
      final holidayEvents = rawHolidays
          .map((item) => AcademicEventModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      debugPrint('[AcademicRepository] ✅ Berhasil memetakan ${holidayEvents.length} data libur dari REST API.');

      events.addAll(holidayEvents);
      events.addAll(academicMilestones);

      // Urutkan tanggal secara kronologis
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return events;
    } catch (e) {
      debugPrint('[AcademicRepository] ⚠️ Gagal menghubungi REST API: $e. Menggunakan data offline.');
      return academicMilestones;
    }
  }
}
