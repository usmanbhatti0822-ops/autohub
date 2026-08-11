class AppUser {
  final String id;
  final String phone;
  final String? fullName;
  final String? email;
  final String? city;
  final String? avatarUrl;
  final bool phoneVerified;
  final String verificationLevel;
  final String role;

  const AppUser({
    required this.id,
    required this.phone,
    this.fullName,
    this.email,
    this.city,
    this.avatarUrl,
    this.phoneVerified = false,
    required this.verificationLevel,
    required this.role,
  });

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : phone;

  bool get hasCompleteProfile =>
      fullName != null && fullName!.trim().isNotEmpty && email != null && email!.trim().isNotEmpty;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        fullName: json['fullName'] as String?,
        email: json['email'] as String?,
        city: json['city'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        phoneVerified: json['phoneVerified'] as bool? ?? false,
        verificationLevel: json['verificationLevel'] as String? ?? 'unverified',
        role: json['role'] as String? ?? 'buyer_seller',
      );
}
