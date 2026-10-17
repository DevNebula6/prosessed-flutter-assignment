import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/review.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile(this.review, {super.key});

  final Review review;

  String get _initials {
    final names = review.reviewerName.split(' ').where((n) => n.isNotEmpty);
    return names.take(2).map((name) => name[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.secondaryContainer,
            child: Text(
              _initials,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      formatDate(review.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                _Stars(review.rating),
                const SizedBox(height: AppSpacing.xs),
                Text(review.comment, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars(this.rating);

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rated $rating out of 5',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var star = 1; star <= 5; star++)
            Icon(
              star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16,
              color: AppColors.rating,
            ),
        ],
      ),
    );
  }
}
