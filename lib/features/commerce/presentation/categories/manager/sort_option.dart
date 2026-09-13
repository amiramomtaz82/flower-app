import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';

enum SortOption {
  priceLowToHigh,
  priceHighToLow,
  newest,
  oldest,
  discount;

  String get apiValue {
    switch (this) {
      case SortOption.priceLowToHigh:
        return 'PriceLowToHigh';
      case SortOption.priceHighToLow:
        return 'PriceHighToLow';
      case SortOption.newest:
        return 'Newest';
      case SortOption.oldest:
        return 'Oldest';
      case SortOption.discount:
        return 'Discount';
    }
  }

  String get label {
    switch (this) {
      case SortOption.priceLowToHigh:
        return AppStrings.lowestPrice.tr();
      case SortOption.priceHighToLow:
        return AppStrings.highestPrice.tr();
      case SortOption.newest:
        return AppStrings.newest.tr();
      case SortOption.oldest:
        return AppStrings.oldest.tr();
      case SortOption.discount:
        return AppStrings.discount.tr();
    }
  }
}
