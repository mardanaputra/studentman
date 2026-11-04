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
    // 1. Ekstrak judul (mendukung nager.date, api-harilibur, dan mock json)
    final resolvedTitle = json['localName'] ??
        json['holiday_name'] ??
        json['name'] ??
        json['title'] ??
        json['summary'] ??
        'Agenda Akademik';

    // 2. Ekstrak tanggal (format YYYY-MM-DD)
    final resolvedDate = json['date'] ??
        json['eventDate'] ??
        json['holiday_date'] ??
        json['event_date'] ??
        '';

    // 3. Tentukan kategori
    final isHoliday = json['is_national_holiday'] == true ||
        json['types'] != null ||
        json['localName'] != null ||
        json['holiday_name'] != null;

    final resolvedCategory = json['category'] ?? (isHoliday ? 'Libur Nasional' : 'Agenda Akademik');

    // 4. Ekstrak deskripsi
    final resolvedDescription = json['description'] ??
        (isHoliday
            ? 'Hari Libur Nasional Indonesia: $resolvedTitle'
            : 'Agenda resmi akademik perkuliahan TRPL');

    final resolvedId = json['id']?.toString() ??
        '${resolvedDate}_${resolvedTitle.hashCode}';

    return AcademicEventModel(
      id: resolvedId,
      title: resolvedTitle.toString(),
      eventDate: resolvedDate.toString(),
      category: resolvedCategory.toString(),
      description: resolvedDescription.toString(),
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
