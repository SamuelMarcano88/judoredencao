enum AttendanceStatus {
  present,
  absent,
  excused;

  static AttendanceStatus fromDatabase(String value) {
    return switch (value) {
      'present' => AttendanceStatus.present,
      'absent' => AttendanceStatus.absent,
      'excused' => AttendanceStatus.excused,
      _ => throw FormatException('Unknown attendance status: $value'),
    };
  }
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.cycleId,
    required this.classDate,
    required this.status,
  });

  final String cycleId;
  final DateTime classDate;
  final AttendanceStatus status;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      cycleId: json['cycle_id'] as String,
      classDate: DateTime.parse(json['class_date'] as String),
      status: AttendanceStatus.fromDatabase(json['status'] as String),
    );
  }
}

class AttendanceStatistics {
  AttendanceStatistics.fromRecords(List<AttendanceRecord> records)
    : totalRecords = records.length,
      presentCount = records
          .where((record) => record.status == AttendanceStatus.present)
          .length,
      absentCount = records
          .where((record) => record.status == AttendanceStatus.absent)
          .length,
      excusedCount = records
          .where((record) => record.status == AttendanceStatus.excused)
          .length;

  final int totalRecords;
  final int presentCount;
  final int absentCount;
  final int excusedCount;

  double? get attendanceRate {
    final countedClasses = presentCount + absentCount;
    return countedClasses == 0 ? null : presentCount / countedClasses;
  }
}

class AttendanceRosterEntry {
  const AttendanceRosterEntry({
    required this.studentId,
    required this.studentName,
    required this.status,
  });

  final String studentId;
  final String studentName;
  final AttendanceStatus? status;
}

enum TechnicalEvaluationStatus {
  developing,
  needsWork,
  achieved;

  static TechnicalEvaluationStatus fromDatabase(String value) {
    return switch (value) {
      'developing' => TechnicalEvaluationStatus.developing,
      'needs_work' => TechnicalEvaluationStatus.needsWork,
      'achieved' => TechnicalEvaluationStatus.achieved,
      _ => throw FormatException('Unknown technical status: $value'),
    };
  }

  String get databaseValue => switch (this) {
    TechnicalEvaluationStatus.developing => 'developing',
    TechnicalEvaluationStatus.needsWork => 'needs_work',
    TechnicalEvaluationStatus.achieved => 'achieved',
  };
}

class TechnicalRequirementProgress {
  const TechnicalRequirementProgress({
    required this.id,
    required this.beltId,
    required this.namePt,
    required this.nameEs,
    required this.descriptionPt,
    required this.descriptionEs,
    required this.status,
    required this.observation,
  });

  final String id;
  final String beltId;
  final String namePt;
  final String nameEs;
  final String? descriptionPt;
  final String? descriptionEs;
  final TechnicalEvaluationStatus? status;
  final String? observation;

  factory TechnicalRequirementProgress.fromJson(
    Map<String, dynamic> json, {
    required Map<String, dynamic>? evaluation,
  }) {
    return TechnicalRequirementProgress(
      id: json['id'] as String,
      beltId: json['belt_id'] as String,
      namePt: json['name_pt'] as String,
      nameEs: json['name_es'] as String,
      descriptionPt: json['description_pt'] as String?,
      descriptionEs: json['description_es'] as String?,
      status: evaluation == null
          ? null
          : TechnicalEvaluationStatus.fromDatabase(
              evaluation['status'] as String,
            ),
      observation: evaluation?['observation'] as String?,
    );
  }
}

class TechnicalRequirement {
  const TechnicalRequirement({
    required this.id,
    required this.beltId,
    required this.namePt,
    required this.nameEs,
    required this.descriptionPt,
    required this.descriptionEs,
    required this.sortOrder,
  });

  final String id;
  final String beltId;
  final String namePt;
  final String nameEs;
  final String? descriptionPt;
  final String? descriptionEs;
  final int sortOrder;

  factory TechnicalRequirement.fromJson(Map<String, dynamic> json) {
    return TechnicalRequirement(
      id: json['id'] as String,
      beltId: json['belt_id'] as String,
      namePt: json['name_pt'] as String,
      nameEs: json['name_es'] as String,
      descriptionPt: json['description_pt'] as String?,
      descriptionEs: json['description_es'] as String?,
      sortOrder: json['sort_order'] as int,
    );
  }
}
