import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // State
  bool _isScanning = false;
  bool _scanComplete = false;
  String _statusMessage = 'Ready to Scan';
  String _statusSubMessage = 'Please look at the camera';

  final _apiService = ApiService();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      user = args['user'] as UserModel?;
      token = args['token'] as String?;
      pendingTransaction = args['transaction'] as TransactionModel?;
      approvalAction = args['action'] as String?;
    }

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);

    // Update subtitle jika untuk approval
    if (pendingTransaction != null && approvalAction != null) {
      _statusSubMessage = 'Verify to $approvalAction transaction';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startVerification() async {
    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _statusMessage = 'Scanning...';
      _statusSubMessage = 'Hold still';
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _statusMessage = 'Processing...';
      _statusSubMessage = 'Verifying your identity';
    });

    try {
      final response = await _apiService.verifyFace(
        base64Image: 'mock_base64_image',
        userId: user?.id ?? '',
        nik: user?.nik ?? '',
      );

      if (response.success && response.isMatch == true) {
        setState(() {
          _scanComplete = true;
          _statusMessage = 'Verified!';
          _statusSubMessage = 'Face recognition successful';
        });

        await Future.delayed(const Duration(seconds: 1));

        if (pendingTransaction != null && approvalAction != null) {
          await _processApproval();
        } else {
          _navigateToTransactionList();
        }
      } else {
        setState(() {
          _isScanning = false;
          _statusMessage = 'Verification Failed';
          _statusSubMessage = response.message ?? 'Please try again';
        });

        Get.snackbar(
          'Verifikasi Gagal',
          response.message ?? 'Wajah tidak cocok',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error';
        _statusSubMessage = 'Failed to verify. Please try again.';
      });
    }
  }

  Future<void> _processApproval() async {
    try {
      final response = await _apiService.submitApproval(
        documentNumber: pendingTransaction!.documentNumber,
        status: approvalAction == 'accept' ? 'accepted' : 'rejected',
        base64Image: 'mock_base64_image',
        userId: user?.id ?? '',
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
        Get.snackbar(
          'Gagal',
          response.message ?? 'Gagal memproses approval',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  void _navigateToTransactionList() {
    Get.offNamed(
      AppRoutes.transactionList,
      arguments: {'user': user, 'token': token},
    );
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
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 30),
              Expanded(child: _buildCameraFrame()),
              _buildBottomSection(),
              const SizedBox(height: 30),
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
          if (user != null) ...[
            Text(
              user!.name,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user!.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
            'Face Recognition',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pendingTransaction != null
                ? 'Verify to $approvalAction transaction'
                : _statusSubMessage,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraFrame() {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isScanning ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          width: 280,
          height: 360,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _scanComplete
                  ? AppColors.success
                  : _isScanning
                  ? AppColors.gold
                  : AppColors.gold.withOpacity(0.35),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: (_scanComplete ? AppColors.success : AppColors.gold)
                    .withOpacity(0.25),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                _buildFacePreview(),
                if (_isScanning && !_scanComplete) _buildScanningOverlay(),
                ..._buildCornerMarkers(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacePreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: _scanComplete
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.gold.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: Icon(
              _scanComplete ? Icons.check_circle_rounded : Icons.face_rounded,
              size: 90,
              color: _scanComplete ? AppColors.success : AppColors.gold,
            ),
          ),
          const SizedBox(height: 20),
          if (user != null) ...[
            Text(
              user!.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user!.nik,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gold.withOpacity(0.08),
            Colors.transparent,
            Colors.transparent,
            AppColors.gold.withOpacity(0.08),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    final color = _scanComplete
        ? AppColors.success
        : _isScanning
        ? AppColors.gold
        : AppColors.gold.withOpacity(0.5);

    return [
      Positioned(top: 24, left: 24, child: _buildCorner(color, true, true)),
      Positioned(top: 24, right: 24, child: _buildCorner(color, true, false)),
      Positioned(bottom: 24, left: 24, child: _buildCorner(color, false, true)),
      Positioned(
        bottom: 24,
        right: 24,
        child: _buildCorner(color, false, false),
      ),
    ];
  }

  Widget _buildCorner(Color color, bool isTop, bool isLeft) {
    return SizedBox(
      width: 28,
      height: 28,
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
          Icon(
            _scanComplete
                ? Icons.check_circle_rounded
                : _isScanning
                ? Icons.face_retouching_natural_rounded
                : Icons.face_rounded,
            size: 44,
            color: _scanComplete ? AppColors.success : AppColors.gold,
          ),
          const SizedBox(height: 14),
          Text(
            _statusMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _scanComplete ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _statusSubMessage,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          if (_isScanning && !_scanComplete)
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            )
          else if (!_isScanning && !_scanComplete)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.primaryDark,
                  elevation: 4,
                  shadowColor: AppColors.gold.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Start Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
      ..strokeWidth = 3.5
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
