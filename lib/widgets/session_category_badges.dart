import 'package:flutter/material.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/widgets/soft.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:provider/provider.dart';

class SessionCategoryBadges extends StatelessWidget {
  final int sessionId;
  const SessionCategoryBadges({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = context.watch<CategoryProvider>();
    final data = context.select<SessionProvider, Map<int, int>>(
      (p) => p.categoryCounts(sessionId),
    );
    if (data.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 24,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final e in data.entries)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CountBadge(
                label: '${e.value} ${_name(categories, e.key, l10n)}',
                horizontalPadding: 10,
                mode: CountBadgeMode.normal,
              ),
            ),
        ],
      ),
    );
  }

  String _name(CategoryProvider categories, int id, AppLocalizations l10n) {
    final c = categories.byId(id);
    return c == null ? '' : categoryName(c, l10n);
  }
}
