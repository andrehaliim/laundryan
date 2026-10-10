import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundryan/data/wardrobe_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/photo_storage.dart';
import 'package:laundryan/widgets/category_sheet.dart';
import 'package:laundryan/widgets/confirm_dialog.dart';
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
  late final int? _initialCategoryId;

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
    _categoryId =
        e?.item.categoryId ??
        context.read<CategoryProvider>().categories.firstOrNull?.id;
    _initialCategoryId = _categoryId;
  }

  @override
  void dispose() {
    if (!_done && _photo != _originalPhoto) PhotoStorage.delete(_photo);
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _dirty {
    final item = widget.entry?.item;
    return _name.text.trim() != (item?.name ?? '') ||
        _note.text.trim() != (item?.note ?? '') ||
        _photo != _originalPhoto ||
        _qty != (item?.totalQty ?? 1) ||
        _categoryId != _initialCategoryId;
  }

  Future<void> _onPop(bool didPop) async {
    if (didPop) return;
    final navigator = Navigator.of(context);
    if (_dirty && !await showDiscardChangesDialog(context)) return;
    navigator.pop();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final name = await PhotoStorage.pick(source);
      if (name == null || !mounted) return;
      if (_photo != _originalPhoto) await PhotoStorage.delete(_photo);
      setState(() => _photo = name);
    } catch (_) {}
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
              leading: const HugeIcon(
                icon: HugeIcons.strokeRoundedCamera01,
                strokeWidth: 2,
              ),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const HugeIcon(
                icon: HugeIcons.strokeRoundedImage02,
                strokeWidth: 2,
              ),
              title: Text(l10n.chooseGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            if (_photo != null)
              ListTile(
                leading: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete01,
                  strokeWidth: 2,
                ),
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

    final confirm = await showConfirmDialog(
      context,
      title: l10n.deleteItemTitle,
      message: l10n.deleteItemMessage,
      confirmLabel: l10n.delete,
      icon: HugeIcons.strokeRoundedDelete02,
      tone: ConfirmTone.danger,
    );
    if (!confirm) return;

    final result = await provider.delete(widget.entry!.item.id);
    if (result == WardrobeDeleteResult.blocked) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.itemInUse)));
      return;
    }
    _done = true;
    if (result == WardrobeDeleteResult.deleted) {
      await PhotoStorage.delete(_originalPhoto);
    }
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

    final placeholder = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedImageAdd02,
            size: 36,
            strokeWidth: 1.8,
            color: scheme.onSurface,
          ),
          const SizedBox(height: 8),
          Text(l10n.addPhoto, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.addPhotoHint,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          SoftButton(
            label: l10n.upload,
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            onPressed: () => _pick(ImageSource.gallery),
          ),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPop(didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? l10n.editWardrobe : l10n.addWardrobe),
          actions: [
            if (_isEdit)
              IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete01,
                  strokeWidth: 2,
                ),
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
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 4,
                    child: SoftCard(
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
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.itemName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    " *",
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: scheme.error),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SoftTextField(
                controller: _name,
                label: '',
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.category,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    " *",
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: scheme.error),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => showCategorySheet(context),
                    child: CountBadge(
                      label: '+ ${l10n.manageCategories}',
                      horizontalPadding: 8,
                      mode: CountBadgeMode.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: SoftDropdown<int>(
                      value: _categoryId,
                      entries: [
                        for (final c in categories)
                          DropdownMenuEntry(
                            value: c.id,
                            label: categoryName(c, l10n),
                            leadingIcon: HugeIcon(
                              icon: iconFor(c.iconKey),
                              size: 20,
                              color: scheme.primary,
                            ),
                          ),
                      ],
                      onSelected: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalOwnedQty,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        l10n.totalOwnedQtyHint,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          Text(
                            l10n.inventoryCount,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: scheme.outlineVariant),
                              borderRadius: BorderRadius.circular(12),
                              color: scheme.surface,
                            ),
                            child: Row(
                              children: [
                                IconButton.filledTonal(
                                  icon: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedMinusSign,
                                    strokeWidth: 2,
                                  ),
                                  onPressed: _qty > _minQty
                                      ? () => setState(() => _qty--)
                                      : null,
                                ),
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    '$_qty',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                IconButton.filledTonal(
                                  icon: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedPlusSign,
                                    strokeWidth: 2,
                                  ),
                                  onPressed: () => setState(() => _qty++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (locked > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.minQtyHint(locked),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 16),
              Text(l10n.note, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              SoftTextField(
                controller: _note,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SoftButton(
                      label: l10n.cancel,
                      variant: SoftButtonVariant.secondary,
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SoftButton(
                      label: l10n.save,
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      onPressed: () => _save(l10n),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
