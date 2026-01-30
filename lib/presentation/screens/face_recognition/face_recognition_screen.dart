import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/transaction_model.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key});

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen>
    with SingleTickerProviderStateMixin {
  // Data dari arguments
  UserModel? user;
  String? token;
  TransactionModel? pendingTransaction;
  String? approvalAction;
  String? deviceId;

  // State
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _scanComplete = false;
  bool _isCameraReady = false;
  String _statusMessage = 'Initializing Camera...';
  String _statusSubMessage = 'Please wait';
  String? _capturedBase64Image;
  Uint8List? _capturedImageBytes;

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  // Camera controller
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initArguments();
    _setupAnimations();
    _initializeCamera();
  }

  void _initArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      user = args['user'] as UserModel?;
      token = args['token'] as String?;
      pendingTransaction = args['transaction'] as TransactionModel?;
      approvalAction = args['action'] as String?;
      deviceId = args['deviceId'] as String?;
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      // Web: Gunakan mock/manual capture
      setState(() {
        _isInitialized = true;
        _statusMessage = 'Ready to Scan';
        _statusSubMessage = 'Tap the button to verify';
      });
      return;
    }

    // Mobile: Initialize camera package
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Cari front camera
      CameraDescription? frontCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      // Jika tidak ada front camera, gunakan camera pertama
      final selectedCamera = frontCamera ?? _cameras!.first;

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isCameraReady = true;
          _statusMessage = 'Position Your Face';
          _statusSubMessage = 'Look at the camera and tap capture';
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isCameraReady = false;
          _statusMessage = 'Camera Error';
          _statusSubMessage = 'Using manual verification';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Capture foto dari camera
  Future<void> _capturePhoto() async {
    if (_isScanning || _scanComplete) return;

    if (!kIsWeb &&
        (_cameraController == null ||
            !_cameraController!.value.isInitialized)) {
      _showErrorSnackbar('Camera belum siap');
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Capturing...';
      _statusSubMessage = 'Please hold still';
    });

    try {
      String base64Image;

      if (kIsWeb) {
        // Web: Gunakan mock base64
        await Future.delayed(const Duration(seconds: 1));
        base64Image =
            'mock_base64_image_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // Mobile: Capture dari camera
        final XFile imageFile = await _cameraController!.takePicture();

        // Convert ke bytes dan Base64
        final bytes = await imageFile.readAsBytes();
        base64Image = base64Encode(bytes);

        setState(() {
          _capturedBase64Image = base64Image;
          _capturedImageBytes = bytes;
        });

        debugPrint('📸 Image captured! Size: ${bytes.length} bytes');
        debugPrint('📸 Base64 length: ${base64Image.length}');
      }

      // Kirim ke API untuk verifikasi
      await _verifyFace(base64Image);
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      setState(() {
        _isScanning = false;
        _statusMessage = 'Capture Failed';
        _statusSubMessage = 'Please try again';
      });

      _showErrorSnackbar('Gagal mengambil foto: $e');
    }
  }

  /// Kirim foto ke API Face Recognition
  Future<void> _verifyFace(String base64Image) async {
    setState(() {
      _statusMessage = 'Verifying...';
      _statusSubMessage = 'Checking identity';
    });

    try {
      debugPrint('🔐 Sending to Face Recognition API...');

      final response = await ApiService.verifyFace(
        base64Image: base64Image,
        userId: user?.id ?? '',
        nik: user?.nik ?? '',
      );

      debugPrint('📨 Response: ${response.success} - ${response.message}');
      debugPrint('📊 Confidence: ${response.confidence}');

      if (response.success && response.isMatch == true) {
        // Verifikasi berhasil!
        setState(() {
          _scanComplete = true;
          _statusMessage = 'Verified!';
          _statusSubMessage = 'Face recognition successful';
        });

        _showSuccessSnackbar('Verifikasi wajah berhasil!');

        await Future.delayed(const Duration(milliseconds: 1200));

        // Navigate berdasarkan flow
        if (pendingTransaction != null && approvalAction != null) {
          await _processApproval(base64Image);
        } else {
          _navigateToTransactionList();
        }
      } else {
        // Verifikasi gagal
        setState(() {
          _isScanning = false;
          _statusMessage = 'Verification Failed';
          _statusSubMessage = response.message ?? 'Face not recognized';
        });

        _showErrorSnackbar(
          response.message ?? 'Wajah tidak cocok. Silakan coba lagi.',
        );
      }
    } catch (e) {
      debugPrint('❌ Verification error: $e');
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error';
        _statusSubMessage = 'Verification failed';
      });

      _showErrorSnackbar('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  /// Process approval setelah face verified
  Future<void> _processApproval(String base64Image) async {
    try {
      setState(() {
        _statusMessage = 'Processing...';
        _statusSubMessage = 'Submitting approval';
      });

      final response = await ApiService.submitApproval(
        documentNumber: pendingTransaction!.documentNumber,
        status: approvalAction == 'accept' ? 'accepted' : 'rejected',
        base64Image: base64Image,
        userId: user?.id ?? '',
        nik: user?.nik ?? '',
        token: token,
      );

      if (response.success) {
        Get.offNamed(
          AppRoutes.success,
          arguments: {
            'action': approvalAction,
            'transaction': pendingTransaction,
            'user': user,
            'token': token,
          },
        );
      } else {
        _showErrorSnackbar(response.message ?? 'Gagal memproses approval');
        Get.back();
      }
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan: $e');
      Get.back();
    }
  }

  void _navigateToTransactionList() {
    Get.offNamed(
      AppRoutes.transactionList,
      arguments: {'user': user, 'token': token},
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Retry verification
  void _retryVerification() {
    setState(() {
      _isScanning = false;
      _scanComplete = false;
      _capturedBase64Image = null;
      _capturedImageBytes = null;
      _statusMessage = kIsWeb ? 'Ready to Scan' : 'Position Your Face';
      _statusSubMessage = kIsWeb
          ? 'Tap the button to verify'
          : 'Look at the camera and tap capture';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTitle(),
              const SizedBox(height: 24),
              Expanded(child: _buildCameraSection()),
              _buildBottomSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Back button (hanya jika bukan dari approval flow)
          if (pendingTransaction == null)
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            )
          else
            const SizedBox(width: 48),

          const Spacer(),

          // User info
          if (user != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user!.nik,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.gold.withOpacity(0.2),
              child: Text(
                user!.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Face Verification',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          if (pendingTransaction != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: approvalAction == 'accept'
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${approvalAction == 'accept' ? 'Approve' : 'Reject'}: ${pendingTransaction!.documentNumber}',
                style: TextStyle(
                  fontSize: 13,
                  color: approvalAction == 'accept'
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraSection() {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: (_isScanning && !_scanComplete)
                ? _pulseAnimation.value
                : 1.0,
            child: child,
          );
        },
        child: Container(
          width: 300,
          height: 380,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _getBorderColor(), width: 4),
            boxShadow: [
              BoxShadow(
                color: _getBorderColor().withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera Preview atau Placeholder
                _buildCameraPreview(),

                // Scanning overlay
                if (_isScanning && !_scanComplete) _buildScanningOverlay(),

                // Success overlay
                if (_scanComplete) _buildSuccessOverlay(),

                // Corner markers
                ..._buildCornerMarkers(),

                // Captured image preview
                if (_capturedImageBytes != null && _scanComplete)
                  _buildCapturedPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (kIsWeb) {
      // Web: Tampilkan placeholder
      return _buildWebPlaceholder();
    }

    // Mobile: Real camera preview
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return CameraPreview(_cameraController!);
    } else {
      return _buildCameraErrorPlaceholder();
    }
  }

  Widget _buildWebPlaceholder() {
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _scanComplete ? Icons.check_circle_rounded : Icons.face_rounded,
              size: 70,
              color: _scanComplete ? AppColors.success : AppColors.gold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Web Mode - Manual Verification',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraErrorPlaceholder() {
    return Container(
      color: AppColors.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 60,
            color: AppColors.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Camera not available',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Using manual verification',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gold.withOpacity(0.2),
            Colors.transparent,
            Colors.transparent,
            AppColors.gold.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.gold.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: AppColors.success.withOpacity(0.1),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 60,
            color: AppColors.success,
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedPreview() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(_capturedImageBytes!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (_scanComplete) return AppColors.success;
    if (_isScanning) return AppColors.gold;
    return AppColors.gold.withOpacity(0.5);
  }

  List<Widget> _buildCornerMarkers() {
    final color = _getBorderColor();

    return [
      Positioned(top: 16, left: 16, child: _buildCorner(color, true, true)),
      Positioned(top: 16, right: 16, child: _buildCorner(color, true, false)),
      Positioned(bottom: 16, left: 16, child: _buildCorner(color, false, true)),
      Positioned(
        bottom: 16,
        right: 16,
        child: _buildCorner(color, false, false),
      ),
    ];
  }

  Widget _buildCorner(Color color, bool isTop, bool isLeft) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: CornerPainter(color: color, isTop: isTop, isLeft: isLeft),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Status icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _getStatusIcon(),
              key: ValueKey(_statusMessage),
              size: 40,
              color: _getStatusColor(),
            ),
          ),
          const SizedBox(height: 12),

          // Status message
          Text(
            _statusMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _statusSubMessage,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_scanComplete) return Icons.check_circle_rounded;
    if (_isScanning) return Icons.face_retouching_natural_rounded;
    return Icons.face_rounded;
  }

  Color _getStatusColor() {
    if (_scanComplete) return AppColors.success;
    if (_isScanning) return AppColors.gold;
    return AppColors.primary;
  }

  Widget _buildActionButtons() {
    // Jika sudah complete, tampilkan retry button
    if (_scanComplete) {
      return const SizedBox.shrink();
    }

    // Jika sedang scanning, tampilkan progress
    if (_isScanning) {
      return const SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
        ),
      );
    }

    // Button untuk capture
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _capturePhoto,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text(
              'Capture & Verify',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.primaryDark,
              elevation: 4,
              shadowColor: AppColors.gold.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          kIsWeb
              ? 'Click to start verification'
              : 'Position your face and tap capture',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

/// Custom painter untuk corner markers
class CornerPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;

  CornerPainter({
    required this.color,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
