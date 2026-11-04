import 'package:flutter/material.dart';
import '../widgets/task_card_item.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas Kuliah'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          TaskCardItem(
            title: 'Implementasi Arsitektur UTS Mobile',
            courseName: 'Workshop Pemrograman Mobile',
            deadlineDate: '2026-11-08',
            priority: 'Tinggi',
            status: 'In Progress',
            notes: 'Menerapkan clean architecture dengan Provider dan Supabase CRUD.',
            onTap: () {},
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditTaskScreen(
                    taskId: 1,
                    title: 'Implementasi Arsitektur UTS Mobile',
                    courseName: 'Workshop Pemrograman Mobile',
                    deadlineDate: '2026-11-08',
                    priority: 'Tinggi',
                    status: 'In Progress',
                    notes: 'Menerapkan clean architecture dengan Provider dan Supabase CRUD.',
                  ),
                ),
              );
            },
            onDelete: () {},
          ),
          TaskCardItem(
            title: 'Laporan Analisis Kebutuhan Perangkat Lunak',
            courseName: 'Rekayasa Perangkat Lunak',
            deadlineDate: '2026-11-12',
            priority: 'Sedang',
            status: 'Pending',
            notes: 'Menyelesaikan dokumen SRS bab 3 dan diagram UML.',
            onTap: () {},
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditTaskScreen(
                    taskId: 2,
                    title: 'Laporan Analisis Kebutuhan Perangkat Lunak',
                    courseName: 'Rekayasa Perangkat Lunak',
                    deadlineDate: '2026-11-12',
                    priority: 'Sedang',
                    status: 'Pending',
                    notes: 'Menyelesaikan dokumen SRS bab 3 dan diagram UML.',
                  ),
                ),
              );
            },
            onDelete: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }
}
