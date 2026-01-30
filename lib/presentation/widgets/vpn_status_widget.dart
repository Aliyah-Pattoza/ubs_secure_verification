import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/services/vpn_service.dart';

/// Widget untuk menampilkan status VPN di header
class VpnStatusBadge extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const VpnStatusBadge({super.key, this.showDetails = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<VpnService>()) {
      return const SizedBox.shrink();
    }
    final vpnService = Get.find<VpnService>();
    return Obx(() {
      final status = vpnService.status.value;
      final config = _getStatusConfig(status);

      return GestureDetector(
        onTap: onTap ?? () => _showVpnBottomSheet(context, vpnService),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: showDetails ? 12 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: config.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: config.color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status icon with animation
              if (status == VpnStatus.connecting ||
                  status == VpnStatus.disconnecting)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(config.color),
                  ),
                )
              else
                Icon(config.icon, size: 14, color: config.color),

              if (showDetails) ...[
                const SizedBox(width: 6),
                Text(
                  config.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: config.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  _StatusConfig _getStatusConfig(VpnStatus status) {
    switch (status) {
      case VpnStatus.connected:
        return _StatusConfig(
          icon: Icons.shield_rounded,
          label: 'VPN On',
          color: AppColors.success,
        );
      case VpnStatus.connecting:
        return _StatusConfig(
          icon: Icons.shield_outlined,
          label: 'Connecting',
          color: AppColors.warning,
        );
      case VpnStatus.disconnecting:
        return _StatusConfig(
          icon: Icons.shield_outlined,
          label: 'Disconnecting',
          color: AppColors.warning,
        );
      case VpnStatus.error:
        return _StatusConfig(
          icon: Icons.shield_outlined,
          label: 'Error',
          color: AppColors.error,
        );
      case VpnStatus.disconnected:
        return _StatusConfig(
          icon: Icons.shield_outlined,
          label: 'VPN Off',
          color: AppColors.textMuted,
        );
    }
  }

  void _showVpnBottomSheet(BuildContext context, VpnService vpnService) {
    if (!context.mounted) return;
    Get.bottomSheet(
      VpnStatusSheet(vpnService: vpnService),
      isScrollControlled: true,
    );
  }
}

class _StatusConfig {
  final IconData icon;
  final String label;
  final Color color;

  _StatusConfig({required this.icon, required this.label, required this.color});
}

/// Bottom sheet untuk detail VPN
class VpnStatusSheet extends StatelessWidget {
  final VpnService vpnService;

  const VpnStatusSheet({super.key, required this.vpnService});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Status Card
                  _buildStatusCard(),
                  const SizedBox(height: 20),

                  // Connection Info
                  Obx(
                    () => vpnService.isConnected
                        ? _buildConnectionInfo()
                        : const SizedBox(),
                  ),

                  // Connect/Disconnect Button
                  const SizedBox(height: 24),
                  _buildActionButton(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.vpn_key_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VPN Connection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Secure tunnel for UBS transactions',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Obx(() {
      final status = vpnService.status.value;
      final isConnected = status == VpnStatus.connected;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isConnected
                ? [
                    AppColors.success.withOpacity(0.1),
                    AppColors.success.withOpacity(0.05),
                  ]
                : [AppColors.backgroundLight, AppColors.background],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnected
                ? AppColors.success.withOpacity(0.3)
                : AppColors.textMuted.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            // Big status icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isConnected
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.textMuted.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isConnected ? Icons.shield_rounded : Icons.shield_outlined,
                size: 40,
                color: isConnected ? AppColors.success : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            // Status text
            Text(
              vpnService.statusMessage.value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isConnected ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),

            // Server info
            if (vpnService.currentConfig.value != null && isConnected)
              Text(
                vpnService.currentConfig.value!.serverLocation,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted.withOpacity(0.8),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildConnectionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // IP Address
          _buildInfoRow(
            icon: Icons.language_rounded,
            label: 'IP Address',
            value: vpnService.ipAddress.value,
          ),
          const Divider(height: 20),

          // Connection Duration
          Obx(
            () => _buildInfoRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: vpnService.connectionDuration,
            ),
          ),
          const Divider(height: 20),

          // Speed
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildSpeedInfo(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Upload',
                    value: vpnService.formatSpeed(vpnService.uploadSpeed.value),
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => _buildSpeedInfo(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Download',
                    value: vpnService.formatSpeed(
                      vpnService.downloadSpeed.value,
                    ),
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted.withOpacity(0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Obx(() {
      final status = vpnService.status.value;
      final isConnected = status == VpnStatus.connected;
      final isLoading =
          status == VpnStatus.connecting || status == VpnStatus.disconnecting;

      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : () => vpnService.toggle(),
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isConnected ? AppColors.error : Colors.white,
                    ),
                  ),
                )
              : Icon(
                  isConnected
                      ? Icons.power_settings_new_rounded
                      : Icons.power_rounded,
                ),
          label: Text(
            isLoading
                ? (status == VpnStatus.connecting
                      ? 'Connecting...'
                      : 'Disconnecting...')
                : (isConnected ? 'Disconnect' : 'Connect'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? AppColors.error : AppColors.success,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                (isConnected ? AppColors.error : AppColors.success).withOpacity(
                  0.5,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    });
  }
}

/// Security indicator untuk header
class SecurityIndicator extends StatelessWidget {
  const SecurityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<VpnService>()) {
      return const SizedBox.shrink();
    }
    final vpnService = Get.find<VpnService>();
    return Obx(() {
      final isSecure = vpnService.isConnected;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSecure
              ? AppColors.success.withOpacity(0.1)
              : AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSecure
                ? AppColors.success.withOpacity(0.3)
                : AppColors.warning.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSecure ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 12,
              color: isSecure ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: 4),
            Text(
              isSecure ? 'Secure' : 'Not Secure',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSecure ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
      );
    });
  }
}
