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
import 'package:laundryan/widgets/empty_state.dart';
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
      body = EmptyState(
        icon: HugeIcons.strokeRoundedWardrobe01,
        orbit: const [
          HugeIcons.strokeRoundedTShirt,
          HugeIcons.strokeRoundedDress01,
        ],
        title: l10n.wardrobeEmpty,
        message: l10n.wardrobeEmptyHint,
        actionLabel: l10n.addWardrobe,
        actionIcon: HugeIcons.strokeRoundedPlusSign,
        onAction: () => _open(context),
      );
    } else if (items.isEmpty) {
      body = EmptyState(
        tone: EmptyStateTone.secondary,
        icon: HugeIcons.strokeRoundedSearchRemove,
        orbit: const [
          HugeIcons.strokeRoundedTShirt,
          HugeIcons.strokeRoundedTag01,
        ],
        title: l10n.noResults,
        message: l10n.noResultsHint,
      );
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
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
      floatingActionButton: wardrobe.isEmpty
          ? null
          : FloatingActionButton(
              heroTag: 'fab_wardrobe',
              tooltip: l10n.addWardrobe,
              onPressed: () => _open(context),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedPlusSign,
                strokeWidth: 2,
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!wardrobe.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: context.read<WardrobeProvider>().setQuery,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            size: 20,
                            strokeWidth: 2,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: wardrobe.toggleSort,
                    child: HugeIcon(
                      icon: switch (wardrobe.sort) {
                        WardrobeSort.alphabetDesc =>
                          HugeIcons.strokeRoundedSortingZA01,
                        WardrobeSort.alphabetAsc =>
                          HugeIcons.strokeRoundedSortingAZ02,
                      },
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
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
                      '${l10n.all} (${items.length})',
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
          ],
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget buildChip(
    BuildContext context,
    String label,
    bool selected,
    ValueChanged<bool>? onTap,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    final radius = BorderRadius.circular(20);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isLight ? 0.01 : 0.3),
            blurRadius: 3,
          ),
        ],
      ),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: onTap,
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        backgroundColor: theme.cardTheme.color,
        selectedColor: scheme.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? scheme.onPrimary : scheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.availableQty.toString(),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedWardrobe01,
                      size: 16,
                      color: scheme.tertiary,
                      strokeWidth: 2,
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                    Text(
                      entry.lockedQty.toString(),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedWashingMachine,
                      size: 16,
                      color: scheme.primary,
                      strokeWidth: 2,
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
                    Text(
                      entry.missingQty.toString(),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert01,
                      size: 16,
                      color: scheme.secondary,
                      strokeWidth: 2,
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.01),
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
