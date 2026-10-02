import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/wardrobe_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/screens/wardrobe_item_screen.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/photo_storage.dart';
import 'package:laundryan/widgets/settings_button.dart';
import 'package:provider/provider.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  void _open(BuildContext context, [WardrobeEntry? entry]) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => WardrobeItemScreen(entry: entry)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wardrobe = context.watch<WardrobeProvider>();
    final categories = context.watch<CategoryProvider>().categories;
    final scheme = Theme.of(context).colorScheme;
    final items = wardrobe.items;
    final selectedId = categories.any((c) => c.id == wardrobe.categoryId)
        ? wardrobe.categoryId
        : null;
    if (wardrobe.categoryId != null && selectedId == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => wardrobe.setCategory(null),
      );
    }

    Widget body;
    if (wardrobe.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedShirt01,
              size: 72,
              color: scheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.wardrobeEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.wardrobeEmptyHint,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    } else if (items.isEmpty) {
      body = Center(child: Text(l10n.noResults));
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final entry = items[i];
          final Category? cat = categories
              .where((c) => c.id == entry.item.categoryId)
              .firstOrNull;
          return _ItemCard(
            entry: entry,
            category: cat,
            onTap: () => _open(context, entry),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/icon/icon.png', height: 40),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  l10n.wardrobe,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        actions: [const SettingsButton()],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addWardrobe,
        onPressed: () => _open(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  l10n.myWardrobe,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                CountBadge(
                  count: items.length,
                  label: l10n.items,
                  horizontalPadding: 12,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: context.read<WardrobeProvider>().setQuery,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          if (!wardrobe.isEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: buildChip(
                      context,
                      l10n.all,
                      selectedId == null,
                      (_) => wardrobe.setCategory(null),
                    ),
                  ),
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: buildChip(
                        context,
                        categoryName(c, l10n),
                        selectedId == c.id,
                        (_) => wardrobe.setCategory(c.id),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: body),
        ],
      ),
    );
  }

  //chip style
  Widget buildChip(
    BuildContext context,
    String label,
    bool selected,
    ValueChanged<bool>? onTap,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: selected
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurface,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      side: BorderSide.none,
      elevation: 3,
      pressElevation: 4,
      selectedShadowColor: Theme.of(context).colorScheme.onSurface
          .withValues(alpha: 0.2),
      shadowColor: Theme.of(context).colorScheme.onSurface
          .withValues(alpha: 0.2),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final WardrobeEntry entry;
  final Category? category;
  final VoidCallback onTap;

  const _ItemCard({
    required this.entry,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final file = PhotoStorage.file(entry.item.photoPath);
    final cat = context.watch<CategoryProvider>().byId(entry.item.categoryId);
    final catName = cat == null ? '' : categoryName(cat, l10n);

    final iconBox = Container(
      width: double.infinity,
      color: scheme.primaryContainer.withValues(alpha: 0.4),
      alignment: Alignment.center,
      child: HugeIcon(
        icon: iconFor(category?.iconKey ?? ''),
        size: 48,
        color: scheme.primary,
      ),
    );

    return SoftCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: file == null
                    ? iconBox
                    : Image.file(
                        file,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheWidth: 400,
                        errorBuilder: (_, _, _) => iconBox,
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Text(
                  entry.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CountBadge(
                      count: 3,
                      label: 'Available',
                      mode: CountBadgeMode.tertiary,
                      horizontalPadding:
                          MediaQuery.sizeOf(context).width * 0.015,
                    ),
                    Spacer(),
                    CountBadge(
                      count: 5,
                      label: 'in Wash',
                      mode: CountBadgeMode.secondary,
                      horizontalPadding:
                          MediaQuery.sizeOf(context).width * 0.015,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
