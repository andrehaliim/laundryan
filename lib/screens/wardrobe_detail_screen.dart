import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/widgets/wardrobe_icons.dart';
import 'package:laundryan/widgets/widgets.dart';

class WardrobeDetailScreen extends StatefulWidget {
  const WardrobeDetailScreen({super.key});

  @override
  State<WardrobeDetailScreen> createState() => _WardrobeDetailScreenState();
}

class _WardrobeDetailScreenState extends State<WardrobeDetailScreen>
    with SingleTickerProviderStateMixin {
  String selectedCategory = 'Celana Panjang';
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  int _quantity = 1;
  static const _minQty = 1;
  static const _maxQty = 99;

  void _updateQuantity(int newVal) {
    setState(() => _quantity = newVal.clamp(_minQty, _maxQty));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        leadingWidth: 56,
        leading: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(fixedSize: const Size(40, 40)),
          ),
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah ke Wardrobe',
              style: textTheme.titleLarge?.copyWith(color: AppColors.royalBlue),
            ),
            Text(
              'Lengkapi detail koleksi pakaian',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        actions: [
          IconButton.filled(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await DeleteConfirmSheet.show(
                context,
                itemIcon: Icons.checkroom_outlined,
                itemName: _nameController.text.isEmpty
                    ? 'Item Pakaian'
                    : _nameController.text,
                categoryLabel: selectedCategory,
                totalQuantity: _quantity,
                inWardrobeQuantity: _quantity,
                inUseQuantity: 0,
              );
              if (confirmed == true && context.mounted) {
                Navigator.pop(context);
              }
            },
            style: IconButton.styleFrom(
              fixedSize: const Size(40, 40),
              backgroundColor: AppColors.dangerTint,
              foregroundColor: AppColors.danger,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Jenis & Icon Pakaian',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.richBlack,
                      ),
                    ),
                    Text(
                      selectedCategory,
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: AppColors.tealBlue),
                    ),
                  ],
                ),

                Text(
                  'Pilih icon yang paling mewakili pakaian ini di lemari',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                ClothingCategorySelector(
                  selectedCategory: selectedCategory,
                  onChanged: (category) {
                    setState(() {
                      selectedCategory = category.name;
                    });
                  },
                ),

                const SizedBox(height: 16),

                Container(
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
                      // Nama Pakaian
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
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Kaos Polos Uniqlo, Celana Chino',
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

                      // Kategori Sistem — synced dgn icon grid di atas
                      Text(
                        'Kategori Sistem',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.royalBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        icon: const Icon(Icons.unfold_more, size: 20),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundIconButton,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: clothingCategories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.name,
                                child: Text(
                                  c.name,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.richBlack,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedCategory = value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Catatan Varian / Warna (opsional)
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
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText:
                              'Misal: Warna hitam, navy, putih atau ukuran L',
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
                ),

                const SizedBox(height: 16),

                // ── Section 3: Quantity-First Stepper ──
                Container(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jumlah Unit Dimiliki',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.royalBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Total pakaian jenis ini yang ada di lemari kamu',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.tealBlue.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: AppColors.tealBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Big stepper
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BigStepperButton(
                              icon: Icons.remove,
                              enabled: _quantity > _minQty,
                              background: Colors.white,
                              foreground: AppColors.royalBlue,
                              onTap: () => _updateQuantity(_quantity - 1),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_quantity',
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: AppColors.royalBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'pcs',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: AppColors.tealBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Siap rotasi laundry',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            _BigStepperButton(
                              icon: Icons.add,
                              enabled: _quantity < _maxQty,
                              background: AppColors.royalBlue,
                              foreground: AppColors.offWhite,
                              onTap: () => _updateQuantity(_quantity + 1),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Quick add chips
                      Text(
                        'Tambah cepat instan:',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [1, 2, 5, 10].map((amount) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: amount == 10 ? 0 : 8,
                              ),
                              child: _QuickAddChip(
                                amount: amount,
                                onTap: () =>
                                    _updateQuantity(_quantity + amount),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final saved = await Future.delayed(
                        const Duration(seconds: 1),
                        () => true,
                      );
                      if (mounted && saved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pakaian berhasil disimpan'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Simpan ke Wardrobe',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.offWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BigStepperButton extends StatelessWidget {
  const _BigStepperButton({
    required this.icon,
    required this.enabled,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? background : AppColors.borderSubtle,
      shape: const CircleBorder(),
      elevation: enabled && background == Colors.white ? 1 : 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? foreground
                : AppColors.richBlack.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({required this.amount, required this.onTap});

  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.tealBlue.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          child: Center(
            child: Text(
              '+$amount pcs',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.royalBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
