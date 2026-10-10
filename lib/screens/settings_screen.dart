import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:laundryan/screens/onboarding_screen.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/widgets/category_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

typedef _Option<T> = ({T value, String label, List<List<dynamic>> icon});

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();

    final languages = <_Option<String>>[
      (
        value: 'en',
        label: l10n.english,
        icon: HugeIcons.strokeRoundedLanguageSkill,
      ),
      (
        value: 'id',
        label: l10n.indonesian,
        icon: HugeIcons.strokeRoundedLanguageSkill,
      ),
    ];
    final themes = <_Option<ThemeMode>>[
      (
        value: ThemeMode.light,
        label: l10n.light,
        icon: HugeIcons.strokeRoundedSun03,
      ),
      (
        value: ThemeMode.dark,
        label: l10n.dark,
        icon: HugeIcons.strokeRoundedMoon02,
      ),
      (
        value: ThemeMode.system,
        label: l10n.system,
        icon: HugeIcons.strokeRoundedSmartPhone01,
      ),
    ];
    final language = languages.firstWhere(
      (o) => o.value == settings.locale.languageCode,
      orElse: () => languages.first,
    );
    final theme = themes.firstWhere((o) => o.value == settings.themeMode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _sectionLabel(context, l10n.appearance),
          SoftCard(
            child: Column(
              children: [
                _tile(
                  context,
                  icon: HugeIcons.strokeRoundedLanguageSkill,
                  bg: scheme.primaryContainer,
                  fg: scheme.onPrimaryContainer,
                  title: l10n.language,
                  value: language.label,
                  onTap: () => _pick(
                    context,
                    title: l10n.language,
                    options: languages,
                    selected: language.value,
                    onSelected: settings.setLanguage,
                  ),
                ),
                _divider(),
                _tile(
                  context,
                  icon: HugeIcons.strokeRoundedPaintBoard,
                  bg: scheme.secondaryContainer,
                  fg: scheme.onSecondaryContainer,
                  title: l10n.theme,
                  value: theme.label,
                  onTap: () => _pick(
                    context,
                    title: l10n.theme,
                    options: themes,
                    selected: theme.value,
                    onSelected: settings.setThemeMode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, l10n.data),
          SoftCard(
            child: _tile(
              context,
              icon: HugeIcons.strokeRoundedTag01,
              bg: scheme.tertiaryContainer,
              fg: scheme.onTertiaryContainer,
              title: l10n.categories,
              subtitle: l10n.categoriesHint,
              onTap: () => showCategorySheet(context),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, l10n.general),
          SoftCard(
            child: _tile(
              context,
              icon: HugeIcons.strokeRoundedBookOpen01,
              bg: scheme.primaryContainer,
              fg: scheme.onPrimaryContainer,
              title: l10n.showOnboarding,
              subtitle: l10n.showOnboardingHint,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, l10n.about),
          SoftCard(
            child: Column(
              children: [
                _appHeader(context),
                _divider(),
                _tile(
                  context,
                  icon: HugeIcons.strokeRoundedLegalDocument01,
                  bg: scheme.surfaceContainerHigh,
                  fg: scheme.onSurfaceVariant,
                  title: l10n.licenses,
                  subtitle: l10n.licensesHint,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appName,
                  ),
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _sectionLabel(context, l10n.developer),
            SoftCard(
              child: _tile(
                context,
                icon: HugeIcons.strokeRoundedDatabase,
                bg: scheme.surfaceContainerHigh,
                fg: scheme.onSurfaceVariant,
                title: 'DB Viewer',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DriftDbViewer(context.read<AppDatabase>()),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          _footer(context),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return Column(
      children: [
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            return Text(
              info == null ? '' : l10n.appVersion(info.version),
              style: style,
            );
          },
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            text: '${l10n.madeBy} ',
            children: [
              TextSpan(
                text: '@andrehaliim',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          style: style,
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 64);

  Widget _iconBadge(List<List<dynamic>> icon, Color bg, Color fg) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: HugeIcon(icon: icon, color: fg, size: 20, strokeWidth: 2),
    );
  }

  Widget _tile(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required Color bg,
    required Color fg,
    required String title,
    String? subtitle,
    String? value,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _iconBadge(icon, bg, fg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(width: 4),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: scheme.outline,
              size: 18,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _appHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tagline = l10n.tagline.split(' - ').last;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/icon/icon.png', width: 48, height: 48),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tagline,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick<T>(
    BuildContext context, {
    required String title,
    required List<_Option<T>> options,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        final textTheme = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(title, style: textTheme.titleLarge),
                ),
                for (final o in options) ...[
                  _optionRow(
                    sheetContext,
                    option: o,
                    isSelected: o.value == selected,
                    onTap: () {
                      onSelected(o.value);
                      Navigator.of(sheetContext).pop();
                    },
                    scheme: scheme,
                  ),
                  if (o != options.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionRow<T>(
    BuildContext context, {
    required _Option<T> option,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(12);

    return Material(
      color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? scheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: option.icon,
                color: isSelected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
                size: 20,
                strokeWidth: 2,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? scheme.onPrimaryContainer : null,
                  ),
                ),
              ),
              if (isSelected)
                HugeIcon(
                  icon: HugeIcons.strokeRoundedTick02,
                  color: scheme.onPrimaryContainer,
                  size: 20,
                  strokeWidth: 2.5,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
