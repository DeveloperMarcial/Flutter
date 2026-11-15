import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:esp32_remote_control/core/errors.dart';
import 'package:esp32_remote_control/core/remote_transport.dart';
import 'package:esp32_remote_control/generated/esp_remote.pb.dart';
import 'package:esp32_remote_control/transport/ble_scanner_service.dart';
import 'package:esp32_remote_control/vault/token_vault.dart';
import 'package:esp32_remote_control/viewmodels/node_session_viewmodel.dart';
import 'token_vault_test.dart';

class MockTransport implements RemoteTransport {
  bool _connected = false;
  final int _mtu = 255;
  RemoteOp? lastOp;
  GeneratedMessage? lastArgs;
  String? lastToken;

  final _connController = StreamController<bool>.broadcast();
  final _eventController = StreamController<EventNotification>.broadcast();

  Future<RemoteResponse> Function(RemoteOp op, GeneratedMessage? args, String? token)? handler;

  @override
  bool get isConnected => _connected;

  @override
  int get negotiatedMtu => _mtu;

  @override
  Stream<bool> get connectionStream => _connController.stream;

  @override
  Stream<EventNotification> get eventStream => _eventController.stream;

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
    GeneratedMessage? args,
    String? authToken,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    lastOp = op;
    lastArgs = args;
    lastToken = authToken;

    if (handler != null) {
      return await handler!(op, args, authToken);
    }

    return RemoteResponse()
      ..version = 1
      ..requestId = 1
      ..ok = true;
  }

  @override
  Future<String> readMetadata() async => 'eNode-49 FW:test';

  void emitEvent(EventNotification evt) {
    _eventController.add(evt);
  }
}

