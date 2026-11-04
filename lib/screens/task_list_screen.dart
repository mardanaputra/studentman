import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card_item.dart';
import '../widgets/state_feedback_placeholder.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  void _confirmDelete(BuildContext context, StudentTaskModel task) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Tugas'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus tugas "${task.taskTitle}"? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (task.id != null) {
                final success = await context.read<TaskProvider>().deleteTask(task.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Tugas berhasil dihapus dari database.'
                            : 'Gagal menghapus tugas.',
                      ),
                      backgroundColor: success ? Colors.black87 : Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final filterOptions = ['Semua', 'Pending', 'In Progress', 'Selesai'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas Kuliah'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: filterOptions.map((status) {
                final isSelected = taskProvider.selectedStatus.toLowerCase() == status.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => taskProvider.setStatusFilter(status),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (taskProvider.isLoading) {
            return const StateFeedbackPlaceholder.loading();
          }

          if (taskProvider.errorMessage != null) {
            return StateFeedbackPlaceholder.error(
              message: taskProvider.errorMessage!,
              onRetry: () => taskProvider.loadInitialData(),
            );
          }

          final tasks = taskProvider.filteredTasks;
          if (tasks.isEmpty) {
            return StateFeedbackPlaceholder.empty(
              title: 'Tidak Ada Tugas',
              message: 'Tidak ada tugas yang sesuai dengan filter "${taskProvider.selectedStatus}".',
              onRetry: () => taskProvider.setStatusFilter('Semua'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCardItem(
                title: task.taskTitle,
                courseName: task.courseName,
                deadlineDate: task.deadlineDate,
                priority: task.priority,
                status: task.taskStatus,
                notes: task.notes,
                onTap: () {},
                onStatusToggle: (val) {
                  if (task.id != null) {
                    taskProvider.toggleTaskStatus(task.id!, val ?? false);
                  }
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(
                        taskId: task.id,
                        title: task.taskTitle,
                        courseName: task.courseName,
                        deadlineDate: task.deadlineDate,
                        priority: task.priority,
                        status: task.taskStatus,
                        notes: task.notes,
                      ),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, task),
              );
            },
          );
        },
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
