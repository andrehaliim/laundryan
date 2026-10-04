import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:provider/provider.dart';

Future<void> showCategorySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CategorySheet(),
  );
}

class CategorySheet extends StatefulWidget {
  const CategorySheet({super.key});

  @override
  State<CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<CategorySheet> {
  final _nameCtrl = TextEditingController();
  int _tab = 0; // 0 = list, 1 = form
  Category? _editing;
  String _iconKey = categoryIcons.keys.first;
  String? _listError;
  String? _formError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    _editing = null;
    _nameCtrl.clear();
    _iconKey = categoryIcons.keys.first;
    _formError = null;
  }

  void _openEdit(Category c, AppLocalizations l10n) {
    setState(() {
      _editing = c;
      _nameCtrl.text = categoryName(c, l10n);
      _iconKey = c.iconKey;
      _formError = null;
      _listError = null;
      _tab = 1;
    });
  }

  void _selectTab(int i) {
    setState(() {
      // pindah manual ke tab 2 = mulai kategori baru
      if (i == 1 && _tab == 0) _resetForm();
      _listError = null;
      _tab = i;
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    final text = _nameCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _formError = l10n.nameRequired);
      return;
    }
    final provider = context.read<CategoryProvider>();
    final editing = _editing;
    if (editing == null) {
      await provider.add(text, _iconKey);
    } else {
      // Kategori bawaan yang namanya tidak diubah tetap ikut bahasa (name = null)
      final unchanged =
          editing.defaultKey != null && text == categoryName(editing, l10n);
      await provider.update(
        editing.id,
        name: unchanged ? editing.name : text,
        iconKey: _iconKey,
      );
    }
    if (!mounted) return;
    setState(() {
      _resetForm();
      _tab = 0;
    });
  }

  Future<void> _delete(Category c, AppLocalizations l10n) async {
    final ok = await context.read<CategoryProvider>().delete(c);
    if (mounted) setState(() => _listError = ok ? null : l10n.categoryInUse);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final count = context.watch<CategoryProvider>().categories.length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildHeader(l10n, count),
            const SizedBox(height: 12),
            _buildTabs(l10n, count),
            const SizedBox(height: 12),
            _tab == 0 ? _buildList(l10n) : _buildForm(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, int count) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          l10n.manageCategoriesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            l10n.activeCount(count),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.done),
        ),
      ],
    );
  }

  Widget _buildTabs(AppLocalizations l10n, int count) {
    final scheme = Theme.of(context).colorScheme;
    Widget tab(int i, IconData icon, String label) {
      final selected = _tab == i;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectTab(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? scheme.surfaceContainerLowest : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          tab(0, Icons.inventory_2_outlined, l10n.categoriesTab(count)),
          tab(
            1,
            _editing == null ? Icons.add_circle_outline : Icons.edit_outlined,
            _editing == null ? l10n.newCategory : l10n.editCategory,
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    final categories = context.watch<CategoryProvider>().categories;
    final scheme = Theme.of(context).colorScheme;
    final wardrobe = context.watch<WardrobeProvider>();

    return Column(
      children: [
        if (_listError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_listError!, style: TextStyle(color: scheme.error)),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              l10n.organizedItems,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            Text(
              l10n.dragOrTapToEdit,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final c in categories)
          SoftCard(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: iconFor(c.iconKey),
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName(c, l10n),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.totalItems(wardrobe.countByCategory(c.id)),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.editCategory,
                  onPressed: () => _openEdit(c, l10n),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.delete,
                  onPressed: () => _delete(c, l10n),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _formError!,
                style: TextStyle(color: scheme.error),
              ),
            ),
          SoftTextFieldOutline(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            label: l10n.categoryName,
            validator: (v) =>
                v != null && v.trim().isNotEmpty ? null : l10n.nameRequired,
            suffixIcon: Icon(Icons.label_outline_rounded),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.icon, style: Theme.of(context).textTheme.titleSmall),
              Spacer(),
              Text(
                iconLabel(_iconKey, l10n),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.inversePrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SoftCardOutline(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in categoryIcons.keys)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _iconKey = key),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: key == _iconKey
                                ? scheme.primary
                                : Colors.transparent,
                            width: key == _iconKey ? 2 : 1,
                          ),
                        ),
                        child: HugeIcon(
                          icon: iconFor(key),
                          color: key == _iconKey
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _resetForm();
                    _tab = 0;
                  }),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _save(l10n),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
