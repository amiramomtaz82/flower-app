enum LocationFailureType {
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  unableToGetLocation,
  unknown,
}

class LocationFailure {
  final LocationFailureType type;
  final String? message;

  const LocationFailure({
    required this.type,
    this.message,
  });
}