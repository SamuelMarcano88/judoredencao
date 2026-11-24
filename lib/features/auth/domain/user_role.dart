enum UserRole {
  admin,
  parent,
  student,
  unknown;

  static UserRole fromDatabase(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'parent':
        return UserRole.parent;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.unknown;
    }
  }

  String get routeName {
    switch (this) {
      case UserRole.admin:
        return '/admin';
      case UserRole.parent:
        return '/responsavel';
      case UserRole.student:
        return '/aluno';
      case UserRole.unknown:
        return '/login';
    }
  }
}
