import 'package:flutter/material.dart';
import '../models/academic_event_model.dart';

class AcademicProvider extends ChangeNotifier {
  List<AcademicEventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'Semua';

  List<AcademicEventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<AcademicEventModel> get filteredEvents {
    if (_selectedCategory == 'Semua') {
      return _events;
    }
    return _events.where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  List<String> get availableCategories {
    final categories = {'Semua'};
    for (final event in _events) {
      if (event.category.isNotEmpty) {
        categories.add(event.category);
      }
    }
    return categories.toList();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setEvents(List<AcademicEventModel> newEvents) {
    _events = newEvents;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _events = [
      AcademicEventModel(
        id: '1',
        title: 'Pekan Ujian Tengah Semester (UTS)',
        eventDate: '2026-11-10',
        category: 'Akademik',
        description: 'Pelaksanaan UTS Semester Ganjil TA 2026/2027 seluruh program studi TRPL.',
      ),
      AcademicEventModel(
        id: '2',
        title: 'Batas Pengumpulan Project Workshop Mobile',
        eventDate: '2026-11-14',
        category: 'Tugas Kuliah',
        description: 'Pengumpulan laporan, repository git minimal 16 commit, dan file APK rilis.',
      ),
      AcademicEventModel(
        id: '3',
        title: 'Hari Libur Nasional Indonesia',
        eventDate: '2026-11-20',
        category: 'Libur Nasional',
        description: 'Kegiatan perkuliahan diliburkan sesuai kalender libur nasional pemerintah.',
      ),
      AcademicEventModel(
        id: '4',
        title: 'Batas Akhir Input Nilai UTS',
        eventDate: '2026-11-25',
        category: 'Akademik',
        description: 'Dosen menginput nilai UTS ke sistem informasi akademik kampus.',
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }
}
