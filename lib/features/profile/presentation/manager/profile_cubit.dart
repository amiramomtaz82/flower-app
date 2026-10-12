import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:flower_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  ProfileCubit(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._logoutUseCase,
    this._changePasswordUseCase,
  ) : super(ProfileState.initial());

  void doEvent(ProfileEvent event) {
    switch (event) {
      case LoadProfile():
        _loadProfile();
      case UpdateProfile():
        _updateProfile(event.updateProfileEntity);
      case LogoutEvent():
        _logout();
      case ChangePasswordEvent():
        _changePassword(event.changePasswordEntity);
    }
  }

  Future<void> _loadProfile() async {
    emit(state.copyWith(resource: Resource.loading()));

    try {
      final result = await _getProfileUseCase();

      switch (result) {
        case SuccessResponse<ProfileEntity>():
          emit(state.copyWith(resource: Resource.success(result.data)));
        case ErrorResponse<ProfileEntity>():
          emit(state.copyWith(resource: Resource.error(result.errMessage)));
      }
    } catch (e) {
      emit(state.copyWith(resource: Resource.error(e.toString())));
    }
  }

  Future<void> _updateProfile(UpdateProfileParams updateProfileEntity) async {
    emit(state.copyWith(updateProfileResource: Resource.loading()));

    try {
      final result = await _updateProfileUseCase(updateProfileEntity);

      switch (result) {
        case SuccessResponse<ProfileEntity>():
          emit(
            state.copyWith(
              updateProfileResource: Resource.success(result.data),
              resource: Resource.success(result.data),
            ),
          );
        case ErrorResponse<ProfileEntity>():
          emit(
            state.copyWith(
              updateProfileResource: Resource.error(result.errMessage),
            ),
          );
      }
    } catch (e) {
      emit(state.copyWith(updateProfileResource: Resource.error(e.toString())));
    }
  }

  Future<void> _logout() async {
    emit(state.copyWith(logoutResource: Resource.loading()));
    try {
      await _logoutUseCase();
      emit(state.copyWith(logoutResource: Resource.success(null)));
    } catch (e) {
      emit(state.copyWith(logoutResource: Resource.error(e.toString())));
    }
  }

  Future<void> _changePassword(
    ChangePasswordParams changePasswordEntity,
  ) async {
    emit(state.copyWith(changePasswordResource: Resource.loading()));

    try {
      final result = await _changePasswordUseCase(changePasswordEntity);

      switch (result) {
        case SuccessResponse<void>():
          emit(state.copyWith(changePasswordResource: Resource.success(null)));
        case ErrorResponse<void>():
          emit(
            state.copyWith(
              changePasswordResource: Resource.error(result.errMessage),
            ),
          );
      }
    } catch (e) {
      emit(
        state.copyWith(changePasswordResource: Resource.error(e.toString())),
      );
    }
  }
}
