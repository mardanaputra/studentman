class StudentTaskModel {
  final int? id;
  final String courseName;
  final String taskTitle;
  final String deadlineDate;
  final String priority;
  final String taskStatus;
  final String notes;
  final DateTime? createdAt;

  StudentTaskModel({
    this.id,
    required this.courseName,
    required this.taskTitle,
    required this.deadlineDate,
    this.priority = 'Sedang',
    this.taskStatus = 'Pending',
    required this.notes,
    this.createdAt,
  });

  factory StudentTaskModel.fromJson(Map<String, dynamic> json) {
    return StudentTaskModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      courseName: json['course_name'] ?? '',
      taskTitle: json['task_title'] ?? '',
      deadlineDate: json['deadline_date'] ?? '',
      priority: json['priority'] ?? 'Sedang',
      taskStatus: json['task_status'] ?? 'Pending',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'course_name': courseName,
      'task_title': taskTitle,
      'deadline_date': deadlineDate,
      'priority': priority,
      'task_status': taskStatus,
      'notes': notes,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  StudentTaskModel copyWith({
    int? id,
    String? courseName,
    String? taskTitle,
    String? deadlineDate,
    String? priority,
    String? taskStatus,
    String? notes,
    DateTime? createdAt,
  }) {
    return StudentTaskModel(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      taskTitle: taskTitle ?? this.taskTitle,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      priority: priority ?? this.priority,
      taskStatus: taskStatus ?? this.taskStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

