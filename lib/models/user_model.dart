class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // student, parent, admin, counsellor, warden, police
  final bool isApproved; // For police and counsellor/warden
  final String? phone;
  final String? department;
  final String? idProofUrl; // ID proof document URL
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.isApproved = false,
    this.phone,
    this.department,
    this.idProofUrl,
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
      'idProofUrl': idProofUrl,
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
      idProofUrl: map['idProofUrl'],
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
    String? idProofUrl,
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
      idProofUrl: idProofUrl ?? this.idProofUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

