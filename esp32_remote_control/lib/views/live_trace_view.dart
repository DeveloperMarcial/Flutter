import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/trace_log_service.dart';

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
        content: Text('Copied ${traceService.totalCount} trace events to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.teal.shade800,
      ),
    );
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
                  const Icon(Icons.terminal, size: 18, color: Colors.tealAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Trace (${entries.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  // Auto-scroll toggle
                  FilterChip(
                    label: Text(
                      'Auto-Scroll',
                      style: TextStyle(
                        fontSize: 10,
                        color: traceService.autoScroll ? Colors.white : Colors.white54,
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
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: entries.isEmpty ? null : () => _copyAllLogs(context, traceService),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Clear trace logs',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: entries.isEmpty ? null : () => traceService.clear(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(traceService, null, 'ALL'),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.rx, 'RX (Cyan)', const Color(0xFF00E5FF)),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.tx, 'TX (Green)', const Color(0xFF69F0AE)),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.control, 'CTRL (Yellow)', const Color(0xFFFFD740)),
                    const SizedBox(width: 6),
                    _buildFilterPill(traceService, TraceDirection.error, 'ERR (Red)', const Color(0xFFFF5252)),
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
                ? const Center(
                    child: Text(
                      'No packet trace events logged yet.\nBLE TX/RX activity will display here in real time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white30, fontFamily: 'monospace', fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      final hexString = (item.rawBytes != null && item.rawBytes!.isNotEmpty)
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
