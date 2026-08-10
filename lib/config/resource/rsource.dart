enum ApiStatus { initial, loading, success, error }

class Resource<E> {
  E? data = null;
  String? errorMessage;
  late ApiStatus status;

  Resource(this.status, this.data, this.errorMessage);

  Resource.loading() {
    status = ApiStatus.loading;
  }

  Resource.success(this.data) {
    status = ApiStatus.success;
  }

  Resource.error(String error) {
    errorMessage = error;
    status = ApiStatus.error;
  }

  Resource.initial() {
    status = ApiStatus.initial;
  }

  bool get isSuccess => status == ApiStatus.success;

  bool get isLoading => status == ApiStatus.loading;

  bool get isError => status == ApiStatus.error;
}
