import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/providers.dart';

import '../domain/progress_models.dart';
import 'providers.dart';

class AttendanceManagementView extends ConsumerStatefulWidget {
  const AttendanceManagementView({super.key});

  @override
  ConsumerState<AttendanceManagementView> createState() =>
      _AttendanceManagementViewState();
}

class _AttendanceManagementViewState
    extends ConsumerState<AttendanceManagementView> {
  late DateTime _classDate;
  final Map<String, AttendanceStatus> _statusOverrides = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _classDate = DateTime(today.year, today.month, today.day);
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDatePicker(
      context: context,
      initialDate: _classDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l10n.attendanceDate,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _classDate = selected;
      _statusOverrides.clear();
    });
  }

  Future<void> _save({
    required String cycleId,
    required AttendanceRosterRequest request,
    required List<AttendanceRosterEntry> entries,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final statuses = <String, AttendanceStatus>{
      for (final entry in entries)
        if (_statusOverrides[entry.studentId] != null)
          entry.studentId: _statusOverrides[entry.studentId]!
        else if (entry.status != null)
          entry.studentId: entry.status!,
    };
    if (statuses.length != entries.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.attendanceIncomplete)));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(progressRepositoryProvider)
          .saveAttendance(
            cycleId: cycleId,
            classDate: _classDate,
            entries: entries,
            statuses: statuses,
          );
      ref.invalidate(attendanceRosterProvider(request));
      ref.invalidate(attendanceHistoryProvider);
      if (!mounted) return;
      _statusOverrides.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.attendanceSaved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.attendanceSaveFailed}: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycles = ref.watch(trainingCyclesProvider);
    return cycles.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${l10n.dashboardLoadError}: $error'),
            TextButton(
              onPressed: () => ref.invalidate(trainingCyclesProvider),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.noCycles),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => context.go('/admin/cycles/new'),
                  child: Text(l10n.createCycle),
                ),
              ],
            ),
          );
        }

        final selectedCycle = items.firstWhere(
          (cycle) => cycle.id == _cycleId,
          orElse: () => items.firstWhere(
            (cycle) => cycle.status == 'active',
            orElse: () => items.first,
          ),
        );
        final request = (cycleId: selectedCycle.id, classDate: _classDate);
        final roster = ref.watch(attendanceRosterProvider(request));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedCycle.id,
              decoration: InputDecoration(labelText: l10n.cycles),
              items: items
                  .map(
                    (cycle) => DropdownMenuItem(
                      value: cycle.id,
                      child: Text(cycle.name),
                    ),
                  )
                  .toList(),
              onChanged: (cycleId) {
                if (cycleId == null) return;
                setState(() {
                  _cycleId = cycleId;
                  _statusOverrides.clear();
                });
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${l10n.attendanceDate}: ${_formatDate(_classDate)}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.attendance,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            roster.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Column(
                children: [
                  Text('${l10n.dashboardLoadError}: $error'),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(attendanceRosterProvider(request)),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
              data: (entries) {
                if (entries.isEmpty) return Text(l10n.noStudentsInCycle);
                final allMarked = entries.every(
                  (entry) =>
                      _statusOverrides[entry.studentId] != null ||
                      entry.status != null,
                );
                return Column(
                  children: [
                    ...entries.map((entry) {
                      final selectedStatus =
                          _statusOverrides[entry.studentId] ?? entry.status;
                      return Card(
                        child: ListTile(
                          title: Text(entry.studentName),
                          trailing: SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedStatus?.name ?? '',
                              decoration: const InputDecoration(isDense: true),
                              items: [
                                if (selectedStatus == null)
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text(l10n.chooseAttendance),
                                  ),
                                DropdownMenuItem(
                                  value: 'present',
                                  child: Text(l10n.present),
                                ),
                                DropdownMenuItem(
                                  value: 'absent',
                                  child: Text(l10n.absent),
                                ),
                                DropdownMenuItem(
                                  value: 'excused',
                                  child: Text(l10n.excused),
                                ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(() {
                                      if (value == null || value.isEmpty) {
                                        _statusOverrides.remove(
                                          entry.studentId,
                                        );
                                      } else {
                                        _statusOverrides[entry.studentId] =
                                            AttendanceStatus.fromDatabase(
                                              value,
                                            );
                                      }
                                    }),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: allMarked && !_saving
                            ? () => _save(
                                cycleId: selectedCycle.id,
                                request: request,
                                entries: entries,
                              )
                            : null,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(l10n.saveAttendance),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  String? _cycleId;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
