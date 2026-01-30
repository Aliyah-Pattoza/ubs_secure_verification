import '../core/services/vpn_service.dart';

/// Konfigurasi VPN
enum VpnProfile { local, ubs }

/// Profil VPN yang dipakai saat ini. Ganti ke [VpnProfile.ubs] untuk VPN UBS.
const VpnProfile vpnProfile = VpnProfile.local;

VpnConfig get vpnConfigLocal => VpnConfig(
  serverAddress: '192.168.100.109',
  serverName: 'Local WireGuard',
  serverLocation: 'Local / LAN',
  port: 65483,
  publicKey: 'zUSakgEFdXQ25BoV0Y+DHLyNd1kRtALZLidWnK6d1l0=',
  privateKey: 'kP8HeN6bZ/Ohn4CgEukEVSRG+phx7XthMcxejhsu1Gg=',
  clientAddress: '10.8.0.2/32',
  dns: '1.1.1.1, 8.8.8.8',
);

/// Konfigurasi untuk VPN UBS
VpnConfig get vpnConfigUbs => VpnConfig(
  serverAddress: 'vpn.ubs.example.com',
  serverName: 'UBS Gold Secure Server',
  serverLocation: 'Jakarta, Indonesia',
  port: 65483,
  publicKey: 'SERVER_PUBLIC_KEY_DARI_UBS',
  privateKey: 'CLIENT_PRIVATE_KEY_DARI_UBS',
  clientAddress: '10.8.0.2/32',
  dns: '1.1.1.1, 8.8.8.8',
);

/// Mengembalikan config VPN sesuai [vpnProfile].
VpnConfig get activeVpnConfig =>
    vpnProfile == VpnProfile.local ? vpnConfigLocal : vpnConfigUbs;
