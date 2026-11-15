import 'dart:typed_data';
import '../core/constants.dart';

List<Uint8List> fragmentPayload(Uint8List payload, int maxFrameLen, int msgId) {
  if (maxFrameLen < BleConstants.fragHeaderLen + 1) {
    throw ArgumentError('maxFrameLen must be at least ${BleConstants.fragHeaderLen + 1}, got $maxFrameLen');
  }

  final maxPayload = maxFrameLen - BleConstants.fragHeaderLen;
  final msgIdByte = msgId & 0xFF;

  if (payload.isEmpty) {
    return [Uint8List.fromList([msgIdByte, 0, 1])];
  }

  final totalFrags = (payload.length + maxPayload - 1) ~/ maxPayload;
  if (totalFrags > 255) {
    throw ArgumentError('Payload size ${payload.length} exceeds 255 fragments');
  }

  final List<Uint8List> frames = [];
  for (int fragIdx = 0; fragIdx < totalFrags; fragIdx++) {
    final start = fragIdx * maxPayload;
    final end = (start + maxPayload < payload.length) ? start + maxPayload : payload.length;
    final chunk = payload.sublist(start, end);

    final frame = Uint8List(BleConstants.fragHeaderLen + chunk.length);
    frame[0] = msgIdByte;
    frame[1] = fragIdx;
    frame[2] = totalFrags;
    frame.setRange(BleConstants.fragHeaderLen, frame.length, chunk);
    frames.add(frame);
  }

  return frames;
}

class Defragmenter {
  final Duration timeout;

  int? _msgId;
  int _totalFrags = 0;
  int _nextExpectedFrag = 0;
  final List<int> _buf = [];
  DateTime? _lastTime;

  Defragmenter({this.timeout = BleConstants.reassemblyTimeout});

  void reset() {
    _msgId = null;
    _totalFrags = 0;
    _nextExpectedFrag = 0;
    _buf.clear();
    _lastTime = null;
  }

  Uint8List? feed(List<int> frame) {
    if (frame.length < BleConstants.fragHeaderLen) {
      return null;
    }

    final msgId = frame[0];
    final fragIdx = frame[1];
    final totalFrags = frame[2];
    final payload = frame.sublist(BleConstants.fragHeaderLen);

    if (totalFrags == 0 || fragIdx >= totalFrags) {
      return null;
    }

    final now = DateTime.now();

    // Single frame complete message
    if (totalFrags == 1 && fragIdx == 0) {
      reset();
      return Uint8List.fromList(payload);
    }

    // Multi-frame: start of a new sequence
    if (fragIdx == 0) {
      _msgId = msgId;
      _totalFrags = totalFrags;
      _nextExpectedFrag = 1;
      _buf.clear();
      _buf.addAll(payload);
      _lastTime = now;
      return null;
    }

    // Check timeout
    if (_lastTime != null && now.difference(_lastTime!) > timeout) {
      reset();
      return null;
    }

    // Verify sequential matching fragment
    if (_msgId != null &&
        msgId == _msgId &&
        fragIdx == _nextExpectedFrag &&
        totalFrags == _totalFrags) {
      _buf.addAll(payload);
      _nextExpectedFrag++;
      _lastTime = now;

      if (_nextExpectedFrag == _totalFrags) {
        final completed = Uint8List.fromList(_buf);
        reset();
        return completed;
      }
      return null;
    }

    // Fragment out of order or mismatched msg_id: discard
    reset();
    return null;
  }
}
