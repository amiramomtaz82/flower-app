import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class GetAuthStatusUseCase {
  final AuthRepo _authRepo;

  GetAuthStatusUseCase(this._authRepo);

  Future<bool> call() async {
    return _authRepo.isAuthenticated();
  }
}