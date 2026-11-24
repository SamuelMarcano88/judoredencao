import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_role.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient? _client;

  Stream<AuthState> get authStates {
    final client = _client;
    return client == null
        ? const Stream<AuthState>.empty()
        : client.auth.onAuthStateChange;
  }

  User? get currentUser => _client?.auth.currentUser;

  Future<UserRole> getCurrentRole() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return UserRole.unknown;
    final profile = await client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    return UserRole.fromDatabase(profile?['role'] as String?);
  }

  Future<void> signIn({required String email, required String password}) {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase no está configurado.');
    }
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signInWithGoogle({required String redirectTo}) {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase no está configurado.');
    }
    return client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  Future<AuthResponse> signUpParent({
    required String fullName,
    required String email,
    required String password,
  }) {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase no está configurado.');
    }
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'preferred_language': 'pt'},
    );
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}
