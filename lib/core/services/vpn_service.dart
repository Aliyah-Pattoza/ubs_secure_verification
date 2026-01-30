import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import '../../config/ubs_api_config.dart';
import '../../config/vpn_config.dart';

/// Status koneksi VPN
enum VpnStatus { disconnected, connecting, connected, disconnecting, error }

/// Model untuk konfigurasi VPN
class VpnConfig {
  final String serverAddress;
  final String serverName;
  final String serverLocation;
  final int port;
  final String publicKey;
  final String privateKey;
  final String clientAddress;
  final List<String> allowedIPs;
  final String dns;

  VpnConfig({
    required this.serverAddress,
    required this.serverName,
    required this.serverLocation,
    this.port = 65483,
    this.publicKey = 'zUSakgEFdXQ25BoV0Y+DHLyNd1kRtALZLidWnK6d1l0=',
    this.privateKey = 'kP8HeN6bZ/Ohn4CgEukEVSRG+phx7XthMcxejhsu1Gg=',
    this.clientAddress = '10.8.0.2/32',
    this.allowedIPs = const ['0.0.0.0/0'],
    this.dns = '1.1.1.1',
  });

  factory VpnConfig.fromJson(Map<String, dynamic> json) {
    return VpnConfig(
      serverAddress: json['server_address'] ?? json['endpoint'] ?? '',
      serverName: json['server_name'] ?? 'UBS VPN Server',
      serverLocation: json['server_location'] ?? 'Jakarta, Indonesia',
      port: json['port'] ?? 65483,
      publicKey: json['public_key'] ?? '',
      privateKey: json['private_key'] ?? '',
      clientAddress:
          json['client_address'] ??
          json['address'] ??
          json['interface_address'] ??
          '10.8.0.2/32',
      allowedIPs: json['allowed_ips'] != null
          ? List<String>.from(json['allowed_ips'])
          : ['0.0.0.0/0'],
      dns: json['dns'] ?? '1.1.1.1',
    );
  }

  /// Default config untuk UBS (pakai key tunnel Anda)
  factory VpnConfig.ubsDefault() {
    return VpnConfig(
      serverAddress: '192.168.100.109', // GANTI dengan IP server WireGuard
      serverName: 'UBS Gold Secure Server',
      serverLocation: 'Jakarta, Indonesia',
      port: 65483,
      publicKey: 'zUSakgEFdXQ25BoV0Y+DHLyNd1kRtALZLidWnK6d1l0=',
      privateKey: 'kP8HeN6bZ/Ohn4CgEukEVSRG+phx7XthMcxejhsu1Gg=',
      clientAddress: '10.8.0.2/32',
      allowedIPs: UbsApiConfig.vpnRouteAllTraffic
          ? const ['0.0.0.0/0']
          : UbsApiConfig.vpnAllowedIps,
      dns: '1.1.1.1, 8.8.8.8',
    );
  }
}

/// Service untuk mengelola koneksi VPN
class VpnService extends GetxService {
  final _wg = WireGuardFlutter.instance;

  // Observable states
  final Rx<VpnStatus> status = VpnStatus.disconnected.obs;
  final Rx<VpnConfig?> currentConfig = Rx<VpnConfig?>(null);
  final RxString statusMessage = 'Not Connected'.obs;
  final RxString ipAddress = ''.obs;
  final RxInt uploadSpeed = 0.obs;
  final RxInt downloadSpeed = 0.obs;
  final Rx<DateTime?> connectedSince = Rx<DateTime?>(null);
  final RxBool isAutoConnect = true.obs;

  // Connection timer
  Timer? _connectionTimer;
  StreamSubscription<VpnStage>? _stageSub;
  bool _isInitialized = false;
  final String _interfaceName = 'ubs_wg_vpn';

  /// Initialize service
  Future<VpnService> init() async {
    debugPrint('🔐 VpnService initialized');
    _stageSub ??= _wg.vpnStageSnapshot.listen(_onStageChanged);
    return this;
  }

