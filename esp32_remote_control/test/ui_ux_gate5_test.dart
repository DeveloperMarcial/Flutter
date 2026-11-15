import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp32_remote_control/core/remote_transport.dart';
import 'package:esp32_remote_control/generated/esp_remote.pb.dart';
import 'package:esp32_remote_control/services/trace_log_service.dart';
import 'package:esp32_remote_control/transport/ble_scanner_service.dart';
import 'package:esp32_remote_control/vault/token_vault.dart';
import 'package:esp32_remote_control/viewmodels/node_session_viewmodel.dart';
import 'token_vault_test.dart';

class MockGate5Transport implements RemoteTransport {
  bool _connected = false;
  final StreamController<bool> _connController = StreamController<bool>.broadcast();
  final StreamController<EventNotification> _eventController = StreamController<EventNotification>.broadcast();

  @override
  bool get isConnected => _connected;

  @override
  int get negotiatedMtu => 255;

  @override
  Stream<bool> get connectionStream => _connController.stream;

  @override
  Stream<EventNotification> get eventStream => _eventController.stream;

  void emitEvent(EventNotification evt) {
    _eventController.add(evt);
  }

  @override
  Future<void> connect(String deviceId) async {
    _connected = true;
    _connController.add(true);
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _connController.add(false);
  }

