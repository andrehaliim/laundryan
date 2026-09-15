import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_icons.dart';

class WardrobeFilterChips extends StatefulWidget {
  const WardrobeFilterChips({super.key, this.onFilterChanged});

  final ValueChanged<String>? onFilterChanged;

  @override
  State<WardrobeFilterChips> createState() => _WardrobeFilterChipsState();
}

class _WardrobeFilterChipsState extends State<WardrobeFilterChips> {
  final List<WardrobeFilterOption> _options = [
    const WardrobeFilterOption(label: 'Semua', count: 0),
    const WardrobeFilterOption(
      label: 'Sedang Dicuci',
      count: 0,
      showWarningDot: true,
    ),
    ...clothingCategories.map((c) {
      return WardrobeFilterOption(label: c.name, count: 0);
    }),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final maxHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: maxHeight * 0.05,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _options[index];
          final isActive = index == _selectedIndex;

          return _FilterChip(
            option: option,
            isActive: isActive,
            textTheme: textTheme,
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onFilterChanged?.call(option.label);
            },
          );
        },
      ),
    );
  }
}

class WardrobeFilterOption {
  const WardrobeFilterOption({
    required this.label,
    required this.count,
    this.showWarningDot = false,
  });

  final String label;
  final int count;
  final bool showWarningDot;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.isActive,
    required this.textTheme,
    required this.onTap,
  });

  final WardrobeFilterOption option;
  final bool isActive;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = textTheme.labelMedium?.copyWith(
      color: isActive ? AppColors.offWhite : AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          margin: const EdgeInsets.symmetric(vertical: 4),
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.royalBlue : Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.richBlack.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.showWarningDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text('${option.label} (${option.count})', style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}