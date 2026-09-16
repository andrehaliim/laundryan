import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

class WardrobeQuantityStepper extends StatefulWidget {
  const WardrobeQuantityStepper({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  State<WardrobeQuantityStepper> createState() =>
      _WardrobeQuantityStepperState();
}

class _WardrobeQuantityStepperState extends State<WardrobeQuantityStepper> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.richBlack.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah Unit Dimiliki',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.royalBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Total pakaian jenis ini yang ada di lemari kamu',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.tealBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: AppColors.tealBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BigStepperButton(
                  icon: Icons.remove,
                  enabled: widget.quantity > 1,
                  background: Colors.white,
                  foreground: AppColors.royalBlue,
                  onTap: () => widget.onQuantityChanged(widget.quantity - 1),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.quantity}',
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.royalBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'pcs',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.tealBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Siap rotasi laundry',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _BigStepperButton(
                  icon: Icons.add,
                  enabled: widget.quantity < 100,
                  background: AppColors.royalBlue,
                  foreground: AppColors.offWhite,
                  onTap: () => widget.onQuantityChanged(widget.quantity + 1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick add chips
          Text(
            'Tambah cepat instan:',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [1, 2, 5, 10].map((amount) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: amount == 10 ? 0 : 8),
                  child: _QuickAddChip(
                    amount: amount,
                    onTap: () => widget.onQuantityChanged(widget.quantity + amount),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BigStepperButton extends StatelessWidget {
  const _BigStepperButton({
    required this.icon,
    required this.enabled,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? background : AppColors.borderSubtle,
      shape: const CircleBorder(),
      elevation: enabled && background == Colors.white ? 1 : 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? foreground
                : AppColors.richBlack.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({required this.amount, required this.onTap});

  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.tealBlue.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          child: Center(
            child: Text(
              '+$amount pcs',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.royalBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
