class AcademicEventModel {
  final String id;
  final String title;
  final String eventDate;
  final String category;
  final String description;

  AcademicEventModel({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.category,
    required this.description,
  });

  factory AcademicEventModel.fromJson(Map<String, dynamic> json) {
    // Handle both standardized academic event fields and public holiday API (api-harilibur)
    final resolvedTitle = json['title'] ?? json['holiday_name'] ?? json['name'] ?? 'Agenda Akademik';
    final resolvedDate = json['eventDate'] ?? json['event_date'] ?? json['holiday_date'] ?? json['date'] ?? '';
    final isHoliday = json['is_national_holiday'] == true;
    final resolvedCategory = json['category'] ?? (isHoliday ? 'Libur Nasional' : 'Agenda Akademik');
    final resolvedDescription = json['description'] ??
        (isHoliday
            ? 'Hari Libur Nasional Indonesia: $resolvedTitle'
            : 'Agenda akademik mahasiswa TRPL');
    final resolvedId = json['id']?.toString() ??
        '${resolvedDate}_${resolvedTitle.hashCode}';

    return AcademicEventModel(
      id: resolvedId,
      title: resolvedTitle,
      eventDate: resolvedDate,
      category: resolvedCategory,
      description: resolvedDescription,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'eventDate': eventDate,
      'category': category,
      'description': description,
    };
  }

  AcademicEventModel copyWith({
    String? id,
    String? title,
    String? eventDate,
    String? category,
    String? description,
  }) {
    return AcademicEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}
