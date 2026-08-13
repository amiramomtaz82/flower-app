import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class ForgetPasswordUseCase {
  final AuthRepo _authRepo;
  ForgetPasswordUseCase(this._authRepo);
  // TODO: implement forget password use case logic
}
