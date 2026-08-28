import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../../core/pagination/paginated_response.dart';
import '../../../domain/entities/occasion_entity.dart';
import '../../../domain/use_cases/get_occasions_use_case.dart';
import '../../../domain/use_cases/get_products_use_case.dart';
import 'occasions_events.dart';
import 'occasions_state.dart';

@injectable
class OccasionsCubit extends Cubit<OccasionsState> {
  final GetOccasionsUseCase _getOccasionsUseCase;
  final GetProductsUseCase _getProductsUseCase;

  OccasionsCubit(this._getOccasionsUseCase, this._getProductsUseCase)
    : super(OccasionsState.initial());

  static const int _pageSize = 20;

  Future<void> doEvents(OccasionsEvent event) async {
    switch (event) {
      case OccasionsStarted():
        await _loadOccasions(event.initialOccasionId);
      case OccasionSelected():
        await _loadProducts(event.occasionId);
    }
  }

  Future<void> _loadOccasions(String? initialOccasionId) async {
    emit(state.copyWith(occasionsResource: Resource.loading()));

    final result = await _getOccasionsUseCase(
      pageNumber: 1,
      pageSize: _pageSize,
    );
    switch (result) {
      case SuccessResponse<PaginatedResponse<OccasionEntity>>():
        final occasions = result.data.data;
        emit(state.copyWith(occasionsResource: Resource.success(occasions)));
        if (occasions.isEmpty) return;

        // the occasion the user tapped on Home wins, as long as it is still
        // one of the tabs; otherwise open on the first one.
        final selected = occasions.any((o) => o.id == initialOccasionId)
            ? initialOccasionId!
            : occasions.first.id;
        await _loadProducts(selected);

      case ErrorResponse<PaginatedResponse<OccasionEntity>>():
        emit(
          state.copyWith(occasionsResource: Resource.error(result.errMessage)),
        );
    }
  }

  Future<void> _loadProducts(String occasionId) async {
    emit(
      state.copyWith(
        selectedOccasionId: occasionId,
        productsResource: Resource.loading(),
      ),
    );

    final result = await _getProductsUseCase(
      occasionId: occasionId,
      pageNumber: 1,
      pageSize: _pageSize,
    );

    // a faster tap on another tab already took over
    if (state.selectedOccasionId != occasionId) return;

    emit(
      state.copyWith(
        productsResource: switch (result) {
          SuccessResponse() => Resource.success(result.data.data),
          ErrorResponse() => Resource.error(result.errMessage),
        },
      ),
    );
  }
}
