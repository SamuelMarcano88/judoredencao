import 'package:flutter_test/flutter_test.dart';
import 'package:missao_proxima_faixa/features/progress/domain/progress_models.dart';

void main() {
  group('AttendanceStatistics', () {
    test('excludes excused classes from the attendance rate', () {
      final statistics = AttendanceStatistics.fromRecords([
        _record(AttendanceStatus.present),
        _record(AttendanceStatus.absent),
        _record(AttendanceStatus.excused),
      ]);

      expect(statistics.totalRecords, 3);
      expect(statistics.attendanceRate, 0.5);
    });

    test('has no rate when all records are excused', () {
      final statistics = AttendanceStatistics.fromRecords([
        _record(AttendanceStatus.excused),
      ]);

      expect(statistics.attendanceRate, isNull);
    });
  });
}

AttendanceRecord _record(AttendanceStatus status) {
  return AttendanceRecord(
    cycleId: 'cycle',
    classDate: DateTime(2026, 1, 1),
    status: status,
  );
}
