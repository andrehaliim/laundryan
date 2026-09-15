import 'package:flutter/material.dart';
import 'package:laundryan/core/database/app_database.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_addedit_screen.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_widget_filterchip.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_icons.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_widget_card.dart';

class WardrobeFilledScreen extends StatelessWidget {
  const WardrobeFilledScreen({
    super.key,
    required this.items,
    required this.searchController,
    required this.onSearchChanged,
    required this.isSearching,
  });

  final List<WardrobeItem> items;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool isSearching;

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
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Pakaian di lemari...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: isSearching
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        WardrobeFilterChips(),
        const SizedBox(height: 8),
        Expanded(
          child: items.isEmpty
              ? _NoSearchResults(query: searchController.text)
              : GridView.builder(
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

                    return WardrobeCard(
                      icon: category.icon,
                      name: item.name,
                      quantityOwned: item.quantityOwned,
                      quantityInUse: 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WardrobeAddEditScreen(existingItem: item),
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

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada hasil untuk "$query"',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
