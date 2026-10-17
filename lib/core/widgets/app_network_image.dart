import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.placeholderUrl,
  });

  final String url;
  final BoxFit fit;

  /// A smaller, usually already cached, image to show while [url] loads.
  final String? placeholderUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, _) => placeholderUrl == null
          ? ColoredBox(color: colors.surfaceContainerHighest)
          : CachedNetworkImage(imageUrl: placeholderUrl!, fit: fit),
      errorWidget: (_, _, _) => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
