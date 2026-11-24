import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';

import '../domain/progress_models.dart';
import 'providers.dart';

class AttendanceHistorySection extends ConsumerWidget {
  const AttendanceHistorySection({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final attendance = ref.watch(attendanceHistoryProvider(studentId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.attendanceHistory,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            attendance.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Column(
                children: [
                  Text('${l10n.dashboardLoadError}: $error'),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(attendanceHistoryProvider(studentId)),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
              data: (records) => records.isEmpty
                  ? Text(l10n.noAttendanceRecords)
                  : _AttendanceSummary(records: records),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({required this.records});

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statistics = AttendanceStatistics.fromRecords(records);
    final rate = statistics.attendanceRate;
    final rateLabel = rate == null
        ? l10n.attendanceRateNotAvailable
        : '${(rate * 100).toStringAsFixed(0)}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text('${l10n.attendanceRate}: $rateLabel'),
            Text(
              '${l10n.attendanceRecordedClasses}: '
              '${statistics.totalRecords}',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...records
            .take(5)
            .map(
              (record) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(switch (record.status) {
                  AttendanceStatus.present => Icons.check_circle_outline,
                  AttendanceStatus.absent => Icons.cancel_outlined,
                  AttendanceStatus.excused => Icons.event_busy_outlined,
                }),
                title: Text(_attendanceStatusLabel(l10n, record.status)),
                trailing: Text(_formatDate(record.classDate)),
              ),
            ),
      ],
    );
  }
}

class TechnicalProgressSection extends ConsumerWidget {
  const TechnicalProgressSection({
    super.key,
    required this.studentId,
    required this.cycleId,
    required this.beltId,
    required this.allowEvaluation,
  });

  final String studentId;
  final String? cycleId;
  final String? beltId;
  final bool allowEvaluation;

  Future<void> _editEvaluation(
    BuildContext context,
    WidgetRef ref,
    TechnicalProgressRequest request,
    TechnicalRequirementProgress requirement,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final draft = await showDialog<_EvaluationDraft>(
      context: context,
      builder: (context) => _TechnicalEvaluationDialog(
        initialStatus: requirement.status,
        initialObservation: requirement.observation,
      ),
    );
    if (draft == null || !context.mounted) return;

    try {
      await ref
          .read(progressRepositoryProvider)
          .saveTechnicalEvaluation(
            studentId: request.studentId,
            cycleId: request.cycleId,
            requirementId: requirement.id,
            status: draft.status,
            observation: draft.observation,
          );
      ref.invalidate(technicalProgressProvider(request));
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.evaluationSaved)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.evaluationSaveFailed}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final request = cycleId == null || beltId == null
        ? null
        : (studentId: studentId, cycleId: cycleId!, beltId: beltId!);
    final progress = request == null
        ? null
        : ref.watch(technicalProgressProvider(request));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.technicalProgress,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (request == null)
              Text(l10n.technicalRequirementNotReady)
            else
              progress!.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => Column(
                  children: [
                    Text('${l10n.dashboardLoadError}: $error'),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(technicalProgressProvider(request)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
                data: (items) {
                  if (items.isEmpty) return Text(l10n.noTechnicalRequirements);
                  final achieved = items
                      .where(
                        (item) =>
                            item.status == TechnicalEvaluationStatus.achieved,
                      )
                      .length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LinearProgressIndicator(value: achieved / items.length),
                      const SizedBox(height: 8),
                      Text('$achieved / ${items.length}'),
                      const SizedBox(height: 8),
                      ...items.map(
                        (item) => _TechnicalRequirementTile(
                          item: item,
                          allowEvaluation: allowEvaluation,
                          onEvaluate: () =>
                              _editEvaluation(context, ref, request, item),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalRequirementTile extends StatelessWidget {
  const _TechnicalRequirementTile({
    required this.item,
    required this.allowEvaluation,
    required this.onEvaluate,
  });

  final TechnicalRequirementProgress item;
  final bool allowEvaluation;
  final VoidCallback onEvaluate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final description = isSpanish ? item.descriptionEs : item.descriptionPt;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(isSpanish ? item.nameEs : item.namePt),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_technicalStatusLabel(l10n, item.status)),
          if (description != null && description.isNotEmpty) Text(description),
          if (item.observation != null && item.observation!.isNotEmpty)
            Text(item.observation!),
        ],
      ),
      trailing: allowEvaluation
          ? IconButton(
              tooltip: l10n.evaluate,
              onPressed: onEvaluate,
              icon: const Icon(Icons.edit_outlined),
            )
          : null,
    );
  }
}

class _TechnicalEvaluationDialog extends StatefulWidget {
  const _TechnicalEvaluationDialog({
    required this.initialStatus,
    required this.initialObservation,
  });

  final TechnicalEvaluationStatus? initialStatus;
  final String? initialObservation;

  @override
  State<_TechnicalEvaluationDialog> createState() =>
      _TechnicalEvaluationDialogState();
}

class _TechnicalEvaluationDialogState
    extends State<_TechnicalEvaluationDialog> {
  late TechnicalEvaluationStatus _status;
  late final TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? TechnicalEvaluationStatus.developing;
    _observationController = TextEditingController(
      text: widget.initialObservation ?? '',
    );
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.technicalEvaluation),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TechnicalEvaluationStatus>(
            initialValue: _status,
            items: TechnicalEvaluationStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(_technicalStatusLabel(l10n, status)),
                  ),
                )
                .toList(),
            onChanged: (status) {
              if (status != null) setState(() => _status = status);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observationController,
            maxLength: 1000,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.evaluationObservation,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _EvaluationDraft(
              status: _status,
              observation: _observationController.text,
            ),
          ),
          child: Text(l10n.saveEvaluation),
        ),
      ],
    );
  }
}

class _EvaluationDraft {
  const _EvaluationDraft({required this.status, required this.observation});

  final TechnicalEvaluationStatus status;
  final String observation;
}

String _attendanceStatusLabel(AppLocalizations l10n, AttendanceStatus status) {
  return switch (status) {
    AttendanceStatus.present => l10n.present,
    AttendanceStatus.absent => l10n.absent,
    AttendanceStatus.excused => l10n.excused,
  };
}

String _technicalStatusLabel(
  AppLocalizations l10n,
  TechnicalEvaluationStatus? status,
) {
  return switch (status) {
    null => l10n.notEvaluated,
    TechnicalEvaluationStatus.developing => l10n.technicalStatusDeveloping,
    TechnicalEvaluationStatus.needsWork => l10n.technicalStatusNeedsWork,
    TechnicalEvaluationStatus.achieved => l10n.technicalStatusAchieved,
  };
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
