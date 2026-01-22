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
    return FaceRecognitionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      confidence: json['confidence']?.toDouble(),
      isMatch: json['is_match'] ?? json['match'],
      userId: json['user_id'],
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
