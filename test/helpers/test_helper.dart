import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  RegisterUseCase,
  AuthRemoteDataSource,
  AuthLocalDataSource,
])
void main() {}
