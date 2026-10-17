import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/page_indicator.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.images,
    this.placeholderUrl,
    this.heroTag,
  });

  final List<String> images;

  /// Shown in place of the first image until it has loaded.
  final String? placeholderUrl;

  /// Wraps the first image in a [Hero] with this tag.
  final Object? heroTag;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                Widget image = AppNetworkImage(
                  images[index],
                  fit: BoxFit.contain,
                  placeholderUrl: index == 0 ? widget.placeholderUrl : null,
                );
                if (index == 0 && widget.heroTag != null) {
                  image = Hero(tag: widget.heroTag!, child: image);
                }
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: image,
                );
              },
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          PageIndicator(count: images.length, current: _page),
        ],
      ],
    );
  }
}
