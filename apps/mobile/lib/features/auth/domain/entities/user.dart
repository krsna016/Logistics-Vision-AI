import 'role.dart';

class User {
  final String id;
  final String employeeId;
  final String name;
  final Role role;
  final String? warehouse;
  final bool isActive;
  final int failedLoginAttempts;
  final DateTime? lockedUntil;
  final String avatarUrl;

  const User({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.role,
    this.warehouse,
    this.isActive = true,
    this.failedLoginAttempts = 0,
    this.lockedUntil,
    this.avatarUrl = '',
  });

  bool get isAdmin => role == Role.administrator;

  User copyWith({
    String? id,
    String? employeeId,
    String? name,
    Role? role,
    String? warehouse,
    bool? isActive,
    int? failedLoginAttempts,
    DateTime? lockedUntil,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      role: role ?? this.role,
      warehouse: warehouse ?? this.warehouse,
      isActive: isActive ?? this.isActive,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
