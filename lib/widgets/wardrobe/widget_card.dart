import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/core/providers/wardrobe_providers.dart';
import 'package:laundryan/core/theme/app_colors.dart';

class WardrobeWidgetCard extends ConsumerWidget {
  const WardrobeWidgetCard({
    super.key,
    required this.icon,
    required this.name,
    required this.quantityOwned,
    this.quantityInUse,
    this.onTap,
  });

  final List<List<dynamic>> icon;
  final String name;
  final int quantityOwned;
  final int? quantityInUse;
  final VoidCallback? onTap;

  bool get hasQuantityInUse => quantityInUse != null && quantityInUse! > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final itemsAsync = ref.watch(wardrobeItemsStreamProvider);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tealBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HugeIcon(
                      icon: icon,
                      strokeWidth: 1.5,
                      size: 24,
                      color: AppColors.royalBlue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: hasQuantityInUse
                          ? AppColors.warningTint
                          : AppColors.successTint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      hasQuantityInUse ? '$quantityInUse dicuci' : 'Available',
                      style: textTheme.bodySmall?.copyWith(
                        color: hasQuantityInUse
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.royalBlue,
                ),
              ),
              itemsAsync.when(
                data: (items) => Text(
                  '$quantityOwned di lemari',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              Spacer(),
              Text(
                'x$quantityOwned',
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.richBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
