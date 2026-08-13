import 'package:flower_app/config/secure_storage/secure_storage.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveToken(String token) => _secureStorage.saveToken(token);

  @override
  Future<String?> getToken() => _secureStorage.getToken();

  @override
  Future<void> clearToken() => _secureStorage.deleteToken();
}
