class StudentPassport {
  const StudentPassport({
    required this.studentId,
    required this.studentName,
    required this.currentBeltNamePt,
    required this.currentBeltNameEs,
    required this.currentBeltColor,
    required this.cycle,
  });

  final String studentId;
  final String studentName;
  final String? currentBeltNamePt;
  final String? currentBeltNameEs;
  final String? currentBeltColor;
  final PassportCycle? cycle;
}

class PassportCycle {
  const PassportCycle({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.nextBeltNamePt,
    required this.nextBeltNameEs,
    required this.items,
  });

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final String? nextBeltNamePt;
  final String? nextBeltNameEs;
  final List<PassportChecklistItem> items;

  int get completedRequiredCount =>
      items.where((item) => item.required && item.isCompleted).length;

  int get requiredCount => items.where((item) => item.required).length;

  double get progress => requiredCount == 0
      ? 0
      : completedRequiredCount / requiredCount;
}

class PassportChecklistItem {
  const PassportChecklistItem({
    required this.id,
    required this.namePt,
    required this.nameEs,
    required this.descriptionPt,
    required this.descriptionEs,
    required this.required,
    required this.isCompleted,
  });

  final String id;
  final String namePt;
  final String nameEs;
  final String? descriptionPt;
  final String? descriptionEs;
  final bool required;
  final bool isCompleted;
}

class TrainingCycleSummary {
  const TrainingCycleSummary({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;

  factory TrainingCycleSummary.fromJson(Map<String, dynamic> json) {
    return TrainingCycleSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
    );
  }
}

class PassportBelt {
  const PassportBelt({
    required this.id,
    required this.namePt,
    required this.nameEs,
    required this.color,
    required this.sequence,
  });

  final String id;
  final String namePt;
  final String nameEs;
  final String color;
  final int sequence;

  factory PassportBelt.fromJson(Map<String, dynamic> json) {
    return PassportBelt(
      id: json['id'] as String,
      namePt: json['name_pt'] as String? ?? json['name'] as String,
      nameEs: json['name_es'] as String? ?? json['name'] as String,
      color: json['color'] as String,
      sequence: json['sequence'] as int,
    );
  }
}
