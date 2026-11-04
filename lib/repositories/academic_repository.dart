import '../models/academic_event_model.dart';
import '../services/api_service.dart';

class AcademicRepository {
  final ApiService apiService;

  AcademicRepository({ApiService? apiService}) : apiService = apiService ?? ApiService();

  Future<List<AcademicEventModel>> getAcademicEvents() async {
    final List<AcademicEventModel> events = [];

    // Standard academic schedule
    final standardEvents = [
      AcademicEventModel(
        id: 'uts-2026',
        title: 'Pekan Ujian Tengah Semester (UTS)',
        eventDate: '2026-11-10',
        category: 'Akademik',
        description: 'Pelaksanaan UTS Semester Ganjil TA 2026/2027 seluruh program studi TRPL.',
      ),
      AcademicEventModel(
        id: 'project-uts-mobile',
        title: 'Batas Pengumpulan Project Workshop Mobile',
        eventDate: '2026-11-14',
        category: 'Tugas Kuliah',
        description: 'Pengumpulan laporan, repository git minimal 16 commit, dan file APK rilis.',
      ),
      AcademicEventModel(
        id: 'input-nilai-uts',
        title: 'Batas Akhir Input Nilai UTS',
        eventDate: '2026-11-25',
        category: 'Akademik',
        description: 'Dosen menginput nilai UTS ke sistem informasi akademik kampus.',
      ),
    ];

    try {
      final rawHolidays = await apiService.fetchHolidays();
      final holidayEvents = rawHolidays
          .map((item) => AcademicEventModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      events.addAll(standardEvents);
      events.addAll(holidayEvents);

      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return events;
    } catch (_) {
      // Graceful fallback to offline standard academic events
      return standardEvents;
    }
  }
}
