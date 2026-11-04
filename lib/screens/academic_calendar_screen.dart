import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_provider.dart';
import '../widgets/state_feedback_placeholder.dart';
import 'academic_detail_screen.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academicProvider = context.watch<AcademicProvider>();
    final categories = academicProvider.availableCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda & Kalender Akademik'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari agenda atau libur nasional...',
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
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => academicProvider.fetchEvents(),
        child: Builder(
          builder: (context) {
            if (academicProvider.isLoading) {
              return const StateFeedbackPlaceholder.loading(
                title: 'Menghubungkan ke REST API...',
                message: 'Sedang mengunduh kalender akademik & hari libur nasional',
              );
            }

            if (academicProvider.errorMessage != null) {
              return StateFeedbackPlaceholder.error(
                message: academicProvider.errorMessage!,
                onRetry: () => academicProvider.fetchEvents(),
              );
            }

            var events = academicProvider.filteredEvents;
            if (_searchQuery.isNotEmpty) {
              events = events.where((e) =>
                  e.title.toLowerCase().contains(_searchQuery) ||
                  e.description.toLowerCase().contains(_searchQuery) ||
                  e.category.toLowerCase().contains(_searchQuery)).toList();
            }

            if (events.isEmpty) {
              return StateFeedbackPlaceholder.empty(
                title: 'Tidak Ada Agenda',
                message: _searchQuery.isNotEmpty
                    ? 'Tidak ada agenda yang cocok dengan pencarian "$_searchQuery".'
                    : 'Tidak ada agenda di kategori "${academicProvider.selectedCategory}".',
                onRetry: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  academicProvider.setCategoryFilter('Semua');
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = events[index];
                final isHoliday = item.category.toLowerCase().contains('libur');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isHoliday
                            ? Colors.red.withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isHoliday ? Icons.beach_access_rounded : Icons.calendar_today_rounded,
                        color: isHoliday ? Colors.red : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("${item.eventDate} • ${item.category}"),
                    ),
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
      ),
    );
  }
}
