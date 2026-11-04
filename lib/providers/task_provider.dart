import 'package:flutter/material.dart';
import '../models/student_task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<StudentTaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatus = 'Semua';

  List<StudentTaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;

  List<StudentTaskModel> get filteredTasks {
    if (_selectedStatus == 'Semua') {
      return _tasks;
    }
    return _tasks.where((t) => t.taskStatus.toLowerCase() == _selectedStatus.toLowerCase()).toList();
  }

  int get pendingCount => _tasks.where((t) => t.taskStatus.toLowerCase() == 'pending').length;
  int get progressCount => _tasks.where((t) => t.taskStatus.toLowerCase() == 'in progress').length;
  int get completedCount => _tasks.where((t) => t.taskStatus.toLowerCase() == 'selesai').length;
  int get totalCount => _tasks.length;

  void setTasks(List<StudentTaskModel> taskList) {
    _tasks = taskList;
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

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void addTaskLocally(StudentTaskModel task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTaskLocally(StudentTaskModel updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTaskLocally(int taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void toggleTaskStatusLocally(int taskId, bool isCompleted) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final current = _tasks[index];
      _tasks[index] = current.copyWith(
        taskStatus: isCompleted ? 'Selesai' : 'Pending',
      );
      notifyListeners();
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _tasks = [
      StudentTaskModel(
        id: 1,
        courseName: 'Workshop Pemrograman Mobile',
        taskTitle: 'Implementasi Arsitektur UTS Mobile',
        deadlineDate: '2026-11-08',
        priority: 'Tinggi',
        taskStatus: 'In Progress',
        notes: 'Menerapkan clean architecture dengan Provider dan Supabase CRUD.',
        createdAt: DateTime.now(),
      ),
      StudentTaskModel(
        id: 2,
        courseName: 'Rekayasa Perangkat Lunak',
        taskTitle: 'Laporan Analisis Kebutuhan Perangkat Lunak',
        deadlineDate: '2026-11-12',
        priority: 'Sedang',
        taskStatus: 'Pending',
        notes: 'Menyelesaikan dokumen SRS bab 3 dan diagram UML.',
        createdAt: DateTime.now(),
      ),
      StudentTaskModel(
        id: 3,
        courseName: 'Kecerdasan Buatan',
        taskTitle: 'Tugas Eksperimen Model Klasifikasi',
        deadlineDate: '2026-11-15',
        priority: 'Rendah',
        taskStatus: 'Selesai',
        notes: 'Melakukan perbandingan akurasi Random Forest vs SVM.',
        createdAt: DateTime.now(),
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }
}
