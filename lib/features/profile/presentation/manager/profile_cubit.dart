import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;

  ProfileCubit(this._getProfileUseCase)
      : super(ProfileState(resource: Resource.initial()));

  void doEvent(ProfileEvent event) {
    switch (event) {
      case LoadProfile():
        _loadProfile();
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
}
