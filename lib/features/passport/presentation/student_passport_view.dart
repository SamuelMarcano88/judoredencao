import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';

import '../domain/student_passport.dart';
import 'providers.dart';

class StudentPassportView extends ConsumerWidget {
  const StudentPassportView({
    super.key,
    this.studentId,
    this.allowCompletion = false,
  });

  final String? studentId;
  final bool allowCompletion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passport = studentId == null
        ? ref.watch(currentStudentPassportProvider)
        : ref.watch(studentPassportProvider(studentId!));
    final l10n = AppLocalizations.of(context)!;

    return passport.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _PassportLoadError(
        message: '${l10n.dashboardLoadError}: $error',
        onRetry: () {
          if (studentId == null) {
            ref.invalidate(currentStudentPassportProvider);
          } else {
            ref.invalidate(studentPassportProvider(studentId!));
          }
        },
      ),
      data: (value) => value == null
          ? Center(child: Text(l10n.studentPassportUnavailable))
          : _PassportContent(
              passport: value,
              studentId: studentId,
              allowCompletion: allowCompletion,
            ),
    );
  }
}

class StudentPassportScreen extends StatelessWidget {
  const StudentPassportScreen({
    super.key,
    required this.studentId,
    this.allowCompletion = false,
  });

  final String studentId;
  final bool allowCompletion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.passport)),
      body: StudentPassportView(
        studentId: studentId,
        allowCompletion: allowCompletion,
      ),
    );
  }
}

class _PassportContent extends ConsumerWidget {
  const _PassportContent({
    required this.passport,
    required this.studentId,
    required this.allowCompletion,
  });

  final StudentPassport passport;
  final String? studentId;
  final bool allowCompletion;

  Future<void> _toggleActivity(
    BuildContext context,
    WidgetRef ref,
    PassportChecklistItem item,
    bool completed,
  ) async {
    try {
      await ref
          .read(passportRepositoryProvider)
          .setActivityCompleted(
            studentId: passport.studentId,
            cycleActivityId: item.id,
            completed: completed,
          );
      if (studentId == null) {
        ref.invalidate(currentStudentPassportProvider);
      } else {
        ref.invalidate(studentPassportProvider(studentId!));
      }
    } catch (error) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.activityUpdateFailed}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final cycle = passport.cycle;
    final currentBelt = isSpanish
        ? passport.currentBeltNameEs
        : passport.currentBeltNamePt;
    final nextBelt = isSpanish
        ? cycle?.nextBeltNameEs
        : cycle?.nextBeltNamePt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passport.studentName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      _BeltLine(
                        label: l10n.currentBelt,
                        value: currentBelt ?? l10n.beltNotDefined,
                        color: passport.currentBeltColor,
                      ),
                      if (cycle != null) ...[
                        const SizedBox(height: 12),
                        _BeltLine(
                          label: l10n.nextBelt,
                          value: nextBelt ?? l10n.beltNotDefined,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (cycle == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.noCycleAssigned),
                  ),
                )
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.currentCycle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cycle.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(_dateRange(cycle, l10n)),
                        const SizedBox(height: 20),
                        Text(l10n.cycleProgress),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: cycle.progress),
                        const SizedBox(height: 8),
                        Text(
                          l10n.requiredActivitiesProgress(
                            cycle.completedRequiredCount,
                            cycle.requiredCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: Text(
                            l10n.checklist,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (cycle.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(l10n.noChecklistActivities),
                          )
                        else
                          ...cycle.items.map((item) {
                            final name = isSpanish
                                ? item.nameEs
                                : item.namePt;
                            final description = isSpanish
                                ? item.descriptionEs
                                : item.descriptionPt;
                            final subtitle = [
                              if (description != null &&
                                  description.isNotEmpty)
                                description,
                              if (!item.required) l10n.optionalActivity,
                            ].join(' • ');
                            return CheckboxListTile(
                              value: item.isCompleted,
                              onChanged: allowCompletion
                                  ? (value) {
                                      if (value != null) {
                                        _toggleActivity(
                                          context,
                                          ref,
                                          item,
                                          value,
                                        );
                                      }
                                    }
                                  : null,
                              title: Text(name),
                              subtitle: subtitle.isEmpty
                                  ? null
                                  : Text(subtitle),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _dateRange(PassportCycle cycle, AppLocalizations l10n) {
    final start = _formatDate(cycle.startDate);
    final end = cycle.endDate == null
        ? l10n.cycleStatusActive
        : _formatDate(cycle.endDate!);
    return '$start – $end';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _BeltLine extends StatelessWidget {
  const _BeltLine({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final parsedColor = _parseColor(color);
    return Row(
      children: [
        if (parsedColor != null) ...[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: parsedColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            '$label: $value',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Color? _parseColor(String? value) {
    if (value == null) return null;
    final hex = value.replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _PassportLoadError extends StatelessWidget {
  const _PassportLoadError({
    required this.message,
    required this.onRetry,
  });

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
