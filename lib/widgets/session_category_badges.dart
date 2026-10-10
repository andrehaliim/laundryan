import 'package:flutter/material.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/widgets/soft.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:provider/provider.dart';

class SessionCategoryBadges extends StatefulWidget {
  final int sessionId;
  const SessionCategoryBadges({super.key, required this.sessionId});

  @override
  State<SessionCategoryBadges> createState() => _SessionCategoryBadgesState();
}

class _SessionCategoryBadgesState extends State<SessionCategoryBadges> {
  late final Future<Map<int, int>> _counts;

  @override
  void initState() {
    super.initState();
    _counts = context.read<SessionProvider>().items(widget.sessionId).then((
      list,
    ) {
      final map = <int, int>{};
      for (final v in list) {
        map.update(
          v.item.categoryId,
          (x) => x + v.sessionItem.quantity,
          ifAbsent: () => v.sessionItem.quantity,
        );
      }
      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cats = context.watch<CategoryProvider>().allCategories;

    return FutureBuilder<Map<int, int>>(
      future: _counts,
      builder: (_, snap) {
        final data = snap.data;
        if (data == null || data.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 24,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final e in data.entries)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: CountBadge(
                    label: '${e.value} ${_name(cats, e.key, l10n)}',
                    horizontalPadding: 10,
                    mode: CountBadgeMode.normal,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _name(List cats, int id, AppLocalizations l10n) {
    final c = cats.where((c) => c.id == id).firstOrNull;
    return c == null ? '' : categoryName(c, l10n);
  }
}
