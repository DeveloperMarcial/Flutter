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

class MockRemoteTransport implements RemoteTransport {
  bool _connected = false;
  final int _mtu = 255;
  String? lastAuthTokenSent;
  RemoteOp? lastOpSent;

  final _connController = StreamController<bool>.broadcast();
  final _eventController = StreamController<EventNotification>.broadcast();

  // Configurable response handler
  Future<RemoteResponse> Function({
    required RemoteOp op,
    GeneratedMessage? args,
    String? authToken,
    Duration timeout,
  })? onExecuteRequest;

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
    lastOpSent = op;
    lastAuthTokenSent = authToken;

    if (onExecuteRequest != null) {
      return await onExecuteRequest!(
        op: op,
        args: args,
        authToken: authToken,
        timeout: timeout,
      );
    }

    return RemoteResponse()
      ..version = 1
      ..requestId = 1
      ..ok = true;
  }

  @override
  Future<String> readMetadata() async {
    return 'eNode-48 FW:6cfc7-4';
  }
}

void main() {
  group('NodeSessionViewModel Enrollment, Persistence & Auth Tests', () {
    late MockRemoteTransport transport;
    late TokenVault vault;
    late NodeSessionViewModel viewModel;
    late DiscoveredNode testNode;

    setUp(() {
      transport = MockRemoteTransport();
      vault = TokenVault(storage: FakeSecureStorage());
      viewModel = NodeSessionViewModel(transport: transport, vault: vault);
      testNode = DiscoveredNode(
        device: BluetoothDevice.fromId('44:B1:76:AD:40:01'),
        name: 'eNode-48',
        rssi: -58,
        lastSeen: DateTime.now(),
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('Task 3.2: Headless PIN enrollment succeeds and persists token in vault', () async {
      await transport.connect(testNode.id);
      // Attach current node to viewModel
      transport.onExecuteRequest = ({
        required RemoteOp op,
        GeneratedMessage? args,
        String? authToken,
        Duration timeout = const Duration(seconds: 8),
      }) async {
        if (op == RemoteOp.OP_HELLO && authToken == '123456') {
          return RemoteResponse()
            ..version = 1
            ..requestId = 1
            ..ok = true
            ..helloResult = (HelloResult()
              ..nodeAddress = 48
              ..nodeName = 'node-48'
              ..authToken = 'tok_deadbeef12345678');
        }
        return RemoteResponse()..ok = false..errorCode = 'invalid_pin';
      };

      await viewModel.connect(testNode);

      // Verify before enroll: unauthenticated
      expect(viewModel.isAuthenticated, isFalse);

      // Perform PIN enrollment
      final result = await viewModel.enroll('123456');
      expect(result.authToken, equals('tok_deadbeef12345678'));
      expect(viewModel.isAuthenticated, isTrue);

      // Verify token persisted in TokenVault
      expect(await vault.getToken('eNode-48'), equals('tok_deadbeef12345678'));
      expect(await vault.getToken('44:B1:76:AD:40:01'), equals('tok_deadbeef12345678'));
    });

    test('Task 3.3: Reconnect automatically retrieves token from vault and injects into requests', () async {
      // Pre-populate vault with saved token from previous enrollment
      await vault.saveToken('eNode-48', 'saved_token_xyz999');

      transport.onExecuteRequest = ({
        required RemoteOp op,
        GeneratedMessage? args,
        String? authToken,
        Duration timeout = const Duration(seconds: 8),
      }) async {
        if (op == RemoteOp.OP_HELLO && authToken == 'saved_token_xyz999') {
          return RemoteResponse()
            ..version = 1
            ..requestId = 2
            ..ok = true
            ..helloResult = (HelloResult()
              ..nodeAddress = 48
              ..nodeName = 'node-48'
              ..authToken = 'saved_token_xyz999');
        }
        return RemoteResponse()..ok = false..errorCode = 'unauthorized';
      };

      // Connect to node
      await viewModel.connect(testNode);

      // Verify auto-authentication succeeded without re-entering PIN
      expect(transport.lastAuthTokenSent, equals('saved_token_xyz999'));
      expect(viewModel.isAuthenticated, isTrue);

      // Execute subsequent request (e.g. OP_NODE_STATUS)
      transport.onExecuteRequest = ({
        required RemoteOp op,
        GeneratedMessage? args,
        String? authToken,
        Duration timeout = const Duration(seconds: 8),
      }) async {
        return RemoteResponse()
          ..version = 1
          ..requestId = 3
          ..ok = true
          ..statusResult = (NodeStatusResult()..freeHeap = 45000);
      };

      final statusResp = await viewModel.executeRequest(op: RemoteOp.OP_NODE_STATUS);
      expect(statusResp.ok, isTrue);
      expect(transport.lastAuthTokenSent, equals('saved_token_xyz999'));
    });

    test('Task 3.4: Unauthorized response throws UnauthorizedException and resets auth state', () async {
      await vault.saveToken('eNode-48', 'revoked_token_123');

      transport.onExecuteRequest = ({
        required RemoteOp op,
        GeneratedMessage? args,
        String? authToken,
        Duration timeout = const Duration(seconds: 8),
      }) async {
        // Node rejects old/revoked token
        return RemoteResponse()
          ..version = 1
          ..requestId = 5
          ..ok = false
          ..errorCode = 'unauthorized';
      };

      await viewModel.connect(testNode);
      expect(viewModel.isAuthenticated, isFalse);

      // Attempting an authenticated request throws UnauthorizedException
      expect(
        viewModel.executeRequest(op: RemoteOp.OP_NODE_STATUS),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
