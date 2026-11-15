import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp32_remote_control/transport/defragmenter.dart';

void main() {
  group('Fragmentation & Defragmentation Engine Tests', () {
    test('Empty payload fragmentation and reassembly', () {
      final payload = Uint8List(0);
      final frames = fragmentPayload(payload, 20, 1);

      expect(frames.length, equals(1));
      expect(frames[0], equals([1, 0, 1]));

      final defrag = Defragmenter();
      final assembled = defrag.feed(frames[0]);
      expect(assembled, isNotNull);
      expect(assembled!.isEmpty, isTrue);
    });

    test('Single-frame complete message', () {
      final payload = Uint8List.fromList([10, 20, 30, 40, 50]);
      final frames = fragmentPayload(payload, 20, 42);

      expect(frames.length, equals(1));
      expect(frames[0].length, equals(8)); // 3 header + 5 payload
      expect(frames[0].sublist(0, 3), equals([42, 0, 1]));

      final defrag = Defragmenter();
      final assembled = defrag.feed(frames[0]);
      expect(assembled, isNotNull);
      expect(assembled, equals(payload));
    });

    test('Multi-frame sequential assembly across small MTU (20 bytes)', () {
      final payload = Uint8List.fromList(List.generate(50, (i) => i));
      // Max frame 20 bytes -> max payload 17 bytes per frame
      // 50 / 17 = 3 full frames (17*3 = 51) -> 3 frames (17, 17, 16)
      final frames = fragmentPayload(payload, 20, 7);

      expect(frames.length, equals(3));
      expect(frames[0], equals([7, 0, 3, ...payload.sublist(0, 17)]));
      expect(frames[1], equals([7, 1, 3, ...payload.sublist(17, 34)]));
      expect(frames[2], equals([7, 2, 3, ...payload.sublist(34, 50)]));

      final defrag = Defragmenter();
      expect(defrag.feed(frames[0]), isNull);
      expect(defrag.feed(frames[1]), isNull);
      final assembled = defrag.feed(frames[2]);

      expect(assembled, isNotNull);
      expect(assembled, equals(payload));
    });

    test('Multi-frame sequential assembly across large MTU (240 bytes)', () {
      final payload = Uint8List.fromList(List.generate(500, (i) => i % 256));
      final frames = fragmentPayload(payload, 240, 99);

      // Max frame 240 -> max payload 237
      // 500 / 237 = 3 frames (237, 237, 26)
      expect(frames.length, equals(3));

      final defrag = Defragmenter();
      expect(defrag.feed(frames[0]), isNull);
      expect(defrag.feed(frames[1]), isNull);
      final assembled = defrag.feed(frames[2]);

      expect(assembled, isNotNull);
      expect(assembled, equals(payload));
    });

    test('Mismatched msg_id in subsequent fragment resets assembly', () {
      final payload = Uint8List.fromList(List.generate(40, (i) => i));
      final frames = fragmentPayload(payload, 20, 5);

      final defrag = Defragmenter();
      expect(defrag.feed(frames[0]), isNull);

      // Corrupt msg_id on frame 1
      final corruptedFrame1 = Uint8List.fromList(frames[1]);
      corruptedFrame1[0] = 99; // Different msg_id

      expect(defrag.feed(corruptedFrame1), isNull);
      // Frame 2 should now also fail because state was reset
      expect(defrag.feed(frames[2]), isNull);
    });

    test('Out of order fragment resets assembly', () {
      final payload = Uint8List.fromList(List.generate(40, (i) => i));
      final frames = fragmentPayload(payload, 20, 5);

      final defrag = Defragmenter();
      expect(defrag.feed(frames[0]), isNull);
      // Skip frame 1 and feed frame 2 directly
      expect(defrag.feed(frames[2]), isNull);
    });

    test('Defragmenter timeout resets buffer', () async {
      final payload = Uint8List.fromList(List.generate(40, (i) => i));
      final frames = fragmentPayload(payload, 20, 5);

      final defrag = Defragmenter(timeout: const Duration(milliseconds: 50));
      expect(defrag.feed(frames[0]), isNull);

      await Future.delayed(const Duration(milliseconds: 80));

      // After timeout, next frame should be rejected and buffer reset
      expect(defrag.feed(frames[1]), isNull);
    });
  });
}
