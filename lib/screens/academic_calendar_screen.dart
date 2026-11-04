import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_provider.dart';
import '../widgets/state_feedback_placeholder.dart';
import 'academic_detail_screen.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final academicProvider = context.watch<AcademicProvider>();
    final categories = academicProvider.availableCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda & Kalender'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = academicProvider.selectedCategory.toLowerCase() == cat.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => academicProvider.setCategoryFilter(cat),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (academicProvider.isLoading) {
            return const StateFeedbackPlaceholder.loading();
          }

          if (academicProvider.errorMessage != null) {
            return StateFeedbackPlaceholder.error(
              message: academicProvider.errorMessage!,
              onRetry: () => academicProvider.loadInitialData(),
            );
          }

          final events = academicProvider.filteredEvents;
          if (events.isEmpty) {
            return StateFeedbackPlaceholder.empty(
              title: 'Tidak Ada Agenda',
              message: 'Tidak ada agenda di kategori "${academicProvider.selectedCategory}".',
              onRetry: () => academicProvider.setCategoryFilter('Semua'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final item = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(item.title),
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
              );
            },
          );
        },
      ),
    );
  }
}
