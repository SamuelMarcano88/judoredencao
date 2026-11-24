import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/progress_repository.dart';
import '../domain/progress_models.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(Supabase.instance.client);
});

final attendanceHistoryProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, studentId) {
      return ref
          .watch(progressRepositoryProvider)
          .fetchAttendanceHistory(studentId);
    });

typedef AttendanceRosterRequest = ({String cycleId, DateTime classDate});

final attendanceRosterProvider =
    FutureProvider.family<List<AttendanceRosterEntry>, AttendanceRosterRequest>(
      (ref, request) {
        return ref
            .watch(progressRepositoryProvider)
            .fetchAttendanceRoster(
              cycleId: request.cycleId,
              classDate: request.classDate,
            );
      },
    );

typedef TechnicalProgressRequest = ({
  String studentId,
  String cycleId,
  String beltId,
});

final technicalProgressProvider =
    FutureProvider.family<
      List<TechnicalRequirementProgress>,
      TechnicalProgressRequest
    >((ref, request) {
      return ref
          .watch(progressRepositoryProvider)
          .fetchTechnicalProgress(
            studentId: request.studentId,
            cycleId: request.cycleId,
            beltId: request.beltId,
          );
    });

final technicalRequirementsProvider =
    FutureProvider<List<TechnicalRequirement>>((ref) {
      return ref.watch(progressRepositoryProvider).fetchTechnicalRequirements();
    });
