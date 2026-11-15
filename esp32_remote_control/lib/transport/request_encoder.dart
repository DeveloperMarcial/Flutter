import 'package:protobuf/protobuf.dart';
import '../generated/esp_remote.pb.dart';

RemoteRequest buildRemoteRequest({
  required int requestId,
  required RemoteOp op,
  GeneratedMessage? args,
  String? authToken,
  int version = 1,
}) {
  final req = RemoteRequest()
    ..version = version
    ..requestId = requestId
    ..op = op;

  if (authToken != null && authToken.isNotEmpty) {
    req.authToken = authToken;
  }

  if (op == RemoteOp.OP_HELLO) {
    if (args is HelloArgs) {
      req.helloArgs = args;
    } else {
      req.helloArgs = HelloArgs();
    }
  } else if (op == RemoteOp.OP_NODE_STATUS) {
    if (args is NodeStatusArgs) {
      req.statusArgs = args;
    } else {
      req.statusArgs = NodeStatusArgs();
    }
  } else if (op == RemoteOp.OP_PEER_ROSTER) {
    if (args is PeerRosterArgs) {
      req.rosterArgs = args;
    } else {
      req.rosterArgs = PeerRosterArgs();
    }
  } else if (op == RemoteOp.OP_GNSS_GET) {
    if (args is GnssGetArgs) {
      req.gnssArgs = args;
    } else {
      req.gnssArgs = GnssGetArgs();
    }
  } else if (op == RemoteOp.OP_ROUTES_GET) {
    if (args is RoutesGetArgs) {
      req.routesArgs = args;
    } else {
      req.routesArgs = RoutesGetArgs();
    }
  } else if (op == RemoteOp.OP_PING) {
    if (args is PingArgs) {
      req.pingArgs = args;
    } else {
      req.pingArgs = PingArgs();
    }
  } else if (op == RemoteOp.OP_MESSAGE_SEND) {
    if (args is MessageSendArgs) {
      req.messageSendArgs = args;
    } else {
      req.messageSendArgs = MessageSendArgs();
    }
  } else if (op == RemoteOp.OP_EVENT_SUB) {
    if (args is EventSubArgs) {
      req.eventSubArgs = args;
    } else {
      req.eventSubArgs = EventSubArgs()
        ..subscribeMessages = true
        ..subscribeTelemetry = true
        ..subscribeStatus = true;
    }
  }

  return req;
}
