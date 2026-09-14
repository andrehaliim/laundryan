import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

class ClothingCategory {
  final String name;
  final String label;
  final IconData icon;

  const ClothingCategory({
    required this.name,
    required this.label,
    required this.icon,
  });
}

const clothingCategories = [
  ClothingCategory(
    name: 'Kaos / T-Shirt',
    label: 'Kaos',
    icon: Icons.checkroom_outlined,
  ),
  ClothingCategory(
    name: 'Kemeja',
    label: 'Kemeja',
    icon: Icons.business_center_outlined,
  ),
  ClothingCategory(
    name: 'Celana Panjang',
    label: 'Celana Pjg',
    icon: Icons.straighten_outlined,
  ),
  ClothingCategory(
    name: 'Celana Pendek',
    label: 'Pendek',
    icon: Icons.short_text_outlined,
  ),
  ClothingCategory(
    name: 'Jaket / Hoodie',
    label: 'Jaket',
    icon: Icons.wb_sunny_outlined,
  ),
  ClothingCategory(
    name: 'Kaos Kaki',
    label: 'Kaos Kaki',
    icon: Icons.snowshoeing_outlined,
  ),
  ClothingCategory(
    name: 'Pakaian Dalam',
    label: 'Undies',
    icon: Icons.dry_cleaning_outlined,
  ),
  ClothingCategory(
    name: 'Handuk / Linen',
    label: 'Handuk',
    icon: Icons.layers_outlined,
  ),
];

class ClothingCategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<ClothingCategory> onChanged;

  const ClothingCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clothingCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final category = clothingCategories[index];
        final isSelected = category.name == selectedCategory;

        return _CategoryItem(
          category: category,
          isSelected: isSelected,
          onTap: () => onChanged(category),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final ClothingCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.royalBlue : AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.richBlack.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Check badge
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 11,
                      color: AppColors.offWhite,
                    ),
                  ),
                ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.backgroundIconButton.withValues(
                                  alpha: 0.15,
                                )
                              : AppColors.backgroundIconButton,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.offWhite
                              : AppColors.royalBlue,
                        ),
                      ),

                      // Label
                      Text(
                        category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppColors.offWhite
                              : AppColors.royalBlue,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
