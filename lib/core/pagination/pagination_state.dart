import '../../config/resource/rsource.dart';

class PaginationState<T> {
  final Resource<List<T>> resource;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String? loadMoreError;

  const PaginationState({
    required this.resource,
    this.currentPage = 0,
    this.hasNextPage = true,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  factory PaginationState.initial() {
    return PaginationState(
      resource: Resource.initial(),
    );
  }

  PaginationState<T> copyWith({
    Resource<List<T>>? resource,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return PaginationState<T>(
      resource: resource ?? this.resource,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
      clearLoadMoreError ? null : loadMoreError ?? this.loadMoreError,
    );
  }
}