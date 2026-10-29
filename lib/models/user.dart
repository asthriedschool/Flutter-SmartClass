class AppUser {
  const AppUser({
    required this.idUser,
    required this.fullName,
    required this.email,
    required this.role,
    required this.accountStatus,
    this.profilePicture,
    this.lastLoginAt,
  });

  final int idUser;
  final String fullName;
  final String email;
  final String role;
  final String accountStatus;
  final String? profilePicture;
  final DateTime? lastLoginAt;

  bool get isAdmin => role == 'ADMIN';

  bool get isActive => accountStatus == 'ACTIVE';

  String get initials => userInitials(fullName);

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final picture = json['profile_picture'];
    return AppUser(
      idUser: (json['id_user'] as num).toInt(),
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      accountStatus:
          json['account_status'] as String? ?? '',
      profilePicture:
          picture is String && picture.isNotEmpty
          ? picture
          : null,
      lastLoginAt: _date(json['last_login_at']),
    );
  }
}

String userInitials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    final word = parts.first;
    return word[0].toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

DateTime? _date(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String? userTimestamp(DateTime? time) {
  if (time == null) {
    return null;
  }
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}
