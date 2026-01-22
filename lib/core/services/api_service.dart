import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/api_response_model.dart';

/// Service untuk komunikasi dengan API Backend
class ApiService {
  // ============================================
  // BASE URLs - GANTI DENGAN IP LAN YANG SESUAI
  // ============================================

  /// API untuk Authentication (user, password, IMEI)
  static const String baseAuthUrl = 'http://xxx.xxx.xxx.xxx';

  /// API untuk Face Recognition
  static const String baseFrUrl = 'http://xxx.xxx.xxx.xxx';

  /// API untuk List Dokumen/Transaksi
  static const String baseListUrl = 'http://xxx.xxx.xxx.yyy';

  /// API untuk Submit Approval
  static const String baseApprovalUrl = 'http://xxx.xxx.xxx.www';

  /// API Test Face Recognition (Beeceptor)
  static const String testFrUrl = 'https://apifr.free.beeceptor.com/recognize';

  /// Timeout duration untuk request
  static const Duration timeoutDuration = Duration(seconds: 30);

  // ============================================
  // HEADERS
  // ============================================

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ============================================
  // AUTH API - Login dengan User, Password, IMEI
  // Endpoint: POST /api/auth/login
  // ============================================

  static Future<AuthResponse> login({
    required String userId,
    required String password,
    required String imei,
  }) async {
    try {
      // ========== MOCK RESPONSE (UNTUK TESTING) ==========
      // Hapus bagian ini saat integrasi dengan API real
      await Future.delayed(const Duration(seconds: 2));

      // Simulasi validasi login
      if (userId == 'admin' && password == 'admin123') {
        return AuthResponse(
          success: true,
          message: 'Login berhasil',
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          user: UserModel(
            id: '1',
            name: 'Admin UBS',
            nik: 'UBS001',
            email: 'admin@ubsgold.com',
            department: 'IT',
            deviceImei: imei,
          ),
        );
      } else if (userId == 'user' && password == 'user123') {
        return AuthResponse(
          success: true,
          message: 'Login berhasil',
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          user: UserModel(
            id: '2',
            name: 'Nayeon',
            nik: 'UBS002',
            email: 'nayeon@ubsgold.com',
            department: 'Finance',
            deviceImei: imei,
          ),
        );
      } else {
        return AuthResponse(
          success: false,
          message: 'User ID atau Password salah',
        );
      }
      // ========== END MOCK RESPONSE ==========

      // ========== REAL API CALL ==========
      // Uncomment bagian ini saat integrasi dengan API real
      /*
      final response = await http.post(
        Uri.parse('$baseAuthUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'password': password,
          'imei': imei,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Login gagal',
        );
      }
      */
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Gagal terhubung ke server: ${e.toString()}',
      );
    }
  }

  // ============================================
  // FACE RECOGNITION API
  // Endpoint: POST /api/face/verify
  // ============================================

  static Future<FaceRecognitionResponse> verifyFace({
    required String base64Image,
    required String userId,
    required String nik,
  }) async {
    try {
      // ========== MOCK RESPONSE (UNTUK TESTING) ==========
      await Future.delayed(const Duration(seconds: 2));

      return FaceRecognitionResponse(
        success: true,
        message: 'Wajah terverifikasi',
        confidence: 0.95,
        isMatch: true,
        userId: userId,
      );
      // ========== END MOCK RESPONSE ==========

      // ========== REAL API CALL ==========
      /*
      final response = await http.post(
        Uri.parse('$baseFrUrl/api/face/verify'),
        headers: _headers,
        body: jsonEncode({
          'image': base64Image,
          'user_id': userId,
          'nik': nik,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      return FaceRecognitionResponse.fromJson(data);
      */
    } catch (e) {
      return FaceRecognitionResponse(
        success: false,
        message: 'Gagal verifikasi wajah: ${e.toString()}',
      );
    }
  }

  /// Test Face Recognition dengan Beeceptor API
  static Future<FaceRecognitionResponse> testFaceRecognition({
    required String base64Image,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(testFrUrl),
            headers: _headers,
            body: jsonEncode({'image': base64Image}),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FaceRecognitionResponse.fromJson(data);
      } else {
        return FaceRecognitionResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return FaceRecognitionResponse(
        success: false,
        message: 'Gagal terhubung ke API test: ${e.toString()}',
      );
    }
  }

  // ============================================
  // TRANSACTION LIST API
  // Endpoint: GET /api/transactions/pending
  // ============================================

  static Future<List<TransactionModel>> getTransactionList({
    String? token,
  }) async {
    try {
      // ========== MOCK RESPONSE (UNTUK TESTING) ==========
      await Future.delayed(const Duration(seconds: 1));

      return [
        TransactionModel(
          id: '1',
          documentNumber: 'IND2B701180001',
          title: 'Pembelian Server',
          amount: 100000000,
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          requesterName: 'John Doe',
          department: 'IT',
        ),
        TransactionModel(
          id: '2',
          documentNumber: 'IND2B701180002',
          title: 'Pembelian NetApp',
          amount: 400000000,
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          requesterName: 'Jane Smith',
          department: 'IT',
        ),
        TransactionModel(
          id: '3',
          documentNumber: 'IND2B701180003',
          title: 'Perjalanan Dinas',
          amount: 8000000,
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          requesterName: 'Bob Wilson',
          department: 'Sales',
        ),
        TransactionModel(
          id: '4',
          documentNumber: 'IND2B701180004',
          title: 'Pembelian Laptop',
          amount: 25000000,
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          requesterName: 'Alice Brown',
          department: 'HR',
        ),
      ];
      // ========== END MOCK RESPONSE ==========

      // ========== REAL API CALL ==========
      /*
      final response = await http.get(
        Uri.parse('$baseListUrl/api/transactions/pending'),
        headers: token != null ? _authHeaders(token) : _headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
      */
    } catch (e) {
      throw Exception('Gagal mengambil data transaksi: ${e.toString()}');
    }
  }

  // ============================================
  // APPROVAL API - Accept/Reject dengan Face Recognition
  // Endpoint: POST /api/transactions/approve
  // ============================================

  static Future<ApprovalResponse> submitApproval({
    required String documentNumber,
    required String status, // 'accepted' atau 'rejected'
    required String base64Image,
    required String userId,
    String? token,
  }) async {
    try {
      // ========== MOCK RESPONSE (UNTUK TESTING) ==========
      await Future.delayed(const Duration(seconds: 2));

      return ApprovalResponse(
        success: true,
        message: status == 'accepted'
            ? 'Transaksi berhasil disetujui'
            : 'Transaksi berhasil ditolak',
        documentNumber: documentNumber,
        newStatus: status,
      );
      // ========== END MOCK RESPONSE ==========

      // ========== REAL API CALL ==========
      /*
      // Step 1: Verify face first
      final faceResponse = await verifyFace(
        base64Image: base64Image,
        userId: userId,
        nik: '', // Get from user data
      );

      if (!faceResponse.success || faceResponse.isMatch != true) {
        return ApprovalResponse(
          success: false,
          message: 'Verifikasi wajah gagal',
        );
      }

      // Step 2: Submit approval
      final response = await http.post(
        Uri.parse('$baseApprovalUrl/api/transactions/approve'),
        headers: token != null ? _authHeaders(token) : _headers,
        body: jsonEncode({
          'document_number': documentNumber,
          'status': status,
          'user_id': userId,
          'face_verified': true,
        }),
      ).timeout(timeoutDuration);

      final data = jsonDecode(response.body);
      return ApprovalResponse.fromJson(data);
      */
    } catch (e) {
      return ApprovalResponse(
        success: false,
        message: 'Gagal submit approval: ${e.toString()}',
      );
    }
  }
}

// ============================================
// DEVICE SERVICE - Untuk mendapatkan IMEI/Android ID
// ============================================

class DeviceService {
  /// Mendapatkan Device ID (Android ID / iOS Identifier)
  /// Catatan: IMEI tidak bisa diakses di Android 10+ karena privacy
  static Future<String> getDeviceId() async {
    try {
      // ========== MOCK RESPONSE (UNTUK TESTING) ==========
      return 'MOCK_DEVICE_${DateTime.now().millisecondsSinceEpoch}';
      // ========== END MOCK RESPONSE ==========

      // ========== REAL IMPLEMENTATION ==========
      // Uncomment dan tambahkan dependency: device_info_plus
      /*
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Gunakan Android ID (bukan IMEI karena privacy restrictions)
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
      
      return '';
      */
    } catch (e) {
      return 'UNKNOWN_DEVICE';
    }
  }
}
