import 'package:flower_app/config/resource/rsource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_controller.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';

void main() {
  group('PaginationController', () {
    test('should load first page successfully', () async {
      final controller = PaginationController<int>(
        fetchPage: (page) async {
          return SuccessResponse(
            PaginatedResponse<int>(
              data: [1, 2, 3],
              pagination: PaginationModel(
                page: 1,
                pageSize: 3,
                totalCount: 6,
                totalPages: 2,
                hasNextPage: true,
                hasPreviousPage: false,
              ),
            ),
          );
        },
      );

      final state = await controller.loadInitialPage();

      expect(state.resource.isSuccess, true);
      expect(state.resource.data, [1, 2, 3]);
      expect(state.currentPage, 1);
      expect(state.hasNextPage, true);
      expect(state.isLoadingMore, false);
      expect(state.loadMoreError, null);
    });
  });

  test('should return error when initial page fails', () async {
    final controller = PaginationController<int>(
      fetchPage: (page) async {
        return ErrorResponse(
          errMessage: 'Network error',
        );
      },
    );

    final state = await controller.loadInitialPage();

    expect(state.resource.isError, true);
    expect(state.resource.errorMessage, 'Network error');
    expect(state.isLoadingMore, false);
  });




  test('should append next page items', () async {
    final controller = PaginationController<int>(
      fetchPage: (page) async {
        if (page == 1) {
          return SuccessResponse(
            PaginatedResponse<int>(
              data: [1, 2, 3],
              pagination: PaginationModel(
                page: 1,
                pageSize: 3,
                totalCount: 6,
                totalPages: 2,
                hasNextPage: true,
                hasPreviousPage: false,
              ),
            ),
          );
        }

        return SuccessResponse(
          PaginatedResponse<int>(
            data: [4, 5, 6],
            pagination: PaginationModel(
              page: 2,
              pageSize: 3,
              totalCount: 6,
              totalPages: 2,
              hasNextPage: false,
              hasPreviousPage: true,
            ),
          ),
        );
      },
    );

    await controller.loadInitialPage();

    final state = await controller.loadNextPage();

    expect(state.resource.data, [1, 2, 3, 4, 5, 6]);
    expect(state.currentPage, 2);
    expect(state.hasNextPage, false);
  });

  test('should not request another page when hasNextPage is false', () async {
    var requestCount = 0;

    final controller = PaginationController<int>(
      fetchPage: (page) async {
        requestCount++;

        return SuccessResponse(
          PaginatedResponse<int>(
            data: [1, 2],
            pagination: PaginationModel(
              page: 1,
              pageSize: 2,
              totalCount: 2,
              totalPages: 1,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
          ),
        );
      },
    );

    await controller.loadInitialPage();

    await controller.loadNextPage();

    expect(requestCount, 1);
  });



  test('should not make duplicate requests while loading next page', () async {
    var pageTwoRequestCount = 0;

    final controller = PaginationController<int>(
      fetchPage: (page) async {
        if (page == 1) {
          return SuccessResponse(
            PaginatedResponse<int>(
              data: [1, 2],
              pagination: PaginationModel(
                page: 1,
                pageSize: 2,
                totalCount: 4,
                totalPages: 2,
                hasNextPage: true,
                hasPreviousPage: false,
              ),
            ),
          );
        }

        pageTwoRequestCount++;

        await Future.delayed(
          const Duration(milliseconds: 100),
        );

        return SuccessResponse(
          PaginatedResponse<int>(
            data: [3, 4],
            pagination: PaginationModel(
              page: 2,
              pageSize: 2,
              totalCount: 4,
              totalPages: 2,
              hasNextPage: false,
              hasPreviousPage: true,
            ),
          ),
        );
      },
    );

    await controller.loadInitialPage();

    await Future.wait([
      controller.loadNextPage(),
      controller.loadNextPage(),
      controller.loadNextPage(),
    ]);

    expect(pageTwoRequestCount, 1);
  });

  test('should preserve loaded items when next page fails', () async {
    final controller = PaginationController<int>(
      fetchPage: (page) async {
        if (page == 1) {
          return SuccessResponse(
            PaginatedResponse<int>(
              data: [1, 2, 3],
              pagination: PaginationModel(
                page: 1,
                pageSize: 3,
                totalCount: 6,
                totalPages: 2,
                hasNextPage: true,
                hasPreviousPage: false,
              ),
            ),
          );
        }

        return ErrorResponse(
          errMessage: 'Failed to load page 2',
        );
      },
    );

    await controller.loadInitialPage();

    final state = await controller.loadNextPage();

    expect(state.resource.data, [1, 2, 3]);
    expect(state.currentPage, 1);
    expect(state.hasNextPage, true);
    expect(state.isLoadingMore, false);
    expect(state.loadMoreError, 'Failed to load page 2');
  });
  test('should retry failed page', () async {
    var pageTwoAttempts = 0;

    final controller = PaginationController<int>(
      fetchPage: (page) async {
        if (page == 1) {
          return SuccessResponse(
            PaginatedResponse<int>(
              data: [1, 2],
              pagination: PaginationModel(
                page: 1,
                pageSize: 2,
                totalCount: 4,
                totalPages: 2,
                hasNextPage: true,
                hasPreviousPage: false,
              ),
            ),
          );
        }

        pageTwoAttempts++;

        if (pageTwoAttempts == 1) {
          return ErrorResponse(
            errMessage: 'Network error',
          );
        }

        return SuccessResponse(
          PaginatedResponse<int>(
            data: [3, 4],
            pagination: PaginationModel(
              page: 2,
              pageSize: 2,
              totalCount: 4,
              totalPages: 2,
              hasNextPage: false,
              hasPreviousPage: true,
            ),
          ),
        );
      },
    );

    await controller.loadInitialPage();

    final errorState = await controller.loadNextPage();

    expect(errorState.resource.data, [1, 2]);
    expect(errorState.loadMoreError, 'Network error');

    final retryState = await controller.retry();

    expect(retryState.resource.data, [1, 2, 3, 4]);
    expect(retryState.currentPage, 2);
    expect(retryState.hasNextPage, false);
    expect(retryState.loadMoreError, null);
  });
  test('should reset pagination state', () async {
    final controller = PaginationController<int>(
      fetchPage: (page) async {
        return SuccessResponse(
          PaginatedResponse<int>(
            data: [1, 2],
            pagination: PaginationModel(
              page: page,
              pageSize: 2,
              totalCount: 4,
              totalPages: 2,
              hasNextPage: page == 1,
              hasPreviousPage: page > 1,
            ),
          ),
        );
      },
    );

    await controller.loadInitialPage();

    expect(controller.state.currentPage, 1);

    controller.reset();

    expect(controller.state.currentPage, 0);
    expect(controller.state.resource.status, Resource.initial);
    expect(controller.state.hasNextPage, true);
  });
}