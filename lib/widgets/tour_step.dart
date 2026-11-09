import 'package:flutter/material.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/widgets/soft.dart';
import 'package:showcaseview/showcaseview.dart';

/// Wraps [child] as one step of a coach-mark tour, shown with a Soft-style
/// tooltip card (step badge, title, description, Skip / Next buttons).
class TourStep extends StatelessWidget {
  /// Showcase scope this step belongs to (see `AppTour`).
  final String scope;
  final GlobalKey showcaseKey;
  final int step;
  final int total;
  final String title;
  final String description;

  /// Label of the last step's button; defaults to "Done".
  final String? finishLabel;

  /// Extra action run after the last step's button finishes the tour.
  final VoidCallback? onFinish;

  /// Cuts a circular spotlight instead of a rounded rectangle.
  final bool circle;

  /// Corner radius of the rectangular spotlight (ignored when [circle]).
  final BorderRadius targetBorderRadius;
  final EdgeInsets targetPadding;
  final Widget child;

  const TourStep({
    super.key,
    required this.scope,
    required this.showcaseKey,
    required this.step,
    required this.total,
    required this.title,
    required this.description,
    required this.child,
    this.finishLabel,
    this.onFinish,
    this.circle = false,
    this.targetBorderRadius = const BorderRadius.all(Radius.circular(12)),
    this.targetPadding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: showcaseKey,
      scope: scope,
      targetShapeBorder: circle
          ? const CircleBorder()
          : const RoundedRectangleBorder(),
      targetBorderRadius: targetBorderRadius,
      targetPadding: targetPadding,
      overlayColor: Theme.of(context).colorScheme.scrim,
      overlayOpacity: 0.6,
      onBarrierClick: () => ShowcaseView.getNamed(scope).dismiss(),
      container: _TourCard(
        scope: scope,
        step: step,
        total: total,
        title: title,
        description: description,
        finishLabel: finishLabel,
        onFinish: onFinish,
      ),
      child: child,
    );
  }
}

class _TourCard extends StatelessWidget {
  final String scope;
  final int step;
  final int total;
  final String title;
  final String description;
  final String? finishLabel;
  final VoidCallback? onFinish;

  const _TourCard({
    required this.scope,
    required this.step,
    required this.total,
    required this.title,
    required this.description,
    this.finishLabel,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLast = step >= total;

    void onNext() {
      ShowcaseView.getNamed(scope).next();
      if (isLast) onFinish?.call();
    }

    return SizedBox(
      width: 280,
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (total > 1) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: CountBadge(
                  label: '$step / $total',
                  horizontalPadding: 8,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isLast)
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => ShowcaseView.getNamed(scope).dismiss(),
                    child: Text(l10n.skip),
                  ),
                const Spacer(),
                SoftButton(
                  isSmall: true,
                  label: isLast ? (finishLabel ?? l10n.done) : l10n.next,
                  onPressed: onNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
