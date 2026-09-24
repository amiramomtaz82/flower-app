import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/notificaions/fcm.dart';
import '../../../auth/domain/use_cases/get_auth_status_use_case.dart';
import '../../../notifications/domain/usecase/sync_fcm_token_use_case.dart';
import 'splash_event.dart';
import 'splash_state.dart';

@injectable
class SplashCubit extends Cubit<SplashState> {
  final GetAuthStatusUseCase _getAuthStatusUseCase;
  final FcmService _fcm;
  final SyncFcmTokenUseCase _syncFcmTokenUseCase;

  SplashCubit(
      this._getAuthStatusUseCase,
      this._fcm,
      this._syncFcmTokenUseCase,
      ) : super(SplashInitial());

  Future<void> doEvents(SplashEvent event) async {
    switch (event) {
      case SplashStarted():
        await _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      _fcm.initialize(),
      _syncFcmTokenUseCase(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    final isAuthenticated = await _getAuthStatusUseCase();

    if (isAuthenticated) {
      emit(SplashAuthenticated());
    } else {
      emit(SplashUnauthenticated());
    }
  }
}