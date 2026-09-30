import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundryan/data/wardrobe_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/photo_storage.dart';
import 'package:laundryan/widgets/category_sheet.dart';
import 'package:provider/provider.dart';

class WardrobeItemScreen extends StatefulWidget {
  final WardrobeEntry? entry;
  const WardrobeItemScreen({super.key, this.entry});

  @override
  State<WardrobeItemScreen> createState() => _WardrobeItemScreenState();
}

class _WardrobeItemScreenState extends State<WardrobeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _note;
  late final String? _originalPhoto;
  int? _categoryId;
  String? _photo;
  late int _qty;
  bool _done = false;

  bool get _isEdit => widget.entry != null;
  int get _minQty => max(1, widget.entry?.lockedQty ?? 0);

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _name = TextEditingController(text: e?.item.name);
    _note = TextEditingController(text: e?.item.note);
    _originalPhoto = e?.item.photoPath;
    _photo = _originalPhoto;
    _qty = e?.item.totalQty ?? 1;
    _categoryId = e?.item.categoryId ??
        context.read<CategoryProvider>().categories.firstOrNull?.id;
  }

  @override
  void dispose() {
    // Foto draft yang belum disimpan dibersihkan
    if (!_done && _photo != _originalPhoto) PhotoStorage.delete(_photo);
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final name = await PhotoStorage.pick(source);
      if (name == null || !mounted) return;
      if (_photo != _originalPhoto) await PhotoStorage.delete(_photo);
      setState(() => _photo = name);
    } catch (_) {
      // izin ditolak / batal: abaikan
    }
  }

  Future<void> _removePhoto() async {
    if (_photo != _originalPhoto) await PhotoStorage.delete(_photo);
    if (mounted) setState(() => _photo = null);
  }

  void _showPhotoOptions(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            if (_photo != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.removePhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    final catId = _categoryId;
    if (!_formKey.currentState!.validate() || catId == null) return;

    final provider = context.read<WardrobeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();

    var ok = true;
    if (_isEdit) {
      ok = await provider.update(
        widget.entry!.item.id,
        name: name,
        categoryId: catId,
        totalQty: _qty,
        photoPath: _photo,
        note: note,
      );
    } else {
      await provider.add(
        name: name,
        categoryId: catId,
        totalQty: _qty,
        photoPath: _photo,
        note: note,
      );
    }

    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.minQtyHint(_minQty))));
      return;
    }
    _done = true;
    if (_originalPhoto != null && _originalPhoto != _photo) {
      await PhotoStorage.delete(_originalPhoto);
    }
    navigator.pop();
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final provider = context.read<WardrobeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteItemTitle),
        content: Text(l10n.deleteItemMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final deleted = await provider.delete(widget.entry!.item.id);
    if (!deleted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.itemInUse)));
      return;
    }
    _done = true;
    await PhotoStorage.delete(_originalPhoto);
    if (_photo != _originalPhoto) await PhotoStorage.delete(_photo);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final categories = context.watch<CategoryProvider>().categories;
    final file = PhotoStorage.file(_photo);
    final locked = widget.entry?.lockedQty ?? 0;

    final placeholder = Icon(
      Icons.add_a_photo_outlined,
      size: 36,
      color: scheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editWardrobe : l10n.addWardrobe),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(l10n),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showPhotoOptions(l10n),
                child: Container(
                  width: 140,
                  height: 140,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: file == null
                      ? placeholder
                      : Image.file(
                          file,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => placeholder,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.itemName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.category,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final c in categories)
                        DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: iconFor(c.iconKey),
                                size: 20,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  categoryName(c, l10n),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _categoryId = v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.category_outlined),
                  tooltip: l10n.categories,
                  onPressed: () => showCategorySheet(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  l10n.quantity,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      _qty > _minQty ? () => setState(() => _qty--) : null,
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$_qty',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _qty++),
                ),
              ],
            ),
            if (locked > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.minQtyHint(locked),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.note,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _save(l10n),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}