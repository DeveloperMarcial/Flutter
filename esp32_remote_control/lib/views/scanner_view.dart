import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../transport/ble_scanner_service.dart';
import '../transport/bluetooth_state_notifier.dart';
import '../viewmodels/node_session_viewmodel.dart';
import 'enrollment_dialog.dart';

class ScannerView extends StatefulWidget {
  final VoidCallback? onNodeConnected;

  const ScannerView({super.key, this.onNodeConnected});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleStartDiscovery() async {
    final scanStatus = await Permission.bluetoothScan.status;
    final connectStatus = await Permission.bluetoothConnect.status;

    if (!scanStatus.isGranted || !connectStatus.isGranted) {
      final res = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (res[Permission.bluetoothScan]?.isPermanentlyDenied == true ||
          res[Permission.bluetoothConnect]?.isPermanentlyDenied == true) {
        await openAppSettings();
        return;
      }
      if (!res[Permission.bluetoothScan]!.isGranted || !res[Permission.bluetoothConnect]!.isGranted) {
        return;
      }
    }

    if (mounted) {
      context.read<BleScannerService>().startScan();
    }
  }

  Future<void> _connectNode(DiscoveredNode node) async {
    final session = context.read<NodeSessionViewModel>();
    try {
      await session.connect(node);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal.shade800,
            content: Text('Connected to ${node.name} (MTU: ${session.negotiatedMtu} B)'),
          ),
        );
        if (session.isAuthenticated) {
          widget.onNodeConnected?.call();
        } else {
          _triggerEnrollment(node);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text('Connection failed: $e'),
          ),
        );
      }
    }
  }

  Future<void> _triggerEnrollment(DiscoveredNode node) async {
    final session = context.read<NodeSessionViewModel>();
    final enrolled = await EnrollmentDialog.show(
      context,
      nodeName: node.name,
      onEnroll: (pin) async {
        await session.enroll(pin);
      },
    );

    if (enrolled == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal.shade700,
          content: Text('Enrolled with ${node.name}! Token saved in Android Keystore.'),
        ),
      );
      widget.onNodeConnected?.call();
    }
  }

  Widget _buildRssiBars(int rssi) {
    int bars = 1;
    Color barColor = Colors.redAccent;
    if (rssi >= -60) {
      bars = 4;
      barColor = Colors.tealAccent;
    } else if (rssi >= -72) {
      bars = 3;
      barColor = Colors.greenAccent;
    } else if (rssi >= -82) {
      bars = 2;
      barColor = Colors.amberAccent;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final height = (index + 1) * 4.0 + 4.0;
        final isActive = index < bars;
        return Container(
          width: 3.5,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? barColor : Colors.white24,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanner = context.watch<BleScannerService>();
    final session = context.watch<NodeSessionViewModel>();
    final btState = context.watch<BluetoothStateNotifier>();

    return Column(
      children: [
        if (!btState.isPoweredOn)
          Container(
            color: Colors.amber.shade900,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.bluetooth_disabled, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Bluetooth is disabled. Please turn on Bluetooth.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => btState.turnOn(),
                  child: const Text('Enable'),
                ),
              ],
            ),
          ),

        // Radar Scan Bar Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900.withValues(alpha: 0.8),
            border: Border(bottom: BorderSide(color: Colors.teal.shade800, width: 1)),
          ),
          child: Row(
            children: [
              // Radar animation icon
              if (scanner.isScanning)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _RadarPulsePainter(_pulseController.value),
                      );
                    },
                  ),
                )
              else
                Icon(Icons.radar, color: Colors.tealAccent.shade400, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scanner.isScanning ? 'Scanning for Mesh eNodes...' : 'Discovery Idle',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      scanner.isScanning
                          ? '${scanner.nodeList.length} node(s) found in RF range'
                          : 'Tap Discover to search for advertising eNodes',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: scanner.isScanning
                    ? () => scanner.stopScan()
                    : _handleStartDiscovery,
                icon: Icon(scanner.isScanning ? Icons.stop : Icons.search, size: 18),
                label: Text(scanner.isScanning ? 'Stop' : 'Discover'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scanner.isScanning ? Colors.red.shade800 : Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Discovered Devices List
        Expanded(
          child: scanner.nodeList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (scanner.isScanning) ...[
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _RadarPulsePainter(_pulseController.value, ringCount: 3),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Listening for eNode BLE advertisements...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ] else ...[
                        Icon(Icons.cell_tower, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        const Text(
                          'No eNodes Discovered',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Verify eNode is powered on and within range',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _handleStartDiscovery,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Start Discovery'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: scanner.nodeList.length,
                  itemBuilder: (context, index) {
                    final node = scanner.nodeList[index];
                    final isCurrentConnected =
                        session.isConnected && session.currentNode?.id == node.id;
                    final isConnectingThis =
                        session.isConnecting && session.currentNode?.id == node.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      elevation: isCurrentConnected ? 4 : 1,
                      color: isCurrentConnected
                          ? Colors.teal.shade900.withValues(alpha: 0.6)
                          : Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isCurrentConnected
                              ? Colors.tealAccent.shade400
                              : Colors.white12,
                          width: isCurrentConnected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isCurrentConnected
                                  ? Colors.tealAccent.shade700
                                  : Colors.blueGrey.shade800,
                              child: Icon(
                                isCurrentConnected
                                    ? Icons.bluetooth_connected
                                    : Icons.router,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        node.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isCurrentConnected)
                                        Chip(
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                          label: Text(
                                            session.isAuthenticated
                                                ? 'ENROLLED'
                                                : 'CONNECTED',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: session.isAuthenticated
                                              ? Colors.teal
                                              : Colors.orange.shade800,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    node.id,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildRssiBars(node.rssi),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${node.rssi} dBm',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Direct connection state button
                            if (isConnectingThis)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              )
                            else if (isCurrentConnected)
                              ElevatedButton(
                                onPressed: () => session.disconnect(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade800,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Disconnect'),
                              )
                            else
                              ElevatedButton(
                                onPressed: session.isConnecting ? null : () => _connectNode(node),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade700,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Connect'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double progress;
  final int ringCount;

  _RadarPulsePainter(this.progress, {this.ringCount = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (progress + (i / ringCount)) % 1.0;
      final radius = maxRadius * ringProgress;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }

    final centerDotPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
