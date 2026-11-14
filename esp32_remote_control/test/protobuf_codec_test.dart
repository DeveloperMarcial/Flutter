import 'package:flutter_test/flutter_test.dart';
import 'package:esp32_remote_control/generated/esp_remote.pb.dart';

void main() {
  group('Protobuf Codec Tests (Vector Parity with Python Suite)', () {
    test('OP_HELLO Request Encoding and Decoding', () {
      final req = RemoteRequest()
        ..version = 1
        ..requestId = 1
        ..op = RemoteOp.OP_HELLO
        ..authToken = 'pin123';

      final bytes = req.writeToBuffer();
      final decoded = RemoteRequest.fromBuffer(bytes);

      expect(decoded.version, 1);
      expect(decoded.requestId, 1);
      expect(decoded.op, RemoteOp.OP_HELLO);
      expect(decoded.authToken, 'pin123');
    });

    test('OP_NODE_STATUS Request Encoding and Decoding', () {
      final req = RemoteRequest()
        ..version = 1
        ..requestId = 2
        ..op = RemoteOp.OP_NODE_STATUS
        ..authToken = 'token_abc';

      final bytes = req.writeToBuffer();
      final decoded = RemoteRequest.fromBuffer(bytes);

      expect(decoded.requestId, 2);
      expect(decoded.op, RemoteOp.OP_NODE_STATUS);
      expect(decoded.authToken, 'token_abc');
    });

    test('OP_PING Request with PingArgs', () {
      final req = RemoteRequest()
        ..version = 1
        ..requestId = 3
        ..op = RemoteOp.OP_PING
        ..authToken = 'token_abc'
        ..pingArgs = (PingArgs()..targetAddress = 49);

      final bytes = req.writeToBuffer();
      final decoded = RemoteRequest.fromBuffer(bytes);

      expect(decoded.op, RemoteOp.OP_PING);
      expect(decoded.pingArgs.targetAddress, 49);
    });

    test('OP_MESSAGE_SEND Request with MessageSendArgs', () {
      final req = RemoteRequest()
        ..version = 1
        ..requestId = 4
        ..op = RemoteOp.OP_MESSAGE_SEND
        ..authToken = 'token_abc'
        ..messageSendArgs = (MessageSendArgs()
          ..destAddress = 51
          ..text = 'Hello mesh!');

      final bytes = req.writeToBuffer();
      final decoded = RemoteRequest.fromBuffer(bytes);

      expect(decoded.op, RemoteOp.OP_MESSAGE_SEND);
      expect(decoded.messageSendArgs.destAddress, 51);
      expect(decoded.messageSendArgs.text, 'Hello mesh!');
    });

    test('RemoteResponse Decoding with NodeStatusResult', () {
      final resp = RemoteResponse()
        ..version = 1
        ..requestId = 99
        ..ok = true
        ..statusResult = (NodeStatusResult()
          ..uptimeSeconds = 1234
          ..freeHeap = 150000
          ..minFreeHeap = 140000
          ..runningSlot = 'Slot A'
          ..otaState = 'IDLE'
          ..ownerMasterId = 43
          ..meshOnline = true);

      final bytes = resp.writeToBuffer();
      final decoded = RemoteResponse.fromBuffer(bytes);

      expect(decoded.version, 1);
      expect(decoded.requestId, 99);
      expect(decoded.ok, true);
      expect(decoded.statusResult.uptimeSeconds, 1234);
      expect(decoded.statusResult.freeHeap, 150000);
      expect(decoded.statusResult.runningSlot, 'Slot A');
      expect(decoded.statusResult.ownerMasterId, 43);
      expect(decoded.statusResult.meshOnline, true);
    });
  });
}
