import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/esp_remote.pb.dart';
import '../viewmodels/node_session_viewmodel.dart';

class NodeDashboardView extends StatefulWidget {
  const NodeDashboardView({super.key});

  @override
  State<NodeDashboardView> createState() => _NodeDashboardViewState();
}

class _NodeDashboardViewState extends State<NodeDashboardView> {
  final TextEditingController _pingTargetController = TextEditingController(text: '43');
  final TextEditingController _sendDestController = TextEditingController(text: '43');
  final TextEditingController _sendTextController = TextEditingController(text: 'Hello from Flutter Mobile');

  @override
  void dispose() {
    _pingTargetController.dispose();
    _sendDestController.dispose();
    _sendTextController.dispose();
    super.dispose();
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final rem1 = seconds % 86400;
    final hours = rem1 ~/ 3600;
    final rem2 = rem1 % 3600;
    final minutes = rem2 ~/ 60;
    final secs = rem2 % 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    parts.add('${minutes}m');
    parts.add('${secs}s');
    return parts.join(' ');
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Command Action Strip
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              ActionChip(
                avatar: const Icon(Icons.info_outline, size: 16),
                label: const Text('Hello (4.1)'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          final h = await session.getHello();
                          _showSnack('Hello: Node ${h.nodeAddress} (${h.nodeName}) Profile ${h.hwProfile}');
                        } catch (e) {
                          _showSnack('Hello failed: $e', isError: true);
                        }
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.monitor_heart_outlined, size: 16),
                label: const Text('Status (4.2)'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          await session.getStatus();
                          _showSnack('Status refreshed!');
                        } catch (e) {
                          _showSnack('Status failed: $e', isError: true);
                        }
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.people_outline, size: 16),
                label: const Text('Peers (4.3)'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          final peers = await session.getPeers();
                          _showSnack('Peers loaded: ${peers.length} active');
                        } catch (e) {
                          _showSnack('Peers failed: $e', isError: true);
                        }
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.location_on_outlined, size: 16),
                label: const Text('GNSS (4.4)'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          await session.getGnss();
                          _showSnack('GNSS queried');
                        } catch (e) {
                          _showSnack('GNSS query failed: $e', isError: true);
                        }
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.alt_route, size: 16),
                label: const Text('Routes (4.5)'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          final routes = await session.getRoutes();
                          _showSnack('Routes loaded: ${routes.length} paths');
                        } catch (e) {
                          _showSnack('Routes failed: $e', isError: true);
                        }
                      },
              ),
              ActionChip(
                avatar: const Icon(Icons.notifications_active_outlined, size: 16),
                label: const Text('Watch (4.7)'),
                onPressed: session.isExecutingCommand
                    ? null
                    : () async {
                        try {
                          await session.subscribeEvents();
                          _showSnack('Subscribed to live mesh events');
                        } catch (e) {
                          _showSnack('Event subscription failed: $e', isError: true);
                        }
                      },
              ),
            ],
          ),
          if (session.isExecutingCommand) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(color: Colors.tealAccent.shade400),
          ],
          const SizedBox(height: 12),

          // Task 4.2 Status Card
          if (session.statusResult != null) _buildStatusCard(session.statusResult!),

          // Task 4.5 Mesh Ping Card
          _buildPingCard(session),

          // Task 4.6 Authenticated Send Card
          _buildSendCard(session),

          // Task 4.3 Peer Roster Card
          if (session.peers.isNotEmpty) _buildPeersCard(session.peers),

          // Task 4.5 Routes Card
          if (session.routes.isNotEmpty) _buildRoutesCard(session.routes),

          // Task 4.4 GNSS Card
          if (session.gnssResult != null) _buildGnssCard(session.gnssResult!),

          // Task 4.7 Live Event Notifications Log
          _buildEventsLog(session.recentEvents),
        ],
      ),
    );
  }

  Widget _buildStatusCard(NodeStatusResult status) {
    final freeKiB = (status.freeHeap / 1024.0).toStringAsFixed(1);
    final minKiB = (status.minFreeHeap / 1024.0).toStringAsFixed(1);

    return Card(
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.tealAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Node Status & Health (Task 4.2)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    status.meshOnline ? 'MESH ONLINE' : 'OFFLINE',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: status.meshOnline ? Colors.teal.shade800 : Colors.red.shade900,
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem('Running Slot', status.runningSlot),
                _statItem('Uptime', _formatUptime(status.uptimeSeconds.toInt())),
                _statItem('Free Heap', '$freeKiB KiB'),
                _statItem('Min Heap', '$minKiB KiB'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'OTA State: ${status.otaState} | Owner Master: ${status.ownerMasterId}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPingCard(NodeSessionViewModel session) {
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.network_ping, color: Colors.lightBlueAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Mesh Ping (Task 4.5)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (session.lastPingResult != null) ...[
                  const Spacer(),
                  Chip(
                    label: Text(
                      session.lastPingResult!.success
                          ? 'RTT: ${session.lastPingResult!.rttMs} ms'
                          : 'FAILED',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: session.lastPingResult!.success
                        ? Colors.teal.shade700
                        : Colors.red.shade900,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _pingTargetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Node',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: session.isExecutingCommand
                      ? null
                      : () async {
                          final target = int.tryParse(_pingTargetController.text.trim()) ?? 43;
                          try {
                            final res = await session.ping(target);
                            _showSnack(
                              res.success
                                  ? 'Ping to $target succeeded! RTT: ${res.rttMs} ms'
                                  : 'Ping to $target timed out',
                              isError: !res.success,
                            );
                          } catch (e) {
                            _showSnack('Ping failed: $e', isError: true);
                          }
                        },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Execute Ping'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendCard(NodeSessionViewModel session) {
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.send_outlined, color: Colors.amberAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Authenticated Mesh Send (Task 4.6)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (session.lastSendResult != null) ...[
                  const Spacer(),
                  Chip(
                    label: Text(
                      'Msg ID: ${session.lastSendResult!.messageId}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.teal.shade700,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _sendDestController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Dest',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _sendTextController,
                    decoration: const InputDecoration(
                      labelText: 'Message Text',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: session.isExecutingCommand
                      ? null
                      : () async {
                          final dest = int.tryParse(_sendDestController.text.trim()) ?? 43;
                          final text = _sendTextController.text.trim();
                          if (text.isEmpty) return;
                          try {
                            final res = await session.sendMessage(dest, text);
                            _showSnack('[OK] Delivered to $dest (Msg ID: ${res.messageId})');
                          } catch (e) {
                            _showSnack('Send failed: $e', isError: true);
                          }
                        },
                  icon: const Icon(Icons.send, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeersCard(List<PeerInfo> peers) {
    return Card(
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_outlined, color: Colors.tealAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Active Peer Roster (Task 4.3: ${peers.length} peers)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(),
            ...peers.map((p) {
              final last = p.lastHeardSec > 0 ? '${p.lastHeardSec}s ago' : 'Never';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Address: ${p.address}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(p.name.isNotEmpty ? p.name : '<unnamed>', style: const TextStyle(fontSize: 13)),
                    Text(last, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutesCard(List<RouteInfo> routes) {
    return Card(
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alt_route, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Mesh Routes (Task 4.5: ${routes.length} paths)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(),
            ...routes.map((r) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dest: ${r.destAddress}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Next Hop: ${r.nextHop}'),
                    Text('State: ${r.state}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGnssCard(GnssGetResult gnss) {
    return Card(
      color: Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.satellite_alt, color: Colors.tealAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'GNSS Telemetry (Task 4.4)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    gnss.fixValid ? '3D FIX' : 'NO FIX / WAITING',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: gnss.fixValid ? Colors.teal.shade800 : Colors.grey.shade800,
                ),
              ],
            ),
            const Divider(),
            if (gnss.fixValid) ...[
              Text('Latitude: ${(gnss.latitudeScaled / 1e7).toStringAsFixed(7)}'),
              Text('Longitude: ${(gnss.longitudeScaled / 1e7).toStringAsFixed(7)}'),
              Text('Satellites: ${gnss.satellitesUsed} | Altitude: ${gnss.altitudeMeters} m'),
            ] else ...[
              const Text(
                'Hardware Profile: gnss=disabled / no fix (matches bench boardinfo)',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventsLog(List<EventNotification> events) {
    return Card(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stream, color: Colors.purpleAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Live Event Notifications (Task 4.7: ${events.length} received)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No unsolicited events received yet. Tap "Watch (4.7)" to subscribe.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              )
            else
              ...events.take(10).map((evt) {
                final typeStr = evt.eventType.name;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade900,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeStr,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'From ${evt.fromAddress}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Expanded(
                        child: Text(
                          evt.payloadText,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
