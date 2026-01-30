import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/ubs_api_config.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/api_response_model.dart';

class ApiService {
  static Duration get _timeout => UbsApiConfig.timeout;
  static Duration get _beeceptorTimeout => UbsApiConfig.timeoutBeeceptor;

  // ============================================
  // REGISTERED DEVICES - Simulasi database IMEI terdaftar
  // ============================================

  static final Map<String, List<String>> _registeredDevices = {
    'admin': ['WEB_DEVICE', 'ANDROID_001', 'IOS_001', 'RP1A.200720.011'],
    'user': ['WEB_DEVICE', 'ANDROID_002', 'IOS_002'],

    'pipit': ['WEB_DEVICE', 'RP1A.200720.011'],
  };

  // ============================================
  // MOCK USER DATA - Simulasi database user
  // ============================================

  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin': {
      'password': 'admin123',
      'id': '1',
      'name': 'Admin UBS',
      'nik': 'UBS001',
      'email': 'admin@ubsgold.com',
      'department': 'IT Department',
      'role': 'Administrator',
    },
    'user': {
      'password': 'user123',
      'id': '2',
      'name': 'Nayeon',
      'nik': 'UBS002',
      'email': 'nayeon@ubsgold.com',
      'department': 'Finance',
      'role': 'Staff',
    },
    'pipit': {
      'password': 'pipit123',
      'id': '3',
      'name': 'PIPIT RAHAYU',
      'nik': '012345',
      'email': 'pipit.rahayu@example.com',
      'department': 'Finance',
      'role': 'Staff',
    },
  };

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
  // a. API AUTH_user_pass_imei (Login: user, password, IMEI)
  // ============================================

  static Future<AuthResponse> login({
    required String userId,
    required String password,
    required String imei,
  }) async {
    try {
      debugPrint('🔐 ApiService.login()');
      debugPrint('   User ID: $userId');
      debugPrint('   IMEI: $imei');

      // Mode 1: UBS Production API
      if (UbsApiConfig.useUbsApis) {
        return await _loginViaApi(
          userId: userId,
          password: password,
          imei: imei,
          url: UbsApiConfig.authUrl,
          timeout: _timeout,
        );
      }

      // Mode 2: Beeceptor Testing API
      if (UbsApiConfig.useBeeceptor) {
        return await _loginViaBeeceptor(
          userId: userId,
          password: password,
          imei: imei,
        );
      }

      // Mode 3: Mock (local development)
      return await _loginMock(userId: userId, password: password, imei: imei);
    } catch (e) {
      debugPrint('   ❌ Error: $e');
      return AuthResponse(
        success: false,
        message: 'Gagal terhubung ke server: ${e.toString()}',
      );
    }
  }

  /// Login via real API (UBS Production or custom)
  static Future<AuthResponse> _loginViaApi({
    required String userId,
    required String password,
    required String imei,
    required String url,
    required Duration timeout,
  }) async {
    debugPrint('   📡 Calling API: $url');

    final response = await http
        .post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'password': password,
            'imei': imei,
          }),
        )
        .timeout(timeout);

    debugPrint('   Response status: ${response.statusCode}');
    debugPrint('   Response body: ${response.body}');

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(data);
    }
    if (response.statusCode == 401) {
      return AuthResponse(
        success: false,
        message: data['message']?.toString() ?? 'User ID atau Password salah',
      );
    }
    if (response.statusCode == 403) {
      return AuthResponse(
        success: false,
        message: data['message']?.toString() ?? 'Perangkat tidak terdaftar',
      );
    }
    return AuthResponse(
      success: false,
      message: data['message']?.toString() ?? 'Login gagal',
    );
  }

  /// Login via Beeceptor (testing)
  static Future<AuthResponse> _loginViaBeeceptor({
    required String userId,
    required String password,
    required String imei,
  }) async {
    try {
      debugPrint('   🧪 Calling Beeceptor: ${UbsApiConfig.beeceptorAuthUrl}');

      final response = await http
          .post(
            Uri.parse(UbsApiConfig.beeceptorAuthUrl),
            headers: _headers,
            body: jsonEncode({
              'user_id': userId,
              'password': password,
              'imei': imei,
            }),
          )
          .timeout(_beeceptorTimeout);

      debugPrint('   Response status: ${response.statusCode}');
      debugPrint('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      }

      return AuthResponse(
        success: false,
        message: 'Login gagal: ${response.statusCode}',
      );
    } on TimeoutException {
      debugPrint('   ⏱️ Beeceptor timeout, using fallback mock...');
      // Fallback ke mock jika Beeceptor timeout
      return await _loginMock(userId: userId, password: password, imei: imei);
    } catch (e) {
      debugPrint('   ❌ Beeceptor error: $e');
      // Fallback ke mock jika ada error koneksi
      if (e.toString().contains('Socket') ||
          e.toString().contains('Connection')) {
        debugPrint('   ℹ️ Using fallback mock due to connection error');
        return await _loginMock(userId: userId, password: password, imei: imei);
      }
      rethrow;
    }
  }

  /// Login Mock (local development)
  static Future<AuthResponse> _loginMock({
    required String userId,
    required String password,
    required String imei,
  }) async {
    debugPrint('   🔧 Using mock login');
    await Future.delayed(const Duration(seconds: 2));

    if (!_mockUsers.containsKey(userId.toLowerCase())) {
      debugPrint('   ❌ User not found');
      return AuthResponse(success: false, message: 'User ID tidak ditemukan');
    }

    final userData = _mockUsers[userId.toLowerCase()]!;
    if (userData['password'] != password) {
      debugPrint('   ❌ Wrong password');
      return AuthResponse(success: false, message: 'Password salah');
    }

    final isDeviceRegistered = _validateDeviceId(userId.toLowerCase(), imei);
    if (!isDeviceRegistered) {
      debugPrint('   ❌ Device not registered');
      return AuthResponse(
        success: false,
        message: 'Perangkat tidak terdaftar. IMEI: $imei',
      );
    }

    debugPrint('   ✅ Login successful (mock)');
    return AuthResponse(
      success: true,
      message: 'Login berhasil',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      user: UserModel(
        id: userData['id'],
        name: userData['name'],
        nik: userData['nik'],
        email: userData['email'],
        department: userData['department'],
        deviceImei: imei,
      ),
    );
  }

  /// Validasi apakah device ID terdaftar untuk user tertentu
  static bool _validateDeviceId(String userId, String imei) {
    // Untuk Web, selalu izinkan (dengan prefix WEB_DEVICE)
    if (imei.startsWith('WEB_DEVICE')) {
      debugPrint('   ℹ️ Web device detected, allowing...');
      return true;
    }

    // Cek di registered devices
    final userDevices = _registeredDevices[userId];
    if (userDevices == null) {
      return false;
    }

    // Cek exact match atau prefix match
    for (final device in userDevices) {
      if (imei == device || imei.startsWith(device)) {
        debugPrint('   ✅ Device matched: $imei with registered: $device');
        return true;
      }
    }

    debugPrint('   ❌ Device not found in registered list');
    debugPrint('   📱 Current device: $imei');
    debugPrint('   📋 Registered devices for $userId: $userDevices');
    return false;
  }

  /// Register device baru untuk user
  static Future<bool> registerDevice({
    required String userId,
    required String imei,
    String? token,
    bool autoRegister = false,
  }) async {
    try {
      debugPrint('📱 Registering device: $imei for user: $userId');

      // Mock implementation untuk development
      await Future.delayed(const Duration(seconds: 1));

      if (!_registeredDevices.containsKey(userId)) {
        _registeredDevices[userId] = [];
      }

      // Cek apakah device sudah terdaftar
      if (_registeredDevices[userId]!.contains(imei)) {
        debugPrint('   ℹ️ Device already registered');
        return true;
      }

      // Tambahkan device
      _registeredDevices[userId]!.add(imei);

      debugPrint('   ✅ Device registered successfully: $imei');
      debugPrint('   📋 Updated device list: ${_registeredDevices[userId]}');
      return true;
    } catch (e) {
      debugPrint('❌ Error registering device: $e');
      return false;
    }
  }

  // ============================================
  // b. API FR_wajah_user_nik (Verifikasi wajah: image, user_id, nik)
  // ============================================

  static Future<FaceRecognitionResponse> verifyFace({
    required String base64Image,
    required String userId,
    required String nik,
  }) async {
    try {
      debugPrint('👤 ApiService.verifyFace()');
      debugPrint('   User ID: $userId');
      debugPrint('   NIK: $nik');

      if (UbsApiConfig.useBeeceptorForFr) {
        return await _callBeeceptorFr(base64Image: base64Image);
      }

      final response = await http
          .post(
            Uri.parse(UbsApiConfig.frVerifyUrl),
            headers: _headers,
            body: jsonEncode({
              'image': base64Image,
              'user_id': userId,
              'nik': nik,
            }),
          )
          .timeout(_timeout);

      debugPrint('   Response status: ${response.statusCode}');
      final data = jsonDecode(response.body);
      final map = data is List && data.isNotEmpty
          ? data[0] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return FaceRecognitionResponse.fromJson(map);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return FaceRecognitionResponse(
        success: false,
        message: 'Gagal verifikasi wajah: ${e.toString()}',
        confidence: 0,
        isMatch: false,
      );
    }
  }

  /// Beeceptor (testing). Response: array
  static Future<FaceRecognitionResponse> _callBeeceptorFr({
    required String base64Image,
  }) async {
    try {
      debugPrint('🧪 ApiService._callBeeceptorFr()');
      debugPrint('   URL: ${UbsApiConfig.beeceptorFrUrl}');

      final response = await http
          .post(
            Uri.parse(UbsApiConfig.beeceptorFrUrl),
            headers: _headers,
            body: jsonEncode({
              'image': base64Image,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(_beeceptorTimeout);

      debugPrint('   Response status: ${response.statusCode}');
      debugPrint('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Beeceptor API returns an array
        if (data is List && data.isNotEmpty) {
          final result = data[0] as Map<String, dynamic>;
          debugPrint('   ✅ Face recognized: ${result['nama'] ?? 'Unknown'}');
          debugPrint('   📊 Confidence: ${result['conf'] ?? '0'}%');

          return FaceRecognitionResponse(
            success: result['success'] ?? false,
            message:
                result['message'] ?? result['nama'] ?? 'Wajah terverifikasi',
            confidence: result['conf'] != null
                ? double.tryParse(result['conf'].toString()) ?? 0.0
                : 0.0,
            isMatch: result['success'] ?? false,
            userId: result['induk'] ?? result['rfid'],
          );
        } else {
          return FaceRecognitionResponse(
            success: false,
            message: 'Tidak ada data wajah yang dikenali',
            confidence: 0,
            isMatch: false,
          );
        }
      } else {
        return FaceRecognitionResponse(
          success: false,
          message: 'Error: ${response.statusCode}',
          confidence: 0,
          isMatch: false,
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ Beeceptor timeout: $e');
      debugPrint(
        '   ℹ️ Using fallback response (API timeout). Konfigurasi rule di Beeceptor agar API merespons.',
      );
      return FaceRecognitionResponse(
        success: true,
        message: 'Verifikasi (fallback - API timeout)',
        confidence: 75.0,
        isMatch: true,
        userId: null,
      );
    } catch (e) {
      debugPrint('❌ Test error: $e');
      // Fallback yang sama untuk SocketException / connection error
      if (e.toString().contains('Timeout') ||
          e.toString().contains('Socket') ||
          e.toString().contains('Connection')) {
        debugPrint(
          '   ℹ️ Using fallback response (koneksi gagal). Cek internet atau konfigurasi Beeceptor.',
        );
        return FaceRecognitionResponse(
          success: true,
          message: 'Verifikasi (fallback - koneksi gagal)',
          confidence: 75.0,
          isMatch: true,
          userId: null,
        );
      }
      return FaceRecognitionResponse(
        success: false,
        message: 'Gagal verifikasi wajah: ${e.toString()}',
        confidence: 0,
        isMatch: false,
      );
    }
  }

  // ============================================
  // c. API LIST_pengesahan (Daftar dokumen pengesahan)
  // ============================================

  static Future<List<TransactionModel>> getTransactionList({
    String? token,
  }) async {
    try {
      debugPrint('📋 ApiService.getTransactionList()');

      // Mode 1: UBS Production API
      if (UbsApiConfig.useUbsApis) {
        return await _getTransactionListViaApi(
          token: token,
          url: UbsApiConfig.listPengesahanUrl,
          timeout: _timeout,
        );
      }

      // Mode 2: Beeceptor Testing API
      if (UbsApiConfig.useBeeceptor) {
        return await _getTransactionListViaBeeceptor(token: token);
      }

      // Mode 3: Mock (local development)
      await Future.delayed(const Duration(seconds: 1));
      return _mockTransactionList;
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw Exception('Gagal mengambil data transaksi: ${e.toString()}');
    }
  }

  /// Get transaction list via real API
  static Future<List<TransactionModel>> _getTransactionListViaApi({
    String? token,
    required String url,
    required Duration timeout,
  }) async {
    debugPrint('   📡 Calling API: $url');

    final response = await http
        .get(
          Uri.parse(url),
          headers: token != null ? _authHeaders(token) : _headers,
        )
        .timeout(timeout);

    debugPrint('   Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Gagal load: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final list = body is List
        ? body
        : (body is Map
              ? (body['data'] ?? body['items'] ?? <dynamic>[])
              : <dynamic>[]);
    final items = list is List ? list : <dynamic>[];
    return items
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get transaction list via Beeceptor (testing)
  static Future<List<TransactionModel>> _getTransactionListViaBeeceptor({
    String? token,
  }) async {
    try {
      debugPrint('   🧪 Calling Beeceptor: ${UbsApiConfig.beeceptorListUrl}');

      final response = await http
          .get(
            Uri.parse(UbsApiConfig.beeceptorListUrl),
            headers: token != null ? _authHeaders(token) : _headers,
          )
          .timeout(_beeceptorTimeout);

      debugPrint('   Response status: ${response.statusCode}');
      debugPrint('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final list = body is List
            ? body
            : (body is Map
                  ? (body['data'] ?? body['items'] ?? <dynamic>[])
                  : <dynamic>[]);
        final items = list is List ? list : <dynamic>[];
        return items
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Gagal load: ${response.statusCode}');
    } on TimeoutException {
      debugPrint('   ⏱️ Beeceptor timeout, using mock data...');
      return _mockTransactionList;
    } catch (e) {
      debugPrint('   ❌ Beeceptor error: $e');
      if (e.toString().contains('Socket') ||
          e.toString().contains('Connection')) {
        debugPrint('   ℹ️ Using mock data due to connection error');
        return _mockTransactionList;
      }
      rethrow;
    }
  }

  static List<TransactionModel> get _mockTransactionList => [
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
    TransactionModel(
      id: '5',
      documentNumber: 'IND2B701180005',
      title: 'Pembelian Monitor',
      amount: 5000000,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      requesterName: 'PIPIT RAHAYU',
      department: 'Finance',
    ),
  ];

  // ============================================
  // d. API FR_wajah_user_nik_nodocument_status (Wajah + no dokumen + status Accept/Reject)
  // ============================================

  static Future<ApprovalResponse> submitApproval({
    required String documentNumber,
    required String status, // 'accepted' atau 'rejected'
    required String base64Image,
    required String userId,
    required String nik,
    String? token,
  }) async {
    try {
      debugPrint('✅ ApiService.submitApproval()');
      debugPrint('   Document: $documentNumber');
      debugPrint('   Status: $status');

      // Mode 1: UBS Production API
      if (UbsApiConfig.useUbsApis) {
        return await _submitApprovalViaApi(
          documentNumber: documentNumber,
          status: status,
          base64Image: base64Image,
          userId: userId,
          nik: nik,
          token: token,
          url: UbsApiConfig.frApprovalUrl,
          timeout: _timeout,
        );
      }

      // Mode 2: Beeceptor Testing API
      if (UbsApiConfig.useBeeceptor) {
        return await _submitApprovalViaBeeceptor(
          documentNumber: documentNumber,
          status: status,
          base64Image: base64Image,
          userId: userId,
          nik: nik,
          token: token,
        );
      }

      // Mode 3: Mock (local development)
      await Future.delayed(const Duration(seconds: 2));
      return ApprovalResponse(
        success: true,
        message: status == 'accepted'
            ? 'Transaksi berhasil disetujui'
            : 'Transaksi berhasil ditolak',
        documentNumber: documentNumber,
        newStatus: status,
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      return ApprovalResponse(
        success: false,
        message: 'Gagal submit approval: ${e.toString()}',
      );
    }
  }

  /// Submit approval via real API
  static Future<ApprovalResponse> _submitApprovalViaApi({
    required String documentNumber,
    required String status,
    required String base64Image,
    required String userId,
    required String nik,
    String? token,
    required String url,
    required Duration timeout,
  }) async {
    debugPrint('   📡 Calling API: $url');

    final response = await http
        .post(
          Uri.parse(url),
          headers: token != null ? _authHeaders(token) : _headers,
          body: jsonEncode({
            'image': base64Image,
            'wajah': base64Image,
            'user_id': userId,
            'nik': nik,
            'no_document': documentNumber,
            'document_number': documentNumber,
            'status': status,
          }),
        )
        .timeout(timeout);

    debugPrint('   Response status: ${response.statusCode}');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return ApprovalResponse.fromJson(data);
    }
    return ApprovalResponse(
      success: false,
      message: data['message']?.toString() ?? 'Gagal submit approval',
    );
  }

  /// Submit approval via Beeceptor (testing)
  static Future<ApprovalResponse> _submitApprovalViaBeeceptor({
    required String documentNumber,
    required String status,
    required String base64Image,
    required String userId,
    required String nik,
    String? token,
  }) async {
    try {
      debugPrint(
        '   🧪 Calling Beeceptor: ${UbsApiConfig.beeceptorApprovalUrl}',
      );

      final response = await http
          .post(
            Uri.parse(UbsApiConfig.beeceptorApprovalUrl),
            headers: token != null ? _authHeaders(token) : _headers,
            body: jsonEncode({
              'image': base64Image,
              'user_id': userId,
              'nik': nik,
              'document_number': documentNumber,
              'status': status,
            }),
          )
          .timeout(_beeceptorTimeout);

      debugPrint('   Response status: ${response.statusCode}');
      debugPrint('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApprovalResponse.fromJson(data);
      }

      return ApprovalResponse(
        success: false,
        message: 'Gagal submit approval: ${response.statusCode}',
      );
    } on TimeoutException {
      debugPrint('   ⏱️ Beeceptor timeout, using mock response...');
      return ApprovalResponse(
        success: true,
        message: status == 'accepted'
            ? 'Transaksi berhasil disetujui (timeout fallback)'
            : 'Transaksi berhasil ditolak (timeout fallback)',
        documentNumber: documentNumber,
        newStatus: status,
      );
    } catch (e) {
      debugPrint('   ❌ Beeceptor error: $e');
      if (e.toString().contains('Socket') ||
          e.toString().contains('Connection')) {
        debugPrint('   ℹ️ Using mock response due to connection error');
        return ApprovalResponse(
          success: true,
          message: status == 'accepted'
              ? 'Transaksi berhasil disetujui (offline fallback)'
              : 'Transaksi berhasil ditolak (offline fallback)',
          documentNumber: documentNumber,
          newStatus: status,
        );
      }
      rethrow;
    }
  }
}
