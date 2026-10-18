import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cart.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key, required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = cart.itemCount == 1 ? '1 item' : '${cart.itemCount} items';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryRow(
          label: 'Subtotal ($items)',
          value: formatPrice(cart.subtotal),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SummaryRow(
          label: 'Discount',
          value: '-${formatPrice(cart.discount)}',
          valueColor: theme.colorScheme.primary,
        ),
        const Divider(height: AppSpacing.xl),
        _SummaryRow(
          label: 'Total',
          value: formatPrice(cart.total),
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.style,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? Theme.of(context).textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style?.copyWith(color: valueColor)),
      ],
    );
  }
}
