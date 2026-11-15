import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Target GATT Service UUID for ESP32 Mesh Remote Control.
const String remoteServiceUuid = '4d657368-0001-4147-5930-000000000001';

/// Discovered eNode target representation.
class DiscoveredNode {
  final BluetoothDevice device;
  final String name;
  final int rssi;
  final DateTime lastSeen;

  DiscoveredNode({
    required this.device,
    required this.name,
    required this.rssi,
    required this.lastSeen,
  });

  String get id => device.remoteId.str;
}

/// Service that discovers eNodes advertising the Mesh Remote Service UUID or 'eNode-' prefix.
class BleScannerService extends ChangeNotifier {
  final Map<String, DiscoveredNode> _nodes = {};
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool _isScanning = false;

  Map<String, DiscoveredNode> get nodes => Map.unmodifiable(_nodes);
  List<DiscoveredNode> get nodeList => _nodes.values.toList()
    ..sort((a, b) => b.rssi.compareTo(a.rssi));
  bool get isScanning => _isScanning;

  BleScannerService() {
    _init();
  }

  void _init() {
    try {
      FlutterBluePlus.isScanning.listen(
        (scanning) {
          _isScanning = scanning;
          notifyListeners();
        },
        onError: (_) {},
      );

      _scanSub = FlutterBluePlus.scanResults.listen(
        (results) {
          for (final r in results) {
            final deviceName = r.advertisementData.advName.isNotEmpty
                ? r.advertisementData.advName
                : r.device.platformName;

            final hasServiceUuid = r.advertisementData.serviceUuids
                .any((u) => u.str.toLowerCase() == remoteServiceUuid.toLowerCase());
            final hasNodePrefix = deviceName.startsWith('eNode-');

            if (hasServiceUuid || hasNodePrefix) {
              _nodes[r.device.remoteId.str] = DiscoveredNode(
                device: r.device,
                name: deviceName.isNotEmpty ? deviceName : 'eNode (Unknown)',
                rssi: r.rssi,
                lastSeen: DateTime.now(),
              );
              notifyListeners();
            }
          }
        },
        onError: (_) {},
      );
    } catch (e) {
      debugPrint('[BleScannerService] Platform not supported or mock: $e');
    }
  }

  /// Start scanning with 15-second timeout.
  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    _nodes.clear();
    notifyListeners();

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(remoteServiceUuid)],
        timeout: timeout,
      );
    } catch (e) {
      debugPrint('[BleScannerService] Filtered scan failed, retrying without service filter: $e');
      try {
        await FlutterBluePlus.startScan(timeout: timeout);
      } catch (err) {
        debugPrint('[BleScannerService] Scan failed: $err');
      }
    }
  }

  /// Stop scanning immediately.
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    super.dispose();
  }
}
