import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_box.dart';

/// Placeholder with the same shape as a product card, shown on first load.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ShimmerBox(width: double.infinity, radius: 0)),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 14),
                  SizedBox(height: AppSpacing.sm),
                  ShimmerBox(width: 80, height: 14),
                  SizedBox(height: AppSpacing.md),
                  ShimmerBox(width: 64, height: 20),
                  SizedBox(height: AppSpacing.sm),
                  ShimmerBox(width: 40, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
