class UserModel {
  final String id;
  final String name;
  final String department;
  final String faceImagePath;
  final List<double> faceFeatures;
  final Map<String, AttendanceRecord> attendanceRecords;

  UserModel({
    required this.id,
    required this.name,
    required this.department,
    required this.faceImagePath,
    required this.faceFeatures,
    Map<String, AttendanceRecord>? attendanceRecords,
  }) : attendanceRecords = attendanceRecords ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'faceImagePath': faceImagePath,
      'faceFeatures': faceFeatures,
      'attendanceRecords': attendanceRecords.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      faceImagePath: json['faceImagePath'],
      faceFeatures: List<double>.from(json['faceFeatures']),
      attendanceRecords: (json['attendanceRecords'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          AttendanceRecord.fromJson(value),
        ),
      ) ?? {},
    );
  }
}

class AttendanceRecord {
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isPresent;

  AttendanceRecord({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.isPresent = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'isPresent': isPresent,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      isPresent: json['isPresent'] ?? false,
    );
  }
} 