import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp32_remote_control/core/errors.dart';
import 'package:esp32_remote_control/generated/esp_remote.pb.dart';
import 'package:esp32_remote_control/transport/response_correlator.dart';

void main() {
  group('Request-Response Correlation & Strict Uncertain-Send Tests', () {
    late ResponseCorrelator correlator;

    setUp(() {
      correlator = ResponseCorrelator();
    });

    tearDown(() {
      correlator.dispose();
    });

    test('Prompted response completes matching request', () async {
      final future = correlator.registerRequest(
        requestId: 101,
        op: RemoteOp.OP_HELLO,
      );

      final resp = RemoteResponse()
        ..version = 1
        ..requestId = 101
        ..ok = true
        ..helloResult = (HelloResult()
          ..nodeAddress = 48
          ..nodeName = 'node-48');

      correlator.handleResponse(resp);

      final result = await future;
      expect(result.requestId, equals(101));
      expect(result.ok, isTrue);
      expect(result.helloResult.nodeAddress, equals(48));
    });

    test('Unprompted event notification is dispatched to eventStream', () async {
      final events = <EventNotification>[];
      final sub = correlator.eventStream.listen(events.add);

      final eventResp = RemoteResponse()
        ..version = 1
        ..requestId = 0
        ..ok = true
        ..eventNotification = (EventNotification()
          ..eventType = EventNotification_EventType.EVT_MESSAGE_RX
          ..fromAddress = 43
          ..payloadText = 'Hello mesh network');

      correlator.handleResponse(eventResp);

      await Future.delayed(Duration.zero);
      expect(events.length, equals(1));
      expect(events[0].eventType, equals(EventNotification_EventType.EVT_MESSAGE_RX));
      expect(events[0].fromAddress, equals(43));
      expect(events[0].payloadText, equals('Hello mesh network'));

      await sub.cancel();
    });

    test('Request times out when response is not received', () async {
      final future = correlator.registerRequest(
        requestId: 102,
        op: RemoteOp.OP_NODE_STATUS,
        timeout: const Duration(milliseconds: 50),
      );

      expect(future, throwsA(isA<TimeoutException>()));
    });

    test('Strict uncertain-send fault handling on disconnection', () async {
      // Register OP_MESSAGE_SEND
      final sendFuture = correlator.registerRequest(
        requestId: 201,
        op: RemoteOp.OP_MESSAGE_SEND,
      );

      // Register non-send request (OP_HELLO)
      final helloFuture = correlator.registerRequest(
        requestId: 202,
        op: RemoteOp.OP_HELLO,
      );

      expect(correlator.pendingCount, equals(2));

      // Simulate connection drop
      correlator.handleDisconnect();

      // OP_MESSAGE_SEND must fail with DisconnectedDuringSendException (uncertain status)
      expect(
        sendFuture,
        throwsA(
          predicate<DisconnectedDuringSendException>(
            (e) => e.status == SendStatus.uncertain,
          ),
        ),
      );

      // Standard request must fail with RemoteTransportException
      expect(helloFuture, throwsA(isA<RemoteTransportException>()));

      // Pending queue must be empty
      expect(correlator.pendingCount, equals(0));
    });
  });
}
