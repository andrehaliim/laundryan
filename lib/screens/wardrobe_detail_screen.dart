import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/widgets/wardrobe_icons.dart';

class WardrobeDetailScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<WardrobeDetailScreen> createState() => _WardrobeDetailScreenState();
}

class _WardrobeDetailScreenState extends State<WardrobeDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String selectedCategory = 'Celana Panjang';
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
            icon: Icon(Icons.delete),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.dangerTint,
              foregroundColor: AppColors.danger,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
