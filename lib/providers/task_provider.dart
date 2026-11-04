import 'package:flutter/material.dart';
import '../models/student_task_model.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository repository;

  TaskProvider({TaskRepository? repository}) : repository = repository ?? TaskRepository();

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

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await repository.getTasks();
      _tasks = fetched;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal mengambil data dari database: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(StudentTaskModel task) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await repository.insertTask(task);
      _tasks.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan tugas baru: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(StudentTaskModel task) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await repository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _tasks[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui tugas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus tugas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleTaskStatus(int taskId, bool isCompleted) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updated = _tasks[index].copyWith(
        taskStatus: isCompleted ? 'Selesai' : 'Pending',
      );
      await updateTask(updated);
    }
  }

  Future<void> loadInitialData() => fetchTasks();
}
