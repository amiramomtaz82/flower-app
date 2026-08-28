import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/occasion_entity.dart';
import '../repo/commerce_repo.dart';

@injectable
class GetOccasionsUseCase {
  final CommerceRepo _commerceRepo;
  GetOccasionsUseCase(this._commerceRepo);

  Future<BaseResponse<PaginatedResponse<OccasionEntity>>> call({
    required int pageNumber,
    required int pageSize,
  }) {
    return _commerceRepo.getOccasions(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
