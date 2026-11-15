import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:esp32_remote_control/core/remote_transport.dart';
import 'package:esp32_remote_control/generated/esp_remote.pb.dart';
import 'package:esp32_remote_control/transport/ble_scanner_service.dart';
import 'package:esp32_remote_control/vault/token_vault.dart';
import 'package:esp32_remote_control/viewmodels/node_session_viewmodel.dart';
import 'token_vault_test.dart';

class MockChurnTransport implements RemoteTransport {
  bool _connected = false;
  final _connController = StreamController<bool>.broadcast();
  final _eventController = StreamController<EventNotification>.broadcast();

  int queryCount = 0;
  int connectCount = 0;
  int disconnectCount = 0;

  @override
  bool get isConnected => _connected;

  @override
  int get negotiatedMtu => 255;

  @override
  Stream<bool> get connectionStream => _connController.stream;

  @override
  Stream<EventNotification> get eventStream => _eventController.stream;

  @override
  Future<void> connect(String deviceId) async {
    connectCount++;
    _connected = true;
    _connController.add(true);
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    _connected = false;
    _connController.add(false);
  }

  @override
  Future<RemoteResponse> executeRequest({
    required RemoteOp op,
    GeneratedMessage? args,
    String? authToken,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (op == RemoteOp.OP_HELLO) {
      return RemoteResponse()
        ..version = 1
        ..requestId = 1
        ..ok = true
        ..helloResult = (HelloResult()
          ..nodeAddress = 48
          ..nodeName = 'eNode-48'
          ..hwProfile = 1
          ..firmwareStamp = '6cfc7-4'
          ..protocolVersion = 1
          ..authToken = authToken ?? 'mock_token_48');
    } else if (op == RemoteOp.OP_NODE_STATUS) {
      queryCount++;
      return RemoteResponse()
        ..version = 1
        ..requestId = 2
        ..ok = true
        ..statusResult = (NodeStatusResult()
          ..runningSlot = 'Slot A'
          ..freeHeap = 263680 // 257.5 KiB
          ..minFreeHeap = 263475
          ..uptimeSeconds = 6000 + queryCount
          ..otaState = 'IDLE'
          ..meshOnline = true);
    }
    return RemoteResponse()
      ..version = 1
      ..requestId = 99
      ..ok = true;
  }

  @override
  Future<String> readMetadata() async => 'HW: XIAO ESP32-S3 | FW: 6cfc7-4';

  @override
  void dispose() {
    _connController.close();
    _eventController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Priority Gate P6 Qualification Tests', () {
    late MockChurnTransport transport;
    late TokenVault vault;
    late NodeSessionViewModel viewModel;

    setUp(() {
      transport = MockChurnTransport();
      vault = TokenVault(storage: FakeSecureStorage());
      viewModel = NodeSessionViewModel(transport: transport, vault: vault);
    });

    tearDown(() {
      viewModel.dispose();
      transport.dispose();
    });

    test('Task 6.1: runChurnTest executes multi-cycle connection, status, and disconnect', () async {
      final node = DiscoveredNode(
        device: BluetoothDevice.fromId('44:B1:76:AD:40:01'),
        name: 'eNode-48',
        rssi: -55,
        lastSeen: DateTime.now(),
      );

      // Pre-save token in vault
      await vault.saveToken('eNode-48', 'valid_token');

      // Initial connection
      await viewModel.connect(node);
      expect(viewModel.isConnected, isTrue);

      final progressEvents = <ChurnProgress>[];

      // Run 5 cycles for unit verification
      final result = await viewModel.runChurnTest(
        totalCycles: 5,
        interCycleDelay: Duration.zero,
        onProgress: (p) => progressEvents.add(p),
      );

      expect(result.totalCycles, equals(5));
      expect(result.successCycles, equals(5));
      expect(result.failCycles, equals(0));
      expect(result.nodeResets, equals(0));
      expect(result.heapDelta, equals(0));
      expect(result.heapStable, isTrue);
      expect(result.passed, isTrue);

      // Verify progress callbacks were made
      expect(progressEvents.isNotEmpty, isTrue);
      expect(progressEvents.last.currentCycle, equals(5));

      // Verify that after churn test finishes, ViewModel remains connected
      expect(viewModel.isConnected, isTrue);
      expect(viewModel.isChurnRunning, isFalse);
    });
  });
}
