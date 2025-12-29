class UserProfile {
  final ProviderInfo provider;
  final UserInfo user;

  UserProfile({required this.provider, required this.user});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      provider: ProviderInfo.fromJson(json['provider'] ?? {}),
      user: UserInfo.fromJson(json['user'] ?? {}),
    );
  }
}

class ProviderInfo {
  final String name;
  final String id;
  final String application;
  final List<String> roles;
  final List<String> permissions;

  ProviderInfo({
    required this.name,
    required this.id,
    required this.application,
    required this.roles,
    required this.permissions,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      application: json['application'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }
}

class UserInfo {
  final String username;
  final String email;
  final String created;
  final String updated;
  final Map<String, dynamic> settings;

  UserInfo({
    required this.username,
    required this.email,
    required this.created,
    required this.updated,
    required this.settings,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
      settings: json['settings'] ?? {},
    );
  }
}
