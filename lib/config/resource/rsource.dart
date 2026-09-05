import 'package:equatable/equatable.dart';

enum ApiStatus { initial, loading, success, error }

class Resource<E> extends Equatable {
  final E? data;
  final String? errorMessage;
  final ApiStatus status;

  const Resource(this.status, this.data, this.errorMessage);

  const Resource.loading({this.data})
      : status = ApiStatus.loading,
        errorMessage = null;

  const Resource.success(this.data)
      : status = ApiStatus.success,
        errorMessage = null;

  const Resource.error(String error, {this.data})
      : status = ApiStatus.error,
        errorMessage = error;

  const Resource.initial()
      : status = ApiStatus.initial,
        data = null,
        errorMessage = null;

  bool get isSuccess => status == ApiStatus.success;
  bool get isLoading => status == ApiStatus.loading;
  bool get isError => status == ApiStatus.error;

  @override
  List<Object?> get props => [status, data, errorMessage];
}