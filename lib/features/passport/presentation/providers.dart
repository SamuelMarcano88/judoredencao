import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/passport_repository.dart';
import '../domain/student_passport.dart';

final passportRepositoryProvider = Provider<PassportRepository>((ref) {
  return PassportRepository(Supabase.instance.client);
});

final studentPassportProvider =
    FutureProvider.family<StudentPassport?, String>((ref, studentId) {
      return ref
          .watch(passportRepositoryProvider)
          .fetchStudentPassport(studentId);
    });

final currentStudentPassportProvider = FutureProvider<StudentPassport?>((ref) {
  return ref.watch(passportRepositoryProvider).fetchCurrentStudentPassport();
});

final trainingCyclesProvider = FutureProvider<List<TrainingCycleSummary>>((
  ref,
) {
  return ref.watch(passportRepositoryProvider).fetchCycles();
});

final passportBeltsProvider = FutureProvider<List<PassportBelt>>((ref) {
  return ref.watch(passportRepositoryProvider).fetchBelts();
});
