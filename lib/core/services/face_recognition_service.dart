import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/models/api_response_model.dart';

/// Service khusus untuk Face Recognition
class FaceRecognitionService {
  // API URLs
  static const String _baseFrUrl = 'http://xxx.xxx.xxx.xxx';
  static const String _testFrUrl = 'https://apifr.free.beeceptor.com/recognize';

  // Timeout
  static const Duration _timeout = Duration(seconds: 30);

  // Minimum confidence threshold untuk match
  static const double _minConfidenceThreshold = 0.75;

  /// Headers untuk API request
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Konversi Uint8List (image bytes) ke Base64 string
  static String convertToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  /// Konversi Base64 string ke Uint8List
  static Uint8List convertFromBase64(String base64String) {
    return base64Decode(base64String);
  }

  /// Compress image jika terlalu besar (optional)
  static Future<Uint8List> compressImage(Uint8List imageBytes, {int maxSizeKB = 500}) async {
    // Jika ukuran sudah di bawah threshold, return langsung
    if (imageBytes.length <= maxSizeKB * 1024) {
      return imageBytes;
    }

    // TODO: Implement image compression jika diperlukan
    // Bisa menggunakan package seperti flutter_image_compress
    debugPrint('⚠️ Image size: ${imageBytes.length ~/ 1024}KB (max: ${maxSizeKB}KB)');

    return imageBytes;
  }

  /// Verifikasi wajah dengan API
  static Future<FaceRecognitionResponse> verifyFace({
    required String base64Image,
    required String userId,
    required String nik,
    String? token,
  }) async {
    try {
      debugPrint('🔐 FaceRecognitionService.verifyFace()');
      debugPrint('   User ID: $userId');
      debugPrint('   NIK: $nik');
      debugPrint('   Image size: ${base64Image.length} chars');

      // ========== MOCK RESPONSE (UNTUK TESTING) ==========
      await Future.delayed(const Duration(seconds: 2));

      // Simulasi random confidence (untuk testing)
      final confidence = 0.85 + (DateTime.now().millisecond % 15) / 100;
      final isMatch = confidence >= _minConfidenceThreshold;

      debugPrint('   Mock confidence: $confidence');
      debugPrint('   Is match: $isMatch');

      return FaceRecognitionResponse(
        success: true,
        message: isMatch ? 'Wajah terverifikasi' : 'Wajah tidak cocok',
        confidence: confidence,
        isMatch: isMatch,
        userId: userId,
      );
      // ========== END MOCK RESPONSE ==========

      // ========== REAL API CALL ==========
      /*
      final response = await http.post(
        Uri.parse('$_baseFrUrl/api/face/verify'),
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'image': base64Image,
          'user_id': userId,
          'nik': nik,
        }),
      ).timeout(_timeout);

      debugPrint('   Response status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return FaceRecognitionResponse.fromJson(data);
      } else {
        return FaceRecognitionResponse(
          success: false,
          message: data['message'] ?? 'Verifikasi gagal',
          confidence: 0,
          isMatch: false,
        );
      }
      */
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

  /// Register wajah baru untuk user
  static Future<FaceRecognitionResponse> registerFace({
    required String base64Image,
    required String userId,
    required String nik,
    required String name,
    String? token,
  }) async {
    try {
      debugPrint('📝 FaceRecognitionService.registerFace()');
      debugPrint('   User ID: $userId');
      debugPrint('   Name: $name');

      // ========== MOCK RESPONSE ==========
      await Future.delayed(const Duration(seconds: 2));

      return FaceRecognitionResponse(
        success: true,
        message: 'Wajah berhasil didaftarkan',
        userId: userId,
      );
      // ========== END MOCK ==========

      // ========== REAL API CALL ==========
      /*
      final response = await http.post(
        Uri.parse('$_baseFrUrl/api/face/register'),
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'image': base64Image,
          'user_id': userId,
          'nik': nik,
          'name': name,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FaceRecognitionResponse(
          success: true,
          message: data['message'] ?? 'Wajah berhasil didaftarkan',
          userId: userId,
        );
      } else {
        return FaceRecognitionResponse(
          success: false,
          message: data['message'] ?? 'Gagal mendaftarkan wajah',
        );
      }
      */
    } catch (e) {
      debugPrint('❌ Error: $e');
      return FaceRecognitionResponse(
        success: false,
        message: 'Gagal mendaftarkan wajah: ${e.toString()}',
      );
    }
  }

  /// Test Face Recognition dengan Beeceptor API
  /// API ini mengembalikan array dengan format:
  /// [{
  ///   "conf": "73.61",
  ///   "duration": "0.4072",
  ///   "induk": "012345",
  ///   "message": "-",
  ///   "nama": "PIPIT RAHAYU",
  ///   "rfid": "0123456789",
  ///   "success": true,
  ///   "uuid": "06902b6d-f123-707z-456-29cb946xx652"
  /// }]
  static Future<FaceRecognitionResponse> testWithBeeceptor({
    required String base64Image,
  }) async {
    try {
      debugPrint('🧪 Testing with Beeceptor API...');
      debugPrint('   URL: $_testFrUrl');
      debugPrint('   Image size: ${base64Image.length} chars');

      final response = await http.post(
        Uri.parse(_testFrUrl),
        headers: _headers,
        body: jsonEncode({
          'image': base64Image,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(_timeout);

      debugPrint('   Response status: ${response.statusCode}');
      debugPrint('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Beeceptor API returns an array
        if (data is List && data.isNotEmpty) {
          final result = data[0] as Map<String, dynamic>;
          debugPrint('   ✅ Face recognized: ${result['nama']}');
          debugPrint('   📊 Confidence: ${result['conf']}%');
          debugPrint('   🆔 Induk/RFID: ${result['induk']}/${result['rfid']}');
          
          return FaceRecognitionResponse(
            success: result['success'] ?? false,
            message: result['message'] ?? result['nama'] ?? 'Wajah terverifikasi',
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
          message: 'Test API error: ${response.statusCode}',
          confidence: 0,
          isMatch: false,
        );
      }
    } catch (e) {
      debugPrint('❌ Test error: $e');
      return FaceRecognitionResponse(
        success: false,
        message: 'Gagal terhubung ke test API: ${e.toString()}',
        confidence: 0,
        isMatch: false,
      );
    }
  }

  /// Cek kualitas gambar (brightness, blur, face position)
  static Map<String, dynamic> checkImageQuality(Uint8List imageBytes) {
    // TODO: Implement image quality check
    // Bisa menggunakan ML atau simple heuristics

    return {
      'isGoodQuality': true,
      'brightness': 'normal',
      'blur': 'none',
      'facePosition': 'center',
      'suggestions': <String>[],
    };
  }

  /// Validasi apakah base64 string valid
  static bool isValidBase64(String base64String) {
    try {
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get estimated image size dari base64 string
  static int getEstimatedImageSize(String base64String) {
    // Base64 encoding increases size by ~33%
    return (base64String.length * 3 / 4).round();
  }
}