import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

enum DuplicateItemAction { merge, createNew, cancel }

/// Dialog khusus buat kasus nama item duplikat (flow.md poin 10).
/// 3 opsi: gabung ke item existing, buat entry baru, atau batal sepenuhnya.
class DuplicateItemDialog extends StatelessWidget {
  const DuplicateItemDialog({super.key, required this.itemName});

  final String itemName;

  static Future<DuplicateItemAction> show(
    BuildContext context, {
    required String itemName,
  }) async {
    final result = await showDialog<DuplicateItemAction>(
      context: context,
      builder: (_) => DuplicateItemDialog(itemName: itemName),
    );
    return result ?? DuplicateItemAction.cancel;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Item Sudah Ada'),
      content: Text(
        'Sudah ada item dengan nama "$itemName". Mau ditambahkan ke situ atau buat entry baru?',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(DuplicateItemAction.cancel),
          child: const Text('Batal', style: TextStyle(color: AppColors.richBlack)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop(DuplicateItemAction.createNew),
              child: const Text('Buat Baru'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(DuplicateItemAction.merge),
              style: FilledButton.styleFrom(backgroundColor: AppColors.royalBlue),
              child: const Text('Tambahkan'),
            ),
          ],
        ),
      ],
    );
  }
}