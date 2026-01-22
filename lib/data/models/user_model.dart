class UserModel {
  final String id;
  final String name;
  final String nik;
  final String email;
  final String? photoUrl;
  final String? department;
  final String? deviceImei;

  UserModel({
    required this.id,
    required this.name,
    required this.nik,
    this.email = '',
    this.photoUrl,
    this.department,
    this.deviceImei,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nik: json['nik'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photo_url'],
      department: json['department'],
      deviceImei: json['device_imei'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nik': nik,
      'email': email,
      'photo_url': photoUrl,
      'department': department,
      'device_imei': deviceImei,
    };
  }

  /// Mendapatkan inisial nama untuk avatar
  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
