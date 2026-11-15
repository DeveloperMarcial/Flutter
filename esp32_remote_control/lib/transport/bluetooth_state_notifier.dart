import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Notifier that tracks Bluetooth hardware adapter states.
class BluetoothStateNotifier extends ChangeNotifier {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription<BluetoothAdapterState>? _subscription;

  BluetoothAdapterState get adapterState => _adapterState;
  bool get isPoweredOn => _adapterState == BluetoothAdapterState.on;
  bool get isAvailable => _adapterState != BluetoothAdapterState.unavailable;

  BluetoothStateNotifier() {
    _init();
  }

  void _init() {
    try {
      _subscription = FlutterBluePlus.adapterState.listen(
        (state) {
          _adapterState = state;
          debugPrint('[BluetoothStateNotifier] Adapter state: $state');
          notifyListeners();
        },
        onError: (e) {
          debugPrint('[BluetoothStateNotifier] Adapter state error: $e');
        },
      );
    } catch (e) {
      debugPrint('[BluetoothStateNotifier] Platform not supported or mock: $e');
    }
  }

  Future<void> turnOn() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      debugPrint('[BluetoothStateNotifier] Failed to turn on Bluetooth: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
