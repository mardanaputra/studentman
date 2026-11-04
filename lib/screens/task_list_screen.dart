import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card_item.dart';
import '../widgets/state_feedback_placeholder.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTaskDetailSheet(BuildContext context, StudentTaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.courseName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.taskStatus,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.taskTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Tenggat: ${task.deadlineDate}',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Prioritas: ${task.priority}',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Catatan Tugas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              task.notes.isEmpty ? 'Tidak ada catatan tambahan.' : task.notes,
              style: TextStyle(color: Colors.grey[800], height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _confirmDelete(context, task);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
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
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau mata kuliah...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim().toLowerCase());
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => taskProvider.fetchTasks(),
        child: Builder(
          builder: (context) {
            if (taskProvider.isLoading) {
              return const StateFeedbackPlaceholder.loading(
                title: 'Mengambil Data Tugas...',
                message: 'Sedang menyinkronkan dengan database Supabase',
              );
            }

            if (taskProvider.errorMessage != null) {
              return StateFeedbackPlaceholder.error(
                message: taskProvider.errorMessage!,
                onRetry: () => taskProvider.fetchTasks(),
              );
            }

            var tasks = taskProvider.filteredTasks;
            if (_searchQuery.isNotEmpty) {
              tasks = tasks.where((t) =>
                  t.taskTitle.toLowerCase().contains(_searchQuery) ||
                  t.courseName.toLowerCase().contains(_searchQuery)).toList();
            }

            if (tasks.isEmpty) {
              return StateFeedbackPlaceholder.empty(
                title: 'Tidak Ada Tugas',
                message: _searchQuery.isNotEmpty
                    ? 'Tidak ada tugas yang cocok dengan pencarian "$_searchQuery".'
                    : 'Tidak ada tugas yang sesuai dengan filter "${taskProvider.selectedStatus}".',
                onRetry: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  taskProvider.setStatusFilter('Semua');
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCardItem(
                  title: task.taskTitle,
                  courseName: task.courseName,
                  deadlineDate: task.deadlineDate,
                  priority: task.priority,
                  status: task.taskStatus,
                  notes: task.notes,
                  onTap: () => _showTaskDetailSheet(context, task),
                  onStatusToggle: (val) async {
                    if (task.id != null) {
                      final newStatus = (val ?? false) ? 'Selesai' : 'Pending';
                      await taskProvider.toggleTaskStatus(task.id!, val ?? false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status tugas "${task.taskTitle}" diubah ke $newStatus'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
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
