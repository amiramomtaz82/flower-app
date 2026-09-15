import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/update_fecm_token.dart';
import '../../data/remote_data_source.dart';

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<void> updateFcmToken(UpdateFcmTokenRequest request) async {
    await _dio.put(
      '/devices/fcm-token', // Confirm the exact endpoint path in your Postman collection
      data: request.toJson(),
    );
  }
}