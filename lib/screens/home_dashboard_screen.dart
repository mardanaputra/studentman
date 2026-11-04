import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/student_task_model.dart';
import '../providers/academic_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/priority_status_badge.dart';
import '../widgets/responsive_layout_builder.dart';
import 'academic_detail_screen.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF2563EB)),
              tooltip: 'Tambah Tugas Baru',
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
      ),
      body: ResponsiveLayoutBuilder(
        compact: (context, constraints) => _buildCompactLayout(context),
        wide: (context, constraints) => _buildWideLayout(context),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderGreeting(context),
          const SizedBox(height: 16),
          _buildDeadlineReminder(context),
          const SizedBox(height: 20),
          _buildStatSection(context),
          const SizedBox(height: 24),
          _buildUpcomingTasksSection(context),
          const SizedBox(height: 24),
          _buildUpcomingAcademicSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderGreeting(context),
                const SizedBox(height: 16),
                _buildDeadlineReminder(context),
                const SizedBox(height: 24),
                _buildStatSection(context),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUpcomingTasksSection(context),
                const SizedBox(height: 24),
                _buildUpcomingAcademicSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderGreeting(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final pendingCount = taskProvider.pendingCount + taskProvider.progressCount;

    String dateStr;
    try {
      dateStr = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now());
    } catch (_) {
      dateStr = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E293B), // Slate 800
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.school_rounded, color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Halo, Suniaramana 👋',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pendingCount > 0
                ? 'Ada $pendingCount tugas & agenda aktif yang perlu diselesaikan.'
                : 'Semua tugas kuliah saat ini sudah terselesaikan. Bagus sekali!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Pengingat Deadline / Agenda Terdekat dari Database
  Widget _buildDeadlineReminder(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final activeTasks = taskProvider.tasks
        .where((t) => t.taskStatus.toLowerCase() != 'selesai')
        .toList();

    activeTasks.sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));
    final closestTask = activeTasks.isNotEmpty ? activeTasks.first : null;

    if (closestTask == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semua Agenda Tuntas!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D), fontSize: 13),
                  ),
                  Text(
                    'Tidak ada deadline mendesak saat ini.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isOrg = closestTask.courseName.startsWith('[Organisasi]');
    final displayCourse = closestTask.courseName
        .replaceFirst('[Organisasi] ', '')
        .replaceFirst('[Organisasi]', '');

    final accentColor = isOrg ? const Color(0xFF9333EA) : const Color(0xFFDC2626);
    final bgLight = isOrg ? const Color(0xFFFAF5FF) : const Color(0xFFFEF2F2);
    final borderLight = isOrg ? const Color(0xFFF3E8FF) : const Color(0xFFFEE2E2);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTaskScreen(
              taskId: closestTask.id,
              title: closestTask.taskTitle,
              courseName: closestTask.courseName,
              deadlineDate: closestTask.deadlineDate,
              priority: closestTask.priority,
              status: closestTask.taskStatus,
              notes: closestTask.notes,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderLight, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOrg ? Icons.groups_rounded : Icons.alarm_rounded,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isOrg ? 'AGENDA TERDEKAT' : 'DEADLINE TERDEKAT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${closestTask.deadlineDate}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    closestTask.taskTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    displayCourse,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Statistik Aktivitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'Total: ${taskProvider.totalCount}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Pending', '${taskProvider.pendingCount}', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
            const SizedBox(width: 10),
            _buildStatCard('Progress', '${taskProvider.progressCount}', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
            const SizedBox(width: 10),
            _buildStatCard('Selesai', '${taskProvider.completedCount}', const Color(0xFF16A34A), const Color(0xFFF0FDF4)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: textColor.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bagian Jadwal & Tugas Kuliah dari Database Supabase
  Widget _buildUpcomingTasksSection(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final activeTasks = taskProvider.tasks
        .where((t) => t.taskStatus.toLowerCase() != 'selesai')
        .toList();
    activeTasks.sort((a, b) => a.deadlineDate.compareTo(b.deadlineDate));
    final displayTasks = activeTasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tugas & Kegiatan Terdekat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${activeTasks.length} aktif',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (displayTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                'Belum ada tugas atau agenda aktif saat ini.',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ),
          )
        else
          ...displayTasks.map((task) => _buildTaskItem(context, task)),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, StudentTaskModel task) {
    final isOrg = task.courseName.startsWith('[Organisasi]');
    final cleanCourse = task.courseName
        .replaceFirst('[Organisasi] ', '')
        .replaceFirst('[Organisasi]', '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOrg
                ? const Color(0xFFFAF5FF)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isOrg ? Icons.groups_rounded : Icons.assignment_outlined,
            color: isOrg ? const Color(0xFF9333EA) : const Color(0xFF2563EB),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            if (isOrg)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Organisasi',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                ),
              ),
            Expanded(
              child: Text(
                task.taskTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
        subtitle: Text(
          "$cleanCourse • $task.deadlineDate",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: PriorityStatusBadge(label: task.priority, isPriority: true),
        onTap: () {
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
      ),
    );
  }

  // Bagian Agenda & Libur Nasional dari Live REST API
  Widget _buildUpcomingAcademicSection(BuildContext context) {
    final academicProvider = context.watch<AcademicProvider>();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    // Ambil agenda/libur terdekat dari hari ini ke depan
    var upcomingEvents = academicProvider.events
        .where((e) => e.eventDate.compareTo(todayStr) >= 0)
        .take(3)
        .toList();

    if (upcomingEvents.isEmpty && academicProvider.events.isNotEmpty) {
      upcomingEvents = academicProvider.events.take(3).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Libur & Agenda Nasional (API)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${academicProvider.events.length} total',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (academicProvider.isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text('Memuat kalender dari REST API...', style: TextStyle(fontSize: 12.5)),
                ],
              ),
            ),
          )
        else if (upcomingEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text('Tidak ada jadwal mendatang.', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ),
          )
        else
          ...upcomingEvents.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.category.toLowerCase().contains('libur')
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.category.toLowerCase().contains('libur')
                        ? Icons.beach_access_rounded
                        : Icons.calendar_today_rounded,
                    color: item.category.toLowerCase().contains('libur')
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFEA580C),
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text("${item.eventDate} • ${item.category}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AcademicDetailScreen(
                        title: item.title,
                        date: item.eventDate,
                        category: item.category,
                        description: item.description,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
