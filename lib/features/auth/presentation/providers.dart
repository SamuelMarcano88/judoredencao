import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../domain/user_role.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    return AuthRepository(Supabase.instance.client);
  } on StateError {
    return AuthRepository(null);
  }
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStates;
});

final currentRoleProvider = FutureProvider<UserRole>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).getCurrentRole();
});
