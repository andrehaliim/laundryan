import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundryan/core/providers/wardrobe_providers.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_addedit_screen.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_empty_screen.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_filled_screen.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
            data: (items) {
              if (items.isEmpty) return const WardrobeEmptyScreen();

              final filteredItems = _searchQuery.isEmpty
                  ? items
                  : items
                        .where(
                          (item) => item.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();

              return WardrobeFilledScreen(
                items: filteredItems,
                searchController: _searchController,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                isSearching: _searchQuery.isNotEmpty,
              );
            },
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
              builder: (context) => const WardrobeAddEditScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Item Baru'),
      ),
    );
  }
}
