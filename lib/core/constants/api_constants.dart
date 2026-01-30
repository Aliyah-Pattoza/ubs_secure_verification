import '../../config/ubs_api_config.dart';

/// Konstanta API (backward compatibility).
/// Semua URL dan endpoint sebaiknya diatur di [UbsApiConfig].
class ApiConstants {
  static String get baseUrlAuth => UbsApiConfig.baseUrlAuth;
  static String get baseUrlFR => UbsApiConfig.baseUrlFrVerify;
  static String get baseUrlList => UbsApiConfig.baseUrlListPengesahan;
  static String get baseUrlVerification => UbsApiConfig.baseUrlFrApproval;

  static String get testFRUrl => UbsApiConfig.beeceptorFrUrl;

  static String get authUserPassImei => UbsApiConfig.authUrl;
  static String get faceRecognition => UbsApiConfig.frVerifyUrl;
  static String get transactionList => UbsApiConfig.listPengesahanUrl;
  static String get verifyTransaction => UbsApiConfig.frApprovalUrl;

  static Duration get connectionTimeout => UbsApiConfig.timeout;
  static Duration get receiveTimeout => UbsApiConfig.timeout;

  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
