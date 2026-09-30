import 'package:flutter/material.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/widgets/category_sheet.dart';
import 'package:laundryan/widgets/settings_button.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wardrobe),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.categories,
            onPressed: () => showCategorySheet(context),
          ),
          const SettingsButton(),
        ],
      ),
      body: Center(child: Text(l10n.wardrobe)),
    );
  }
}