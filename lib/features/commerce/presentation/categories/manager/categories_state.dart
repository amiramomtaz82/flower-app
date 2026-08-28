import 'package:equatable/equatable.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';

class CategoriesState extends Equatable {
  final Resource<List<CategoryEntity>> categoriesResource;
  final Resource<List<ProductEntity>> productsResource;
  final String? selectedCategoryId;

  CategoriesState({
    Resource<List<CategoryEntity>>? categoriesResource,
    Resource<List<ProductEntity>>? productsResource,
    this.selectedCategoryId,
  }) : categoriesResource = categoriesResource ?? Resource.initial(),
       productsResource = productsResource ?? Resource.initial();

  factory CategoriesState.initial() => CategoriesState();

  CategoriesState copyWith({
    Resource<List<CategoryEntity>>? categoriesResource,
    Resource<List<ProductEntity>>? productsResource,
    String? selectedCategoryId,
  }) {
    return CategoriesState(
      categoriesResource: categoriesResource ?? this.categoriesResource,
      productsResource: productsResource ?? this.productsResource,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [
    categoriesResource,
    productsResource,
    selectedCategoryId,
  ];
}
