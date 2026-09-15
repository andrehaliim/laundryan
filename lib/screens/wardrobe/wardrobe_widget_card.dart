import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/core/providers/wardrobe_providers.dart';
import 'package:laundryan/core/theme/app_colors.dart';

class WardrobeCard extends ConsumerWidget {
  const WardrobeCard({
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
                      size: 30,
                      color: AppColors.royalBlue,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningTint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$quantityInUse dicuci',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.royalBlue,
                ),
              ),
              itemsAsync.when(
                data: (items) => Text(
                  '${items.length} di lemari',
                  style: textTheme.bodySmall?.copyWith(
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
