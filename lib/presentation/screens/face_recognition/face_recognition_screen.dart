import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:get/get.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition'),
        backgroundColor: AppColors.darkBackground,
      ),
      body: SmartFaceCamera(
        autoCapture: true,
        defaultCameraLens: CameraLens.front,
        onCapture: (File? image) {
          if (image != null) {
            _processFaceRecognition(image);
          }
        },
        onFaceDetected: (Face? face) {
          // Handle face detected
        },
        messageBuilder: (context, face) {
          if (face == null) {
            return _message('Place your face in the camera');
          }
          if (!face.wellPositioned) {
            return _message('Center your face in the square');
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  Widget _message(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
      child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(
        fontSize: 14, height: 1.5, fontWeight: FontWeight.w400)),
    );
  }
  
  Future<void> _processFaceRecognition(File image) async {
    // TODO: Send to API FR_wajah_user_nik
    Get.offNamed('/transaction-list');
  }
}