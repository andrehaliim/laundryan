import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:provider/provider.dart';

Future<void> showCategorySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
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
  bool _formOpen = false;
  Category? _editing;
  String _iconKey = categoryIcons.keys.first;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _openForm(Category? c, AppLocalizations l10n) {
    setState(() {
      _editing = c;
      _formOpen = true;
      _error = null;
      _nameCtrl.text = c == null ? '' : categoryName(c, l10n);
      _iconKey = c?.iconKey ?? categoryIcons.keys.first;
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    final text = _nameCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = l10n.nameRequired);
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
    if (mounted) setState(() => _formOpen = false);
  }

  Future<void> _delete(Category c, AppLocalizations l10n) async {
    final ok = await context.read<CategoryProvider>().delete(c);
    if (mounted) setState(() => _error = ok ? null : l10n.categoryInUse);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: _formOpen ? _buildForm(l10n) : _buildList(l10n),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    final categories = context.watch<CategoryProvider>().categories;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.categories, style: Theme.of(context).textTheme.titleLarge),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: TextStyle(color: scheme.error)),
          ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final c in categories)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: HugeIcon(
                    icon: iconFor(c.iconKey),
                    color: scheme.primary,
                  ),
                  title: Text(categoryName(c, l10n)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(c, l10n),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(c, l10n),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _openForm(null, l10n),
            icon: const Icon(Icons.add),
            label: Text(l10n.addCategory),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editing == null ? l10n.addCategory : l10n.editCategory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l10n.categoryName,
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.icon, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
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
                            : scheme.outlineVariant,
                        width: key == _iconKey ? 2 : 1,
                      ),
                    ),
                    child: HugeIcon(
                      icon: iconFor(key),
                      color: key == _iconKey
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _formOpen = false;
                    _error = null;
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