import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/domain/user_role.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/providers.dart';
import 'package:missao_proxima_faixa/features/students/presentation/student_dashboard_views.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final title = switch (role) {
      UserRole.admin => l10n.adminDashboard,
      UserRole.parent => l10n.parentDashboard,
      UserRole.student => l10n.studentDashboard,
      UserRole.unknown => l10n.appTitle,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: switch (role) {
        UserRole.admin => const AdminDashboardView(),
        UserRole.parent => const ParentDashboardView(),
        UserRole.student => Center(child: Text(l10n.stageOne)),
        UserRole.unknown => const SizedBox.shrink(),
      },
      floatingActionButton: role == UserRole.admin || role == UserRole.parent
          ? FloatingActionButton.extended(
              onPressed: () => context.go(
                role == UserRole.admin
                    ? '/admin/students/new'
                    : '/responsavel/filhos/novo',
              ),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(l10n.addStudent),
            )
          : null,
    );
  }
}
