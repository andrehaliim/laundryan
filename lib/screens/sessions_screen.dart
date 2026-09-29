import 'package:flutter/material.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/widgets/settings_button.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessions),
        actions: const [SettingsButton()],
      ),
      body: Center(child: Text(l10n.sessions)),
    );
  }
}