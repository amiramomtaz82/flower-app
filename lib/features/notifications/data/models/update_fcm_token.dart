class UpdateFcmTokenRequest {
  final String token;
  final String platform; // "Android" or "iOS"

  const UpdateFcmTokenRequest({
    required this.token,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'platform': platform,
  };
}