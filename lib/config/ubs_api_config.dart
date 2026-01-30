class UbsApiConfig {
  UbsApiConfig._();

  // ==========================================================================
  // FLAG: Mode API
  // ==========================================================================
  static const bool useUbsApis = false;

  static const bool useBeeceptor = true;

  static const bool useBeeceptorForFr = true;

  static const bool vpnRouteAllTraffic = false;

  static const List<String> vpnAllowedIps = ['192.168.0.0/16', '10.0.0.0/8'];

  // ==========================================================================
  // BEECEPTOR BASE URL (Testing)
  // ==========================================================================
  static const String beeceptorBaseUrl = 'https://usecure.free.beeceptor.com';

  // ==========================================================================
  // a. API AUTH_user_pass_imei (Login: user, password, IMEI)
  // ==========================================================================
  // UBS Production URL
  static const String baseUrlAuth = 'http://xxx.xxx.xxx.xxx';
  static const String pathAuth = '/api/auth/login';

  // Beeceptor URL
  static const String beeceptorAuthUrl = '$beeceptorBaseUrl/auth/login';

  /// URL yang digunakan untuk Auth API
  static String get authUrl =>
      useBeeceptor ? beeceptorAuthUrl : _normalizeUrl(baseUrlAuth, pathAuth);

  // ==========================================================================
  // b. API FR_wajah_user_nik (Verifikasi wajah: image, user_id, nik)
  // ==========================================================================
  // UBS Production URL
  static const String baseUrlFrVerify = 'http://xxx.xxx.xxx.xxx';
  static const String pathFrVerify = '/api/fr/wajah-user-nik';

  // Beeceptor URL
  static const String beeceptorFrUrl = '$beeceptorBaseUrl/recognize';

  /// URL yang digunakan untuk Face Recognition API
  static String get frVerifyUrl => useBeeceptorForFr
      ? beeceptorFrUrl
      : _normalizeUrl(baseUrlFrVerify, pathFrVerify);

  // ==========================================================================
  // c. API LIST_pengesahan (Daftar dokumen pengesahan / pending approval)
  // ==========================================================================
  // UBS Production URL
  static const String baseUrlListPengesahan = 'http://xxx.xxx.xxx.yyy';
  static const String pathListPengesahan = '/api/pengesahan/list';

  // Beeceptor URL
  static const String beeceptorListUrl = '$beeceptorBaseUrl/transactions/list';

  /// URL yang digunakan untuk Transaction List API
  static String get listPengesahanUrl => useBeeceptor
      ? beeceptorListUrl
      : _normalizeUrl(baseUrlListPengesahan, pathListPengesahan);

  // ==========================================================================
  // d. API FR_wajah_user_nik_nodocument_status (Verifikasi wajah + no dokumen + status Accept/Reject)
  // ==========================================================================
  // UBS Production URL
  static const String baseUrlFrApproval = 'http://xxx.xxx.xxx.www';
  static const String pathFrApproval =
      '/api/fr/wajah-user-nik-nodocument-status';

  // Beeceptor URL (menggunakan endpoint berbeda: usecures)
  static const String beeceptorApprovalBaseUrl =
      'https://usecures.free.beeceptor.com';
  static const String beeceptorApprovalUrl =
      '$beeceptorApprovalBaseUrl/transactions/approve';

  /// URL yang digunakan untuk Approval API
  static String get frApprovalUrl => useBeeceptor
      ? beeceptorApprovalUrl
      : _normalizeUrl(baseUrlFrApproval, pathFrApproval);

  // ==========================================================================
  // Timeout & Headers
  // ==========================================================================
  static const Duration timeout = Duration(seconds: 30);
  static const Duration timeoutBeeceptor = Duration(seconds: 15);

  /// Timeout yang digunakan berdasarkan mode
  static Duration get activeTimeout =>
      useBeeceptor ? timeoutBeeceptor : timeout;

  static String _normalizeUrl(String base, String path) {
    final b = base.trim().replaceAll(RegExp(r'/$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return p.isEmpty ? b : '$b$p';
  }
}
