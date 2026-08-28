import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/category_entity.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category, this.onTap});

  final CategoryEntity category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = Theme.of(context).extension<LightColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: AdaptiveImage(path: category.icon),
          ),
          const SizedBox(height: 8),
          Text(category.name, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
