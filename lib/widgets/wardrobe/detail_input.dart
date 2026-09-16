import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

class WardrobeDetailInput extends StatelessWidget {
  const WardrobeDetailInput({
    super.key,
    required this.nameController,
    required this.notesController,
  });

  final TextEditingController nameController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.richBlack.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Pakaian',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '*Wajib',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Contoh: Kaos Polos, Celana Chino',
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.backgroundIconButton,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Beri nama spesifik agar mudah dikenali saat verifikasi laundry.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catatan Varian / Warna',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Opsional',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: notesController,
            decoration: InputDecoration(
              hintText: 'Misal: Warna hitam, navy, putih atau ukuran L',
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.backgroundIconButton,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
