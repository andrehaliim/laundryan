import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundryan/core/database/app_database.dart';
import 'package:laundryan/core/providers/wardrobe_providers.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/screens/wardrobe_detail_screen.dart';
import 'package:laundryan/widgets/wardrobe_icons.dart';
import 'package:laundryan/widgets/widgets.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(wardrobeItemsStreamProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wardrobe Saya',
              style: textTheme.titleLarge?.copyWith(color: AppColors.royalBlue),
            ),
            itemsAsync.when(
              data: (items) => Text(
                '${items.length} Pakaian Terdaftar',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: itemsAsync.when(
            data: (items) => items.isEmpty
                ? const _EmptyState()
                : _FilledState(items: items),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WardrobeDetailScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Item Baru'),
      ),
    );
  }
}

class _FilledState extends StatelessWidget {
  const _FilledState({required this.items});

  final List<WardrobeItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.richBlack.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Pakaian di lemari...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        WardrobeFilterChips(),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final category = clothingCategories.firstWhere(
                (c) => c.name == item.iconName,
                orElse: () => clothingCategories.last,
              );

              return WardrobeItemCard(
                icon: category.icon,
                name: item.name,
                quantityOwned: item.quantityOwned,
                quantityInUse: 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WardrobeDetailScreen(existingItem: item),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmptyStateCard(onAddPressed: () {}),
          const SizedBox(height: 24),
          const _BenefitsSection(),
          const SizedBox(height: 16),
          const _TipMicroCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.onAddPressed});

  final VoidCallback onAddPressed;

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
            color: AppColors.richBlack.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
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
                  Icons.checkroom_rounded,
                  size: 72,
                  color: AppColors.royalBlue,
                ),
                Positioned(
                  top: 20,
                  right: 28,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lemari Pakaian Masih Kosong',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(color: AppColors.royalBlue),
          ),
          const SizedBox(height: 8),
          Text(
            'Catat koleksi pakaian yang sering kamu laundry. Cukup masukkan '
            'nama, kategori, dan jumlah unitnya.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Tambah Pakaian Pertama'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection();

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
              Expanded(
                child: Text(
                  'KEUNTUNGAN MENCATAT WARDROBE',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                'Smart Laundry',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.tealBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BenefitCard(
          icon: Icons.bolt,
          iconBg: AppColors.tealBlue.withValues(alpha: 0.12),
          iconColor: AppColors.tealBlue,
          title: 'Input Sesi Lebih Kilat',
          description:
              'Tinggal centang dan pilih jumlah saat mau berangkat ke '
              'laundry tanpa repot mengetik ulang.',
        ),
        const SizedBox(height: 12),
        _BenefitCard(
          icon: Icons.verified_user_outlined,
          iconBg: AppColors.dangerTint,
          iconColor: AppColors.danger,
          title: 'Deteksi Pakaian Hilang Akurat',
          description:
              'Otomatis tahu jenis pakaian apa yang belum kembali saat '
              'sesi verifikasi laundry selesai.',
        ),
      ],
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.w600,
                  ),
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
          ),
        ],
      ),
    );
  }
}

class _TipMicroCard extends StatelessWidget {
  const _TipMicroCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 20, color: AppColors.tealBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: Mulai dari pakaian harian seperti Kaos Oblong, Kemeja '
              'Kerja, atau Celana Jeans.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}