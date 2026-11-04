import 'package:flutter/material.dart';
import '../models/academic_event_model.dart';
import '../repositories/academic_repository.dart';

class AcademicProvider extends ChangeNotifier {
  final AcademicRepository repository;

  AcademicProvider({AcademicRepository? repository})
      : repository = repository ?? AcademicRepository();

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

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await repository.getAcademicEvents();
      _events = fetched;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat agenda akademik: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialData() => fetchEvents();
}
