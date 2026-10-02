import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final AuthRepo _authRepo;

  LogoutUseCase(this._authRepo);

  Future<BaseResponse<void>> call() async {
    return await _authRepo.logout();
  }
}