import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundryan/data/wardrobe_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/widgets/soft.dart';
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
  bool _saving = false;
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
    if (didPop || _saving) return;
    final navigator = Navigator.of(context);
    if (_dirty && !await showDiscardChangesDialog(context)) return;
    navigator.pop();
  }

  Future<void> _pick(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final String? name;
    try {
      name = await PhotoStorage.pick(source);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoFailed)));
      return;
    }
    if (name == null) return;
    if (!mounted || _done) {
      await PhotoStorage.delete(name);
      return;
    }
    if (_photo != _originalPhoto) await PhotoStorage.delete(_photo);
    setState(() => _photo = name);
  }

  Future<void> _removePhoto() async {
    if (_photo != _originalPhoto) await PhotoStorage.delete(_photo);
    if (mounted) setState(() => _photo = null);
  }

  void _showPhotoOptions(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.photo, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                _photoOption(
                  icon: HugeIcons.strokeRoundedCamera01,
                  label: l10n.takePhoto,
                  bg: scheme.primaryContainer,
                  fg: scheme.onPrimaryContainer,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pick(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                _photoOption(
                  icon: HugeIcons.strokeRoundedImage02,
                  label: l10n.chooseGallery,
                  bg: scheme.tertiaryContainer,
                  fg: scheme.onTertiaryContainer,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pick(ImageSource.gallery);
                  },
                ),
                if (_photo != null) ...[
                  const SizedBox(height: 8),
                  _photoOption(
                    icon: HugeIcons.strokeRoundedDelete01,
                    label: l10n.removePhoto,
                    bg: scheme.errorContainer,
                    fg: scheme.onErrorContainer,
                    labelColor: scheme.error,
                    onTap: () {
                      Navigator.pop(ctx);
                      _removePhoto();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoOption({
    required List<List<dynamic>> icon,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
    Color? labelColor,
  }) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: HugeIcon(icon: icon, size: 20, strokeWidth: 2, color: fg),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(color: labelColor),
            ),
          ),
          HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            size: 18,
            strokeWidth: 2,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final catId = _categoryId;
    if (!_formKey.currentState!.validate()) return;
    if (catId == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.selectCategory)));
      return;
    }

    final provider = context.read<WardrobeProvider>();
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();

    setState(() => _saving = true);
    var ok = true;
    try {
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
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }

    if (!ok) {
      if (mounted) setState(() => _saving = false);
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
    if (_saving) return;
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
    if (!categories.any((c) => c.id == _categoryId)) {
      _categoryId = categories.firstOrNull?.id;
    }
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
            icon: HugeIcons.strokeRoundedCamera01,
            onPressed: () => _showPhotoOptions(l10n),
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
                tooltip: l10n.delete,
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
              SizedBox(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height / 4,
                child: SoftCard(
                  child: file == null
                      ? placeholder
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => placeholder,
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: SoftButton(
                                label: l10n.photo,
                                icon: HugeIcons.strokeRoundedEdit02,
                                variant: SoftButtonVariant.secondary,
                                onPressed: () => _showPhotoOptions(l10n),
                              ),
                            ),
                          ],
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
                      onPressed: _saving ? null : () => _save(l10n),
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
