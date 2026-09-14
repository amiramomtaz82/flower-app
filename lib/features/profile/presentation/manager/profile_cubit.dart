import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
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

  ProfileCubit(
    this._getProfileUseCase,
    this._updateProfileUseCase,
  ) : super(ProfileState.initial());

  void doEvent(ProfileEvent event) {
    switch (event) {
      case LoadProfile():
        _loadProfile();
      case UpdateProfile():
        _updateProfile(event.updateProfileEntity);
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

  Future<void> _updateProfile(UpdateProfileEntity updateProfileEntity) async {
    emit(state.copyWith(updateProfileResource: Resource.loading()));

    try {
      final result = await _updateProfileUseCase(updateProfileEntity);

      switch (result) {
        case SuccessResponse<ProfileEntity>():
          emit(state.copyWith(
            updateProfileResource: Resource.success(result.data),
            resource: Resource.success(result.data),
          ));
        case ErrorResponse<ProfileEntity>():
          emit(state.copyWith(
            updateProfileResource: Resource.error(result.errMessage),
          ));
      }
    } catch (e) {
      emit(state.copyWith(
        updateProfileResource: Resource.error(e.toString()),
      ));
    }
  }
}
