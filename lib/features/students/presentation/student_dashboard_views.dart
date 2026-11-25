import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/cycle_management_screen.dart';
import 'package:missao_proxima_faixa/features/progress/presentation/attendance_management_view.dart';
import 'package:missao_proxima_faixa/features/progress/presentation/student_dashboard_overview.dart';
import 'package:missao_proxima_faixa/features/progress/presentation/technical_requirements_view.dart';
import 'package:missao_proxima_faixa/features/students/domain/parent_record.dart';
import 'package:missao_proxima_faixa/features/students/domain/student_record.dart';
import 'providers.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.students, icon: const Icon(Icons.groups_outlined)),
              Tab(
                text: l10n.parents,
                icon: const Icon(Icons.family_restroom_outlined),
              ),
              Tab(text: l10n.cycles, icon: const Icon(Icons.autorenew)),
              Tab(
                text: l10n.attendance,
                icon: const Icon(Icons.fact_check_outlined),
              ),
              Tab(
                text: l10n.technicalRequirements,
                icon: const Icon(Icons.sports_martial_arts),
              ),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                StudentListView(isParent: false),
                ParentListView(),
                CycleListView(),
                AttendanceManagementView(),
                TechnicalRequirementsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParentDashboardView extends StatelessWidget {
  const ParentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            l10n.myChildren,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const Expanded(child: StudentListView(isParent: true)),
      ],
    );
  }
}

class StudentListView extends ConsumerWidget {
  const StudentListView({super.key, required this.isParent});

  final bool isParent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final students = ref.watch(studentsProvider);
    return students.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _LoadError(
        message: '${l10n.dashboardLoadError}: $error',
        onRetry: () => ref.invalidate(studentsProvider),
      ),
      data: (items) {
        if (items.isEmpty) return Center(child: Text(l10n.noStudents));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => isParent
              ? _ParentStudentOverviewCard(student: items[index])
              : _StudentCard(student: items[index], isParent: false),
        );
      },
    );
  }
}

class _ParentStudentOverviewCard extends StatelessWidget {
  const _ParentStudentOverviewCard({required this.student});

  final StudentRecord student;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details = <String>[
      if (student.birthDate != null)
        '${student.birthDate!.day.toString().padLeft(2, '0')}/'
            '${student.birthDate!.month.toString().padLeft(2, '0')}/'
            '${student.birthDate!.year}',
      if (student.username != null) '${l10n.username}: ${student.username}',
    ];
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            onTap: () =>
                context.go('/responsavel/filhos/${student.id}/passaporte'),
            leading: const CircleAvatar(child: Icon(Icons.sports_martial_arts)),
            title: Text(student.fullName),
            subtitle: details.isEmpty ? null : Text(details.join(' • ')),
            trailing: const Icon(Icons.chevron_right),
          ),
          StudentDashboardOverview(
            studentId: student.id,
            dense: true,
            wrapInCard: false,
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.isParent});

  final StudentRecord student;
  final bool isParent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details = <String>[
      if (student.birthDate != null)
        '${student.birthDate!.day.toString().padLeft(2, '0')}/'
            '${student.birthDate!.month.toString().padLeft(2, '0')}/'
            '${student.birthDate!.year}',
      if (isParent && student.username != null)
        '${l10n.username}: ${student.username}',
    ];
    return Card(
      child: ListTile(
        onTap: () => context.go(
          isParent
              ? '/responsavel/filhos/${student.id}/passaporte'
              : '/admin/students/${student.id}/passport',
        ),
        leading: const CircleAvatar(child: Icon(Icons.sports_martial_arts)),
        title: Text(student.fullName),
        subtitle: details.isEmpty ? null : Text(details.join(' • ')),
        trailing: isParent
            ? const Icon(Icons.chevron_right)
            : IconButton(
                tooltip: l10n.editStudent,
                onPressed: () =>
                    context.go('/admin/students/${student.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
              ),
      ),
    );
  }
}

class ParentListView extends ConsumerWidget {
  const ParentListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final parents = ref.watch(parentsProvider);
    return parents.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _LoadError(
        message: '${l10n.dashboardLoadError}: $error',
        onRetry: () => ref.invalidate(parentsProvider),
      ),
      data: (items) {
        if (items.isEmpty) return Center(child: Text(l10n.noParents));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _ParentCard(parent: items[index]),
        );
      },
    );
  }
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({required this.parent});

  final ParentRecord parent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(parent.fullName),
        subtitle: parent.email == null ? null : Text(parent.email!),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
