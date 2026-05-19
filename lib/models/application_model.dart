

class ApplicationModel {
  final String? id;
  final String userId;
  final String studentName;
  final String studentEmail;
  final int yearOfStudy;

  // Module 1
  final String module1Level;
  final String module1Code;
  final String module1Name;

  // Module 2 (optional)
  final String? module2Level;
  final String? module2Code;
  final String? module2Name;

  final bool meetsRequirements;
  final String? documentUrl;
  final String documentName;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? adminComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationModel({
    this.id,
    required this.userId,
    required this.studentName,
    required this.studentEmail,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Code,
    required this.module1Name,
    this.module2Level,
    this.module2Code,
    this.module2Name,
    required this.meetsRequirements,
    this.documentUrl,
    this.documentName = '',
    this.status = 'pending',
    this.adminComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ─── Supabase Serialization ─────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'student_name': studentName,
        'student_email': studentEmail,
        'year_of_study': yearOfStudy,
        'module1_level': module1Level,
        'module1_code': module1Code,
        'module1_name': module1Name,
        'module2_level': module2Level,
        'module2_code': module2Code,
        'module2_name': module2Name,
        'meets_requirements': meetsRequirements,
        'document_url': documentUrl,
        'document_name': documentName,
        'status': status,
        'admin_comment': adminComment,
      };

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id']?.toString(),
      userId: json['user_id'] ?? '',
      studentName: json['student_name'] ?? '',
      studentEmail: json['student_email'] ?? '',
      yearOfStudy: json['year_of_study'] ?? 1,
      module1Level: json['module1_level'] ?? '',
      module1Code: json['module1_code'] ?? '',
      module1Name: json['module1_name'] ?? '',
      module2Level: json['module2_level'],
      module2Code: json['module2_code'],
      module2Name: json['module2_name'],
      meetsRequirements: json['meets_requirements'] ?? false,
      documentUrl: json['document_url'],
      documentName: json['document_name'] ?? '',
      status: json['status'] ?? 'pending',
      adminComment: json['admin_comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  ApplicationModel copyWith({
    String? id,
    String? studentName,
    String? studentEmail,
    int? yearOfStudy,
    String? module1Level,
    String? module1Code,
    String? module1Name,
    String? module2Level,
    String? module2Code,
    String? module2Name,
    bool? meetsRequirements,
    String? documentUrl,
    String? documentName,
    String? status,
    String? adminComment,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1Level: module1Level ?? this.module1Level,
      module1Code: module1Code ?? this.module1Code,
      module1Name: module1Name ?? this.module1Name,
      module2Level: module2Level ?? this.module2Level,
      module2Code: module2Code ?? this.module2Code,
      module2Name: module2Name ?? this.module2Name,
      meetsRequirements: meetsRequirements ?? this.meetsRequirements,
      documentUrl: documentUrl ?? this.documentUrl,
      documentName: documentName ?? this.documentName,
      status: status ?? this.status,
      adminComment: adminComment ?? this.adminComment,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isPending  => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasSecondModule => module2Code != null && module2Code!.isNotEmpty;
}

// ─── Static Module Data ──────────────────────────────────────────────────────
class ModuleData {
  static const Map<String, List<Map<String, String>>> modulesByLevel = {
    'First Year': [
      {'code': 'PGM111', 'name': 'Introduction to Programming'},
      {'code': 'DBS111', 'name': 'Database Systems I'},
      {'code': 'WEB111', 'name': 'Web Development Fundamentals'},
      {'code': 'NET111', 'name': 'Networking Fundamentals'},
      {'code': 'OSY111', 'name': 'Operating Systems I'},
    ],
    'Second Year': [
      {'code': 'PGM211', 'name': 'Object-Oriented Programming'},
      {'code': 'DBS211', 'name': 'Database Systems II'},
      {'code': 'WEB211', 'name': 'Advanced Web Development'},
      {'code': 'NET211', 'name': 'Network Administration'},
      {'code': 'SAD211', 'name': 'Systems Analysis & Design'},
    ],
    'Third Year': [
      {'code': 'TPG311', 'name': 'Technical Programming I'},
      {'code': 'TPG316', 'name': 'Technical Programming III'},
      {'code': 'PRJ311', 'name': 'IT Project Management'},
      {'code': 'SEC311', 'name': 'Information Security'},
      {'code': 'MOB311', 'name': 'Mobile Application Development'},
    ],
  };

  static List<Map<String, String>> getModules(String level) {
    return modulesByLevel[level] ?? [];
  }

  static const List<String> levels = ['First Year', 'Second Year', 'Third Year'];
  static const List<int> studyYears = [1, 2, 3];
}