  @override
  Future<RemoteResponse> executeRequest({
    required RemoteOp op,
    dynamic args,
    String? authToken,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (op == RemoteOp.OP_HELLO) {
      return RemoteResponse(
        ok: true,
        helloResult: HelloResult(
          nodeAddress: 49,
          nodeName: 'eNode-49',
          hwProfile: 1,
          firmwareStamp: 'esp32_rx_tx_node_ble',
          authToken: 'valid_token_123',
        ),
      );
    }
    if (op == RemoteOp.OP_MESSAGE_SEND) {
      return RemoteResponse(
        ok: true,
        messageSendResult: MessageSendResult(
          enqueued: true,
          messageId: 42,
        ),
      );
    }
    if (op == RemoteOp.OP_NODE_STATUS) {
      return RemoteResponse(
        ok: true,
        statusResult: NodeStatusResult(
          runningSlot: 'slot_a',
          uptimeSeconds: 3665,
          freeHeap: 245760,
          minFreeHeap: 210000,
          meshOnline: true,
          otaState: 'idle',
        ),
      );
    }
    if (op == RemoteOp.OP_PING) {
      return RemoteResponse(
        ok: true,
        pingResult: PingResult(
          targetAddress: (args as PingArgs).targetAddress,
          rttMs: 145,
        ),
      );
    }
    return RemoteResponse(ok: true);
  }

  @override
  Future<String> readMetadata() async => 'node_type=mesh;version=1.0';
}

void main() {
  group('Priority Gate P5: UI/UX & Live Trace Service Tests', () {
    test('Task 5.5: TraceLogService logs color-coded entries and formats timestamps', () {
      final traceService = TraceLogService();

      traceService.logRx('PACKET', 'Incoming data', [0xAA, 0xBB]);
      traceService.logTx('COMMAND', 'Outgoing request', [0x01, 0x02]);
      traceService.logControl('CONNECT', 'Connected to peripheral');
      traceService.logError('TIMEOUT', 'Frame timed out');

      expect(traceService.totalCount, equals(4));

      final rx = traceService.entries[0];
      expect(rx.direction, equals(TraceDirection.rx));
      expect(rx.directionLabel, equals('[BLE RX]'));
      expect(rx.color.toARGB32(), equals(0xFF00E5FF)); // Cyan
      expect(rx.toClipboardString(), contains('[BLE RX] PACKET: Incoming data | HEX: aa bb'));

      final tx = traceService.entries[1];
      expect(tx.direction, equals(TraceDirection.tx));
      expect(tx.directionLabel, equals('[BLE TX]'));
      expect(tx.color.toARGB32(), equals(0xFF69F0AE)); // Light Green

      final ctrl = traceService.entries[2];
      expect(ctrl.direction, equals(TraceDirection.control));
      expect(ctrl.directionLabel, equals('[BLE CTRL]'));
      expect(ctrl.color.toARGB32(), equals(0xFFFFD740)); // Yellow

      final err = traceService.entries[3];
      expect(err.direction, equals(TraceDirection.error));
      expect(err.directionLabel, equals('[ERR]'));
      expect(err.color.toARGB32(), equals(0xFFFF5252)); // Red
    });

    test('Task 5.5: TraceLogService filter by direction and clear operations', () {
      final traceService = TraceLogService();
      traceService.logRx('RX', 'Msg 1');
      traceService.logTx('TX', 'Msg 2');
      traceService.logRx('RX', 'Msg 3');

      expect(traceService.entries.length, equals(3));

      traceService.setFilter(TraceDirection.rx);
      expect(traceService.entries.length, equals(2));
      expect(traceService.entries.every((e) => e.direction == TraceDirection.rx), isTrue);

      traceService.setFilter(null); // Reset filter
      expect(traceService.entries.length, equals(3));

      traceService.clear();
      expect(traceService.totalCount, equals(0));
    });

    test('Task 5.5: TraceLogService loggingEnabled toggle pauses and resumes log capture', () {
      final traceService = TraceLogService();
      expect(traceService.loggingEnabled, isTrue);

      traceService.logRx('RX', 'Before disable');
      expect(traceService.entries.length, equals(1));

      traceService.setLoggingEnabled(false);
      expect(traceService.loggingEnabled, isFalse);

      traceService.logTx('TX', 'While disabled');
      traceService.logControl('CTRL', 'While disabled');
      traceService.logError('ERR', 'While disabled');
      expect(traceService.entries.length, equals(1)); // No new logs captured

      traceService.setLoggingEnabled(true);
      expect(traceService.loggingEnabled, isTrue);

      traceService.logTx('TX', 'After re-enable');
      expect(traceService.entries.length, equals(2));
      expect(traceService.entries.last.message, equals('After re-enable'));
    });

    test('Task 5.5: TraceLogService initializes logfile on disk, writes entries, and exposes path', () async {
      final tempDir = await Directory.systemTemp.createTemp('trace_test_');
      final traceService = TraceLogService(customLogDir: tempDir);
      await traceService.ensureInitialized();

      expect(traceService.currentLogFilePath, isNotNull);
      expect(traceService.currentLogFileName, isNotNull);
      expect(traceService.currentLogFileName, startsWith('esp_trace_'));
      expect(traceService.currentLogFileName, endsWith('.log'));

      traceService.logRx('RX_TEST', 'Testing disk log write');
      await traceService.flush();

      final file = File(traceService.currentLogFilePath!);
      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(content, contains('=== ESP32 BLE Mesh Remote Trace Log Session ==='));
      expect(content, contains('[BLE RX] RX_TEST: Testing disk log write'));

      await traceService.setLoggingEnabled(false);
      final pausedContent = await file.readAsString();
      expect(pausedContent, contains('[LOGGING PAUSED:'));

      traceService.dispose();
      await tempDir.delete(recursive: true);
    });

    DiscoveredNode createTestNode() => DiscoveredNode(
          device: BluetoothDevice.fromId('44:B1:76:AD:2B:AD'),
          name: 'eNode-49',
          rssi: -50,
          lastSeen: DateTime.now(),
        );

    test('Task 5.4: Mesh Chat outgoing message tracks sending and delivered status with msgId', () async {
      final transport = MockGate5Transport();
      final vault = TokenVault(storage: FakeSecureStorage());
      final traceService = TraceLogService();

      final vm = NodeSessionViewModel(
        transport: transport,
        vault: vault,
        traceLog: traceService,
      );

      await vm.connect(createTestNode());

      final sendFuture = vm.sendMessage(43, 'Hello from automated Gate 5 test');
      expect(vm.chatMessages.length, equals(1));
      expect(vm.chatMessages.first.text, equals('Hello from automated Gate 5 test'));
      expect(vm.chatMessages.first.isOutgoing, isTrue);

      await sendFuture;

      expect(vm.chatMessages.first.status, equals(ChatMessageStatus.delivered));
      expect(vm.chatMessages.first.msgId, equals(42));
      expect(traceService.entries.any((e) => e.tag == 'ACK' && e.message.contains('42')), isTrue);
    });

    test('Task 5.4: Incoming EVT_MESSAGE_RX event automatically populates Chat history', () async {
      final transport = MockGate5Transport();
      final vault = TokenVault(storage: FakeSecureStorage());
      final traceService = TraceLogService();

      final vm = NodeSessionViewModel(
        transport: transport,
        vault: vault,
        traceLog: traceService,
      );

      await vm.connect(createTestNode());

      transport.emitEvent(
        EventNotification(
          eventType: EventNotification_EventType.EVT_MESSAGE_RX,
          fromAddress: 43,
          payloadText: 'Live incoming RF alert from Master 43',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(vm.chatMessages.length, equals(1));
      final msg = vm.chatMessages.first;
      expect(msg.isOutgoing, isFalse);
      expect(msg.fromAddress, equals(43));
      expect(msg.text, equals('Live incoming RF alert from Master 43'));
      expect(msg.status, equals(ChatMessageStatus.delivered));
    });

    test('Task 5.3: Peer ping records latency in peerPingRttMs table', () async {
      final transport = MockGate5Transport();
      final vault = TokenVault(storage: FakeSecureStorage());
      final traceService = TraceLogService();

      final vm = NodeSessionViewModel(
        transport: transport,
        vault: vault,
        traceLog: traceService,
      );

      await vm.connect(createTestNode());

      final rtt = await vm.pingPeer(43);
      expect(rtt, equals(145));
      expect(vm.peerPingRttMs[43], equals(145));
      expect(traceService.entries.any((e) => e.tag == 'PING' && e.message.contains('145 ms')), isTrue);
    });

    test('Metadata Sync: formatDashboardMetadataSummary matches dashboard fields and updates logfile header', () async {
      final tempDir = await Directory.systemTemp.createTemp('trace_meta_test_');
      final transport = MockGate5Transport();
      final vault = TokenVault(storage: FakeSecureStorage());
      final traceService = TraceLogService(customLogDir: tempDir);
      await traceService.ensureInitialized();

      final vm = NodeSessionViewModel(
        transport: transport,
        vault: vault,
        traceLog: traceService,
      );

      // Log an entry before connecting
      traceService.logControl('INIT', 'App started, awaiting connection');
      await traceService.flush();

      // Connect to node and query status
      await vm.connect(createTestNode());
      await vm.getStatus();

      // Verify metadata string contains all dashboard fields
      final summary = vm.formatDashboardMetadataSummary(logFileName: traceService.currentLogFileName);
      expect(summary, contains('Target Node: eNode-49 (Address: 49)'));
      expect(summary, contains('Active Slot: Slot A | Mesh Status: MESH ONLINE'));
      expect(summary, contains('Hardware Profile: XIAO ESP32-S3 (1)'));
      expect(summary, contains('Firmware Stamp: esp32_rx_tx_node_ble'));
      expect(summary, contains('ATT MTU: 255 Bytes'));
      expect(summary, contains('BLE Channel: Connected'));
      expect(summary, contains('Uptime: 1h 1m 5s (3665 s)'));
      expect(summary, contains('Continuous Free Heap: 240.0 KiB / 320 KiB (75%)'));
      expect(summary, contains('Min Heap Watermark: 205.1 KiB (64%)'));
      expect(summary, contains('OTA State: IDLE'));

      // Check that the disk logfile header was automatically updated on disk
      await traceService.flush();
      final file = File(traceService.currentLogFilePath!);
      expect(await file.exists(), isTrue);
      final logContent = await file.readAsString();

      expect(logContent, contains('=== ESP32 BLE Mesh Remote Trace Log Session ==='));
      expect(logContent, contains('--- Target Node Telemetry & Diagnostics ---'));
      expect(logContent, contains('Target Node: eNode-49 (Address: 49)'));
      expect(logContent, contains('Active Slot: Slot A | Mesh Status: MESH ONLINE'));
      expect(logContent, contains('Continuous Free Heap: 240.0 KiB / 320 KiB (75%)'));
      // Verify existing log entries were preserved after header rewrite
      expect(logContent, contains('[BLE CTRL] INIT: App started, awaiting connection'));

      traceService.dispose();
      await tempDir.delete(recursive: true);
    });
  });
}
