import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/share_service.dart';
import '../services/trace_log_service.dart';
import '../viewmodels/node_session_viewmodel.dart';

class LiveTraceView extends StatefulWidget {
  const LiveTraceView({super.key});

  @override
  State<LiveTraceView> createState() => _LiveTraceViewState();
}

class _LiveTraceViewState extends State<LiveTraceView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _copyAllLogs(BuildContext context, TraceLogService traceService) {
    final text = traceService.getAllLogsText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Copied ${traceService.totalCount} trace events to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.teal.shade800,
      ),
    );
  }

  Future<void> _shareLogFile(
      BuildContext context, TraceLogService traceService) async {
    final path = traceService.currentLogFilePath;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active logfile available to share.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final session = context.read<NodeSessionViewModel>();
    final metadataText = session.formatDashboardMetadataSummary(
      logFileName: traceService.currentLogFileName,
      exportTimestamp: DateTime.now(),
    );

    // Sync latest telemetry and metadata to the disk logfile header before sharing
    await traceService.updateMetadataHeader(session.formatDashboardMetadataSummary());
    await traceService.flush();

    final file = File(path);
    if (!await file.exists() || await file.length() == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logfile is currently empty. No logs to share yet.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final shareSubject = session.currentNode != null
        ? 'ESP32 BLE Mesh Trace - ${session.currentNode!.name} (${traceService.currentLogFileName})'
        : 'ESP32 BLE Mesh Trace Log (${traceService.currentLogFileName})';

    final shareBody = StringBuffer();
    shareBody.writeln('=== ESP32 BLE Mesh Trace Log Export ===');
    shareBody.writeln(metadataText);
    shareBody.writeln('========================================');

    try {
      final shared = await ShareService.shareFile(
        filePath: path,
        title: 'Share Trace Log (${traceService.currentLogFileName})',
        subject: shareSubject,
        text: shareBody.toString(),
      );
      if (!shared && context.mounted) {
        // If not on Android or native chooser not available, copy path to clipboard
        Clipboard.setData(ClipboardData(text: path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logfile path copied: $path'),
            backgroundColor: Colors.teal.shade800,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final traceService = context.watch<TraceLogService>();
    final entries = traceService.entries;

    if (traceService.autoScroll && entries.isNotEmpty) {
      _scrollToBottom();
    }

    return Column(
      children: [
        // Controls / Filter Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Colors.grey.shade900,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.terminal,
                      size: 18, color: Colors.tealAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Trace (${entries.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  // Logging toggle
                  FilterChip(
                    label: Text(
                      'Logging',
                      style: TextStyle(
                        fontSize: 10,
                        color: traceService.loggingEnabled
                            ? Colors.white
                            : Colors.white54,
                      ),
                    ),
                    selected: traceService.loggingEnabled,
                    onSelected: (val) => traceService.setLoggingEnabled(val),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    selectedColor: Colors.teal.shade800,
                  ),
                  const SizedBox(width: 6),
                  // Auto-scroll toggle
                  FilterChip(
                    label: Text(
                      'Auto-Scroll',
                      style: TextStyle(
                        fontSize: 10,
                        color: traceService.autoScroll
                            ? Colors.white
                            : Colors.white54,
                      ),
                    ),
                    selected: traceService.autoScroll,
                    onSelected: (val) => traceService.setAutoScroll(val),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    selectedColor: Colors.teal.shade800,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy all trace logs',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 30, minHeight: 30),
                    onPressed: entries.isEmpty
                        ? null
                        : () => _copyAllLogs(context, traceService),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Clear trace logs',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 30, minHeight: 30),
                    onPressed:
                        entries.isEmpty ? null : () => traceService.clear(),
                  ),
                ],
              ),
              if (traceService.loggingEnabled &&
                  traceService.currentLogFilePath != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.tealAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description,
                          size: 14, color: Colors.tealAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'File: ${traceService.currentLogFileName ?? "trace.log"}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.tealAccent,
                              ),
                            ),
                            Text(
                              traceService.currentLogFilePath!,
                              style: const TextStyle(
                                fontSize: 9.0,
                                fontFamily: 'monospace',
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton.icon(
                        icon: const Icon(Icons.share,
                            size: 13, color: Colors.tealAccent),
                        label: const Text(
                          'Share',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          backgroundColor:
                              Colors.teal.shade900.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(
                                color:
                                    Colors.tealAccent.withValues(alpha: 0.4)),
                          ),
                        ),
                        onPressed: () => _shareLogFile(context, traceService),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(traceService, null, 'ALL'),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.rx,
                        'RX (Cyan)', const Color(0xFF00E5FF)),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.tx,
                        'TX (Green)', const Color(0xFF69F0AE)),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.control,
                        'CTRL (Yellow)', const Color(0xFFFFD740)),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.error,
                        'ERR (Red)', const Color(0xFFFF5252)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Console Log Stream Window
        Expanded(
          child: Container(
            color: const Color(0xFF0D1117), // Deep dark console background
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      traceService.loggingEnabled
                          ? 'No packet trace events logged yet.\nBLE TX/RX activity will display here in real time.'
                          : 'Trace logging is currently paused / disabled.\nCheck the "Logging" box above to resume capture.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white30,
                          fontFamily: 'monospace',
                          fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      final hexString = (item.rawBytes != null &&
                              item.rawBytes!.isNotEmpty)
                          ? ' [HEX: ${item.rawBytes!.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}${item.rawBytes!.length > 8 ? "..." : ""}]'
                          : '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                            children: [
                              TextSpan(
                                text: '[${item.formattedTimestamp}] ',
                                style: const TextStyle(color: Colors.white38),
                              ),
                              TextSpan(
                                text: '${item.directionLabel} ',
                                style: TextStyle(
                                  color: item.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '${item.tag}: ',
                                style: TextStyle(
                                  color: item.color.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: item.message,
                                style: const TextStyle(color: Colors.white),
                              ),
                              if (hexString.isNotEmpty)
                                TextSpan(
                                  text: hexString,
                                  style: const TextStyle(color: Colors.white54),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(
    TraceLogService service,
    TraceDirection? dir,
    String label, [
    Color? color,
  ]) {
    final isSelected = service.activeFilter == dir;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isSelected ? Colors.black : (color ?? Colors.white70),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => service.setFilter(dir),
      selectedColor: color ?? Colors.tealAccent,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
