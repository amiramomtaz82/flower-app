import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flutter/material.dart';

/// Renders [path] as a network image when it looks like a URL, otherwise as
/// a local asset — the backend and local dummy data both hand back a plain
/// string without indicating which. Falls back to a placeholder asset if the
/// network image fails to load (offline, dead URL, etc.).
class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return Image.asset(
        AppAssets.image,
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppAssets.image,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    return Image.asset(path, width: width, height: height, fit: fit);
  }
}
