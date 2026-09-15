class User {
  final String id;
  final String uniEmail;
  final String role; // 'STUDENT', 'MODERATOR', 'ADMIN'
  final String? firstName;
  final String? lastName;
  final String? department;
  final int? registrationNumber;
  final String? phoneNumber;

  User({
    required this.id,
    required this.uniEmail,
    required this.role,
    this.firstName,
    this.lastName,
    this.department,
    this.registrationNumber,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '').toString(),
      uniEmail: json['uniEmail']?.toString() ?? '',
      role: (json['role'] ?? 'STUDENT').toString().toUpperCase(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      department: json['department']?.toString(),
      registrationNumber: json['registrationNumber'] is num
          ? (json['registrationNumber'] as num).toInt()
          : (json['registrationNumber'] != null
              ? int.tryParse(json['registrationNumber'].toString())
              : null),
      phoneNumber: json['phoneNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uniEmail': uniEmail,
    'role': role,
    'firstName': firstName,
    'lastName': lastName,
    'department': department,
    'registrationNumber': registrationNumber,
    'phoneNumber': phoneNumber,
  };

  bool get isModerator => role == 'MODERATOR' || role == 'ADMIN';
  bool get isAdmin => role == 'ADMIN';
  bool get isStudent => role == 'STUDENT';
}

class TokenResponse {
  final String accessToken;
  final String role;
  final String tokenType;
  final int expiresIn;
  final User? user;

  TokenResponse({
    required this.accessToken,
    required this.role,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
    this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final directRole = json['role']?.toString();
    final userObj = json['user'] is Map<String, dynamic>
        ? User.fromJson(json['user'] as Map<String, dynamic>)
        : null;
    final resolvedRole = (directRole ?? userObj?.role ?? 'STUDENT').toUpperCase();

    return TokenResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      role: resolvedRole,
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: json['expiresIn'] is num
          ? (json['expiresIn'] as num).toInt()
          : 3600,
      user: userObj,
    );
  }
}
