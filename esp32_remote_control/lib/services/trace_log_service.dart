import 'package:flutter/material.dart';

enum TraceDirection {
  rx,
  tx,
  control,
  error,
}

class TraceEntry {
  final DateTime timestamp;
  final TraceDirection direction;
  final String tag;
  final String message;
  final List<int>? rawBytes;

  TraceEntry({
    DateTime? timestamp,
    required this.direction,
    required this.tag,
    required this.message,
    this.rawBytes,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedTimestamp {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  Color get color {
    switch (direction) {
      case TraceDirection.rx:
        return const Color(0xFF00E5FF); // Cyan
      case TraceDirection.tx:
        return const Color(0xFF69F0AE); // Light Green
      case TraceDirection.control:
        return const Color(0xFFFFD740); // Yellow / Amber
      case TraceDirection.error:
        return const Color(0xFFFF5252); // Red
    }
  }

  String get directionLabel {
    switch (direction) {
      case TraceDirection.rx:
        return '[BLE RX]';
      case TraceDirection.tx:
        return '[BLE TX]';
      case TraceDirection.control:
        return '[BLE CTRL]';
      case TraceDirection.error:
        return '[ERR]';
    }
  }

  String toClipboardString() {
    final hexPart = (rawBytes != null && rawBytes!.isNotEmpty)
        ? ' | HEX: ${rawBytes!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}'
        : '';
    return '[$formattedTimestamp] $directionLabel $tag: $message$hexPart';
  }
}

class TraceLogService extends ChangeNotifier {
  static const int maxEntries = 500;
  final List<TraceEntry> _entries = [];
  bool _autoScroll = true;
  TraceDirection? _activeFilter;

  List<TraceEntry> get entries {
    if (_activeFilter == null) {
      return List.unmodifiable(_entries);
    }
    return List.unmodifiable(_entries.where((e) => e.direction == _activeFilter));
  }

  int get totalCount => _entries.length;
  bool get autoScroll => _autoScroll;
  TraceDirection? get activeFilter => _activeFilter;

  void setAutoScroll(bool value) {
    _autoScroll = value;
    notifyListeners();
  }

  void setFilter(TraceDirection? filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void log({
    required TraceDirection direction,
    required String tag,
    required String message,
    List<int>? rawBytes,
  }) {
    final entry = TraceEntry(
      direction: direction,
      tag: tag,
      message: message,
      rawBytes: rawBytes,
    );

    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
    notifyListeners();
  }

  void logRx(String tag, String message, [List<int>? rawBytes]) {
    log(
      direction: TraceDirection.rx,
      tag: tag,
      message: message,
      rawBytes: rawBytes,
    );
  }

  void logTx(String tag, String message, [List<int>? rawBytes]) {
    log(
      direction: TraceDirection.tx,
      tag: tag,
      message: message,
      rawBytes: rawBytes,
    );
  }

  void logControl(String tag, String message) {
    log(
      direction: TraceDirection.control,
      tag: tag,
      message: message,
    );
  }

  void logError(String tag, String message) {
    log(
      direction: TraceDirection.error,
      tag: tag,
      message: message,
    );
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  String getAllLogsText() {
    return _entries.map((e) => e.toClipboardString()).join('\n');
  }
}
