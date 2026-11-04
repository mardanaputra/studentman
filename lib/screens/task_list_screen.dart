import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card_item.dart';
import '../widgets/state_feedback_placeholder.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

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
                    taskProvider.toggleTaskStatusLocally(task.id!, val ?? false);
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
                onDelete: () {
                  if (task.id != null) {
                    taskProvider.deleteTaskLocally(task.id!);
                  }
                },
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
