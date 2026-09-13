import 'package:equatable/equatable.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';

class SearchState extends Equatable {
  final PaginationState<ProductEntity> productsPagination;
  final String keyword;

  SearchState({
    PaginationState<ProductEntity>? productsPagination,
    this.keyword = '',
  }) : productsPagination = productsPagination ?? PaginationState.initial();

  factory SearchState.initial() => SearchState();

  SearchState copyWith({
    PaginationState<ProductEntity>? productsPagination,
    String? keyword,
  }) {
    return SearchState(
      productsPagination: productsPagination ?? this.productsPagination,
      keyword: keyword ?? this.keyword,
    );
  }

  @override
  List<Object?> get props => [productsPagination, keyword];
}
