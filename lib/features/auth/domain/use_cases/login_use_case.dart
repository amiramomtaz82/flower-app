import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/device/device_id_service.dart';
import '../../../../config/notificaions/fcm.dart';

import '../../data/models/login_request.dart';

@injectable
class LoginUseCase {
  LoginUseCase(
      this._authRepository,
      this._deviceIdService,
      this._firebaseMessagingService,
      );

  final AuthRepo _authRepository;
  final DeviceIdService _deviceIdService;
  final Fcm _firebaseMessagingService;

  Future<BaseResponse<LoginEntity>> call({
    required String email,
    required String password,
  }) async {
    final deviceId = await _deviceIdService.getDeviceId();

    final fcmToken = await Fcm.getToken();

    final request = LoginRequest(
      email: email,
      password: password,
      deviceId: deviceId,
      fcmToken: fcmToken,
    );

    return await _authRepository.login(request);
  }
}
