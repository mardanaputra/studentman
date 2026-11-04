import 'package:flutter/foundation.dart';
import '../models/student_task_model.dart';
import '../services/supabase_service.dart';

class TaskRepository {
  // Local fallback storage for initial demo or offline condition
  final List<StudentTaskModel> _localTasks = [
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

  Future<List<StudentTaskModel>> getTasks() async {
    final client = SupabaseService.client;
    if (client != null) {
      try {
        final response = await client
            .from(SupabaseService.tasksTable)
            .select()
            .order('id', ascending: false);
        final list = (response as List)
            .map((item) => StudentTaskModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        debugPrint('[Supabase] Berhasil mengambil ${list.length} tugas dari cloud.');
        return list;
      } catch (e) {
        debugPrint('[Supabase] Gagal mengambil tugas: $e. Menggunakan fallback lokal.');
        return List.from(_localTasks);
      }
    }
    return List.from(_localTasks);
  }

  Future<StudentTaskModel> insertTask(StudentTaskModel task) async {
    final client = SupabaseService.client;
    if (client != null) {
      try {
        final response = await client
            .from(SupabaseService.tasksTable)
            .insert(task.toJson())
            .select()
            .single();
        final created = StudentTaskModel.fromJson(Map<String, dynamic>.from(response));
        debugPrint('[Supabase] Berhasil menyimpan tugas id ${created.id} ke cloud.');
        _localTasks.insert(0, created);
        return created;
      } catch (e) {
        debugPrint('[Supabase] Gagal menyimpan ke cloud: $e. Menyimpan lokal.');
        final localId = (_localTasks.map((t) => t.id ?? 0).fold<int>(0, (prev, id) => id > prev ? id : prev)) + 1;
        final created = task.copyWith(id: localId, createdAt: DateTime.now());
        _localTasks.insert(0, created);
        return created;
      }
    }

    final localId = (_localTasks.map((t) => t.id ?? 0).fold<int>(0, (prev, id) => id > prev ? id : prev)) + 1;
    final created = task.copyWith(id: localId, createdAt: DateTime.now());
    _localTasks.insert(0, created);
    return created;
  }

  Future<StudentTaskModel> updateTask(StudentTaskModel task) async {
    final client = SupabaseService.client;
    if (client != null && task.id != null) {
      try {
        final response = await client
            .from(SupabaseService.tasksTable)
            .update(task.toJson())
            .eq('id', task.id!)
            .select()
            .single();
        final updated = StudentTaskModel.fromJson(Map<String, dynamic>.from(response));
        debugPrint('[Supabase] Berhasil memperbarui tugas id ${updated.id} di cloud.');
        final idx = _localTasks.indexWhere((t) => t.id == updated.id);
        if (idx != -1) _localTasks[idx] = updated;
        return updated;
      } catch (e) {
        debugPrint('[Supabase] Gagal update cloud: $e. Update lokal.');
        final idx = _localTasks.indexWhere((t) => t.id == task.id);
        if (idx != -1) _localTasks[idx] = task;
        return task;
      }
    }

    final idx = _localTasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _localTasks[idx] = task;
    return task;
  }

  Future<bool> deleteTask(int id) async {
    final client = SupabaseService.client;
    if (client != null) {
      try {
        await client
            .from(SupabaseService.tasksTable)
            .delete()
            .eq('id', id);
        debugPrint('[Supabase] Berhasil menghapus tugas id $id di cloud.');
        _localTasks.removeWhere((t) => t.id == id);
        return true;
      } catch (e) {
        debugPrint('[Supabase] Gagal delete cloud: $e. Hapus lokal.');
        _localTasks.removeWhere((t) => t.id == id);
        return true;
      }
    }

    _localTasks.removeWhere((t) => t.id == id);
    return true;
  }
}
