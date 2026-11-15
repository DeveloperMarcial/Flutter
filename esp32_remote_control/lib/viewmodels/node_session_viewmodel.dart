import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';
import '../core/constants.dart';
import '../core/errors.dart';
import '../core/remote_transport.dart';
import '../generated/esp_remote.pb.dart';
import '../services/trace_log_service.dart';
import '../transport/ble_scanner_service.dart';
import '../vault/token_vault.dart';

enum ChatMessageStatus {
  sending,
  delivered,
  failed,
  uncertain,
}

class ChatMessage {
  final String id;
  final int fromAddress;
  final int toAddress;
  final String text;
  final DateTime timestamp;
  final bool isOutgoing;
  ChatMessageStatus status;
  int? msgId;
  String? error;

  ChatMessage({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.text,
    required this.timestamp,
    required this.isOutgoing,
    this.status = ChatMessageStatus.sending,
    this.msgId,
    this.error,
  });
}

class NodeSessionViewModel extends ChangeNotifier {
  final RemoteTransport _transport;
  final TokenVault _vault;
  TraceLogService? traceLog;

  DiscoveredNode? _currentNode;
  HelloResult? _helloResult;
  NodeStatusResult? _statusResult;
  List<PeerInfo> _peers = [];
  GnssGetResult? _gnssResult;
  List<RouteInfo> _routes = [];
  PingResult? _lastPingResult;
  MessageSendResult? _lastSendResult;
  String? _metadata;
  bool _isConnecting = false;
  bool _isExecutingCommand = false;
  bool _isAuthenticated = false;
  String? _activeToken;
  String? _lastError;

  final Map<int, int?> _peerPingRttMs = {};
  final List<ChatMessage> _chatMessages = [];

  StreamSubscription<bool>? _connSub;
  StreamSubscription<EventNotification>? _eventSub;
  final List<EventNotification> _recentEvents = [];

  NodeSessionViewModel({
    required RemoteTransport transport,
    required TokenVault vault,
    this.traceLog,
  })  : _transport = transport,
        _vault = vault {
    _connSub = _transport.connectionStream.listen(_onConnectionChanged);
    _eventSub = _transport.eventStream.listen(_onEventReceived);
    if (traceLog != null) {
      traceLog!.metadataProvider = () => formatDashboardMetadataSummary();
    }
  }

