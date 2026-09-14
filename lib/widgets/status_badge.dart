import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

/// 3 status yang bisa ditampilkan sebagai pill badge.
/// Dipisah dari `SessionStatus` (enum di database) biar widget ini
/// nggak depend langsung ke layer data.
enum BadgeStatus { running, success, lost }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, required this.label});

  final BadgeStatus status;
  final String label;

  Color get _color {
    switch (status) {
      case BadgeStatus.running:
        return AppColors.warning;
      case BadgeStatus.success:
        return AppColors.success;
      case BadgeStatus.lost:
        return AppColors.danger;
    }
  }

  Color get _tint {
    switch (status) {
      case BadgeStatus.running:
        return AppColors.warningTint;
      case BadgeStatus.success:
        return AppColors.successTint;
      case BadgeStatus.lost:
        return AppColors.dangerTint;
    }
  }

  IconData get _icon {
    switch (status) {
      case BadgeStatus.running:
        return Icons.local_laundry_service_rounded;
      case BadgeStatus.success:
        return Icons.check_circle_rounded;
      case BadgeStatus.lost:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // space-sm / space-xs
      decoration: BoxDecoration(
        color: _tint,
        borderRadius: BorderRadius.circular(999), // radius-badge
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}