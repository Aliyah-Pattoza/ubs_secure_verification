import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class DeviceHelper {
  static Future<String> getDeviceId() async {
    // Jika running di Web
    if (kIsWeb) {
      return 'WEB_DEVICE_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Untuk Mobile (Android/iOS)
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }

    return 'UNKNOWN_DEVICE_${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    // Jika running di Web
    if (kIsWeb) {
      return {
        'platform': 'web',
        'model': 'Web Browser',
        'brand': 'Browser',
        'version': 'N/A',
      };
    }

    // Untuk Mobile (Android/iOS)
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'version': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'ios',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'version': iosInfo.systemVersion,
      };
    }

    return {
      'platform': 'unknown',
      'model': 'Unknown',
    };
  }
}