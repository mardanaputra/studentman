import 'package:flutter/material.dart';
import 'priority_status_badge.dart';

class TaskCardItem extends StatelessWidget {
  final String title;
  final String courseName;
  final String deadlineDate;
  final String priority;
  final String status;
  final String? notes;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool?>? onStatusToggle;

  const TaskCardItem({
    super.key,
    required this.title,
    required this.courseName,
    required this.deadlineDate,
    required this.priority,
    required this.status,
    this.notes,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusToggle,
  });

  bool get isCompleted =>
      status.toLowerCase() == 'selesai' || status.toLowerCase() == 'completed';
  bool get isOrganization => courseName.startsWith('[Organisasi]');
  String get displayCourse => courseName
      .replaceFirst('[Organisasi] ', '')
      .replaceFirst('[Organisasi]', '');

  bool get isOverdue {
    if (isCompleted) return false;
    try {
      final now = DateTime.now();
      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      return deadlineDate.compareTo(todayStr) < 0;
    } catch (_) {
      return false;
    }
  }

  bool get isToday {
    try {
      final now = DateTime.now();
      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      return deadlineDate == todayStr;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const cardBorderColor = Color(0xFFE2E8F0);
    const slateText = Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? const Color(0xFFFCA5A5) : cardBorderColor,
          width: isOverdue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isOrganization) ...[
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
                              Expanded(
                                child: Text(
                                  displayCourse,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isOrganization
                                        ? const Color(0xFF9333EA)
                                        : const Color(0xFF2563EB),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: slateText,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF64748B), size: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: Color(0xFF334155)),
                              SizedBox(width: 8),
                              Text('Edit Jadwal', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                              SizedBox(width: 8),
                              Text('Hapus', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (notes != null && notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isOverdue
                              ? Icons.warning_amber_rounded
                              : (isOrganization
                                  ? Icons.calendar_month_outlined
                                  : Icons.schedule_rounded),
                          size: 14,
                          color: isOverdue
                              ? const Color(0xFFDC2626)
                              : (isToday ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isToday
                              ? '$deadlineDate (Hari Ini)'
                              : (isOverdue ? '$deadlineDate (Terlewat)' : deadlineDate),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isOverdue
                                ? const Color(0xFFDC2626)
                                : (isToday ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                            fontWeight: (isOverdue || isToday) ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (isOverdue)
                          const PriorityStatusBadge(label: 'Terlewat', color: Color(0xFFDC2626)),
                        PriorityStatusBadge(label: priority, isPriority: true),
                        PriorityStatusBadge(label: status),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
