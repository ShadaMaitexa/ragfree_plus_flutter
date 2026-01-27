class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // student, parent, admin, counsellor, warden, police
  final bool isApproved; // For police and counsellor/warden
  final String? phone;
  final String? department;
  final String? institution;
  final String? institutionNormalized;
  final String? idProofUrl; // ID proof document URL
  final String? parentName;
  final String? parentEmail;
  final String? parentPhone;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.isApproved = false,
    this.phone,
    this.department,
    this.institution,
    this.institutionNormalized,
    this.idProofUrl,
    this.parentName,
    this.parentEmail,
    this.parentPhone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'isApproved': isApproved,
      'phone': phone,
      'department': department,
      'institution': institution,
      'institutionNormalized': institutionNormalized,
      'idProofUrl': idProofUrl,
      'parentName': parentName,
      'parentEmail': parentEmail,
      'parentPhone': parentPhone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      isApproved: map['isApproved'] ?? false,
      phone: map['phone'],
      department: map['department'],
      institution: map['institution'],
      institutionNormalized: map['institutionNormalized'],
      idProofUrl: map['idProofUrl'],
      parentName: map['parentName'],
      parentEmail: map['parentEmail'],
      parentPhone: map['parentPhone'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    bool? isApproved,
    String? phone,
    String? department,
    String? institution,
    String? institutionNormalized,
    String? idProofUrl,
    String? parentName,
    String? parentEmail,
    String? parentPhone,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      institution: institution ?? this.institution,
      institutionNormalized: institutionNormalized ?? this.institutionNormalized,
      idProofUrl: idProofUrl ?? this.idProofUrl,
      parentName: parentName ?? this.parentName,
      parentEmail: parentEmail ?? this.parentEmail,
      parentPhone: parentPhone ?? this.parentPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

