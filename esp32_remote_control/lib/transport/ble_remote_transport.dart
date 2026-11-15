import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:protobuf/protobuf.dart';
import '../core/constants.dart';
import '../core/errors.dart';
import '../core/remote_transport.dart';
import '../generated/esp_remote.pb.dart';
import '../services/trace_log_service.dart';
import 'defragmenter.dart';
import 'request_encoder.dart';
import 'response_correlator.dart';

class BleRemoteTransport implements RemoteTransport {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _reqChar;
  BluetoothCharacteristic? _respChar;
  BluetoothCharacteristic? _metaChar;

  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _respSub;

  final Defragmenter _defragmenter = Defragmenter();
  final ResponseCorrelator _correlator = ResponseCorrelator();
  final StreamController<bool> _connectionStreamController = StreamController<bool>.broadcast();

  TraceLogService? traceLog;

  bool _isConnected = false;
  int _negotiatedMtu = BleConstants.defaultAttMtu;
  int _reqCounter = 1;
  int _outMsgId = 1;

  BleRemoteTransport({this.traceLog});

  @override
  bool get isConnected => _isConnected;

  @override
  int get negotiatedMtu => _negotiatedMtu;

  @override
  Stream<EventNotification> get eventStream => _correlator.eventStream;

  @override
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  BluetoothDevice? get device => _device;

  @override
  Future<void> connect(String deviceId) async {
    await disconnect();

    final device = BluetoothDevice.fromId(deviceId);
    _device = device;

    // Listen to connection state transitions
    _connSub = device.connectionState.listen((state) {
      final connected = (state == BluetoothConnectionState.connected);
      if (_isConnected != connected) {
        _isConnected = connected;
        if (!_connectionStreamController.isClosed) {
          _connectionStreamController.add(connected);
        }
      }
      if (!connected) {
        _handleDisconnect();
      }
    });

    // 1. Establish physical BLE connection
    traceLog?.logControl('CONNECT', 'Connecting to $deviceId...');
    await device.connect(
      autoConnect: false,
      timeout: const Duration(seconds: 15),
    );

    // 2. Request ATT MTU negotiation (Task 2.2)
    try {
      final mtu = await device.requestMtu(BleConstants.requestedMtu);
      _negotiatedMtu = mtu;
      traceLog?.logControl('MTU', 'Negotiated ATT MTU: $_negotiatedMtu B');
    } catch (e) {
      _negotiatedMtu = BleConstants.defaultAttMtu;
      traceLog?.logControl('MTU', 'MTU negotiation fallback: $_negotiatedMtu B ($e)');
    }

    // 3. Discover services and resolve characteristics (Task 2.1)
    final services = await device.discoverServices();
    BluetoothService? meshService;
    for (final s in services) {
      if (s.uuid == Guid(BleConstants.serviceUuid)) {
        meshService = s;
        break;
      }
    }

    if (meshService == null) {
      traceLog?.logError('GATT', 'Mesh service ${BleConstants.serviceUuid} not found');
      await disconnect();
      throw const RemoteTransportException('Primary mesh remote service not found on peripheral');
    }

    for (final c in meshService.characteristics) {
      if (c.uuid == Guid(BleConstants.charReqUuid)) {
        _reqChar = c;
      } else if (c.uuid == Guid(BleConstants.charRespUuid)) {
        _respChar = c;
      } else if (c.uuid == Guid(BleConstants.charMetaUuid)) {
        _metaChar = c;
      }
    }

    if (_reqChar == null || _respChar == null) {
      traceLog?.logError('GATT', 'Req or Resp characteristic missing');
      await disconnect();
      throw const RemoteTransportException('Required request/response GATT characteristics missing');
    }

    // 4. Subscribe to notifications on Response characteristic immediately
    await _respChar!.setNotifyValue(true);
    _respSub = _respChar!.onValueReceived.listen(_onFrameReceived);

    _isConnected = true;
    traceLog?.logControl('READY', 'GATT ready on $deviceId (MTU: $_negotiatedMtu B)');
    if (!_connectionStreamController.isClosed) {
      _connectionStreamController.add(true);
    }
  }

  void _onFrameReceived(List<int> frame) {
    traceLog?.logRx('FRAME', 'Frame rx (${frame.length} B)', frame);
    final assembled = _defragmenter.feed(frame);
    if (assembled != null) {
      traceLog?.logRx('PAYLOAD', 'Reassembled payload (${assembled.length} B)', assembled);
      _correlator.handleIncomingPayload(assembled);
    }
  }

  void _handleDisconnect() {
    traceLog?.logControl('DISCONN', 'Peripheral disconnected');
    _isConnected = false;
    _defragmenter.reset();
    _correlator.handleDisconnect();
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _handleDisconnect();

    try {
      await _respSub?.cancel();
      _respSub = null;
    } catch (_) {}

    try {
      await _connSub?.cancel();
      _connSub = null;
    } catch (_) {}

    try {
      if (_respChar != null) {
        await _respChar!.setNotifyValue(false);
      }
    } catch (_) {}

    try {
      await _device?.disconnect();
    } catch (_) {}

    _reqChar = null;
    _respChar = null;
    _metaChar = null;
    _device = null;
    _negotiatedMtu = BleConstants.defaultAttMtu;
    if (!_connectionStreamController.isClosed) {
      _connectionStreamController.add(false);
    }
  }

  @override
  Future<RemoteResponse> executeRequest({
    required RemoteOp op,
    GeneratedMessage? args,
    String? authToken,
    Duration timeout = BleConstants.defaultRequestTimeout,
  }) async {
    if (!_isConnected || _device == null || _reqChar == null) {
      throw const RemoteTransportException('BLE transport not connected');
    }

    final reqId = _reqCounter;
    _reqCounter = (_reqCounter + 1) & 0xFFFFFFFF;
    if (_reqCounter == 0) _reqCounter = 1;

    final request = buildRemoteRequest(
      requestId: reqId,
      op: op,
      args: args,
      authToken: authToken,
    );

    final rawBytes = request.writeToBuffer();

    // Determine MTU chunk size: 3-byte ATT header, max 240 bytes payload
    final maxFrameLen = max(20, min(_negotiatedMtu - 3, 240));
    final msgId = _outMsgId;
    _outMsgId = (_outMsgId + 1) & 0xFF;

    final frames = fragmentPayload(rawBytes, maxFrameLen, msgId);
    traceLog?.logTx(
      'SEND',
      'OP: ${op.name}, ReqId: $reqId, Frames: ${frames.length}, Bytes: ${rawBytes.length}',
      rawBytes,
    );

    // Register correlation future before transmitting frames
    final future = _correlator.registerRequest(
      requestId: reqId,
      op: op,
      timeout: timeout,
    );

    for (final frame in frames) {
      traceLog?.logTx('FRAME', 'Writing frame (${frame.length} B)', frame);
      await _reqChar!.write(frame, withoutResponse: true);
    }

    return await future;
  }

  @override
  Future<String> readMetadata() async {
    if (!_isConnected || _metaChar == null) {
      throw const RemoteTransportException('Transport not connected or metadata characteristic missing');
    }

    final rawBytes = await _metaChar!.read();
    return utf8.decode(rawBytes, allowMalformed: true);
  }

  void dispose() {
    disconnect();
    _correlator.dispose();
    _connectionStreamController.close();
  }
}
