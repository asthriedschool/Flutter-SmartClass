class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInSeconds;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresInSeconds,
  });

  factory AuthResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'],
      expiresInSeconds: json['expiresInSeconds'],
    );
  }
}