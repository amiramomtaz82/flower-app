
import 'dart:async' as _i4;

import 'package:flower_app/config/base_response/base_response.dart' as _i5;
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart'
    as _i10;
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart'
    as _i9;
import 'package:flower_app/features/auth/data/models/register_request.dart'
    as _i7;
import 'package:flower_app/features/auth/data/models/register_response.dart'
    as _i2;
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart'
    as _i6;
import 'package:flower_app/features/auth/domain/use_cases/register_use_case.dart'
    as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i8;



class _FakeAuthResponse_0 extends _i1.SmartFake implements _i2.AuthResponse {
  _FakeAuthResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [RegisterUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockRegisterUseCase extends _i1.Mock implements _i3.RegisterUseCase {
  MockRegisterUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i5.BaseResponse<_i6.RegisterEntity>> call(
    _i7.SignUpRequest? request,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#call, [request]),
            returnValue: _i4.Future<_i5.BaseResponse<_i6.RegisterEntity>>.value(
              _i8.dummyValue<_i5.BaseResponse<_i6.RegisterEntity>>(
                this,
                Invocation.method(#call, [request]),
              ),
            ),
          )
          as _i4.Future<_i5.BaseResponse<_i6.RegisterEntity>>);
}

/// A class which mocks [AuthRemoteDataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthRemoteDataSource extends _i1.Mock
    implements _i9.AuthRemoteDataSource {
  MockAuthRemoteDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.AuthResponse> signUp(_i7.SignUpRequest? request) =>
      (super.noSuchMethod(
            Invocation.method(#signUp, [request]),
            returnValue: _i4.Future<_i2.AuthResponse>.value(
              _FakeAuthResponse_0(this, Invocation.method(#signUp, [request])),
            ),
          )
          as _i4.Future<_i2.AuthResponse>);
}

/// A class which mocks [AuthLocalDataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthLocalDataSource extends _i1.Mock
    implements _i10.AuthLocalDataSource {
  MockAuthLocalDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> saveToken(String? token) =>
      (super.noSuchMethod(
            Invocation.method(#saveToken, [token]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<String?> getToken() =>
      (super.noSuchMethod(
            Invocation.method(#getToken, []),
            returnValue: _i4.Future<String?>.value(),
          )
          as _i4.Future<String?>);

  @override
  _i4.Future<void> clearToken() =>
      (super.noSuchMethod(
            Invocation.method(#clearToken, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}
