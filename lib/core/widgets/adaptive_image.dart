import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flutter/material.dart';

// handles full urls, paths relative to the base url, and local assets
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
    if (path.isEmpty) return _placeholder();

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    return Image.network(
      path.startsWith('http') ? path : _resolveAgainstBaseUrl(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  String _resolveAgainstBaseUrl(String relativePath) {
    final base = Endpoints.baseUrl;
    final trimmedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final trimmedPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;

    return '$trimmedBase/$trimmedPath';
  }

  Widget _placeholder() {
    return Image.asset(
      AppAssets.image,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
