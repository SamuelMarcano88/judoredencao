import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/progress_models.dart';

class ProgressRepository {
  ProgressRepository(this._client);

  final SupabaseClient _client;

  Future<List<AttendanceRecord>> fetchAttendanceHistory(
    String studentId,
  ) async {
    final rows = await _client
        .from('attendance')
        .select('cycle_id, class_date, status')
        .eq('student_id', studentId)
        .order('class_date', ascending: false);
    return rows.map(AttendanceRecord.fromJson).toList();
  }

  Future<List<AttendanceRosterEntry>> fetchAttendanceRoster({
    required String cycleId,
    required DateTime classDate,
  }) async {
    final assignments = await _client
        .from('student_cycles')
        .select('student_id')
        .eq('cycle_id', cycleId);
    final studentIds = assignments
        .map((row) => row['student_id'] as String)
        .toList();
    if (studentIds.isEmpty) return const [];

    final students = await _client
        .from('students')
        .select('id, full_name')
        .inFilter('id', studentIds)
        .order('full_name');
    final attendanceRows = await _client
        .from('attendance')
        .select('student_id, status')
        .eq('cycle_id', cycleId)
        .eq('class_date', _formatDate(classDate))
        .inFilter('student_id', studentIds);
    final statuses = <String, AttendanceStatus>{
      for (final row in attendanceRows)
        row['student_id'] as String: AttendanceStatus.fromDatabase(
          row['status'] as String,
        ),
    };

    return students
        .map(
          (row) => AttendanceRosterEntry(
            studentId: row['id'] as String,
            studentName: row['full_name'] as String,
            status: statuses[row['id'] as String],
          ),
        )
        .toList();
  }

  Future<void> saveAttendance({
    required String cycleId,
    required DateTime classDate,
    required List<AttendanceRosterEntry> entries,
    required Map<String, AttendanceStatus> statuses,
  }) async {
    final records = entries.map((entry) {
      final status = statuses[entry.studentId];
      if (status == null) {
        throw StateError('Attendance is missing for ${entry.studentName}.');
      }
      return {'studentId': entry.studentId, 'status': status.name};
    }).toList();

    await _client.rpc(
      'record_cycle_attendance',
      params: {
        'p_cycle_id': cycleId,
        'p_class_date': _formatDate(classDate),
        'p_records': records,
      },
    );
  }

  Future<List<TechnicalRequirementProgress>> fetchTechnicalProgress({
    required String studentId,
    required String cycleId,
    required String beltId,
  }) async {
    final requirements = await _client
        .from('technical_requirements')
        .select('id, belt_id, name_pt, name_es, description_pt, description_es')
        .eq('belt_id', beltId)
        .eq('active', true)
        .order('sort_order');
    if (requirements.isEmpty) return const [];

    final requirementIds = requirements
        .map((row) => row['id'] as String)
        .toList();
    final evaluations = await _client
        .from('student_technical_evaluations')
        .select('requirement_id, status, observation')
        .eq('student_id', studentId)
        .eq('cycle_id', cycleId)
        .inFilter('requirement_id', requirementIds);
    final evaluationsByRequirement = <String, Map<String, dynamic>>{
      for (final row in evaluations) row['requirement_id'] as String: row,
    };

    return requirements
        .map(
          (row) => TechnicalRequirementProgress.fromJson(
            row,
            evaluation: evaluationsByRequirement[row['id'] as String],
          ),
        )
        .toList();
  }

  Future<List<TechnicalRequirement>> fetchTechnicalRequirements() async {
    final rows = await _client
        .from('technical_requirements')
        .select(
          'id, belt_id, name_pt, name_es, description_pt, description_es, sort_order',
        )
        .eq('active', true)
        .order('sort_order');
    return rows.map(TechnicalRequirement.fromJson).toList();
  }

  Future<void> createTechnicalRequirement({
    required String beltId,
    required String namePt,
    required String nameEs,
    required String? descriptionPt,
    required String? descriptionEs,
  }) async {
    await _client.from('technical_requirements').insert({
      'belt_id': beltId,
      'name_pt': namePt.trim(),
      'name_es': nameEs.trim(),
      'description_pt': _optionalText(descriptionPt),
      'description_es': _optionalText(descriptionEs),
    });
  }

  Future<void> saveTechnicalEvaluation({
    required String studentId,
    required String cycleId,
    required String requirementId,
    required TechnicalEvaluationStatus status,
    required String? observation,
  }) async {
    await _client.rpc(
      'save_student_technical_evaluation',
      params: {
        'p_student_id': studentId,
        'p_cycle_id': cycleId,
        'p_requirement_id': requirementId,
        'p_status': status.databaseValue,
        'p_observation': _optionalText(observation),
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String? _optionalText(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
