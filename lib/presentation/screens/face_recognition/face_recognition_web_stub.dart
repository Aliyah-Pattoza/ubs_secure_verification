import 'package:flutter/material.dart';

// Stub file untuk Web platform
// face_camera tidak support web, jadi kita buat dummy classes

/// Dummy Face class untuk web
class Face {
  final dynamic boundingBox;
  Face({this.boundingBox});
}

/// Dummy CameraLens enum
enum CameraLens { front, back }

/// Dummy FaceCamera class
class FaceCamera {
  static Future<void> initialize() async {
    // No-op untuk web
  }
}

/// Dummy FaceCameraController
class FaceCameraController {
  Future<dynamic> takePicture() async {
    return null;
  }

  void dispose() {}
}

/// Dummy SmartFaceCamera widget
class SmartFaceCamera extends StatelessWidget {
  final bool autoCapture;
  final bool showCaptureControl;
  final bool showCameraLensControl;
  final bool showFlashControl;
  final CameraLens defaultCameraLens;
  final Function(dynamic)? onCapture;
  final Function(Face?)? onFaceDetected;
  final Widget Function(BuildContext, Face?)? messageBuilder;
  final Function(FaceCameraController)? controller;

  const SmartFaceCamera({
    super.key,
    this.autoCapture = false,
    this.showCaptureControl = true,
    this.showCameraLensControl = true,
    this.showFlashControl = true,
    this.defaultCameraLens = CameraLens.front,
    this.onCapture,
    this.onFaceDetected,
    this.messageBuilder,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty container untuk web
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Camera not available on Web',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

