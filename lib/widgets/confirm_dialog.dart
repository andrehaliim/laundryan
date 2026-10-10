import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/l10n/app_localizations.dart';

enum ConfirmTone { primary, danger }

/// Shows a [ConfirmDialog] and resolves to `true` only when the user taps
/// the confirm button. Dismissing or cancelling resolves to `false`.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  List<List<dynamic>>? icon,
  ConfirmTone tone = ConfirmTone.primary,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      tone: tone,
    ),
  );
  return ok == true;
}

/// Asks whether to drop unsaved form changes. Resolves to `true` on discard.
Future<bool> showDiscardChangesDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showConfirmDialog(
    context,
    title: l10n.discardChangesTitle,
    message: l10n.discardChangesMessage,
    confirmLabel: l10n.discard,
    cancelLabel: l10n.keepEditing,
    icon: HugeIcons.strokeRoundedFileEdit,
    tone: ConfirmTone.danger,
  );
}

/// Confirmation dialog for crucial actions: tinted icon badge, title,
/// message and stacked confirm/cancel buttons. Use [ConfirmTone.danger]
/// for destructive actions.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final List<List<dynamic>>? icon;
  final ConfirmTone tone;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.icon,
    this.tone = ConfirmTone.primary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final danger = tone == ConfirmTone.danger;

    final (container, onContainer) = danger
        ? (scheme.errorContainer, scheme.onErrorContainer)
        : (scheme.primaryContainer, scheme.onPrimaryContainer);
    final (confirmBg, confirmFg) = danger
        ? (scheme.error, scheme.onError)
        : (scheme.primary, scheme.onPrimary);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final labelStyle = theme.textTheme.titleSmall;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: container,
                ),
                child: Center(
                  child: HugeIcon(
                    icon:
                        icon ??
                        (danger
                            ? HugeIcons.strokeRoundedAlert02
                            : HugeIcons.strokeRoundedHelpCircle),
                    size: 30,
                    strokeWidth: 1.8,
                    color: onContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: confirmBg,
                    foregroundColor: confirmFg,
                    minimumSize: const Size(0, 48),
                    shape: buttonShape,
                    textStyle: labelStyle,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmLabel ?? l10n.confirm),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurfaceVariant,
                    minimumSize: const Size(0, 48),
                    shape: buttonShape,
                    textStyle: labelStyle,
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(cancelLabel ?? l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
