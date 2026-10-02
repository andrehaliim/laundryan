import 'package:flutter/material.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:laundryan/screens/test_screen.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          IconButton(
            icon: Icon(Icons.safety_check),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TestScreen())),
          ),
        ],
      ),
    );
  }
}
