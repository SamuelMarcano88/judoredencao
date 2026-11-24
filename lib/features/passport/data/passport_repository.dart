import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/student_passport.dart';

class PassportRepository {
  PassportRepository(this._client);

  final SupabaseClient _client;

  Future<List<TrainingCycleSummary>> fetchCycles() async {
    final rows = await _client
        .from('cycles')
        .select('id, name, start_date, end_date, status')
        .order('start_date', ascending: false);
    return rows.map(TrainingCycleSummary.fromJson).toList();
  }

  Future<List<PassportBelt>> fetchBelts() async {
    final rows = await _client
        .from('belts')
        .select('id, name, name_pt, name_es, color, sequence')
        .eq('active', true)
        .order('sequence');
    return rows.map(PassportBelt.fromJson).toList();
  }

  Future<StudentPassport?> fetchCurrentStudentPassport() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final access = await _client
        .from('student_access')
        .select('student_id')
        .eq('auth_user_id', userId)
        .eq('active', true)
        .maybeSingle();
    final studentId = access?['student_id'] as String?;
    if (studentId == null) return null;
    return fetchStudentPassport(studentId);
  }

  Future<StudentPassport?> fetchStudentPassport(String studentId) async {
    final student = await _client
        .from('students')
        .select('id, full_name, current_belt_id')
        .eq('id', studentId)
        .maybeSingle();
    if (student == null) return null;

    final assignments = await _client
        .from('student_cycles')
        .select('cycle_id, status')
        .eq('student_id', studentId);
    final cycleIds = assignments
        .map((row) => row['cycle_id'] as String)
        .toSet()
        .toList();

    Map<String, dynamic>? cycle;
    if (cycleIds.isNotEmpty) {
      final cycleRows = await _client
          .from('cycles')
          .select('id, name, start_date, end_date, status, current_belt_id, next_belt_id')
          .inFilter('id', cycleIds);
      final candidates = cycleRows.toList()
        ..sort((left, right) {
          final leftActive = left['status'] == 'active';
          final rightActive = right['status'] == 'active';
          if (leftActive != rightActive) return rightActive ? 1 : -1;
          return DateTime.parse(right['start_date'] as String).compareTo(
            DateTime.parse(left['start_date'] as String),
          );
        });
      if (candidates.isNotEmpty) cycle = candidates.first;
    }

    final cycleActivities = cycle == null
        ? <Map<String, dynamic>>[]
        : (await _client
                  .from('cycle_activities')
                  .select(
                    'id, sort_order, required, activities(id, name_pt, name_es, description_pt, description_es)',
                  )
                  .eq('cycle_id', cycle['id'])
                  .order('sort_order'))
              .cast<Map<String, dynamic>>();

    final activityIds = cycleActivities
        .map((row) => row['id'] as String)
        .toList();
    final completedIds = <String>{};
    if (activityIds.isNotEmpty) {
      final logs = await _client
          .from('student_activity_logs')
          .select('cycle_activity_id')
          .eq('student_id', studentId)
          .inFilter('cycle_activity_id', activityIds);
      completedIds.addAll(
        logs.map((row) => row['cycle_activity_id'] as String),
      );
    }

    final items = <PassportChecklistItem>[];
    for (final row in cycleActivities) {
      final activity = row['activities'] as Map<String, dynamic>?;
      if (activity == null) continue;
      items.add(
        PassportChecklistItem(
          id: row['id'] as String,
          namePt: activity['name_pt'] as String,
          nameEs: activity['name_es'] as String,
          descriptionPt: activity['description_pt'] as String?,
          descriptionEs: activity['description_es'] as String?,
          required: row['required'] as bool,
          isCompleted: completedIds.contains(row['id']),
        ),
      );
    }

    final studentBeltId = student['current_belt_id'] as String?;
    final cycleBeltId = cycle?['current_belt_id'] as String?;
    final nextBeltId = cycle?['next_belt_id'] as String?;
    final beltIds = {studentBeltId, cycleBeltId, nextBeltId}
        .whereType<String>()
        .toList();
    final belts = beltIds.isEmpty
        ? <Map<String, dynamic>>[]
        : (await _client
                  .from('belts')
                  .select('id, name, name_pt, name_es, color, sequence')
                  .inFilter('id', beltIds))
              .cast<Map<String, dynamic>>();
    final beltsById = <String, PassportBelt>{
      for (final row in belts)
        row['id'] as String: PassportBelt.fromJson(row),
    };
    final currentBelt = beltsById[studentBeltId ?? cycleBeltId];
    final nextBelt = beltsById[nextBeltId];

    return StudentPassport(
      studentId: studentId,
      studentName: student['full_name'] as String,
      currentBeltNamePt: currentBelt?.namePt,
      currentBeltNameEs: currentBelt?.nameEs,
      currentBeltColor: currentBelt?.color,
      cycle: cycle == null
          ? null
          : PassportCycle(
              id: cycle['id'] as String,
              name: cycle['name'] as String,
              startDate: DateTime.parse(cycle['start_date'] as String),
              endDate: cycle['end_date'] == null
                  ? null
                  : DateTime.parse(cycle['end_date'] as String),
              nextBeltNamePt: nextBelt?.namePt,
              nextBeltNameEs: nextBelt?.nameEs,
              items: items,
            ),
    );
  }

  Future<void> setActivityCompleted({
    required String studentId,
    required String cycleActivityId,
    required bool completed,
  }) async {
    if (completed) {
      await _client.from('student_activity_logs').insert({
        'student_id': studentId,
        'cycle_activity_id': cycleActivityId,
      });
    } else {
      await _client
          .from('student_activity_logs')
          .delete()
          .eq('student_id', studentId)
          .eq('cycle_activity_id', cycleActivityId);
    }
  }

  Future<void> createCycle({
    required String name,
    required DateTime startDate,
    required DateTime? endDate,
    required String? currentBeltId,
    required String? nextBeltId,
    required List<String> studentIds,
    required List<Map<String, dynamic>> activities,
  }) async {
    await _client.rpc(
      'create_training_cycle',
      params: {
        'p_name': name.trim(),
        'p_start_date': _formatDate(startDate),
        'p_end_date': endDate == null ? null : _formatDate(endDate),
        'p_current_belt_id': currentBeltId,
        'p_next_belt_id': nextBeltId,
        'p_student_ids': studentIds,
        'p_activities': activities,
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
