import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

/// Confirmation dialog reusable. Dipakai untuk: hapus item/sesi,
/// duplikat nama item, dan 2 varian submit verifikasi.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.cancelLabel = 'Batal',
    this.isDestructive = false,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;

  /// true -> tombol kanan pakai warna danger (mis. "Hapus").
  final bool isDestructive;

  /// Return `true` kalau user konfirmasi, `false`/`null` kalau batal/dismiss.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    String cancelLabel = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(body, style: TextStyle(color: AppColors.textSecondary)),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal', style: TextStyle(color: AppColors.richBlack)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.danger : AppColors.royalBlue,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}