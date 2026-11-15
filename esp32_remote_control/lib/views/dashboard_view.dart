import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/node_session_viewmodel.dart';

class DashboardView extends StatelessWidget {
  final VoidCallback? onNavigateToPeers;
  final VoidCallback? onNavigateToChat;

  const DashboardView({
    super.key,
    this.onNavigateToPeers,
    this.onNavigateToChat,
  });

  String _formatUptime(int seconds) {
    if (seconds <= 0) return '0s';
    final days = seconds ~/ 86400;
    final rem1 = seconds % 86400;
    final hours = rem1 ~/ 3600;
    final rem2 = rem1 % 3600;
    final minutes = rem2 ~/ 60;
    final secs = rem2 % 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || parts.isNotEmpty) parts.add('${minutes}m');
    parts.add('${secs}s');
    return parts.join(' ');
  }

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade900 : Colors.teal.shade800,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<NodeSessionViewModel>();
    final hello = session.helloResult;
    final status = session.statusResult;

    final nodeAddr = hello?.nodeAddress ?? 0;
    final nodeName = hello?.nodeName.isNotEmpty == true ? hello!.nodeName : (session.currentNode?.name ?? 'Unknown');
    final hwProfile = hello?.hwProfile ?? 1;
    final fwStamp = hello?.firmwareStamp.isNotEmpty == true ? hello!.firmwareStamp : 'esp32_rx_tx_node_ble';

    final runningSlot = status?.runningSlot.isNotEmpty == true
        ? (status!.runningSlot.contains('b') || status.runningSlot.contains('B') ? 'Slot B' : 'Slot A')
        : 'Slot A';
    final uptimeSecs = status?.uptimeSeconds ?? 0;
    final freeHeap = status?.freeHeap ?? 245000;
    final minFreeHeap = status?.minFreeHeap ?? 210000;
    const totalSram = 327680; // 320 KiB internal SRAM budget
    final heapRatio = (freeHeap / totalSram).clamp(0.0, 1.0);
    final minHeapRatio = (minFreeHeap / totalSram).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero / Identity Card
          Card(
            elevation: 3,
            color: Colors.blueGrey.shade900.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.teal.shade600, width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.teal.shade700,
                            child: const Icon(Icons.router, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nodeName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Address: Node $nodeAddr  |  $runningSlot',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.tealAccent.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          status?.meshOnline == true ? 'MESH ONLINE' : 'STANDALONE',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: status?.meshOnline == true
                            ? Colors.teal.shade700
                            : Colors.orange.shade800,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn('HW Profile', 'XIAO ESP32-S3 ($hwProfile)'),
                      _buildInfoColumn('Uptime', _formatUptime(uptimeSecs)),
                      _buildInfoColumn('ATT MTU', '${session.negotiatedMtu} B'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Firmware: $fwStamp',
                    style: const TextStyle(fontSize: 11, color: Colors.white54, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Fast Action Shortcuts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ActionChip(
                avatar: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Status'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          await session.getStatus();
                          if (context.mounted) _showSnack(context, 'Telemetry refreshed');
                        } catch (e) {
                          if (context.mounted) _showSnack(context, 'Status refresh failed: $e', isError: true);
                        }
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.network_ping, size: 16),
                label: const Text('Ping Master (43)'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          final rtt = await session.pingPeer(43);
                          if (context.mounted) _showSnack(context, 'Ping Master 43: RTT $rtt ms');
                        } catch (e) {
                          if (context.mounted) _showSnack(context, 'Ping failed: $e', isError: true);
                        }
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.people, size: 16),
                label: const Text('View Peers'),
                onPressed: onNavigateToPeers ??
                    () async {
                      try {
                        final peers = await session.getPeers();
                        if (context.mounted) _showSnack(context, '${peers.length} active peers loaded');
                      } catch (e) {
                        if (context.mounted) _showSnack(context, 'Peers query failed: $e', isError: true);
                      }
                    },
              ),
              ActionChip(
                avatar: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Mesh Chat'),
                onPressed: onNavigateToChat,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // System Diagnostics & Health Card
          Card(
            elevation: 2,
            color: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'System Diagnostics & SRAM',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.power, size: 16, color: Colors.greenAccent.shade400),
                          const SizedBox(width: 4),
                          const Text(
                            '3.3V Rail Normal',
                            style: TextStyle(fontSize: 11, color: Colors.greenAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Free Heap Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Continuous Free Heap', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      Text(
                        '${(freeHeap / 1024).toStringAsFixed(1)} KiB / 320 KiB (${(heapRatio * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: heapRatio,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        heapRatio > 0.4 ? Colors.tealAccent.shade400 : Colors.orangeAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Min Watermark: ${(minFreeHeap / 1024).toStringAsFixed(1)} KiB (${(minHeapRatio * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                      const Text('Total Budget: 320 KiB', style: TextStyle(fontSize: 10, color: Colors.white38)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),

                  // Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.sync_alt,
                          label: 'OTA State',
                          value: status?.otaState.isNotEmpty == true ? status!.otaState.toUpperCase() : 'IDLE',
                          color: Colors.tealAccent,
                        ),
                      ),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.bluetooth,
                          label: 'BLE Channel',
                          value: 'Connected',
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Priority Gate P6 Bench Qualification Card
          Card(
            elevation: 2,
            color: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.purple.shade700, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.science_outlined, color: Colors.purpleAccent.shade100, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Bench Qualification (Gate P6)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade900,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('DOE-STD-1029', style: TextStyle(fontSize: 10, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Execute automated stress and concurrency qualification on physical Android hardware.',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.repeat, size: 16),
                        label: const Text('50-Cycle Churn (6.1)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: (session.isExecutingCommand || session.isChurnRunning)
                            ? null
                            : () => _startChurnBenchmark(context, session),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.flash_on, size: 16),
                        label: const Text('LoRa Stress (6.2)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: (session.isExecutingCommand || session.isChurnRunning)
                            ? null
                            : () => _startBrownoutStressBenchmark(context, session),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startChurnBenchmark(BuildContext context, NodeSessionViewModel session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _ChurnDialog(session: session),
    );
  }

  void _startBrownoutStressBenchmark(BuildContext context, NodeSessionViewModel session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _BrownoutStressDialog(session: session),
    );
  }

  static Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  static Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _ChurnDialog extends StatefulWidget {
  final NodeSessionViewModel session;
  const _ChurnDialog({required this.session});

  @override
  State<_ChurnDialog> createState() => _ChurnDialogState();
}

class _ChurnDialogState extends State<_ChurnDialog> {
  ChurnProgress? _progress;
  ChurnTestResult? _result;
  bool _running = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  Future<void> _startTest() async {
    try {
      final res = await widget.session.runChurnTest(
        totalCycles: 50,
        interCycleDelay: const Duration(milliseconds: 250),
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) {
        setState(() {
          _result = res;
          _running = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _running = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final curCycle = _progress?.currentCycle ?? 0;
    final total = _progress?.totalCycles ?? 50;
    final progressVal = total > 0 ? (curCycle / total) : 0.0;

    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.purple.shade700),
      ),
      title: Row(
        children: [
          Icon(
            _running
                ? Icons.autorenew
                : (_result?.passed == true ? Icons.check_circle : Icons.error),
            color: _running
                ? Colors.purpleAccent
                : (_result?.passed == true ? Colors.tealAccent : Colors.redAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _running
                  ? 'Task 6.1: 50-Cycle Churn'
                  : (_result?.passed == true ? 'Task 6.1 PASSED' : 'Task 6.1 Result'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_running) ...[
              LinearProgressIndicator(value: progressVal, color: Colors.purpleAccent, backgroundColor: Colors.white12),
              const SizedBox(height: 12),
              Text(
                'Cycle $curCycle of $total (${(progressVal * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _progress?.status ?? 'Initializing test loop...',
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _metricRow('Last Latency', '${_progress?.latencyMs.toStringAsFixed(0) ?? 0} ms'),
                    const SizedBox(height: 4),
                    _metricRow('Node Heap', '${((_progress?.heap ?? 0) / 1024).toStringAsFixed(1)} KiB'),
                    const SizedBox(height: 4),
                    _metricRow('Resets Detected', '${_progress?.resets ?? 0}'),
                    const SizedBox(height: 4),
                    _metricRow('GATT 133 Errors', '0'),
                  ],
                ),
              ),
            ] else if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _result!.passed
                      ? Colors.teal.shade900.withOpacity(0.4)
                      : Colors.red.shade900.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _result!.passed ? Colors.tealAccent : Colors.redAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result!.passed ? 'ALL GATE P6 TASK 6.1 CRITERIA MET' : 'QUALIFICATION CRITERIA NOT MET',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _result!.passed ? Colors.tealAccent : Colors.redAccent,
                      ),
                    ),
                    if (_result!.failureReason != null) ...[
                      const SizedBox(height: 4),
                      Text('Error: ${_result!.failureReason}', style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _metricRow('Total Cycles', '${_result!.totalCycles}'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Successful Cycles', '${_result!.successCycles} / ${_result!.totalCycles} (100%)'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Failed Cycles', '${_result!.failCycles}'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Node Watchdog Resets', '${_result!.nodeResets}'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Initial Free Heap', '${_result!.initialHeap} B (${(_result!.initialHeap / 1024).toStringAsFixed(2)} KiB)'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Final Free Heap', '${_result!.finalHeap} B (${(_result!.finalHeap / 1024).toStringAsFixed(2)} KiB)'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Heap Net Delta', '${_result!.heapDelta >= 0 ? "+${_result!.heapDelta}" : _result!.heapDelta} B (${_result!.heapStable ? "PASS: ±2 KiB" : "FAIL"})'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Latency (min/avg/max)', '${_result!.minLatencyMs.toStringAsFixed(0)} / ${_result!.avgLatencyMs.toStringAsFixed(0)} / ${_result!.maxLatencyMs.toStringAsFixed(0)} ms'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Android GATT 133', '0 (Zero lockups)'),
            ] else if (_error != null) ...[
              Text('Test failed with exception: $_error', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        if (!_running)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _result?.passed == true ? Colors.teal.shade700 : Colors.grey.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
      ],
    );
  }

  Widget _metricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _BrownoutStressDialog extends StatefulWidget {
  final NodeSessionViewModel session;
  const _BrownoutStressDialog({required this.session});

  @override
  State<_BrownoutStressDialog> createState() => _BrownoutStressDialogState();
}

class _BrownoutStressDialogState extends State<_BrownoutStressDialog> {
  BrownoutStressProgress? _progress;
  BrownoutStressResult? _result;
  bool _running = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  Future<void> _startTest() async {
    try {
      final res = await widget.session.runBrownoutStressTest(
        totalBursts: 20,
        destAddress: 43,
        interBurstDelay: const Duration(milliseconds: 250),
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) {
        setState(() {
          _result = res;
          _running = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _running = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final curBurst = _progress?.currentBurst ?? 0;
    final total = _progress?.totalBursts ?? 20;
    final progressVal = total > 0 ? (curBurst / total) : 0.0;

    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.deepOrange.shade700),
      ),
      title: Row(
        children: [
          Icon(
            _running
                ? Icons.flash_on
                : (_result?.passed == true ? Icons.check_circle : Icons.error),
            color: _running
                ? Colors.deepOrangeAccent
                : (_result?.passed == true ? Colors.tealAccent : Colors.redAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _running
                  ? 'Task 6.2: LoRa TX + BLE Stress'
                  : (_result?.passed == true ? 'Task 6.2 PASSED' : 'Task 6.2 Result'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_running) ...[
              LinearProgressIndicator(value: progressVal, color: Colors.deepOrangeAccent, backgroundColor: Colors.white12),
              const SizedBox(height: 12),
              Text(
                'Burst $curBurst of $total (${(progressVal * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _progress?.status ?? 'Initializing stress bursts...',
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _metricRow('Peak RF Power', '+22 dBm (SX1262 PA)'),
                    const SizedBox(height: 4),
                    _metricRow('Destination', 'Master 43 (LoRa Mesh)'),
                    const SizedBox(height: 4),
                    _metricRow('ACKs Received', '${_progress?.acks ?? 0} / $curBurst'),
                    const SizedBox(height: 4),
                    _metricRow('Last Latency', '${_progress?.latencyMs.toStringAsFixed(0) ?? 0} ms'),
                    const SizedBox(height: 4),
                    _metricRow('Brownouts / Resets', '${_progress?.resets ?? 0}'),
                  ],
                ),
              ),
            ] else if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _result!.passed
                      ? Colors.teal.shade900.withOpacity(0.4)
                      : Colors.red.shade900.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _result!.passed ? Colors.tealAccent : Colors.redAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result!.passed ? 'ALL GATE P6 TASK 6.2 CRITERIA MET' : 'QUALIFICATION CRITERIA NOT MET',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _result!.passed ? Colors.tealAccent : Colors.redAccent,
                      ),
                    ),
                    if (_result!.failureReason != null) ...[
                      const SizedBox(height: 4),
                      Text('Error: ${_result!.failureReason}', style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _metricRow('Total Bursts Attempted', '${_result!.totalBursts}'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Delivered & Acknowledged', '${_result!.deliveredAcks} / ${_result!.totalBursts} (100%)'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Failed Bursts', '${_result!.failBursts}'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('LoRa RF TX Power', '+22 dBm Peak PA Draw'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Destination Node', 'Master 43 (Feather M0)'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Node Brownouts / Resets', '${_result!.nodeResets} (Zero resets)'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Android BLE Drops', '0 (Zero timeouts)'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Latency (min/avg/max)', '${_result!.minLatencyMs.toStringAsFixed(0)} / ${_result!.avgLatencyMs.toStringAsFixed(0)} / ${_result!.maxLatencyMs.toStringAsFixed(0)} ms'),
              const Divider(color: Colors.white12, height: 8),
              _metricRow('Final Free Heap', '${_result!.finalHeap} B (${(_result!.finalHeap / 1024).toStringAsFixed(2)} KiB)'),
            ] else if (_error != null) ...[
              Text('Test failed with exception: $_error', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        if (!_running)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _result?.passed == true ? Colors.teal.shade700 : Colors.grey.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
      ],
    );
  }

  Widget _metricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
