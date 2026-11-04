import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card_item.dart';
import '../widgets/state_feedback_placeholder.dart';
import '../widgets/responsive_layout_builder.dart';
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
  String _dateFilter = 'Semua Tanggal';
  DateTime? _customSelectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH TANGGAL JADWAL',
    );
    if (picked != null) {
      setState(() {
        _customSelectedDate = picked;
        _dateFilter = 'Custom';
      });
    }
  }

  void _showTaskDetailSheet(BuildContext context, StudentTaskModel task) {
    final isOrg = task.courseName.startsWith('[Organisasi]');
    final cleanCourse = task.courseName
        .replaceFirst('[Organisasi] ', '')
        .replaceFirst('[Organisasi]', '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isOrg) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Organisasi',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9333EA),
                          ),
                        ),
                      ),
                    ],
                    Text(
                      cleanCourse,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isOrg ? const Color(0xFF9333EA) : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.taskStatus,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.taskTitle,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'Tenggat: ${task.deadlineDate}',
                    style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  const Spacer(),
                  const Icon(Icons.flag_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'Prioritas: ${task.priority}',
                    style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              task.notes.isEmpty ? 'Tidak ada catatan tambahan.' : task.notes,
              style: const TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _confirmDelete(context, task);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                    label: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
                    icon: const Icon(Icons.edit_outlined, size: 18),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Hapus Jadwal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${task.taskTitle}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
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
                            ? 'Data berhasil dihapus dari database.'
                            : 'Gagal menghapus data.',
                      ),
                      backgroundColor: success ? const Color(0xFF0F172A) : const Color(0xFFEF4444),
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
    final statusFilterOptions = ['Semua Status', 'Pending', 'In Progress', 'Selesai'];
    final dateFilterOptions = ['Semua Tanggal', 'Hari Ini', 'Mendatang', 'Terlewat'];

    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas & Jadwal'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF2563EB)),
              tooltip: 'Tambah Jadwal',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau kegiatan organisasi...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                            color: _customSelectedDate != null
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                          ),
                          tooltip: 'Filter Tanggal',
                          onPressed: () => _pickDate(context),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim().toLowerCase());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    // 1. Dropdown Filter Tanggal
                    Expanded(
                      child: PopupMenuButton<String>(
                        tooltip: 'Filter Tanggal',
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (val) {
                          if (val == 'picker') {
                            _pickDate(context);
                          } else {
                            setState(() {
                              _dateFilter = val;
                              _customSelectedDate = null;
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          ...dateFilterOptions.map((opt) => PopupMenuItem(
                            value: opt,
                            child: Row(
                              children: [
                                if (_customSelectedDate == null && _dateFilter == opt)
                                  const Icon(Icons.check_rounded, size: 16, color: Color(0xFF2563EB))
                                else
                                  const SizedBox(width: 16),
                                const SizedBox(width: 8),
                                Text(opt, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          )),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'picker',
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF2563EB)),
                                SizedBox(width: 8),
                                Text('Pilih Tanggal Bebas...', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (_customSelectedDate != null || _dateFilter != 'Semua Tanggal')
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                              width: (_customSelectedDate != null || _dateFilter != 'Semua Tanggal') ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: (_customSelectedDate != null || _dateFilter != 'Semua Tanggal')
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _customSelectedDate != null
                                      ? "${_customSelectedDate!.year}-${_customSelectedDate!.month.toString().padLeft(2, '0')}-${_customSelectedDate!.day.toString().padLeft(2, '0')}"
                                      : _dateFilter,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: (_customSelectedDate != null || _dateFilter != 'Semua Tanggal')
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: (_customSelectedDate != null || _dateFilter != 'Semua Tanggal')
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (_customSelectedDate != null || _dateFilter != 'Semua Tanggal')
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _customSelectedDate = null;
                                      _dateFilter = 'Semua Tanggal';
                                    });
                                  },
                                  child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                                )
                              else
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 2. Dropdown Filter Status
                    Expanded(
                      child: PopupMenuButton<String>(
                        tooltip: 'Filter Status',
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (val) {
                          final normalized = val == 'Semua Status' ? 'Semua' : val;
                          taskProvider.setStatusFilter(normalized);
                        },
                        itemBuilder: (context) => statusFilterOptions.map((status) {
                          final normalized = status == 'Semua Status' ? 'Semua' : status;
                          final isSelected = taskProvider.selectedStatus.toLowerCase() == normalized.toLowerCase();
                          return PopupMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                if (isSelected)
                                  const Icon(Icons.check_rounded, size: 16, color: Color(0xFF2563EB))
                                else
                                  const SizedBox(width: 16),
                                const SizedBox(width: 8),
                                Text(status, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        }).toList(),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: taskProvider.selectedStatus != 'Semua'
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                              width: taskProvider.selectedStatus != 'Semua' ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                size: 15,
                                color: taskProvider.selectedStatus != 'Semua'
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  taskProvider.selectedStatus == 'Semua'
                                      ? 'Semua Status'
                                      : taskProvider.selectedStatus,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: taskProvider.selectedStatus != 'Semua'
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: taskProvider.selectedStatus != 'Semua'
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (taskProvider.selectedStatus != 'Semua')
                                GestureDetector(
                                  onTap: () {
                                    taskProvider.setStatusFilter('Semua');
                                  },
                                  child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                                )
                              else
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                title: 'Mengambil Data Jadwal...',
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

            // 1. Text Search Filter
            if (_searchQuery.isNotEmpty) {
              tasks = tasks.where((t) =>
                  t.taskTitle.toLowerCase().contains(_searchQuery) ||
                  t.courseName.toLowerCase().contains(_searchQuery) ||
                  t.deadlineDate.contains(_searchQuery) ||
                  t.notes.toLowerCase().contains(_searchQuery)).toList();
            }

            // 2. Date Filtering
            if (_customSelectedDate != null) {
              final target =
                  "${_customSelectedDate!.year}-${_customSelectedDate!.month.toString().padLeft(2, '0')}-${_customSelectedDate!.day.toString().padLeft(2, '0')}";
              tasks = tasks.where((t) => t.deadlineDate == target).toList();
            } else if (_dateFilter == 'Hari Ini') {
              tasks = tasks.where((t) => t.deadlineDate == todayStr).toList();
            } else if (_dateFilter == 'Mendatang') {
              tasks = tasks.where((t) => t.deadlineDate.compareTo(todayStr) >= 0).toList();
            } else if (_dateFilter == 'Terlewat') {
              tasks = tasks.where((t) =>
                  t.deadlineDate.compareTo(todayStr) < 0 &&
                  t.taskStatus.toLowerCase() != 'selesai').toList();
            }

            // 3. Smart Prioritized Sorting:
            // 0: Terlewat (Overdue & not completed) -> Paling atas!
            // 1: Hari Ini (Today & not completed)
            // 2: Mendatang (Upcoming & not completed) -> sorted ascending by date
            // 3: Selesai (Completed) -> Paling bawah
            tasks = List.from(tasks);
            tasks.sort((a, b) {
              final aCompleted = a.taskStatus.toLowerCase() == 'selesai';
              final bCompleted = b.taskStatus.toLowerCase() == 'selesai';

              int getGroup(StudentTaskModel t, bool completed) {
                if (completed) return 3;
                final cmp = t.deadlineDate.compareTo(todayStr);
                if (cmp < 0) return 0; // Terlewat (Urgent)
                if (cmp == 0) return 1; // Hari ini
                return 2; // Mendatang
              }

              final aGroup = getGroup(a, aCompleted);
              final bGroup = getGroup(b, bCompleted);

              if (aGroup != bGroup) {
                return aGroup.compareTo(bGroup);
              }

              return a.deadlineDate.compareTo(b.deadlineDate);
            });

            if (tasks.isEmpty) {
              String emptyMsg = 'Tidak ada jadwal yang cocok.';
              if (_searchQuery.isNotEmpty) {
                emptyMsg = 'Tidak ada jadwal yang cocok dengan kata kunci "$_searchQuery".';
              } else if (_customSelectedDate != null) {
                final target =
                    "${_customSelectedDate!.year}-${_customSelectedDate!.month.toString().padLeft(2, '0')}-${_customSelectedDate!.day.toString().padLeft(2, '0')}";
                emptyMsg = 'Tidak ada jadwal pada tanggal $target.';
              } else if (_dateFilter != 'Semua Tanggal') {
                emptyMsg = 'Tidak ada jadwal untuk filter "$_dateFilter".';
              } else if (taskProvider.selectedStatus != 'Semua') {
                emptyMsg = 'Tidak ada jadwal dengan status "${taskProvider.selectedStatus}".';
              }

              return StateFeedbackPlaceholder.empty(
                title: 'Tidak Ada Jadwal',
                message: emptyMsg,
                onRetry: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _dateFilter = 'Semua Tanggal';
                    _customSelectedDate = null;
                  });
                  taskProvider.setStatusFilter('Semua');
                },
              );
            }

            return ResponsiveLayoutBuilder(
              compact: (ctx, constraints) => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasks.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) => _buildItem(context, tasks[index], taskProvider),
              ),
              wide: (ctx, constraints) => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                ),
                itemCount: tasks.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) => _buildItem(context, tasks[index], taskProvider),
              ),
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildItem(BuildContext context, StudentTaskModel task, TaskProvider taskProvider) {
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
                content: Text('Status jadwal "${task.taskTitle}" diubah ke $newStatus'),
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
  }
}
