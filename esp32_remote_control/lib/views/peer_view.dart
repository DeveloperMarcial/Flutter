import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/node_session_viewmodel.dart';

class PeerView extends StatefulWidget {
  const PeerView({super.key});

  @override
  State<PeerView> createState() => _PeerViewState();
}

class _PeerViewState extends State<PeerView> {
  String _filter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<NodeSessionViewModel>();
      if (session.isConnected && session.isAuthenticated && session.peers.isEmpty) {
        session.getPeers();
        session.getRoutes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getRole(int address) {
    if (address == 42 || address == 43) {
      return 'MASTER ROUTER';
    } else if (address == 48 || address == 49) {
      return 'ESP32-S3 eNODE';
    } else {
      return 'MESH NODE';
    }
  }

  Color _getRoleColor(int address) {
    if (address == 42 || address == 43) {
      return Colors.amber.shade700;
    } else if (address == 48 || address == 49) {
      return Colors.teal;
    } else {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<NodeSessionViewModel>();
    final peers = session.peers;
    final rttMap = session.peerPingRttMs;

    final filteredPeers = peers.where((p) {
      if (_filter == 'MASTERS' && !(p.address == 42 || p.address == 43)) {
        return false;
      }
      if (_filter == 'NODES' && (p.address == 42 || p.address == 43)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final matchesAddr = p.address.toString().contains(_searchQuery);
        final matchesName = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matchesAddr && !matchesName) return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filter and Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.grey.shade900,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by node # or name...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: session.isExecutingCommand
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    tooltip: 'Refresh Peer List',
                    onPressed: session.isExecutingCommand
                        ? null
                        : () async {
                            try {
                              await session.getPeers();
                              await session.getRoutes();
                            } catch (_) {}
                          },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildFilterChip('ALL', 'All (${peers.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('MASTERS', 'Masters'),
                  const SizedBox(width: 8),
                  _buildFilterChip('NODES', 'Nodes / Relays'),
                ],
              ),
            ],
          ),
        ),

        // Peer List
        Expanded(
          child: filteredPeers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 56, color: Colors.grey.shade600),
                      const SizedBox(height: 12),
                      Text(
                        peers.isEmpty ? 'No mesh peers heard yet' : 'No matching peers',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await session.getPeers();
                          await session.getRoutes();
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Poll Peers'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredPeers.length,
                  itemBuilder: (context, index) {
                    final peer = filteredPeers[index];
                    final rtt = rttMap[peer.address];
                    final role = _getRole(peer.address);
                    final roleColor = _getRoleColor(peer.address);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.white12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: roleColor,
                              child: Text(
                                '${peer.address}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
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
                                        peer.name.isNotEmpty ? peer.name : 'Node ${peer.address}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: roleColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: roleColor.withValues(alpha: 0.6), width: 0.8),
                                        ),
                                        child: Text(
                                          role,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: roleColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Last Heard: ${peer.lastHeardSec}s ago',
                                        style: const TextStyle(fontSize: 11, color: Colors.white60),
                                      ),
                                      if (rtt != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: rtt >= 0 ? Colors.teal.shade900 : Colors.red.shade900,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            rtt >= 0 ? 'RTT: $rtt ms' : 'TIMEOUT',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: rtt >= 0 ? Colors.tealAccent : Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 1-Tap Ping Button
                            ElevatedButton.icon(
                              onPressed: session.isExecutingCommand
                                  ? null
                                  : () async {
                                      try {
                                        await session.pingPeer(peer.address);
                                      } catch (_) {}
                                    },
                              icon: const Icon(Icons.network_ping, size: 15),
                              label: const Text('Ping', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade800,
                                foregroundColor: Colors.white,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              ),
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

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filter = key;
        });
      },
      selectedColor: Colors.teal.shade700,
      visualDensity: VisualDensity.compact,
    );
  }
}
