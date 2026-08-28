import 'package:flower_app/core/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/occasion_entity.dart';

class OccasionCard extends StatelessWidget {
  const OccasionCard({super.key, required this.occasion, this.onTap});

  final OccasionEntity occasion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AdaptiveImage(
                path: occasion.imageUrl,
                width: 110,
                height: 130,
              ),
            ),
            const SizedBox(height: 8),
            Text(occasion.name, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
