import 'package:flower_app/config/base_response/base_response.dart';

import 'package:flower_app/features/auth/domain/entities/login_entity.dart';



import '../../../../config/base_response/base_response.dart';
import '../../data/models/register_request.dart';
import '../entities/auth_entity.dart';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<LoginEntity>> login({
    required String email,
    required String password,
  });
  Future<BaseResponse<RegisterEntity>> signUp(SignUpRequest request);

  // TODO: implement login

  Future<BaseResponse<AuthMessageEntity>> forgetPassword({
    required String email,
  });

  Future<BaseResponse<ResetToken>> verifyOtp({
    required String email,
    required String otpCode,
  });

  Future<BaseResponse<AuthMessageEntity>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  });
}
