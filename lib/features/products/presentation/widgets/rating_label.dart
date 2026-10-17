import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class RatingLabel extends StatelessWidget {
  const RatingLabel(this.rating, {super.key});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final value = rating.toStringAsFixed(1);

    return Semantics(
      label: 'Rated $value out of 5',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: AppColors.rating),
          const SizedBox(width: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
