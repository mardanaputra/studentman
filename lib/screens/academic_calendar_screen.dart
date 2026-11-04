import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/academic_event_model.dart';
import '../models/student_task_model.dart';
import '../providers/academic_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/priority_status_badge.dart';
import '../widgets/responsive_layout_builder.dart';
import '../widgets/state_feedback_placeholder.dart';
import 'academic_detail_screen.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class CalendarDisplayItem {
  final String id;
  final String title;
  final String date;
  final String category;
  final String subtitle;
  final String description;
  final bool isTask;
  final bool isOrganization;
  final StudentTaskModel? taskSource;
  final AcademicEventModel? academicSource;

  CalendarDisplayItem({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.isTask,
    this.isOrganization = false,
    this.taskSource,
    this.academicSource,
  });
}

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  String _dateFilter = 'Semua Tanggal';
  DateTime? _customSelectedDate;
  final TextEditingController _searchController = TextEditingController();

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
      helpText: 'PILIH TANGGAL AGENDA',
    );
    if (picked != null) {
      setState(() {
        _customSelectedDate = picked;
        _dateFilter = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicProvider = context.watch<AcademicProvider>();
    final taskProvider = context.watch<TaskProvider>();

    // 1. Data dari Supabase Database (Tugas & Organisasi)
    final dbItems = taskProvider.tasks.map((task) {
      final isOrg = task.courseName.startsWith('[Organisasi]');
      final cleanCourse = task.courseName
          .replaceFirst('[Organisasi] ', '')
          .replaceFirst('[Organisasi]', '');

      final cat = isOrg ? 'Kegiatan Organisasi' : 'Tugas Kuliah';

      return CalendarDisplayItem(
        id: 'db_${task.id}',
        title: task.taskTitle,
        date: task.deadlineDate,
        category: cat,
        subtitle: '$cleanCourse • Status: ${task.taskStatus}',
        description: task.notes.isNotEmpty
            ? task.notes
            : (isOrg ? 'Agenda kegiatan $cleanCourse' : 'Tugas mata kuliah $cleanCourse'),
        isTask: true,
        isOrganization: isOrg,
        taskSource: task,
      );
    }).toList();

    // 2. Data dari Live REST API (Hari Libur & Kalender Kampus)
    final apiItems = academicProvider.events.map((event) {
      return CalendarDisplayItem(
        id: 'api_${event.id}',
        title: event.title,
        date: event.eventDate,
        category: event.category,
        subtitle: event.category,
        description: event.description,
        isTask: false,
        academicSource: event,
      );
    }).toList();

    // 3. Gabungkan dan urutkan
    final allItems = [...dbItems, ...apiItems];

    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final categoryFilterOptions = [
      'Semua',
      'Kegiatan Organisasi',
      'Tugas Kuliah',
      'Libur Nasional',
      'Akademik'
    ];
    final dateFilterOptions = ['Semua Tanggal', 'Hari Ini', 'Mendatang', 'Terlewat'];

    var filteredItems = allItems;

    // 1. Text Search Filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) =>
          item.title.toLowerCase().contains(_searchQuery) ||
          item.subtitle.toLowerCase().contains(_searchQuery) ||
          item.date.contains(_searchQuery) ||
          item.description.toLowerCase().contains(_searchQuery)).toList();
    }

    // 2. Kategori Filter
    if (_selectedFilter != 'Semua') {
      filteredItems = filteredItems.where((item) {
        if (_selectedFilter == 'Kegiatan Organisasi') return item.isOrganization;
        if (_selectedFilter == 'Tugas Kuliah') return item.isTask && !item.isOrganization;
        if (_selectedFilter == 'Libur Nasional') return item.category.toLowerCase().contains('libur');
        if (_selectedFilter == 'Akademik') return item.category.toLowerCase().contains('akademik');
        return item.category.toLowerCase() == _selectedFilter.toLowerCase();
      }).toList();
    }

    // 3. Tanggal Filter
    if (_customSelectedDate != null) {
      final target =
          "${_customSelectedDate!.year}-${_customSelectedDate!.month.toString().padLeft(2, '0')}-${_customSelectedDate!.day.toString().padLeft(2, '0')}";
      filteredItems = filteredItems.where((item) => item.date == target).toList();
    } else if (_dateFilter == 'Hari Ini') {
      filteredItems = filteredItems.where((item) => item.date == todayStr).toList();
    } else if (_dateFilter == 'Mendatang') {
      filteredItems = filteredItems.where((item) => item.date.compareTo(todayStr) >= 0).toList();
    } else if (_dateFilter == 'Terlewat') {
      filteredItems = filteredItems.where((item) {
        final isCompleted = item.taskSource?.taskStatus.toLowerCase() == 'selesai';
        return item.date.compareTo(todayStr) < 0 && !isCompleted;
      }).toList();
    }

    // 4. Smart Prioritized Sorting:
    // 0: Terlewat (Overdue task & not completed) -> Paling atas!
    // 1: Hari Ini
    // 2: Mendatang
    // 3: Selesai -> Paling bawah
    filteredItems.sort((a, b) {
      final aCompleted = a.taskSource?.taskStatus.toLowerCase() == 'selesai';
      final bCompleted = b.taskSource?.taskStatus.toLowerCase() == 'selesai';

      int getGroup(CalendarDisplayItem item, bool completed) {
        if (completed) return 3;
        final cmp = item.date.compareTo(todayStr);
        if (cmp < 0 && item.isTask) return 0;
        if (cmp == 0) return 1;
        return 2;
      }

      final aGroup = getGroup(a, aCompleted);
      final bGroup = getGroup(b, bCompleted);

      if (aGroup != bGroup) {
        return aGroup.compareTo(bGroup);
      }

      return a.date.compareTo(b.date);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender & Agenda'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF9333EA)),
              tooltip: 'Tambah Agenda Organisasi',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(
                      initialCategory: 'Kegiatan Organisasi',
                    ),
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
                    hintText: 'Cari agenda, rapat organisasi, atau libur...',
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
                                ? const Color(0xFF9333EA)
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
                                  const Icon(Icons.check_rounded, size: 16, color: Color(0xFF9333EA))
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
                                Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF9333EA)),
                                SizedBox(width: 8),
                                Text('Pilih Tanggal Bebas...', style: TextStyle(fontSize: 13, color: Color(0xFF9333EA), fontWeight: FontWeight.bold)),
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
                                  ? const Color(0xFF9333EA)
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
                                    ? const Color(0xFF9333EA)
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
                                        ? const Color(0xFF9333EA)
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
                    // 2. Dropdown Filter Kategori
                    Expanded(
                      child: PopupMenuButton<String>(
                        tooltip: 'Filter Kategori',
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (val) {
                          setState(() => _selectedFilter = val);
                        },
                        itemBuilder: (context) => categoryFilterOptions.map((cat) => PopupMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              if (_selectedFilter == cat)
                                const Icon(Icons.check_rounded, size: 16, color: Color(0xFF9333EA))
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Text(cat, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        )).toList(),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedFilter != 'Semua'
                                  ? const Color(0xFF9333EA)
                                  : const Color(0xFFE2E8F0),
                              width: _selectedFilter != 'Semua' ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                size: 15,
                                color: _selectedFilter != 'Semua'
                                    ? const Color(0xFF9333EA)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _selectedFilter == 'Semua' ? 'Semua Kategori' : _selectedFilter,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _selectedFilter != 'Semua' ? FontWeight.bold : FontWeight.w500,
                                    color: _selectedFilter != 'Semua'
                                        ? const Color(0xFF9333EA)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (_selectedFilter != 'Semua')
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedFilter = 'Semua');
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
        onRefresh: () async {
          await Future.wait([
            academicProvider.fetchEvents(),
            taskProvider.fetchTasks(),
          ]);
        },
        child: Builder(
          builder: (context) {
            if (academicProvider.isLoading && taskProvider.isLoading) {
              return const StateFeedbackPlaceholder.loading(
                title: 'Menyinkronkan Kalender...',
                message: 'Memuat data tugas, agenda organisasi & REST API',
              );
            }

            if (filteredItems.isEmpty) {
              String emptyMsg = 'Tidak ada jadwal yang cocok.';
              if (_searchQuery.isNotEmpty) {
                emptyMsg = 'Tidak ada jadwal yang cocok dengan kata kunci "$_searchQuery".';
              } else if (_customSelectedDate != null) {
                final target =
                    "${_customSelectedDate!.year}-${_customSelectedDate!.month.toString().padLeft(2, '0')}-${_customSelectedDate!.day.toString().padLeft(2, '0')}";
                emptyMsg = 'Tidak ada jadwal pada tanggal $target.';
              } else if (_dateFilter != 'Semua Tanggal') {
                emptyMsg = 'Tidak ada jadwal untuk filter "$_dateFilter".';
              } else if (_selectedFilter != 'Semua') {
                emptyMsg = 'Tidak ada jadwal di kategori "$_selectedFilter".';
              }

              return StateFeedbackPlaceholder.empty(
                title: 'Tidak Ada Jadwal',
                message: emptyMsg,
                onRetry: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedFilter = 'Semua';
                    _dateFilter = 'Semua Tanggal';
                    _customSelectedDate = null;
                  });
                },
              );
            }

            return ResponsiveLayoutBuilder(
              compact: (ctx, constraints) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredItems.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) => _buildModernCalendarCard(context, filteredItems[index]),
              ),
              wide: (ctx, constraints) => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredItems.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) => _buildModernCalendarCard(context, filteredItems[index]),
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
              builder: (context) => const AddTaskScreen(
                initialCategory: 'Kegiatan Organisasi',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Agenda Organisasi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildModernCalendarCard(BuildContext context, CalendarDisplayItem item) {
    final isHoliday = item.category.toLowerCase().contains('libur');

    Color themeColor;
    Color bgPillColor;

    if (item.isOrganization) {
      themeColor = const Color(0xFF9333EA);
      bgPillColor = const Color(0xFFFAF5FF);
    } else if (item.isTask) {
      themeColor = const Color(0xFF2563EB);
      bgPillColor = const Color(0xFFEFF6FF);
    } else if (isHoliday) {
      themeColor = const Color(0xFFDC2626);
      bgPillColor = const Color(0xFFFEF2F2);
    } else {
      themeColor = const Color(0xFFEA580C);
      bgPillColor = const Color(0xFFFFF7ED);
    }

    // Parsing tanggal untuk date badge (DD / MMM)
    String dayText = '';
    String monthText = 'AGENDA';
    final parts = item.date.split('-');
    if (parts.length >= 3) {
      dayText = parts[2].trim();
      final monthNum = int.tryParse(parts[1].trim()) ?? 1;
      const monthNames = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'];
      if (monthNum > 0 && monthNum <= 12) {
        monthText = monthNames[monthNum];
      }
    } else {
      dayText = '•';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (item.isTask && item.taskSource != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskScreen(
                    taskId: item.taskSource!.id,
                    title: item.taskSource!.taskTitle,
                    courseName: item.taskSource!.courseName,
                    deadlineDate: item.taskSource!.deadlineDate,
                    priority: item.taskSource!.priority,
                    status: item.taskSource!.taskStatus,
                    notes: item.taskSource!.notes,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AcademicDetailScreen(
                    title: item.title,
                    date: item.date,
                    category: item.category,
                    description: item.description,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Modern Date Badge (Left Block)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: bgPillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        monthText,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: themeColor.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.5,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (item.isTask && item.taskSource != null) ...[
                            const SizedBox(width: 6),
                            PriorityStatusBadge(label: item.taskSource!.priority, isPriority: true),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
