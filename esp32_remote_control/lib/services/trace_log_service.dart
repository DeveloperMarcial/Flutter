import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  final Directory? _customLogDir;
  File? _currentLogFile;
  IOSink? _logSink;
  String? _currentLogFilePath;
  String? _currentLogFileName;
  Future<void>? _initFuture;
  bool _loggingEnabled = true;
  bool _autoScroll = true;
  TraceDirection? _activeFilter;
  String Function()? metadataProvider;
  DateTime _sessionStartTime = DateTime.now();

  TraceLogService({Directory? customLogDir}) : _customLogDir = customLogDir {
    if (_loggingEnabled) {
      _initFuture = _initLogFile();
    }
  }

  List<TraceEntry> get entries {
    if (_activeFilter == null) {
      return List.unmodifiable(_entries);
    }
    return List.unmodifiable(_entries.where((e) => e.direction == _activeFilter));
  }

  int get totalCount => _entries.length;
  bool get loggingEnabled => _loggingEnabled;
  bool get autoScroll => _autoScroll;
  TraceDirection? get activeFilter => _activeFilter;

  File? get currentLogFile => _currentLogFile;
  String? get currentLogFilePath => _currentLogFilePath;
  String? get currentLogFileName => _currentLogFileName;
  Future<void>? get initFuture => _initFuture;

  Future<void> ensureInitialized() async {
    if (_initFuture != null) {
      await _initFuture;
    } else if (_currentLogFile == null) {
      _initFuture = _initLogFile();
      await _initFuture;
    }
  }

  Future<Directory> _resolveLogDir() async {
    final customDir = _customLogDir;
    if (customDir != null) return customDir;
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  Future<void> _initLogFile() async {
    if (_currentLogFile != null && _logSink != null) return;
    try {
      final baseDir = await _resolveLogDir();
      final logsDir = Directory('${baseDir.path}/trace_logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      _sessionStartTime = now;
      _currentLogFileName = 'esp_trace_$timestamp.log';
      _currentLogFilePath = '${logsDir.path}/$_currentLogFileName';
      final file = File(_currentLogFilePath!);
      _currentLogFile = file;
      _logSink = file.openWrite(mode: FileMode.append);
      _logSink?.writeln('===============================================');
      _logSink?.writeln('=== ESP32 BLE Mesh Remote Trace Log Session ===');
      _logSink?.writeln('Session Started: ${now.toIso8601String()}');
      if (metadataProvider != null) {
        final meta = metadataProvider!().trim();
        if (meta.isNotEmpty) {
          _logSink?.writeln('--- Target Node Telemetry & Diagnostics ---');
          _logSink?.writeln(meta);
        }
      }
      _logSink?.writeln('===============================================');
      await _logSink?.flush();
      notifyListeners();
    } catch (e) {
      debugPrint('TraceLogService file init error: $e');
    }
  }

  Future<void> setLoggingEnabled(bool value) async {
    if (_loggingEnabled != value) {
      _loggingEnabled = value;
      if (_loggingEnabled) {
        if (_currentLogFile == null || _logSink == null) {
          await _initLogFile();
        } else {
          _logSink?.writeln('[LOGGING RESUMED: ${DateTime.now().toIso8601String()}]');
          await _logSink?.flush();
        }
      } else {
        _logSink?.writeln('[LOGGING PAUSED: ${DateTime.now().toIso8601String()}]');
        await _logSink?.flush();
      }
      notifyListeners();
    }
  }

  void setAutoScroll(bool value) {
    _autoScroll = value;
    notifyListeners();
  }

  void setFilter(TraceDirection? filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> flush() async {
    await _logSink?.flush();
  }

  /// Updates or inserts the telemetry and diagnostic metadata in the logfile header.
  Future<void> updateMetadataHeader(String metadata) async {
    if (_currentLogFilePath == null) return;
    try {
      await _logSink?.flush();
      await _logSink?.close();
      _logSink = null;

      final file = File(_currentLogFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        const headerTitle = '=== ESP32 BLE Mesh Remote Trace Log Session ===';
        const divider = '===============================================';

        final headerStartIndex = content.indexOf(headerTitle);
        String remainingLogs = '';

        if (headerStartIndex != -1) {
          final nextDividerIndex = content.indexOf(divider, headerStartIndex + headerTitle.length);
          if (nextDividerIndex != -1) {
            final endOfLine = content.indexOf('\n', nextDividerIndex);
            if (endOfLine != -1) {
              remainingLogs = content.substring(endOfLine + 1);
            }
          } else {
            remainingLogs = content.substring(headerStartIndex + headerTitle.length);
          }
        } else {
          remainingLogs = content;
        }

        final buf = StringBuffer();
        buf.writeln(divider);
        buf.writeln(headerTitle);
        buf.writeln('Session Started: ${_sessionStartTime.toIso8601String()}');
        buf.writeln('Header Updated:  ${DateTime.now().toIso8601String()}');
        if (metadata.trim().isNotEmpty) {
          buf.writeln('--- Target Node Telemetry & Diagnostics ---');
          buf.writeln(metadata.trim());
        }
        buf.writeln(divider);
        buf.write(remainingLogs);

        await file.writeAsString(buf.toString(), flush: true);
      }

      _logSink = file.openWrite(mode: FileMode.append);
      notifyListeners();
    } catch (e) {
      debugPrint('[TraceLogService] updateMetadataHeader error: $e');
      if (_currentLogFilePath != null) {
        _logSink = File(_currentLogFilePath!).openWrite(mode: FileMode.append);
      }
    }
  }

  void log({
    required TraceDirection direction,
    required String tag,
    required String message,
    List<int>? rawBytes,
  }) {
    if (!_loggingEnabled) return;

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

    _logSink?.writeln(entry.toClipboardString());

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

  @override
  void dispose() {
    _logSink?.flush();
    _logSink?.close();
    super.dispose();
  }
}
