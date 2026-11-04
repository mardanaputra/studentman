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
      return Colors.red;
    }
    if (normalized.contains('sedang') || normalized.contains('medium') || normalized.contains('progress')) {
      return Colors.orange;
    }
    if (normalized.contains('selesai') || normalized.contains('completed') || normalized.contains('rendah') || normalized.contains('low')) {
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _resolveColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
