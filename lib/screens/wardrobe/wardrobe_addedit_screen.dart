import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundryan/core/database/app_database.dart';
import 'package:laundryan/core/providers/database_provider.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/widgets/widgets.dart';

class WardrobeAddEditScreen extends ConsumerStatefulWidget {
  const WardrobeAddEditScreen({super.key, this.existingItem});

  final WardrobeItem? existingItem;

  @override
  ConsumerState<WardrobeAddEditScreen> createState() =>
      _WardrobeDetailScreenState();
}

class _WardrobeDetailScreenState extends ConsumerState<WardrobeAddEditScreen> {
  late String selectedCategory;
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  int _quantity = 1;

  bool get _isEditMode => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    selectedCategory = existing?.iconName ?? 'Kaos / T-Shirt';
    _nameController = TextEditingController(text: existing?.name ?? '');
    _notesController = TextEditingController(text: existing?.detail ?? '');
    _quantity = existing?.quantityOwned ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama pakaian wajib diisi')));
      return;
    }

    final dao = ref.read(wardrobeDaoProvider);

    if (_isEditMode) {
      await dao.updateItem(
        widget.existingItem!
            .copyWith(
              name: name,
              iconName: selectedCategory,
              quantityOwned: _quantity,
              detail: Value(
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
            )
            .toCompanion(true),
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    final existing = await dao.findByNameIgnoreCase(name);
    if (existing != null) {
      final action = await DuplicateItemDialog.show(context, itemName: name);

      switch (action) {
        case DuplicateItemAction.merge:
          await dao.incrementQuantity(existing.id, _quantity);
          break;
        case DuplicateItemAction.createNew:
          await dao.insertItem(
            WardrobeItemsCompanion.insert(
              name: name,
              iconName: selectedCategory,
              quantityOwned: _quantity,
              detail: Value(
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              ),
            ),
          );
          break;
        case DuplicateItemAction.cancel:
          return;
      }
    } else {
      await dao.insertItem(
        WardrobeItemsCompanion.insert(
          name: name,
          iconName: selectedCategory,
          quantityOwned: _quantity,
          detail: Value(
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        ),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pakaian berhasil disimpan')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final confirmed = await WardrobeDeleteConfirmation.show(
      context,
      itemIcon: Icons.checkroom_outlined,
      itemName: _nameController.text.isEmpty
          ? 'Item Pakaian'
          : _nameController.text,
      categoryLabel: selectedCategory,
      totalQuantity: _quantity,
      inWardrobeQuantity: _quantity,
      inUseQuantity: 0, // TODO: hitung dari SessionItems aktif pas Fase 5/6
    );
    if (confirmed == true && mounted) {
      await ref.read(wardrobeDaoProvider).deleteItem(widget.existingItem!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(fixedSize: const Size(40, 40)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? 'Edit Wardrobe' : 'Tambah ke Wardrobe',
              style: textTheme.titleLarge?.copyWith(color: AppColors.royalBlue),
            ),
            Text(
              'Lengkapi detail koleksi pakaian',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (_isEditMode)
            IconButton.filled(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
              style: IconButton.styleFrom(
                fixedSize: const Size(40, 40),
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.danger,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WardrobeCategorySelector(
                  selectedCategory: selectedCategory,
                  onChanged: (category) {
                    setState(() {
                      selectedCategory = category.name;
                    });
                  },
                ),

                const SizedBox(height: 16),

                WardrobeDetailInput(
                  nameController: _nameController,
                  notesController: _notesController,
                ),

                const SizedBox(height: 16),

                WardrobeQuantityStepper(
                  quantity: _quantity,
                  onQuantityChanged: (newQuantity) {
                    setState(() => _quantity = newQuantity.clamp(1, 99));
                  },
                ),

                const SizedBox(height: 16),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      _isEditMode ? 'Update Wardrobe' : 'Simpan ke Wardrobe',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.offWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
