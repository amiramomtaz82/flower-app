import 'package:flower_app/core/app_constants/app_assets.dart';

import '../../../domain/entities/category_entity.dart';

List<CategoryEntity> dummyCategories = const [
  CategoryEntity(id: '1', name: 'Flowers', icon: AppAssets.categoryTulip),
  CategoryEntity(id: '2', name: 'Gift', icon: AppAssets.categoryGift),
  CategoryEntity(id: '3', name: 'Card', icon: AppAssets.categoryCard),
  CategoryEntity(id: '4', name: 'Jewellery', icon: AppAssets.categoryJewellery),
  CategoryEntity(id: '5', name: 'Flowers', icon: AppAssets.categoryTulip),
];
