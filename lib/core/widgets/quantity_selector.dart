import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A minus / value / plus stepper.
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = this.max;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease quantity',
            icon: const Icon(Icons.remove_rounded),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 24),
            child: Text(
              '$value',
              semanticsLabel: 'Quantity $value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            icon: const Icon(Icons.add_rounded),
            onPressed: max == null || value < max
                ? () => onChanged(value + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
