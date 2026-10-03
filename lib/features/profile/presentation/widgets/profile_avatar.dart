import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final File? imageFile;
  final Color? backgroundColor;
  final Color? iconColor;

  const ProfileAvatar({
    super.key,
    this.radius = 40,
    this.imageUrl,
    this.imageFile,
    this.backgroundColor,
    this.iconColor,
  });

  ImageProvider? _resolveImageProvider() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final path = imageUrl!.trim();
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return CachedNetworkImageProvider(path);
      }
      return FileImage(File(path));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final imageProvider = _resolveImageProvider();

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ??
          colors?.surface ??
          Theme.of(context).colorScheme.surface,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              Icons.person,
              size: radius,
              color: iconColor ?? colors?.white ?? Colors.white,
            )
          : null,
    );
  }
}
