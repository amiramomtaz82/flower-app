import 'package:equatable/equatable.dart';

import 'package:flower_app/core/pagination/pagination_state.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';

class CategoriesState extends Equatable {
  final Resource<List<CategoryEntity>> categoriesResource;
  final PaginationState<ProductEntity> productsPagination;
  final String? selectedCategoryId;
  final String? keyword;
  final String? sortBy;

  CategoriesState({
    Resource<List<CategoryEntity>>? categoriesResource,
    PaginationState<ProductEntity>? productsPagination,
    this.selectedCategoryId,
    this.keyword,
    this.sortBy,
  }) : categoriesResource = categoriesResource ?? Resource.initial(),
       productsPagination = productsPagination ?? PaginationState.initial();

  factory CategoriesState.initial() => CategoriesState();

  CategoriesState copyWith({
    Resource<List<CategoryEntity>>? categoriesResource,
    PaginationState<ProductEntity>? productsPagination,
    String? selectedCategoryId,
    String? keyword,
    String? sortBy,
  }) {
    return CategoriesState(
      categoriesResource: categoriesResource ?? this.categoriesResource,
      productsPagination: productsPagination ?? this.productsPagination,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      keyword: keyword ?? this.keyword,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
    categoriesResource,
    productsPagination,
    selectedCategoryId,
    keyword,
    sortBy,
  ];
}
