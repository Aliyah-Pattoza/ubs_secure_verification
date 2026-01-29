import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF1A2D42), // Base navy color
        child: Stack(
          children: [
            // Background wave pattern
            CustomPaint(
              size: size,
              painter: UBSWaveBackgroundPainter(),
            ),

            // Main Content
            SafeArea(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo UBS dari image asset
                    _buildLogo(),

                    const Spacer(flex: 2),

                    // Gold Bar (lebih besar)
                    _buildGoldBar(),

                    const Spacer(flex: 3),

                    // Bottom Section
                    _buildBottomSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logo UBS Gold - menggunakan image asset
  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Image.asset(
        'assets/images/ubs_logo_gold.png',
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }

  /// Gold Bar - lebih besar dengan logo image (FIXED VERSION)
  Widget _buildGoldBar() {
    return Container(
      width: 130,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8D54E), // Bright gold
            Color(0xFFD4B93C), // Medium gold
            Color(0xFFC9A227), // Dark gold
            Color(0xFFD4B93C), // Medium gold
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4B93C).withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8), // Reduced from 12 to 8
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo UBS dari image (kecil)
            Image.asset(
              'assets/images/ubs_logo_gold.png',
              height: 30, // Reduced from 40 to 30
              fit: BoxFit.contain,
              color: const Color(0xFF5C4827), // Warna gelap untuk kontras
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 4), // Reduced from 6 to 4
            Text(
              'Trust in Gold',
              style: TextStyle(
                fontSize: 6, // Reduced from 7 to 6
                fontStyle: FontStyle.italic,
                color: const Color(0xFF5C4827).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8), // Reduced from 14 to 8
            const Text(
              '1 Gr.',
              style: TextStyle(
                fontSize: 22, // Reduced from 24 to 22
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C4827),
              ),
            ),
            const SizedBox(height: 4), // Reduced from 6 to 4
            const Text(
              'FINE GOLD',
              style: TextStyle(
                fontSize: 9, // Reduced from 10 to 9
                fontWeight: FontWeight.w500,
                color: Color(0xFF5C4827),
                letterSpacing: 1.5, // Reduced from 2 to 1.5
              ),
            ),
            const SizedBox(height: 4), // Reduced from 6 to 4
            Container(
              width: 40, // Reduced from 50 to 40
              height: 1,
              color: const Color(0xFF8B7355).withOpacity(0.5),
            ),
            const SizedBox(height: 4), // Reduced from 6 to 4
            const Text(
              '999.9',
              style: TextStyle(
                fontSize: 13, // Reduced from 14 to 13
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C4827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Section
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSecurityBadge(),
          const SizedBox(height: 20),
          _buildContinueButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 16,
            color: const Color(0xFFD4A574).withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Text(
            'Secure Verification System',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFD4A574).withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _navigateToLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4A574),
          foregroundColor: const Color(0xFF1A2D42),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter untuk background wave pattern
class UBSWaveBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Wave colors (rose gold / peach tones)
    final waveColor1 = const Color(0xFFD4A574).withOpacity(0.15);
    final waveColor2 = const Color(0xFFB8917A).withOpacity(0.12);
    final waveColor3 = const Color(0xFFD4A574).withOpacity(0.08);

    // Wave 1 - Top right flowing down
    final paint1 = Paint()
      ..color = waveColor1
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(size.width * 0.6, 0);
    path1.quadraticBezierTo(
      size.width * 1.1, size.height * 0.2,
      size.width * 0.85, size.height * 0.45,
    );
    path1.quadraticBezierTo(
      size.width * 0.6, size.height * 0.7,
      size.width * 0.9, size.height * 0.85,
    );
    path1.quadraticBezierTo(
      size.width * 1.1, size.height * 0.95,
      size.width, size.height,
    );
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Wave 2 - Middle wave
    final paint2 = Paint()
      ..color = waveColor2
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(size.width * 0.3, size.height);
    path2.quadraticBezierTo(
      size.width * 0.1, size.height * 0.85,
      size.width * 0.25, size.height * 0.65,
    );
    path2.quadraticBezierTo(
      size.width * 0.45, size.height * 0.4,
      size.width * 0.2, size.height * 0.2,
    );
    path2.quadraticBezierTo(
      size.width * 0.05, size.height * 0.05,
      0, size.height * 0.15,
    );
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Wave 3 - Bottom accent
    final paint3 = Paint()
      ..color = waveColor3
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(0, size.height * 0.7);
    path3.quadraticBezierTo(
      size.width * 0.3, size.height * 0.6,
      size.width * 0.5, size.height * 0.75,
    );
    path3.quadraticBezierTo(
      size.width * 0.7, size.height * 0.9,
      size.width * 0.4, size.height,
    );
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);

    // Wave 4 - Top left subtle
    final paint4 = Paint()
      ..color = const Color(0xFFD4A574).withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final path4 = Path();
    path4.moveTo(0, 0);
    path4.quadraticBezierTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.15, size.height * 0.25,
    );
    path4.quadraticBezierTo(
      0, size.height * 0.35,
      0, size.height * 0.4,
    );
    path4.lineTo(0, 0);
    path4.close();
    canvas.drawPath(path4, paint4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}