void main() {
  group('Priority Gate P4: Command Core & Functional Parity Tests', () {
    late MockTransport transport;
    late TokenVault vault;
    late NodeSessionViewModel vm;
    late DiscoveredNode node;

    setUp(() async {
      transport = MockTransport();
      vault = TokenVault(storage: FakeSecureStorage());
      await vault.saveToken('eNode-49', 'mock_token_1234');
      vm = NodeSessionViewModel(transport: transport, vault: vault);
      node = DiscoveredNode(
        device: BluetoothDevice.fromId('44:B1:76:AD:2B:AD'),
        name: 'eNode-49',
        rssi: -50,
        lastSeen: DateTime.now(),
      );

      // Connect with mocked HELLO success
      transport.handler = (op, args, token) async {
        return RemoteResponse()
          ..version = 1
          ..requestId = 1
          ..ok = true
          ..helloResult = (HelloResult()
            ..nodeAddress = 49
            ..nodeName = 'node-49'
            ..hwProfile = 1
            ..firmwareStamp = '6cfc7-4'
            ..protocolVersion = 1
            ..authToken = 'mock_token_1234');
      };
      await vm.connect(node);
      expect(vm.isAuthenticated, isTrue);
    });

    test('Task 4.1: getHello() queries capabilities and metadata', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_HELLO));
        expect(token, equals('mock_token_1234'));
        return RemoteResponse()
          ..version = 1
          ..requestId = 2
          ..ok = true
          ..helloResult = (HelloResult()
            ..nodeAddress = 49
            ..nodeName = 'node-49'
            ..hwProfile = 1
            ..firmwareStamp = 'v1.4.0'
            ..protocolVersion = 1);
      };

      final hello = await vm.getHello();
      expect(hello.nodeAddress, equals(49));
      expect(hello.nodeName, equals('node-49'));
      expect(hello.hwProfile, equals(1));
      expect(hello.firmwareStamp, equals('v1.4.0'));
      expect(vm.helloResult?.nodeAddress, equals(49));
    });

    test('Task 4.2: getStatus() queries runtime telemetry and diagnostics', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_NODE_STATUS));
        expect(args, isA<NodeStatusArgs>());
        return RemoteResponse()
          ..version = 1
          ..requestId = 3
          ..ok = true
          ..statusResult = (NodeStatusResult()
            ..uptimeSeconds = 3600
            ..freeHeap = 264000
            ..minFreeHeap = 250000
            ..runningSlot = 'Slot A'
            ..otaState = 'IDLE'
            ..ownerMasterId = 42
            ..meshOnline = true);
      };

      final status = await vm.getStatus();
      expect(status.uptimeSeconds, equals(3600));
      expect(status.freeHeap, equals(264000));
      expect(status.minFreeHeap, equals(250000));
      expect(status.runningSlot, equals('Slot A'));
      expect(status.otaState, equals('IDLE'));
      expect(status.ownerMasterId, equals(42));
      expect(status.meshOnline, isTrue);
      expect(vm.statusResult?.freeHeap, equals(264000));
    });

    test('Task 4.3: getPeers() queries peer roster', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_PEER_ROSTER));
        expect(args, isA<PeerRosterArgs>());
        return RemoteResponse()
          ..version = 1
          ..requestId = 4
          ..ok = true
          ..rosterResult = (PeerRosterResult()
            ..peers.addAll([
              PeerInfo()..address = 42..name = 'Master 42'..lastHeardSec = 5,
              PeerInfo()..address = 43..name = 'Master 43'..lastHeardSec = 1,
              PeerInfo()..address = 48..name = 'node-48'..lastHeardSec = 12,
            ]));
      };

      final peers = await vm.getPeers();
      expect(peers.length, equals(3));
      expect(peers[0].address, equals(42));
      expect(peers[1].address, equals(43));
      expect(peers[2].name, equals('node-48'));
      expect(vm.peers.length, equals(3));
    });

    test('Task 4.4: getGnss() queries GNSS fix status and telemetry', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_GNSS_GET));
        expect(args, isA<GnssGetArgs>());
        return RemoteResponse()
          ..version = 1
          ..requestId = 5
          ..ok = true
          ..gnssResult = (GnssGetResult()
            ..fixValid = false
            ..fixAgeMs = 0
            ..satellitesUsed = 0);
      };

      final gnss = await vm.getGnss();
      expect(gnss.fixValid, isFalse);
      expect(gnss.satellitesUsed, equals(0));
      expect(vm.gnssResult?.fixValid, isFalse);
    });

    test('Task 4.5: getRoutes() queries routing table', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_ROUTES_GET));
        expect(args, isA<RoutesGetArgs>());
        return RemoteResponse()
          ..version = 1
          ..requestId = 6
          ..ok = true
          ..routesResult = (RoutesGetResult()
            ..routes.addAll([
              RouteInfo()..destAddress = 42..nextHop = 42..state = 1,
              RouteInfo()..destAddress = 43..nextHop = 43..state = 1,
            ]));
      };

      final routes = await vm.getRoutes();
      expect(routes.length, equals(2));
      expect(routes[0].destAddress, equals(42));
      expect(routes[1].nextHop, equals(43));
      expect(vm.routes.length, equals(2));
    });

    test('Task 4.5: ping() executes mesh ping with RTT reporting', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_PING));
        expect(args, isA<PingArgs>());
        expect((args as PingArgs).targetAddress, equals(43));
        return RemoteResponse()
          ..version = 1
          ..requestId = 7
          ..ok = true
          ..pingResult = (PingResult()
            ..targetAddress = 43
            ..rttMs = 180
            ..success = true);
      };

      final pingRes = await vm.ping(43);
      expect(pingRes.targetAddress, equals(43));
      expect(pingRes.rttMs, equals(180));
      expect(pingRes.success, isTrue);
      expect(vm.lastPingResult?.rttMs, equals(180));
    });

    test('Task 4.6: sendMessage() transmits authenticated mesh message', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_MESSAGE_SEND));
        expect(args, isA<MessageSendArgs>());
        final msgArgs = args as MessageSendArgs;
        expect(msgArgs.destAddress, equals(43));
        expect(msgArgs.text, equals('Hello from Flutter Mobile'));
        return RemoteResponse()
          ..version = 1
          ..requestId = 8
          ..ok = true
          ..messageSendResult = (MessageSendResult()
            ..destAddress = 43
            ..messageId = 1
            ..enqueued = true);
      };

      final sendRes = await vm.sendMessage(43, 'Hello from Flutter Mobile');
      expect(sendRes.destAddress, equals(43));
      expect(sendRes.messageId, equals(1));
      expect(sendRes.enqueued, isTrue);
      expect(vm.lastSendResult?.messageId, equals(1));
    });

    test('Task 4.7: subscribeEvents() sends subscription and collects push events', () async {
      transport.handler = (op, args, token) async {
        expect(op, equals(RemoteOp.OP_EVENT_SUB));
        expect(args, isA<EventSubArgs>());
        final subArgs = args as EventSubArgs;
        expect(subArgs.subscribeMessages, isTrue);
        expect(subArgs.subscribeTelemetry, isTrue);
        expect(subArgs.subscribeStatus, isTrue);
        return RemoteResponse()
          ..version = 1
          ..requestId = 9
          ..ok = true;
      };

      await vm.subscribeEvents();

      // Simulate unsolicited mesh push event
      transport.emitEvent(
        EventNotification()
          ..eventType = EventNotification_EventType.EVT_MESSAGE_RX
          ..fromAddress = 43
          ..payloadText = 'Alert: battery low',
      );

      // Allow microtasks to process
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(vm.recentEvents.length, equals(1));
      expect(vm.recentEvents.first.fromAddress, equals(43));
      expect(vm.recentEvents.first.payloadText, equals('Alert: battery low'));
      expect(vm.recentEvents.first.eventType, equals(EventNotification_EventType.EVT_MESSAGE_RX));
    });

    test('Error handling: RemoteTransportException thrown on non-ok response', () async {
      transport.handler = (op, args, token) async {
        return RemoteResponse()
          ..version = 1
          ..requestId = 10
          ..ok = false
          ..errorCode = 'timeout: peer_unreachable';
      };

      await expectLater(
        vm.ping(99),
        throwsA(isA<RemoteTransportException>().having(
          (e) => e.message,
          'message',
          contains('timeout: peer_unreachable'),
        )),
      );
      expect(vm.lastError, contains('timeout: peer_unreachable'));
    });
  });
}
