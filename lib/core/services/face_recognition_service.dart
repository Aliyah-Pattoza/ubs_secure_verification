import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../constants/api_constants.dart';

class FaceRecognitionService {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, dynamic>> recognizeFace(File imageFile, String nik) async {
    try {
      // Create multipart form data
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'face.jpg',
        ),
        'nik': nik,
      });
      
      // Send to API
      final response = await _apiService.postMultipart(
        ApiConstants.testFRUrl, // Ganti dengan API sebenarnya
        formData,
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Face recognition failed: $e');
    }
  }
  
  Future<Map<String, dynamic>> verifyTransaction(
    File imageFile, 
    String nik, 
    String documentId,
    String status,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'face.jpg',
        ),
        'nik': nik,
        'document_id': documentId,
        'status': status,
      });
      
      final response = await _apiService.postMultipart(
        ApiConstants.baseUrlVerification + ApiConstants.verifyTransaction,
        formData,
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Transaction verification failed: $e');
    }
  }
}

class ApiService {
  Future<dynamic> postMultipart(String testFRUrl, FormData formData) async {}
}