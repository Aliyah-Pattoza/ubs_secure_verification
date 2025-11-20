class ApiConstants {
  // Base URLs - Sesuaikan dengan IP LAN Anda
  static const String baseUrlAuth = 'http://xxx.xxx.xxx.xxx';
  static const String baseUrlFR = 'http://xxx.xxx.xxx.xxx';
  static const String baseUrlList = 'http://xxx.xxx.xxx.yyy';
  static const String baseUrlVerification = 'http://xxx.xxx.xxx.www';
  
  // Temporary Test URL
  static const String testFRUrl = 'https://apifr.free.beeceptor.com/recognize';
  
  // API Endpoints
  static const String authUserPassImei = '/api/auth/login';
  static const String faceRecognition = '/api/fr/recognize';
  static const String transactionList = '/api/transactions/pending';
  static const String verifyTransaction = '/api/transactions/verify';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}