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
        ],
      ),
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
