import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_response/base_response.dart';
import '../../../../../core/app_constants/app_strings.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../../core/pagination/paginated_response.dart';
import '../../../domain/entities/home_section_entity.dart';
import '../../../domain/entities/home_section_type.dart';
import '../../../domain/entities/occasion_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/use_cases/get_categories_use_case.dart';
import '../../../domain/use_cases/get_home_sections_use_case.dart';
import '../../../domain/use_cases/get_occasions_use_case.dart';
import '../../../domain/use_cases/get_products_by_category_use_case.dart';
import '../../../domain/use_cases/get_products_use_case.dart';
import 'home_events.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetHomeSectionsUseCase _getHomeSectionsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetOccasionsUseCase _getOccasionsUseCase;
  final GetProductsUseCase _getProductsUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;

  HomeCubit(
    this._getHomeSectionsUseCase,
    this._getCategoriesUseCase,
    this._getOccasionsUseCase,
    this._getProductsUseCase,
    this._getProductsByCategoryUseCase,
  ) : super(HomeState.initial());

  Future<void> doEvents(HomeEvent event) async {
    switch (event) {
      case HomeStarted():
        await _loadHome();
    }
  }

  Future<void> _loadHome() async {
    emit(state.copyWith(sectionsResource: Resource.loading()));

    final result = await _getHomeSectionsUseCase();
    switch (result) {
      case SuccessResponse<List<HomeSectionEntity>>():
        emit(
          state.copyWith(sectionsResource: Resource.success(result.data)),
        );
        await Future.wait(result.data.map(_loadSectionContent));

      case ErrorResponse<List<HomeSectionEntity>>():
        emit(
          state.copyWith(sectionsResource: Resource.error(result.errMessage)),
        );
    }
  }

  Future<void> _loadSectionContent(HomeSectionEntity section) {
    switch (section.type) {
      case HomeSectionType.categories:
        return _loadCategories();
      case HomeSectionType.occasions:
        return _loadOccasions();
      case HomeSectionType.productsCarousel:
        return _loadCarousel(section);
      case HomeSectionType.bestSeller:
        return _loadBestSellers();
      case HomeSectionType.unknown:
        return Future.value();
    }
  }

  Future<void> _loadCategories() async {
    emit(state.copyWith(categoriesResource: Resource.loading()));
    final result = await _getCategoriesUseCase();
    emit(
      state.copyWith(
        categoriesResource: switch (result) {
          SuccessResponse() => Resource.success(result.data),
          ErrorResponse() => Resource.error(result.errMessage),
        },
      ),
    );
  }

  Future<void> _loadOccasions() async {
    emit(state.copyWith(occasionsResource: Resource.loading()));
    final result = await _getOccasionsUseCase(pageNumber: 1, pageSize: 20);
    emit(
      state.copyWith(
        occasionsResource: switch (result) {
          SuccessResponse() => Resource.success(result.data.data),
          ErrorResponse() => Resource.error(result.errMessage),
        },
      ),
    );
  }

  Future<void> _loadCarousel(HomeSectionEntity section) async {
    _emitCarousel(section.id, Resource.loading());

    if (section.occasionId != null) {
      final result = await _getProductsUseCase(
        occasionId: section.occasionId,
        pageNumber: 1,
        pageSize: 20,
      );
      _emitCarousel(section.id, switch (result) {
        SuccessResponse() => Resource.success(result.data.data),
        ErrorResponse() => Resource.error(result.errMessage),
      });
      return;
    }

    if (section.categoryId != null) {
      final result = await _getProductsByCategoryUseCase(
        categoryId: section.categoryId!,
      );
      _emitCarousel(section.id, switch (result) {
        SuccessResponse() => Resource.success(result.data),
        ErrorResponse() => Resource.error(result.errMessage),
      });
      return;
    }

    _emitCarousel(section.id, Resource.error(AppStrings.sectionHasNoFilter));
  }

  void _emitCarousel(String sectionId, Resource<List<ProductEntity>> resource) {
    emit(
      state.copyWith(
        carouselResources: {...state.carouselResources, sectionId: resource},
      ),
    );
  }

  // Backend has no best-sellers endpoint and won't add one, so this fetches
  // products per occasion and keeps whichever ones are flagged with
  // isBestSeller, instead of leaving the section empty.
  Future<void> _loadBestSellers() async {
    emit(state.copyWith(bestSellerResource: Resource.loading()));

    final occasionsResult = await _getOccasionsUseCase(
      pageNumber: 1,
      pageSize: 50,
    );

    switch (occasionsResult) {
      case SuccessResponse<PaginatedResponse<OccasionEntity>>():
        await _fetchBestSellersForOccasions(occasionsResult.data.data);
      case ErrorResponse<PaginatedResponse<OccasionEntity>>():
        emit(
          state.copyWith(
            bestSellerResource: Resource.error(occasionsResult.errMessage),
          ),
        );
    }
  }

  Future<void> _fetchBestSellersForOccasions(
    List<OccasionEntity> occasions,
  ) async {
    final List<BaseResponse<PaginatedResponse<ProductEntity>>> results;
    try {
      results = await Future.wait(
        occasions.map(
          (occasion) => _getProductsUseCase(
            occasionId: occasion.id,
            pageNumber: 1,
            pageSize: 20,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(bestSellerResource: Resource.error(e.toString())));
      return;
    }

    final bestSellersById = <String, ProductEntity>{};
    for (final result in results) {
      if (result is SuccessResponse<PaginatedResponse<ProductEntity>>) {
        for (final product in result.data.data) {
          if (product.isBestSeller == true && product.id != null) {
            bestSellersById[product.id!] = product;
          }
        }
      }
    }

    emit(
      state.copyWith(
        bestSellerResource: Resource.success(bestSellersById.values.toList()),
      ),
    );
  }
}
