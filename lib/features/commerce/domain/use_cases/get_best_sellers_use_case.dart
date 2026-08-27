import 'package:flower_app/core/domain/result.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/repo/commerce_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetBestSellersUseCase {
  final CommerceRepo _repo;

  GetBestSellersUseCase(this._repo);

  Future<Result<PaginatedResponse<ProductEntity>>> call({
    required int page,
    required int pageSize,
    required String sort,
  }) {
    return _repo.getBestSellers(page: page, pageSize: pageSize, sort: sort);
  }
}
