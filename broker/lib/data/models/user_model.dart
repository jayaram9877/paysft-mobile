/// Mirrors the API `UserResponse` (GET /auth/me).
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String mobile;
  final String userType;
  final String? avatarUrl;
  final bool isActive;
  final bool emailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.mobile,
    required this.userType,
    this.avatarUrl,
    this.isActive = false,
    this.emailVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      mobile: (json['mobile'] as String?) ?? '',
      userType: (json['user_type'] as String?) ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? false,
      emailVerified: json['email_verified_at'] != null,
    );
  }

  /// Up to 2 uppercase initials from the full name (for the avatar fallback).
  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
