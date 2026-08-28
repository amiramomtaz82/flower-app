import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';

import 'paginated_response.dart';
import 'pagination_state.dart';

class PaginationController<T> {
  final Future<BaseResponse<PaginatedResponse<T>>> Function(int page) fetchPage;

  PaginationState<T> _state = PaginationState<T>.initial();

  PaginationState<T> get state => _state;

  bool _isRequestInProgress = false;

  PaginationController({required this.fetchPage});

  Future<PaginationState<T>> loadInitialPage() async {
    if (_isRequestInProgress) {
      return _state;
    }

    _isRequestInProgress = true;

    _state = _state.copyWith(
      resource: Resource.loading(),
      currentPage: 0,
      hasNextPage: true,
      isLoadingMore: false,
      clearLoadMoreError: true,
    );

    try {
      final result = await fetchPage(1);

      switch (result) {
        case SuccessResponse<PaginatedResponse<T>>():
          final data = result.data;

          _state = _state.copyWith(
            resource: Resource.success(data.data),
            currentPage: data.pagination.page ?? 1,
            hasNextPage: data.pagination.hasNextPage ?? false,
            isLoadingMore: false,
            clearLoadMoreError: true,
          );

        case ErrorResponse<PaginatedResponse<T>>():
          _state = _state.copyWith(
            resource: Resource.error(result.errMessage),
            isLoadingMore: false,
          );
      }

      return _state;
    } finally {
      _isRequestInProgress = false;
    }
  }

  Future<PaginationState<T>> loadNextPage() async {
    if (_isRequestInProgress || !_state.hasNextPage) {
      return _state;
    }

    _isRequestInProgress = true;

    final nextPage = _state.currentPage + 1;

    _state = _state.copyWith(
      isLoadingMore: true,
      clearLoadMoreError: true,
    );

    try {
      final result = await fetchPage(nextPage);

      switch (result) {
        case SuccessResponse<PaginatedResponse<T>>():
          final data = result.data;

          final updatedItems = [
            ...?_state.resource.data,
            ...data.data,
          ];

          _state = _state.copyWith(
            resource: Resource.success(updatedItems),
            currentPage: data.pagination.page ?? nextPage,
            hasNextPage: data.pagination.hasNextPage ?? false,
            isLoadingMore: false,
            clearLoadMoreError: true,
          );

        case ErrorResponse<PaginatedResponse<T>>():
          _state = _state.copyWith(
            isLoadingMore: false,
            loadMoreError: result.errMessage,
          );
      }

      return _state;
    } finally {
      _isRequestInProgress = false;
    }
  }

  Future<PaginationState<T>> retry() async {
    if (_state.loadMoreError == null) {
      return _state;
    }

    return loadNextPage();
  }

  void reset() {
    _state = PaginationState<T>.initial();
    _isRequestInProgress = false;
  }
}
