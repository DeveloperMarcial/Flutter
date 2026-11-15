import 'dart:async';
import 'dart:typed_data';
import '../core/errors.dart';
import '../generated/esp_remote.pb.dart';

class ResponseCorrelator {
  final Map<int, Completer<RemoteResponse>> _pending = {};
  final StreamController<EventNotification> _eventController = StreamController<EventNotification>.broadcast();
  int? _activeSendReqId;

  Stream<EventNotification> get eventStream => _eventController.stream;
  int get pendingCount => _pending.length;
  bool isPending(int requestId) => _pending.containsKey(requestId);

  Future<RemoteResponse> registerRequest({
    required int requestId,
    required RemoteOp op,
    Duration timeout = const Duration(seconds: 10),
  }) {
    final completer = Completer<RemoteResponse>();
    _pending[requestId] = completer;
    if (op == RemoteOp.OP_MESSAGE_SEND) {
      _activeSendReqId = requestId;
    }

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pending.remove(requestId);
        if (_activeSendReqId == requestId) {
          _activeSendReqId = null;
        }
        throw TimeoutException('Request $requestId (op: $op) timed out after $timeout');
      },
    );
  }

  void handleIncomingPayload(Uint8List rawBytes) {
    final resp = RemoteResponse.fromBuffer(rawBytes);
    handleResponse(resp);
  }

  void handleResponse(RemoteResponse resp) {
    if (resp.hasEventNotification()) {
      _eventController.add(resp.eventNotification);
      return;
    }

    final reqId = resp.requestId;
    final completer = _pending.remove(reqId);
    if (reqId == _activeSendReqId) {
      _activeSendReqId = null;
    }

    if (completer != null && !completer.isCompleted) {
      completer.complete(resp);
    }
  }

  void handleDisconnect() {
    for (final entry in _pending.entries) {
      final reqId = entry.key;
      final completer = entry.value;
      if (!completer.isCompleted) {
        if (reqId == _activeSendReqId) {
          completer.completeError(const DisconnectedDuringSendException());
        } else {
          completer.completeError(const RemoteTransportException('Link dropped before response received'));
        }
      }
    }
    _pending.clear();
    _activeSendReqId = null;
  }

  void dispose() {
    handleDisconnect();
    _eventController.close();
  }
}
