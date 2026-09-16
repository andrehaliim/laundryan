import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

class WardrobeDeleteConfirmation extends StatelessWidget {
  const WardrobeDeleteConfirmation({
    super.key,
    required this.itemIcon,
    required this.itemName,
    required this.categoryLabel,
    required this.totalQuantity,
    required this.inWardrobeQuantity,
    this.inUseQuantity = 0,
    this.inUseSessionLabel,
  });

  final IconData itemIcon;
  final String itemName;
  final String categoryLabel;
  final int totalQuantity;
  final int inWardrobeQuantity;

  final int inUseQuantity;
  final String? inUseSessionLabel;

  static Future<bool?> show(
    BuildContext context, {
    required IconData itemIcon,
    required String itemName,
    required String categoryLabel,
    required int totalQuantity,
    required int inWardrobeQuantity,
    int inUseQuantity = 0,
    String? inUseSessionLabel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.richBlack.withValues(alpha: 0.5),
      builder: (_) => WardrobeDeleteConfirmation(
        itemIcon: itemIcon,
        itemName: itemName,
        categoryLabel: categoryLabel,
        totalQuantity: totalQuantity,
        inWardrobeQuantity: inWardrobeQuantity,
        inUseQuantity: inUseQuantity,
        inUseSessionLabel: inUseSessionLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.richBlack.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Konfirmasi Hapus',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.royalBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.borderSubtle),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            itemIcon,
                            size: 26,
                            color: AppColors.royalBlue,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.royalBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$categoryLabel • Total $totalQuantity pcs di lemari',
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.tealBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _AllocationRow(
                          icon: Icons.delete_sweep,
                          iconColor: AppColors.danger,
                          title: 'Unit di lemari',
                          description:
                              '$inWardrobeQuantity pcs akan langsung dihapus dari daftar lemari kamu.',
                        ),
                        if (inUseQuantity > 0) ...[
                          const SizedBox(height: 10),
                          Container(height: 1, color: AppColors.borderSubtle),
                          const SizedBox(height: 10),
                          _AllocationRow(
                            icon: Icons.sync,
                            iconColor: AppColors.tealBlue,
                            title: 'Unit sedang dicuci',
                            description:
                                '$inUseQuantity pcs'
                                '${inUseSessionLabel != null ? ' ($inUseSessionLabel)' : ''}'
                                ' – item akan otomatis diarsipkan sampai sesi selesai.',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          size: 20,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tindakan ini tidak dapat dibatalkan. Pastikan pakaian memang sudah tidak dimiliki.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Hapus Pakaian Ini'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Kembali ke Wardrobe',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationRow extends StatelessWidget {
  const _AllocationRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}