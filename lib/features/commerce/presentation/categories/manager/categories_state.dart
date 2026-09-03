import 'package:equatable/equatable.dart';

import 'package:flower_app/core/pagination/pagination_state.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import 'sort_option.dart';

class CategoriesState extends Equatable {
  final Resource<List<CategoryEntity>> categoriesResource;
  final PaginationState<ProductEntity> productsPagination;
  final String? selectedCategoryId;
  final String? keyword;
  final SortOption? sortOption;

  CategoriesState({
    Resource<List<CategoryEntity>>? categoriesResource,
    PaginationState<ProductEntity>? productsPagination,
    this.selectedCategoryId,
    this.keyword,
    this.sortOption,
  }) : categoriesResource = categoriesResource ?? Resource.initial(),
       productsPagination = productsPagination ?? PaginationState.initial();

  factory CategoriesState.initial() => CategoriesState();

  CategoriesState copyWith({
    Resource<List<CategoryEntity>>? categoriesResource,
    PaginationState<ProductEntity>? productsPagination,
    String? selectedCategoryId,
    String? keyword,
    SortOption? sortOption,
    bool clearKeyword = false,
  }) {
    return CategoriesState(
      categoriesResource: categoriesResource ?? this.categoriesResource,
      productsPagination: productsPagination ?? this.productsPagination,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  List<Object?> get props => [
    categoriesResource,
    productsPagination,
    selectedCategoryId,
    keyword,
    sortOption,
  ];
}
