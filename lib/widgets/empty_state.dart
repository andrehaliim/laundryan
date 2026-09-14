import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

/// Empty state generik: illustration (icon dalam circle) + headline + subtext + CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.headline,
    required this.subtext,
    this.ctaLabel,
    this.onCtaPressed,
  });

  final IconData icon;
  final String headline;
  final String subtext;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // radius-card
        boxShadow: [
          BoxShadow(
            color: AppColors.richBlack.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.tealBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: AppColors.royalBlue),
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(color: AppColors.royalBlue),
          ),
          const SizedBox(height: 8),
          Text(
            subtext,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (ctaLabel != null && onCtaPressed != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCtaPressed,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(ctaLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}