import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'status_badge.dart';

/// Card buat list "Sesi Aktif" & "Riwayat" di tab Sesi Laundry.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.dateLabel,
    required this.totalItems,
    required this.status,
    required this.statusLabel,
    this.lostItemsCount,
    this.onTap,
  });

  final String dateLabel;
  final int totalItems;
  final BadgeStatus status;
  final String statusLabel;

  /// Diisi kalau status = lost, buat nampilin "X item hilang" (variant Riwayat).
  final int? lostItemsCount;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12), // radius-card
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '$totalItems item',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (lostItemsCount != null && lostItemsCount! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$lostItemsCount item hilang',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(status: status, label: statusLabel),
            ],
          ),
        ),
      ),
    );
  }
}