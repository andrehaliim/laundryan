import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/wardrobe_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/screens/wardrobe_item_screen.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/photo_storage.dart';
import 'package:laundryan/widgets/category_sheet.dart';
import 'package:laundryan/widgets/settings_button.dart';
import 'package:provider/provider.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  void _open(BuildContext context, [WardrobeEntry? entry]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WardrobeItemScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wardrobe = context.watch<WardrobeProvider>();
    final categories = context.watch<CategoryProvider>().categories;
    final scheme = Theme.of(context).colorScheme;
    final items = wardrobe.items;

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
            Text(l10n.wardrobeEmpty,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.wardrobeEmptyHint,
                style: TextStyle(color: scheme.onSurfaceVariant)),
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
          childAspectRatio: 0.85,
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
        title: Text(l10n.wardrobe),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.categories,
            onPressed: () => showCategorySheet(context),
          ),
          const SettingsButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addWardrobe,
        onPressed: () => _open(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
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
          Expanded(child: body),
        ],
      ),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.available(entry.availableQty),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}