  Future<void> showVpnPermissionDialog() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) return;
    if (!_isInitialized) {
      await _wg.initialize(interfaceName: _interfaceName);
      _isInitialized = true;
    }
    // initialize() di plugin sudah memanggil checkPermission() → muncul dialog sistem
    debugPrint('🔐 VPN permission dialog should be visible');
  }

  /// Connect ke VPN dengan config
  /// Di Android: pertama kali akan muncul dialog "Allow VPN?". User harus tap OK,
  /// lalu panggil connect() lagi (atau tap Connect lagi).
  Future<bool> connect({VpnConfig? config}) async {
    if (status.value == VpnStatus.connecting ||
        status.value == VpnStatus.connected) {
      debugPrint('⚠️ VPN already connecting/connected');
      return false;
    }

    try {
      // Set config: dari parameter atau konfigurasi terpusat (lib/config/vpn_config.dart)
      currentConfig.value = config ?? activeVpnConfig;

      status.value = VpnStatus.connecting;
      statusMessage.value =
          'Connecting to ${currentConfig.value!.serverName}...';
      debugPrint('🔐 Connecting to VPN: ${currentConfig.value!.serverAddress}');

      if (kIsWeb) {
        throw Exception('WireGuard VPN tidak didukung di Web');
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        throw Exception(
          'iOS WireGuard butuh Network Extension (providerBundleIdentifier).',
        );
      }

      final cfg = currentConfig.value!;
      final validationError = _validateConfig(cfg);
      if (validationError != null) throw Exception(validationError);

      // Initialize sekali (ini yang memunculkan dialog izin di Android)
      if (!_isInitialized) {
        await _wg.initialize(interfaceName: _interfaceName);
        _isInitialized = true;
      }

      final wgQuickConfig = _buildWgQuickConfig(cfg);
      final endpoint = '${cfg.serverAddress}:${cfg.port}';
      debugPrint('📝 WireGuard endpoint: $endpoint');

      await _wg.startVpn(
        serverAddress: endpoint,
        wgQuickConfig: wgQuickConfig,
        providerBundleIdentifier: '',
      );

      debugPrint('✅ WireGuard startVpn() called');
      return true;
    } on PlatformException catch (e) {
      debugPrint('❌ VPN PlatformException: ${e.code} - ${e.message}');
      status.value = VpnStatus.error;

      if (e.message != null &&
          e.message!.toLowerCase().contains('permission')) {
        statusMessage.value = 'Izin VPN belum diberikan';
        _showPermissionRequiredDialog();
      } else {
        statusMessage.value = e.message ?? 'Connection failed';
        Get.snackbar(
          'VPN Error',
          statusMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (e) {
      debugPrint('❌ VPN Connection error: $e');
      status.value = VpnStatus.error;
      final msg = e.toString();
      if (msg.toLowerCase().contains('permission')) {
        statusMessage.value = 'Izin VPN belum diberikan';
        _showPermissionRequiredDialog();
      } else {
        statusMessage.value = 'Connection failed: $msg';
        Get.snackbar(
          'VPN Error',
          statusMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
  }

  /// Dialog instruksi: user harus tap OK di dialog sistem, lalu Coba Lagi
  void _showPermissionRequiredDialog() {
    Get.dialog(
      barrierDismissible: false,
      _VpnPermissionDialog(
        onRetry: () {
          Get.back();
          connect(config: currentConfig.value);
        },
      ),
    );
  }

  /// Disconnect dari VPN
  Future<bool> disconnect() async {
    if (status.value == VpnStatus.disconnected ||
        status.value == VpnStatus.disconnecting) {
      return true;
    }

    try {
      status.value = VpnStatus.disconnecting;
      statusMessage.value = 'Disconnecting...';

      debugPrint('🔐 Disconnecting VPN...');

      if (!kIsWeb) {
        await _wg.stopVpn();
      }

      status.value = VpnStatus.disconnected;
      statusMessage.value = 'Disconnected';
      ipAddress.value = '';
      connectedSince.value = null;
      uploadSpeed.value = 0;
      downloadSpeed.value = 0;

      debugPrint('✅ VPN Disconnected');
      return true;
    } catch (e) {
      debugPrint('❌ VPN Disconnect error: $e');
      status.value = VpnStatus.error;
      statusMessage.value = 'Disconnect failed: ${e.toString()}';
      return false;
    }
  }

  /// Toggle koneksi VPN
  Future<bool> toggle() async {
    if (status.value == VpnStatus.connected) {
      return await disconnect();
    } else {
      return await connect();
    }
  }

  /// Get connection duration string
  String get connectionDuration {
    if (connectedSince.value == null) return '--:--:--';

    final duration = DateTime.now().difference(connectedSince.value!);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  /// Format speed untuk display
  String formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond >= 1000000) {
      return '${(bytesPerSecond / 1000000).toStringAsFixed(1)} MB/s';
    } else if (bytesPerSecond >= 1000) {
      return '${(bytesPerSecond / 1000).toStringAsFixed(1)} KB/s';
    }
    return '$bytesPerSecond B/s';
  }

  /// Check if connected
  bool get isConnected => status.value == VpnStatus.connected;

  /// Check if connecting
  bool get isConnecting => status.value == VpnStatus.connecting;

  @override
  void onClose() {
    _connectionTimer?.cancel();
    _stageSub?.cancel();
    super.onClose();
  }

  void _onStageChanged(VpnStage stage) {
    final stageName = stage.name;
    debugPrint('🔐 VPN Stage changed: $stageName');

    switch (stageName) {
      case 'connecting':
      case 'preparing':
      case 'authenticating':
      case 'waitingConnection':
      case 'reconnect':
        status.value = VpnStatus.connecting;
        statusMessage.value = 'Connecting...';
        break;
      case 'connected':
        status.value = VpnStatus.connected;
        statusMessage.value = 'Connected';
        connectedSince.value ??= DateTime.now();
        debugPrint('✅ VPN Connected successfully');
        break;
      case 'disconnecting':
      case 'exiting':
        status.value = VpnStatus.disconnecting;
        statusMessage.value = 'Disconnecting...';
        break;
      case 'disconnected':
      case 'noConnection':
        status.value = VpnStatus.disconnected;
        statusMessage.value = 'Disconnected';
        connectedSince.value = null;
        break;
      case 'denied':
        status.value = VpnStatus.error;
        statusMessage.value = 'VPN permission denied';
        debugPrint('❌ VPN Permission denied by user');
        break;
      default:
        debugPrint('ℹ️ WireGuard stage: $stageName');
    }
  }

  String? _validateConfig(VpnConfig cfg) {
    if (cfg.serverAddress.trim().isEmpty) return 'VPN serverAddress kosong';
    if (cfg.port <= 0) return 'VPN port tidak valid';
    if (cfg.privateKey.trim().isEmpty) {
      return 'VPN privateKey kosong (wajib dari server WireGuard client)';
    }
    if (cfg.publicKey.trim().isEmpty) {
      return 'VPN publicKey kosong (wajib: server public key)';
    }
    return null;
  }

  String _buildWgQuickConfig(VpnConfig cfg) {
    final dnsLine = cfg.dns.trim().isEmpty ? '' : 'DNS = ${cfg.dns}\n';
    final allowedIps = cfg.allowedIPs.isEmpty ? ['0.0.0.0/0'] : cfg.allowedIPs;

    return '''
[Interface]
Address = ${cfg.clientAddress}
${dnsLine}PrivateKey = ${cfg.privateKey}

[Peer]
PublicKey = ${cfg.publicKey}
AllowedIPs = ${allowedIps.join(', ')}
Endpoint = ${cfg.serverAddress}:${cfg.port}
PersistentKeepalive = 25
''';
  }
}

/// Dialog saat izin VPN belum diberikan: user tap OK di dialog sistem, lalu Coba Lagi
class _VpnPermissionDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const _VpnPermissionDialog({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Izin VPN Diperlukan'),
      content: const SingleChildScrollView(
        child: Text(
          'Aplikasi membutuhkan izin VPN untuk terhubung ke server aman.\n\n'
          '1. Jika muncul dialog dari sistem, tap **OK** untuk mengizinkan VPN.\n'
          '2. Setelah itu, tap tombol **Coba Lagi** di bawah.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
      ],
    );
  }
}