  bool get isConnected => _transport.isConnected;
  bool get isConnecting => _isConnecting;
  bool get isExecutingCommand => _isExecutingCommand;
  bool get isAuthenticated => _isAuthenticated;
  int get negotiatedMtu => _transport.negotiatedMtu;
  DiscoveredNode? get currentNode => _currentNode;
  HelloResult? get helloResult => _helloResult;
  NodeStatusResult? get statusResult => _statusResult;
  List<PeerInfo> get peers => List.unmodifiable(_peers);
  GnssGetResult? get gnssResult => _gnssResult;
  List<RouteInfo> get routes => List.unmodifiable(_routes);
  PingResult? get lastPingResult => _lastPingResult;
  MessageSendResult? get lastSendResult => _lastSendResult;
  String? get metadata => _metadata;
  String? get lastError => _lastError;
  List<EventNotification> get recentEvents => List.unmodifiable(_recentEvents);
  Map<int, int?> get peerPingRttMs => Map.unmodifiable(_peerPingRttMs);
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);

  void _onConnectionChanged(bool connected) {
    if (!connected) {
      _isAuthenticated = false;
      _helloResult = null;
      _statusResult = null;
      _peers = [];
      _gnssResult = null;
      _routes = [];
      _lastPingResult = null;
      _lastSendResult = null;
      _isExecutingCommand = false;
      _syncTraceMetadata();
    }
    notifyListeners();
  }

  void _onEventReceived(EventNotification evt) {
    _recentEvents.insert(0, evt);
    if (_recentEvents.length > 50) {
      _recentEvents.removeLast();
    }
    traceLog?.logRx(
      'EVENT',
      'Evt ${evt.eventType.name} from Node ${evt.fromAddress}: "${evt.payloadText}"',
    );

    if (evt.eventType == EventNotification_EventType.EVT_MESSAGE_RX) {
      _chatMessages.add(
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          fromAddress: evt.fromAddress,
          toAddress: _helloResult?.nodeAddress ?? 0,
          text: evt.payloadText,
          timestamp: DateTime.now(),
          isOutgoing: false,
          status: ChatMessageStatus.delivered,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> connect(DiscoveredNode node) async {
    _isConnecting = true;
    _lastError = null;
    _currentNode = node;
    notifyListeners();

    try {
      await _transport.connect(node.id);

      // Read metadata characteristic
      try {
        _metadata = await _transport.readMetadata();
      } catch (e) {
        _metadata = 'Metadata read unavailable: $e';
      }

      // Check for saved token in TokenVault (Task 3.3)
      final storedToken = await _vault.getToken(node.name) ??
          await _vault.getToken(node.id);
      _activeToken = storedToken;

      // Execute OP_HELLO with saved token (or unauthenticated if no token)
      try {
        final helloResp = await _transport.executeRequest(
          op: RemoteOp.OP_HELLO,
          authToken: storedToken,
          timeout: const Duration(seconds: 8),
        );

        if (helloResp.ok && helloResp.hasHelloResult()) {
          _helloResult = helloResp.helloResult;
          _isAuthenticated = helloResp.helloResult.authToken.isNotEmpty;
        } else {
          _isAuthenticated = false;
        }
      } catch (e) {
        _isAuthenticated = false;
        debugPrint('[NodeSessionViewModel] Initial HELLO failed: $e');
      }

      await _syncTraceMetadata();

      _isConnecting = false;
      notifyListeners();
    } catch (e) {
      _isConnecting = false;
      _currentNode = null;
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await _transport.disconnect();
    _currentNode = null;
    _helloResult = null;
    _statusResult = null;
    _peers = [];
    _gnssResult = null;
    _routes = [];
    _lastPingResult = null;
    _lastSendResult = null;
    _metadata = null;
    _isAuthenticated = false;
    _isExecutingCommand = false;
    _activeToken = null;
    notifyListeners();
    await _syncTraceMetadata();
  }

  /// Headless PIN enrollment (Task 3.2)
  Future<HelloResult> enroll(String pin) async {
    final cleanPin = pin.trim();
    if (_currentNode == null || !_transport.isConnected) {
      throw const RemoteTransportException('Cannot enroll: transport not connected');
    }

    try {
      final resp = await _transport.executeRequest(
        op: RemoteOp.OP_HELLO,
        authToken: cleanPin,
        timeout: const Duration(seconds: 8),
      );

      if (!resp.ok) {
        throw RemoteTransportException('Enrollment rejected: ${resp.errorCode}');
      }

      if (!resp.hasHelloResult() || resp.helloResult.authToken.isEmpty) {
        throw const RemoteTransportException('Enrollment failed: node returned no token');
      }

      final issuedToken = resp.helloResult.authToken;
      _activeToken = issuedToken;
      _helloResult = resp.helloResult;
      _isAuthenticated = true;

      // Persist token in secure storage under node name and MAC id
      final nodeName = _currentNode!.name;
      await _vault.saveToken(nodeName, issuedToken);
      await _vault.saveToken(_currentNode!.id, issuedToken);

      final address = resp.helloResult.nodeAddress;
      if (address > 0) {
        await _vault.saveToken('eNode-$address', issuedToken);
      }

      await _syncTraceMetadata();
      notifyListeners();
      return resp.helloResult;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Execute an authenticated request with automatic token injection (Task 3.3 & 3.4)
  Future<RemoteResponse> executeRequest({
    required RemoteOp op,
    GeneratedMessage? args,
    Duration timeout = BleConstants.defaultRequestTimeout,
  }) async {
    if (!isConnected || _currentNode == null) {
      throw const RemoteTransportException('Transport not connected');
    }

    // Automatic token retrieval if not already in memory
    String? token = _activeToken;
    if (token == null || token.isEmpty) {
      token = await _vault.getToken(_currentNode!.name) ??
          await _vault.getToken(_currentNode!.id);
      _activeToken = token;
    }

    final resp = await _transport.executeRequest(
      op: op,
      args: args,
      authToken: token,
      timeout: timeout,
    );

    // Task 3.4: Unauthorized rejection detection
    if (!resp.ok && resp.errorCode.toLowerCase() == 'unauthorized') {
      _isAuthenticated = false;
      notifyListeners();
      throw const UnauthorizedException();
    }

    return resp;
  }

  /// Task 4.1: Query node hello / capabilities
  Future<HelloResult> getHello() async {
    _isExecutingCommand = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await executeRequest(op: RemoteOp.OP_HELLO);
      if (!resp.ok) {
        throw RemoteTransportException('HELLO failed: ${resp.errorCode}');
      }
      _helloResult = resp.helloResult;
      return resp.helloResult;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  /// Task 4.2: Query node status and diagnostics
  Future<NodeStatusResult> getStatus() async {
    _isExecutingCommand = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await executeRequest(
        op: RemoteOp.OP_NODE_STATUS,
        args: NodeStatusArgs(),
      );
      if (!resp.ok) {
        throw RemoteTransportException('NODE_STATUS failed: ${resp.errorCode}');
      }
      _statusResult = resp.statusResult;
      await _syncTraceMetadata();
      return resp.statusResult;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  /// Task 4.3: Query active peer roster
  Future<List<PeerInfo>> getPeers() async {
    _isExecutingCommand = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await executeRequest(
        op: RemoteOp.OP_PEER_ROSTER,
        args: PeerRosterArgs(),
      );
      if (!resp.ok) {
        throw RemoteTransportException('PEER_ROSTER failed: ${resp.errorCode}');
      }
      _peers = List.from(resp.rosterResult.peers);
      return _peers;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  /// Task 4.4: Query GNSS telemetry
  Future<GnssGetResult> getGnss() async {
    _isExecutingCommand = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await executeRequest(
        op: RemoteOp.OP_GNSS_GET,
        args: GnssGetArgs(),
      );
      if (!resp.ok) {
        throw RemoteTransportException('GNSS_GET failed: ${resp.errorCode}');
      }
      _gnssResult = resp.gnssResult;
      return resp.gnssResult;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  /// Task 4.5: Query mesh routing table
  Future<List<RouteInfo>> getRoutes() async {
    _isExecutingCommand = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await executeRequest(
        op: RemoteOp.OP_ROUTES_GET,
        args: RoutesGetArgs(),
      );
      if (!resp.ok) {
        throw RemoteTransportException('ROUTES_GET failed: ${resp.errorCode}');
      }
      _routes = List.from(resp.routesResult.routes);
      return _routes;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  /// Task 4.5: Execute mesh ping to target address
  Future<PingResult> ping(int targetAddress, {Duration timeout = const Duration(seconds: 12)}) async {
    _isExecutingCommand = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await executeRequest(
        op: RemoteOp.OP_PING,
        args: PingArgs(targetAddress: targetAddress),
        timeout: timeout,
      );
      if (!resp.ok) {
        throw RemoteTransportException('PING failed: ${resp.errorCode}');
      }
      _lastPingResult = resp.pingResult;
      return resp.pingResult;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  /// Task 4.5: Mesh ping with peer latency tracking
  Future<int> pingPeer(int targetAddress, {Duration timeout = const Duration(seconds: 8)}) async {
    _peerPingRttMs[targetAddress] = null; // pending
    notifyListeners();
    try {
      final res = await ping(targetAddress, timeout: timeout);
      _peerPingRttMs[targetAddress] = res.rttMs;
      traceLog?.logRx('PING', 'Node $targetAddress ACK received in ${res.rttMs} ms');
      notifyListeners();
      return res.rttMs;
    } catch (e) {
      _peerPingRttMs[targetAddress] = -1; // failed/unreachable
      traceLog?.logError('PING', 'Ping to $targetAddress failed: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Task 4.6: Transmit authenticated mesh message with chat tracking
  Future<MessageSendResult> sendMessage(
    int destAddress,
    String text, {
    Duration timeout = const Duration(seconds: 12),
  }) async {
    _isExecutingCommand = true;
    _lastError = null;

    final myAddr = _helloResult?.nodeAddress ?? 0;
    final chatMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fromAddress: myAddr,
      toAddress: destAddress,
      text: text,
      timestamp: DateTime.now(),
      isOutgoing: true,
      status: ChatMessageStatus.sending,
    );
    _chatMessages.add(chatMsg);
    notifyListeners();

    try {
      traceLog?.logTx('SEND', 'Sending "$text" to dest=$destAddress');
      final resp = await executeRequest(
        op: RemoteOp.OP_MESSAGE_SEND,
        args: MessageSendArgs(destAddress: destAddress, text: text),
        timeout: timeout,
      );
      if (!resp.ok || !resp.messageSendResult.enqueued) {
        final err = resp.errorCode.isNotEmpty ? resp.errorCode : "not enqueued";
        chatMsg.status = ChatMessageStatus.failed;
        chatMsg.error = err;
        throw RemoteTransportException('MESSAGE_SEND failed: $err');
      }
      _lastSendResult = resp.messageSendResult;
      chatMsg.status = ChatMessageStatus.delivered;
      chatMsg.msgId = resp.messageSendResult.messageId;
      traceLog?.logRx('ACK', 'Message enqueued, ID: ${resp.messageSendResult.messageId}');
      return resp.messageSendResult;
    } catch (e) {
      _lastError = e.toString();
      if (e is RemoteTransportException && e.message.contains('timeout')) {
        chatMsg.status = ChatMessageStatus.uncertain;
        chatMsg.error = 'Uncertain: Delivery ACK not received before timeout';
      } else {
        chatMsg.status = ChatMessageStatus.failed;
        chatMsg.error = e.toString();
      }
      traceLog?.logError('ERR', 'Send failed: $e');
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  /// Refresh all core node data
  Future<void> refreshAll() async {
    if (!isConnected || !isAuthenticated) return;
    try {
      await getStatus();
    } catch (_) {}
    try {
      await getPeers();
    } catch (_) {}
    try {
      await getRoutes();
    } catch (_) {}
    try {
      await getGnss();
    } catch (_) {}
  }

  /// Task 4.7: Subscribe to asynchronous event streams
  Future<void> subscribeEvents({
    bool messages = true,
    bool telemetry = true,
    bool status = true,
  }) async {
    _isExecutingCommand = true;
    _lastError = null;
    notifyListeners();
    try {
      final resp = await executeRequest(
        op: RemoteOp.OP_EVENT_SUB,
        args: EventSubArgs(
          subscribeMessages: messages,
          subscribeTelemetry: telemetry,
          subscribeStatus: status,
        ),
      );
      if (!resp.ok) {
        throw RemoteTransportException('EVENT_SUB failed: ${resp.errorCode}');
      }
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isExecutingCommand = false;
      notifyListeners();
    }
  }

  Future<void> clearAuthToken() async {
    if (_currentNode != null) {
      await _vault.deleteToken(_currentNode!.name);
      await _vault.deleteToken(_currentNode!.id);
    }
    _activeToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Formats the dashboard telemetry and metadata into a standardized human-readable summary.
  String formatDashboardMetadataSummary({
    String? logFileName,
    DateTime? exportTimestamp,
  }) {
    final hello = _helloResult;
    final status = _statusResult;

    final nodeAddr = hello?.nodeAddress ?? 0;
    final nodeName = hello?.nodeName.isNotEmpty == true
        ? hello!.nodeName
        : (_currentNode?.name ?? 'Unknown Node');
    final hwProfile = hello?.hwProfile ?? 1;
    final fwStamp = hello?.firmwareStamp.isNotEmpty == true
        ? hello!.firmwareStamp
        : 'esp32_rx_tx_node_ble';

    final runningSlot = status?.runningSlot.isNotEmpty == true
        ? (status!.runningSlot.contains('b') || status.runningSlot.contains('B')
            ? 'Slot B'
            : 'Slot A')
        : (isConnected ? 'Slot A' : 'N/A');
    final uptimeSecs = status?.uptimeSeconds ?? 0;
    final freeHeap = status?.freeHeap ?? 0;
    final minFreeHeap = status?.minFreeHeap ?? 0;
    const totalSram = 327680; // 320 KiB internal SRAM budget
    final heapRatio = totalSram > 0 ? (freeHeap / totalSram).clamp(0.0, 1.0) : 0.0;
    final minHeapRatio = totalSram > 0 ? (minFreeHeap / totalSram).clamp(0.0, 1.0) : 0.0;
    final meshStatus = status != null
        ? (status.meshOnline ? 'MESH ONLINE' : 'STANDALONE')
        : (isConnected ? 'STANDALONE' : 'OFFLINE');
    final otaState = status?.otaState.isNotEmpty == true
        ? status!.otaState.toUpperCase()
        : 'IDLE';
    final bleState = isConnected
        ? 'Connected (${_currentNode?.id ?? ""})'
        : 'Disconnected';

    final buf = StringBuffer();
    if (logFileName != null) {
      buf.writeln('Logfile: $logFileName');
    }
    if (exportTimestamp != null) {
      buf.writeln('Export Time: ${exportTimestamp.toIso8601String()}');
    }
    buf.writeln('Target Node: $nodeName (Address: $nodeAddr)');
    buf.writeln('Active Slot: $runningSlot | Mesh Status: $meshStatus');
    buf.writeln('Hardware Profile: XIAO ESP32-S3 ($hwProfile)');
    buf.writeln('Firmware Stamp: $fwStamp');
    buf.writeln('ATT MTU: $negotiatedMtu Bytes');
    buf.writeln('BLE Channel: $bleState');
    if (status != null) {
      buf.writeln('Uptime: ${formatUptime(uptimeSecs)} ($uptimeSecs s)');
      buf.writeln(
          'Continuous Free Heap: ${(freeHeap / 1024).toStringAsFixed(1)} KiB / 320 KiB (${(heapRatio * 100).toStringAsFixed(0)}%)');
      buf.writeln(
          'Min Heap Watermark: ${(minFreeHeap / 1024).toStringAsFixed(1)} KiB (${(minHeapRatio * 100).toStringAsFixed(0)}%)');
      buf.writeln('OTA State: $otaState');
    } else {
      buf.writeln('System Telemetry: Pending refresh / initial query');
    }
    return buf.toString().trim();
  }

  static String formatUptime(int seconds) {
    if (seconds <= 0) return '0s';
    final days = seconds ~/ 86400;
    final rem1 = seconds % 86400;
    final hours = rem1 ~/ 3600;
    final rem2 = rem1 % 3600;
    final minutes = rem2 ~/ 60;
    final secs = rem2 % 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || parts.isNotEmpty) parts.add('${minutes}m');
    parts.add('${secs}s');
    return parts.join(' ');
  }

  Future<void> _syncTraceMetadata() async {
    if (traceLog != null) {
      final summary = formatDashboardMetadataSummary();
      await traceLog!.updateMetadataHeader(summary);
    }
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _eventSub?.cancel();
    super.dispose();
  }
}
