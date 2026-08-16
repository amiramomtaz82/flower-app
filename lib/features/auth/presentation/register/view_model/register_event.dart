import 'package:flower_app/features/auth/data/models/register_request.dart';

sealed class RegisterEvent {}

class DoRegister extends RegisterEvent {
  final SignUpRequest request;

  DoRegister(this.request);
}