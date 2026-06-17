class UserProfile {
  const UserProfile({
    this.phone,
    this.customPhotoUrl,
    this.notificationsOnboarded = false,
  });

  final String? phone;
  final String? customPhotoUrl;
  final bool notificationsOnboarded;

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;
  bool get hasCustomPhoto =>
      customPhotoUrl != null && customPhotoUrl!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'customPhotoUrl': customPhotoUrl,
        'notificationsOnboarded': notificationsOnboarded,
      };

  factory UserProfile.fromSnapshot(Object? raw) {
    if (raw is! Map) return const UserProfile();
    final map = Map<String, dynamic>.from(raw);
    return UserProfile(
      phone: (map['phone'] as String?)?.trim().isNotEmpty == true
          ? (map['phone'] as String).trim()
          : null,
      customPhotoUrl:
          (map['customPhotoUrl'] as String?)?.trim().isNotEmpty == true
              ? (map['customPhotoUrl'] as String).trim()
              : null,
      notificationsOnboarded:
          (map['notificationsOnboarded'] as bool?) ?? false,
    );
  }
}
