class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.username,
  });

  final String id;
  final String fullName;
  final DateTime? birthDate;
  final String? username;

  factory StudentRecord.fromJson(
    Map<String, dynamic> json, {
    String? username,
  }) {
    final birthDateValue = json['birth_date'] as String?;
    return StudentRecord(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      birthDate: birthDateValue == null ? null : DateTime.parse(birthDateValue),
      username: username,
    );
  }
}
