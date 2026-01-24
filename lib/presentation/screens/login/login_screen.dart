import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/device_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userIdFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _deviceId;
  Map<String, dynamic>? _deviceInfo;

  // Animation controller untuk loading
  late AnimationController _loadingAnimController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
    _setupAnimations();
  }

  void _setupAnimations() {
    _loadingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingAnimController, curve: Curves.easeInOut),
    );
  }

  /// Ambil Device ID/IMEI saat halaman dibuka
  Future<void> _initDeviceInfo() async {
    try {
      final deviceId = await DeviceHelper.getDeviceId();
      final deviceInfo = await DeviceHelper.getDeviceInfo();

      if (mounted) {
        setState(() {
          _deviceId = deviceId;
          _deviceInfo = deviceInfo;
        });
      }

      debugPrint('📱 Device ID: $deviceId');
      debugPrint('📱 Device Info: $deviceInfo');
    } catch (e) {
      debugPrint('❌ Error getting device info: $e');
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _userIdFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loadingAnimController.dispose();
    super.dispose();
  }

  /// Validasi User ID
  String? _validateUserId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'User ID tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'User ID minimal 3 karakter';
    }
    // Hanya boleh alphanumeric dan underscore
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'User ID hanya boleh huruf, angka, dan underscore';
    }
    return null;
  }

  /// Validasi Password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Handle Login Process
  Future<void> _handleLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackbar('Mohon lengkapi form dengan benar');
      return;
    }

    // Check device ID
    if (_deviceId == null || _deviceId!.isEmpty) {
      _showErrorSnackbar('Gagal mendapatkan Device ID. Coba restart aplikasi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadingAnimController.forward();

    try {
      debugPrint('🔐 Attempting login...');
      debugPrint('👤 User ID: ${_userIdController.text.trim()}');
      debugPrint('📱 Device ID: $_deviceId');

      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      final response = await ApiService.login(
        userId: _userIdController.text.trim(),
        password: _passwordController.text,
        imei: _deviceId!,
      );

      debugPrint('📨 Response: ${response.success} - ${response.message}');

      if (response.success && response.user != null) {
        // Login berhasil
        debugPrint('✅ Login successful!');
        debugPrint('👤 User: ${response.user!.name}');

        _showSuccessSnackbar('Login berhasil! Selamat datang, ${response.user!.name}');

        // Tunggu sebentar agar snackbar terlihat
        await Future.delayed(const Duration(milliseconds: 800));

        // Navigate ke Face Recognition
        Get.offNamed(
          AppRoutes.faceRecognition,
          arguments: {
            'user': response.user,
            'token': response.token,
            'deviceId': _deviceId,
          },
        );
      } else {
        // Login gagal
        debugPrint('❌ Login failed: ${response.message}');
        setState(() {
          _errorMessage = _getReadableErrorMessage(response.message);
        });
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Periksa koneksi internet Anda.';
      });
    } finally {
      if (mounted) {
        _loadingAnimController.reverse();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Convert error message to user-friendly message
  String _getReadableErrorMessage(String? message) {
    if (message == null) return 'Login gagal. Silakan coba lagi.';

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('imei') || lowerMessage.contains('device')) {
      return 'Perangkat ini tidak terdaftar. Hubungi admin untuk mendaftarkan perangkat Anda.';
    }
    if (lowerMessage.contains('password')) {
      return 'Password salah. Silakan coba lagi.';
    }
    if (lowerMessage.contains('user') || lowerMessage.contains('tidak ditemukan')) {
      return 'User ID tidak ditemukan. Periksa kembali User ID Anda.';
    }
    if (lowerMessage.contains('blocked') || lowerMessage.contains('suspended')) {
      return 'Akun Anda diblokir. Hubungi admin untuk informasi lebih lanjut.';
    }

    return message;
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
      duration: const Duration(seconds: 3),
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
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.background,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildWelcomeText(),
                      const SizedBox(height: 8),
                      _buildDeviceInfoBadge(),
                      const SizedBox(height: 24),
                      _buildLoginForm(),
                      const SizedBox(height: 20),
                      if (_errorMessage != null) _buildErrorMessage(),
                      _buildLoginButton(),
                      const SizedBox(height: 16),
                      _buildForgotPassword(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // UBS Logo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'UBS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UBS GOLD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Trust In Gold',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gold.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Security badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security_rounded,
                size: 14,
                color: AppColors.success.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                'Secure',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.success.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 16, color: AppColors.textMuted),
        ),
      ],
    );
  }

  /// Badge yang menampilkan Device ID
  Widget _buildDeviceInfoBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _deviceId != null
            ? AppColors.success.withOpacity(0.08)
            : AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _deviceId != null
              ? AppColors.success.withOpacity(0.2)
              : AppColors.warning.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _deviceId != null ? Icons.smartphone : Icons.warning_amber_rounded,
            size: 16,
            color: _deviceId != null ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _deviceId != null
                  ? 'Device: ${_deviceId!.length > 20 ? '${_deviceId!.substring(0, 20)}...' : _deviceId}'
                  : 'Getting device info...',
              style: TextStyle(
                fontSize: 12,
                color: _deviceId != null ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_deviceId == null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.warning.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User ID Field
            const Text(
              'User ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _userIdController,
              focusNode: _userIdFocusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: _inputDecoration(
                'Enter your user ID',
                Icons.person_outline_rounded,
              ),
              validator: _validateUserId,
              onFieldSubmitted: (_) {
                _passwordFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 20),

            // Password Field
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading,
              decoration: _inputDecoration(
                'Enter your password',
                Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      key: ValueKey(_obscurePassword),
                      color: AppColors.textMuted.withOpacity(0.7),
                      size: 22,
                    ),
                  ),
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: _validatePassword,
              onFieldSubmitted: (_) => _handleLogin(),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String hint,
      IconData icon, {
        Widget? suffixIcon,
      }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textMuted.withOpacity(0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.textMuted.withOpacity(0.7),
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildErrorMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login Gagal',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.error.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || _deviceId == null) ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.primaryDark,
          disabledBackgroundColor: AppColors.gold.withOpacity(0.4),
          disabledForegroundColor: AppColors.primaryDark.withOpacity(0.5),
          elevation: _isLoading ? 0 : 4,
          shadowColor: AppColors.gold.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryDark.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Signing in...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark.withOpacity(0.7),
                ),
              ),
            ],
          )
              : const Text(
            'Login',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : () {
          Get.snackbar(
            'Info',
            'Hubungi admin untuk reset password',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: const Icon(Icons.info_outline, color: Colors.white),
          );
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: _isLoading ? AppColors.textMuted.withOpacity(0.5) : AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated loading indicator
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    backgroundColor: AppColors.gold.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verifying credentials...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}