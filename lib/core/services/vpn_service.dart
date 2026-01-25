import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Status koneksi VPN
enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// Model untuk konfigurasi VPN
class VpnConfig {
  final String serverAddress;
  final String serverName;
  final String serverLocation;
  final int port;
  final String publicKey;
  final String privateKey;
  final List<String> allowedIPs;
  final String dns;

  VpnConfig({
    required this.serverAddress,
    required this.serverName,
    required this.serverLocation,
    this.port = 51820,
    this.publicKey = '',
    this.privateKey = '',
    this.allowedIPs = const ['0.0.0.0/0'],
    this.dns = '1.1.1.1',
  });

  factory VpnConfig.fromJson(Map<String, dynamic> json) {
    return VpnConfig(
      serverAddress: json['server_address'] ?? json['endpoint'] ?? '',
      serverName: json['server_name'] ?? 'UBS VPN Server',
      serverLocation: json['server_location'] ?? 'Jakarta, Indonesia',
      port: json['port'] ?? 51820,
      publicKey: json['public_key'] ?? '',
      privateKey: json['private_key'] ?? '',
      allowedIPs: json['allowed_ips'] != null
          ? List<String>.from(json['allowed_ips'])
          : ['0.0.0.0/0'],
      dns: json['dns'] ?? '1.1.1.1',
    );
  }

  /// Default config untuk UBS
  factory VpnConfig.ubsDefault() {
    return VpnConfig(
      serverAddress: '103.xxx.xxx.xxx',
      serverName: 'UBS Gold Secure Server',
      serverLocation: 'Jakarta, Indonesia',
      port: 51820,
      publicKey: 'UBS_PUBLIC_KEY_PLACEHOLDER',
      dns: '1.1.1.1, 8.8.8.8',
    );
  }
}

/// Service untuk mengelola koneksi VPN
/// NOTE: Ini adalah MOCK implementation untuk testing
/// Untuk production, integrasikan dengan WireGuard native
class VpnService extends GetxService {
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
  Timer? _speedUpdateTimer;

  /// Initialize service
  Future<VpnService> init() async {
    debugPrint('🔐 VpnService initialized');
    return this;
  }

  /// Connect ke VPN dengan config
  Future<bool> connect({VpnConfig? config}) async {
    if (status.value == VpnStatus.connecting ||
        status.value == VpnStatus.connected) {
      debugPrint('⚠️ VPN already connecting/connected');
      return false;
    }

    try {
      // Set config
      currentConfig.value = config ?? VpnConfig.ubsDefault();

      // Update status
      status.value = VpnStatus.connecting;
      statusMessage.value = 'Connecting to ${currentConfig.value!.serverName}...';

      debugPrint('🔐 Connecting to VPN: ${currentConfig.value!.serverAddress}');

      // ========== MOCK CONNECTION ==========
      // Simulasi proses koneksi (2-3 detik)
      await Future.delayed(const Duration(seconds: 2));

      // Simulasi 90% success rate
      final isSuccess = DateTime.now().millisecond % 10 != 0;

      if (isSuccess) {
        status.value = VpnStatus.connected;
        statusMessage.value = 'Connected to ${currentConfig.value!.serverName}';
        ipAddress.value = '10.8.0.${DateTime.now().millisecond % 255}';
        connectedSince.value = DateTime.now();

        // Start speed update simulation
        _startSpeedSimulation();

        debugPrint('✅ VPN Connected! IP: ${ipAddress.value}');
        return true;
      } else {
        throw Exception('Connection timeout');
      }
      // ========== END MOCK ==========

      // ========== REAL WIREGUARD IMPLEMENTATION ==========
      // Untuk production, gunakan package seperti:
      // - wireguard_flutter
      // - flutter_vpn
      //
      // Contoh:
      // await WireGuardFlutter.initialize();
      // await WireGuardFlutter.connect(config: wgConfig);
      // ========== END REAL IMPLEMENTATION ==========

    } catch (e) {
      debugPrint('❌ VPN Connection error: $e');
      status.value = VpnStatus.error;
      statusMessage.value = 'Connection failed: ${e.toString()}';
      return false;
    }
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

      // Stop speed simulation
      _stopSpeedSimulation();

      // ========== MOCK DISCONNECTION ==========
      await Future.delayed(const Duration(seconds: 1));
      // ========== END MOCK ==========

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

  /// Simulasi update speed (untuk demo)
  void _startSpeedSimulation() {
    _speedUpdateTimer?.cancel();
    _speedUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (status.value == VpnStatus.connected) {
        // Random speed antara 1-10 MB/s
        uploadSpeed.value = 1000 + (DateTime.now().millisecond % 9000);
        downloadSpeed.value = 2000 + (DateTime.now().millisecond % 8000);
      }
    });
  }

  void _stopSpeedSimulation() {
    _speedUpdateTimer?.cancel();
    _speedUpdateTimer = null;
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
    _speedUpdateTimer?.cancel();
    super.onClose();
  }
}