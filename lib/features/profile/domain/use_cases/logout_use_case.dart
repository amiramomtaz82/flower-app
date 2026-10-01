import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final AuthRepo _authRepo;
  LogoutUseCase(this._authRepo);

  Future<void> call() async {
    await _authRepo.clearAuthData();
  }
}
