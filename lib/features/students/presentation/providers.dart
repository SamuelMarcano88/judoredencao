import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/student_repository.dart';
import '../domain/parent_record.dart';
import '../domain/student_record.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(Supabase.instance.client);
});

final studentsProvider = FutureProvider<List<StudentRecord>>((ref) {
  return ref.watch(studentRepositoryProvider).fetchStudents();
});

final parentsProvider = FutureProvider<List<ParentRecord>>((ref) {
  return ref.watch(studentRepositoryProvider).fetchParents();
});
