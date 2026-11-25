import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:missao_proxima_faixa/core/l10n/app_localizations.dart';
import 'package:missao_proxima_faixa/features/passport/domain/student_passport.dart';
import 'package:missao_proxima_faixa/features/passport/presentation/providers.dart';

import '../domain/progress_models.dart';
import 'providers.dart';

class StudentDashboardOverview extends ConsumerWidget {
  const StudentDashboardOverview({
    super.key,
    required this.studentId,
    this.passportValue,
    this.dense = false,
    this.wrapInCard = true,
  });

  final String studentId;
  final StudentPassport? passportValue;
  final bool dense;
  final bool wrapInCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final passport = passportValue == null
        ? ref.watch(studentPassportProvider(studentId))
        : AsyncData(passportValue);
    final attendance = ref.watch(attendanceHistoryProvider(studentId));
    final cycle = passport.asData?.value?.cycle;
    final cycleId = cycle?.id;
    final beltId = cycle?.nextBeltId;
    final technical = cycleId == null || beltId == null
        ? null
        : ref.watch(
            technicalProgressProvider((
              studentId: studentId,
              cycleId: cycleId,
              beltId: beltId,
            )),
          );
    final content = Padding(
      padding: EdgeInsets.all(dense ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.progressOverview,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          passport.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => _OverviewError(
              message: '${l10n.dashboardLoadError}: $error',
              onRetry: () => ref.invalidate(studentPassportProvider(studentId)),
            ),
            data: (value) => value == null
                ? Text(l10n.studentPassportUnavailable)
                : _OverviewData(
                    cycle: value.cycle,
                    attendance: attendance,
                    technical: technical,
                    studentId: studentId,
                    dense: dense,
                  ),
          ),
        ],
      ),
    );
    return wrapInCard ? Card(child: content) : content;
  }
}

class _OverviewData extends ConsumerWidget {
  const _OverviewData({
    required this.cycle,
    required this.attendance,
    required this.technical,
    required this.studentId,
    required this.dense,
  });

  final PassportCycle? cycle;
  final AsyncValue<List<AttendanceRecord>> attendance;
  final AsyncValue<List<TechnicalRequirementProgress>>? technical;
  final String studentId;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cycle == null)
          Text(l10n.noCycleAssigned)
        else ...[
          Text(cycle!.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: cycle!.progress),
          const SizedBox(height: 6),
          Text(
            l10n.requiredActivitiesProgress(
              cycle!.completedRequiredCount,
              cycle!.requiredCount,
            ),
          ),
        ],
        SizedBox(height: dense ? 10 : 16),
        attendance.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => _OverviewError(
            message: '${l10n.dashboardLoadError}: $error',
            onRetry: () => ref.invalidate(attendanceHistoryProvider(studentId)),
          ),
          data: (records) {
            if (records.isEmpty) return Text(l10n.noAttendanceRecords);
            final statistics = AttendanceStatistics.fromRecords(records);
            final rate = statistics.attendanceRate == null
                ? l10n.attendanceRateNotAvailable
                : '${(statistics.attendanceRate! * 100).toStringAsFixed(0)}%';
            return Text(
              '${l10n.attendanceRate}: $rate · '
              '${l10n.attendanceRecordedClasses}: ${statistics.totalRecords}',
            );
          },
        ),
        if (cycle != null) ...[
          SizedBox(height: dense ? 8 : 12),
          if (cycle!.nextBeltId == null)
            Text(l10n.technicalRequirementNotReady)
          else
            technical!.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => _OverviewError(
                message: '${l10n.dashboardLoadError}: $error',
                onRetry: () => ref.invalidate(
                  technicalProgressProvider((
                    studentId: studentId,
                    cycleId: cycle!.id,
                    beltId: cycle!.nextBeltId!,
                  )),
                ),
              ),
              data: (items) {
                if (items.isEmpty) return Text(l10n.noTechnicalRequirements);
                final achieved = items
                    .where(
                      (item) =>
                          item.status == TechnicalEvaluationStatus.achieved,
                    )
                    .length;
                return Text(
                  l10n.technicalRequirementsSummary(achieved, items.length),
                );
              },
            ),
        ],
      ],
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        TextButton(onPressed: onRetry, child: Text(l10n.retry)),
      ],
    );
  }
}
