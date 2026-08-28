import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/home_section_entity.dart';
import '../repo/commerce_repo.dart';

@injectable
class GetHomeSectionsUseCase {
  final CommerceRepo _commerceRepo;
  GetHomeSectionsUseCase(this._commerceRepo);

  Future<BaseResponse<List<HomeSectionEntity>>> call() async {
    final result = await _commerceRepo.getHomeSections();
    return switch (result) {
      SuccessResponse() => SuccessResponse(_activeSortedByIndex(result.data)),
      ErrorResponse() => result,
    };
  }

  List<HomeSectionEntity> _activeSortedByIndex(List<HomeSectionEntity> sections) {
    return sections.where((s) => s.isActive).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
  }
}
