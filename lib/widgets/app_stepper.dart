import 'package:flutter/material.dart';
import 'package:laundryan/core/theme/app_colors.dart';

/// Stepper +/- reusable. Dipakai di: Pilih Item (buat sesi, min 1 max = stok),
/// Verifikasi ("Jumlah Ketemu"), dan Tambah/Edit Item ("Jumlah Dimiliki").
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  bool get _canDecrement => value > min;
  bool get _canIncrement => max == null || value < max!;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          enabled: _canDecrement,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.richBlack,
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          enabled: _canIncrement,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.royalBlue.withValues(alpha: 0.08)
          : AppColors.borderSubtle,
      borderRadius: BorderRadius.circular(8), // radius-button
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? AppColors.royalBlue
                : AppColors.richBlack.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}