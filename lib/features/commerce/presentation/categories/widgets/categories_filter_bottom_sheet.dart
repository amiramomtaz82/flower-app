import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/categories_cubit.dart';
import '../manager/categories_events.dart';

class CategoriesFilterBottomSheet extends StatefulWidget {
  final String? initialSortBy;

  const CategoriesFilterBottomSheet({super.key, this.initialSortBy});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<CategoriesCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CategoriesFilterBottomSheet(
          initialSortBy: cubit.state.sortBy,
        ),
      ),
    );
  }

  @override
  State<CategoriesFilterBottomSheet> createState() => _CategoriesFilterBottomSheetState();
}

class _CategoriesFilterBottomSheetState extends State<CategoriesFilterBottomSheet> {
  String? _selectedSort;

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Lowest Price', 'value': 'PriceLowToHigh'},
    {'label': 'Highest Price', 'value': 'PriceHighToLow'},
    {'label': 'New', 'value': 'Newest'},
    {'label': 'Old', 'value': 'Oldest'},
    {'label': 'Discount', 'value': 'Discount'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSortBy;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sort by',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._sortOptions.map((option) {
            final isSelected = _selectedSort == option['value'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSort = option['value'];
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option['label']!,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_selectedSort != null) {
                context.read<CategoriesCubit>().doEvents(CategoriesSortChanged(_selectedSort!));
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text('Filter', style: textTheme.labelLarge?.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
