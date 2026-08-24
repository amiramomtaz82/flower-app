import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Horizontal, scrollable category selector with an underline on the
/// selected tab. Index 0 is always "All".
class CategoryTabsBar extends StatelessWidget {
  const CategoryTabsBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = LightColors();

    return Column(
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: labels.length,
            separatorBuilder: (_, _) => const SizedBox(width: 24),
            itemBuilder: (context, index) {
              final bool isSelected = index == selectedIndex;

              return InkWell(
                onTap: () => onSelected(index),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? colors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected ? colors.primary : colors.darkGrey,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(height: 1, color: colors.surface.withValues(alpha: 0.5)),
      ],
    );
  }
}
