import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/parent_record.dart';
import '../domain/student_record.dart';

class StudentRepository {
  StudentRepository(this._client);

  final SupabaseClient _client;

  Future<List<StudentRecord>> fetchStudents() async {
    final rows = await _client
        .from('students')
        .select('id, full_name, birth_date')
        .order('full_name');
    final accessRows = await _client
        .from('student_access')
        .select('student_id, username');
    final usernames = <String, String>{
      for (final row in accessRows)
        row['student_id'] as String: row['username'] as String,
    };

    return rows
        .map(
          (row) => StudentRecord.fromJson(
            row,
            username: usernames[row['id'] as String],
          ),
        )
        .toList();
  }

  Future<List<ParentRecord>> fetchParents() async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name, email')
        .eq('role', 'parent')
        .order('full_name');
    return rows.map(ParentRecord.fromJson).toList();
  }

  Future<StudentRecord> fetchStudent(String studentId) async {
    final row = await _client
        .from('students')
        .select('id, full_name, birth_date')
        .eq('id', studentId)
        .single();
    return StudentRecord.fromJson(row);
  }

  Future<void> updateStudent({
    required String studentId,
    required String fullName,
    required DateTime? birthDate,
  }) async {
    await _client
        .from('students')
        .update({
          'full_name': fullName.trim(),
          'birth_date': birthDate == null
              ? null
              : '${birthDate.year.toString().padLeft(4, '0')}-'
                    '${birthDate.month.toString().padLeft(2, '0')}-'
                    '${birthDate.day.toString().padLeft(2, '0')}',
        })
        .eq('id', studentId);
  }

  Future<void> createStudent({
    required String fullName,
    required String username,
    required String password,
    required DateTime? birthDate,
    required String? relationship,
    required String? parentUserId,
  }) async {
    await _client.functions.invoke(
      'create-student-account',
      body: {
        'fullName': fullName.trim(),
        'username': username.trim().toLowerCase(),
        'password': password,
        'birthDate': birthDate == null
            ? null
            : '${birthDate.year.toString().padLeft(4, '0')}-'
                  '${birthDate.month.toString().padLeft(2, '0')}-'
                  '${birthDate.day.toString().padLeft(2, '0')}',
        'relationship': relationship?.trim(),
        'parentUserId': ?parentUserId,
      },
    );
  }
}
