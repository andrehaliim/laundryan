import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laundryan',
              style: textTheme.titleLarge?.copyWith(color: AppColors.royalBlue),
            ),
            Text(
              '0 Sesi Aktif',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EmptyStateCard(
                onCreatePressed: () {},
              ),
              const SizedBox(height: 24),
              const _TipsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // radius-card
        boxShadow: [
          BoxShadow(
            color: AppColors.richBlack.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Illustration
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.tealBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.local_laundry_service_rounded,
                  size: 72,
                  color: AppColors.royalBlue,
                ),
                Positioned(
                  top: 16,
                  right: 24,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Badge "Siap Digunakan"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warningTint,
              borderRadius: BorderRadius.circular(999), // radius-badge
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.dry_cleaning, size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(
                  'Siap Digunakan',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Belum ada sesi laundry', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Mulai catat cucian kamu biar nggak ada yang hilang atau tertukar.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Buat Sesi Baru'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tips Praktis', style: textTheme.titleLarge),
              Text(
                'PANDUAN',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.tealBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TipCard(
                icon: Icons.verified_outlined,
                iconBg: AppColors.royalBlue.withValues(alpha: 0.08),
                iconColor: AppColors.royalBlue,
                title: 'Hitung & Cek',
                description:
                    'Catat jumlah baju sebelum diserahkan ke kasir laundry.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TipCard(
                icon: Icons.notifications_active_outlined,
                iconBg: AppColors.tealBlue.withValues(alpha: 0.12),
                iconColor: AppColors.tealBlue,
                title: 'Lacak Status',
                description:
                    'Pantau sesi aktif sampai pakaian kembali rapi ke lemari.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}