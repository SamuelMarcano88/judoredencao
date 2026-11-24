import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/user_role.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/providers.dart';
import 'shell/dashboard_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final user = ref.read(authRepositoryProvider).currentUser;
      final loggingIn = state.matchedLocation == '/login';
      if (user == null) return loggingIn ? null : '/login';

      final role = await ref.read(authRepositoryProvider).getCurrentRole();
      if (role == UserRole.unknown) return '/login';
      if (loggingIn) return role.routeName;

      final location = state.matchedLocation;
      if (role == UserRole.admin && !location.startsWith('/admin')) {
        return '/admin';
      }
      if (role == UserRole.parent &&
          !location.startsWith('/responsavel')) {
        return '/responsavel';
      }
      if (role == UserRole.student && !location.startsWith('/aluno')) {
        return '/aluno';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) =>
            const DashboardShell(role: UserRole.admin),
      ),
      GoRoute(
        path: '/responsavel',
        builder: (context, state) =>
            const DashboardShell(role: UserRole.parent),
      ),
      GoRoute(
        path: '/aluno',
        builder: (context, state) =>
            const DashboardShell(role: UserRole.student),
      ),
    ],
  );
});
