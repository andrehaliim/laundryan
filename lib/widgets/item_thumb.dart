import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/photo_storage.dart';

class ItemThumb extends StatelessWidget {
  final String? photo;
  final Category? category;
  final double size;
  final Color? background;
  const ItemThumb({
    super.key,
    required this.photo,
    required this.category,
    this.size = 48,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final file = PhotoStorage.file(photo);
    final icon = Container(
      width: size,
      height: size,
      color: background ?? scheme.primaryContainer.withValues(alpha: 0.4),
      alignment: Alignment.center,
      child: HugeIcon(
        icon: iconFor(category?.iconKey ?? ''),
        size: size * 0.5,
        color: scheme.primary,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: file == null
          ? icon
          : Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: 300,
              errorBuilder: (_, _, _) => icon,
            ),
    );
  }
}
