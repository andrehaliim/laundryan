import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(l10n.language, style: titleStyle),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.english)),
                ButtonSegment(value: 'id', label: Text(l10n.indonesian)),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (s) => settings.setLanguage(s.first),
            ),
            const SizedBox(height: 24),
            Text(l10n.theme, style: titleStyle),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.light)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.dark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
            const SizedBox(height: 24),
            Spacer(),
            if (kDebugMode)
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('DB Viewer'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DriftDbViewer(context.read<AppDatabase>()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
