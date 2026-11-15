import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service managing runtime Bluetooth and Location permissions for Android.
class PermissionService {
  /// Request all required permissions depending on the Android OS version.
  /// Android 12+ (API 31+) uses BLUETOOTH_SCAN and BLUETOOTH_CONNECT.
  /// Android 8-11 requires Location permission for BLE scanning.
  static Future<bool> requestBlePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      final scanOk = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      final connectOk = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      final locationOk = statuses[Permission.locationWhenInUse]?.isGranted ?? false;

      // On Android 12+, scan and connect are essential.
      // On legacy Android, locationWhenInUse is required.
      final hasBleAccess = (scanOk && connectOk) || locationOk;
      return hasBleAccess;
    } catch (e) {
      debugPrint('[PermissionService] Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if BLE permissions are already granted.
  static Future<bool> hasBlePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final scan = await Permission.bluetoothScan.status;
    final connect = await Permission.bluetoothConnect.status;
    final location = await Permission.locationWhenInUse.status;

    return (scan.isGranted && connect.isGranted) || location.isGranted;
  }

  /// Open application settings if user has permanently denied permissions.
  static Future<bool> openSettings() async {
    return openAppSettings();
  }
}
