import 'user_model.dart';

/// Response dari API Auth
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final UserModel? user;
  final String? vpnConfig;

  AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.user,
    this.vpnConfig,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      vpnConfig: json['vpn_config'],
    );
  }
}

/// Response dari API Face Recognition
class FaceRecognitionResponse {
  final bool success;
  final String? message;
  final double? confidence;
  final bool? isMatch;
  final String? userId;

  FaceRecognitionResponse({
    required this.success,
    this.message,
    this.confidence,
    this.isMatch,
    this.userId,
  });

  factory FaceRecognitionResponse.fromJson(Map<String, dynamic> json) {
    // Handle Beeceptor API response format
    // Response is an array with first element containing the data
    if (json is List && json.isNotEmpty) {
      final data = json[0] as Map<String, dynamic>;
      return FaceRecognitionResponse(
        success: data['success'] ?? false,
        message: data['message'] ?? '-',
        confidence: data['conf'] != null ? double.tryParse(data['conf'].toString()) : null,
        isMatch: data['success'] ?? false,
        userId: data['induk'] ?? data['rfid'],
      );
    }
    
    // Handle standard API response format
    return FaceRecognitionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      confidence: json['confidence']?.toDouble() ?? 
                  (json['conf'] != null ? double.tryParse(json['conf'].toString()) : null),
      isMatch: json['is_match'] ?? json['match'] ?? json['success'] ?? false,
      userId: json['user_id'] ?? json['induk'] ?? json['rfid'],
    );
  }
}

/// Response dari API Approval
class ApprovalResponse {
  final bool success;
  final String? message;
  final String? documentNumber;
  final String? newStatus;

  ApprovalResponse({
    required this.success,
    this.message,
    this.documentNumber,
    this.newStatus,
  });

  factory ApprovalResponse.fromJson(Map<String, dynamic> json) {
    return ApprovalResponse(
      success: json['success'] ?? false,
      message: json['message'],
      documentNumber: json['document_number'],
      newStatus: json['status'],
    );
  }
}

/// Generic API Response
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });
}
