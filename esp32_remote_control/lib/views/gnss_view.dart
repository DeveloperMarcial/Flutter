import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/node_session_viewmodel.dart';

class GnssView extends StatefulWidget {
  const GnssView({super.key});

  @override
  State<GnssView> createState() => _GnssViewState();
}

class _GnssViewState extends State<GnssView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<NodeSessionViewModel>();
      if (session.isConnected && session.isAuthenticated && session.gnssResult == null) {
        session.getGnss();
      }
    });
  }

  void _copyCoordinates(double lat, double lon) {
    Clipboard.setData(ClipboardData(text: '$lat, $lon'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coordinates copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<NodeSessionViewModel>();
    final gnss = session.gnssResult;

    final hasFix = gnss?.fixValid == true;
    final lat = (gnss?.latitudeScaled ?? 0) / 1e7;
    final lon = (gnss?.longitudeScaled ?? 0) / 1e7;
    final alt = gnss?.altitudeMeters ?? 0;
    final sats = gnss?.satellitesUsed ?? 0;
    final hdop = (gnss?.hdopScaled ?? 0) / 100.0;
    final fixAge = gnss?.fixAgeMs ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Header Card
          Card(
            elevation: 3,
            color: hasFix
                ? Colors.teal.shade900.withValues(alpha: 0.8)
                : Colors.blueGrey.shade900.withValues(alpha: 0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: hasFix ? Colors.tealAccent : Colors.white24,
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: hasFix ? Colors.teal : Colors.blueGrey.shade800,
                    child: Icon(
                      hasFix ? Icons.gps_fixed : Icons.gps_off,
                      color: hasFix ? Colors.tealAccent : Colors.orangeAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasFix ? '3D GNSS FIX ACQUIRED' : 'NO FIX / WAITING',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: hasFix ? Colors.tealAccent : Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasFix
                              ? 'Satellites: $sats | HDOP: ${hdop.toStringAsFixed(2)} | Age: ${fixAge}ms'
                              : 'Bench hardware profile: gnss=disabled or searching sky',
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: session.isExecutingCommand
                        ? null
                        : () async {
                            try {
                              await session.getGnss();
                            } catch (_) {}
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade800,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: session.isExecutingCommand
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Poll'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Coordinate details card
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
                        'Coordinate Telemetry',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (hasFix)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy Coordinates',
                          onPressed: () => _copyCoordinates(lat, lon),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasFix) ...[
                    _buildCoordRow('Latitude', '${lat.toStringAsFixed(6)}°'),
                    const Divider(color: Colors.white12, height: 16),
                    _buildCoordRow('Longitude', '${lon.toStringAsFixed(6)}°'),
                    const Divider(color: Colors.white12, height: 16),
                    _buildCoordRow('Altitude (MSL)', '$alt meters'),
                    const Divider(color: Colors.white12, height: 16),
                    _buildCoordRow('Satellites Used', '$sats'),
                    const Divider(color: Colors.white12, height: 16),
                    _buildCoordRow('Horizontal Dilution (HDOP)', hdop.toStringAsFixed(2)),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.satellite_alt, size: 40, color: Colors.grey.shade600),
                          const SizedBox(height: 8),
                          const Text(
                            'GNSS Receiver Inactive / Bench Configuration',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'eNode-48 and eNode-49 bench hardware profiles are built with gnss=disabled. Once deployed with an active GPS antenna, real-time latitude, longitude, and altitude telemetry will display here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
