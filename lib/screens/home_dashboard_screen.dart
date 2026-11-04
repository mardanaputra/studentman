import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/responsive_layout_builder.dart';
import 'academic_detail_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard StudentMan'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(context),
          const SizedBox(height: 20),
          _buildStatSection(context),
          const SizedBox(height: 24),
          _buildUpcomingSection(context),
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
                _buildBanner(context),
                const SizedBox(height: 24),
                _buildStatSection(context),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: _buildUpcomingSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, Suniaramana 👋',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tetap produktif dan kelola jadwal kuliahmu hari ini.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSection(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Tugas Kuliah',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(context, 'Pending', '${taskProvider.pendingCount}', Colors.orange, Icons.hourglass_top_rounded),
            const SizedBox(width: 12),
            _buildStatCard(context, 'Progress', '${taskProvider.progressCount}', Colors.blue, Icons.run_circle_outlined),
            const SizedBox(width: 12),
            _buildStatCard(context, 'Selesai', '${taskProvider.completedCount}', Colors.green, Icons.check_circle_outline),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    final academicProvider = context.watch<AcademicProvider>();
    final upcomingEvents = academicProvider.events.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Agenda Terdekat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Total: ${academicProvider.events.length}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (upcomingEvents.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Belum ada agenda terdekat.'),
            ),
          )
        else
          ...upcomingEvents.map(
            (item) => Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text("${item.eventDate} • ${item.category}"),
                trailing: const Icon(Icons.chevron_right_rounded),
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

  Widget _buildStatCard(BuildContext context, String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
