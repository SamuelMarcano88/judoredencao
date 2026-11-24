import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/auth/domain/user_role.dart';
import 'package:missao_proxima_faixa/features/auth/presentation/providers.dart';

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
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.welcome,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(l10n.stageOne),
                const SizedBox(height: 24),
                const Icon(Icons.sports_martial_arts, size: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
