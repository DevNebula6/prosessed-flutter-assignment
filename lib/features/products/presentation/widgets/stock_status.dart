import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class StockStatus extends StatelessWidget {
  const StockStatus(this.stock, {super.key});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (stock) {
      <= 0 => ('Out of stock', theme.colorScheme.error),
      <= 5 => ('Only $stock left', AppColors.lowStock(theme.brightness)),
      _ => ('In stock', theme.colorScheme.primary),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: theme.textTheme.labelLarge?.copyWith(color: color)),
      ],
    );
  }
}
