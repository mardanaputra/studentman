import 'package:flutter/material.dart';

class PriorityStatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isPriority;

  const PriorityStatusBadge({
    super.key,
    required this.label,
    this.color,
    this.isPriority = false,
  });

  Color _resolveColor() {
    if (color != null) return color!;
    final normalized = label.toLowerCase();
    if (normalized.contains('tinggi') || normalized.contains('high') || normalized.contains('terlambat')) {
      return const Color(0xFFDC2626); // Modern Red
    }
    if (normalized.contains('sedang') || normalized.contains('medium') || normalized.contains('progress')) {
      return const Color(0xFFD97706); // Modern Amber / Orange
    }
    if (normalized.contains('selesai') || normalized.contains('completed')) {
      return const Color(0xFF16A34A); // Modern Green
    }
    if (normalized.contains('rendah') || normalized.contains('low')) {
      return const Color(0xFF64748B); // Slate
    }
    if (normalized.contains('organisasi')) {
      return const Color(0xFF9333EA); // Purple
    }
    return const Color(0xFF2563EB); // Royal Blue
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _resolveColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
