import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/trace_log_service.dart';
import 'transport/bluetooth_state_notifier.dart';
import 'transport/ble_scanner_service.dart';
import 'transport/ble_remote_transport.dart';
import 'vault/token_vault.dart';
import 'viewmodels/node_session_viewmodel.dart';
import 'views/enrollment_dialog.dart';
import 'views/scanner_view.dart';
import 'views/dashboard_view.dart';
import 'views/peer_view.dart';
import 'views/gnss_view.dart';
import 'views/chat_view.dart';
import 'views/live_trace_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final vault = TokenVault();
  final traceLog = TraceLogService();
  final transport = BleRemoteTransport(traceLog: traceLog);

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenVault>.value(value: vault),
        Provider<BleRemoteTransport>.value(value: transport),
        ChangeNotifierProvider<TraceLogService>.value(value: traceLog),
        ChangeNotifierProvider(create: (_) => BluetoothStateNotifier()),
        ChangeNotifierProvider(create: (_) => BleScannerService()),
        ChangeNotifierProvider(
          create: (_) => NodeSessionViewModel(
            transport: transport,
            vault: vault,
            traceLog: traceLog,
          ),
        ),
      ],
      child: const Esp32RemoteApp(),
    ),
  );
}

class Esp32RemoteApp extends StatelessWidget {
  const Esp32RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 BLE Mesh Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with WidgetsBindingObserver {
  int _currentTabIndex = 0;
  bool _forceShowScanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestInitialPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _requestInitialPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  /// Task 5.6: Android App Lifecycle Management
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final traceLog = context.read<TraceLogService>();
    final session = context.read<NodeSessionViewModel>();

    switch (state) {
      case AppLifecycleState.paused:
        traceLog.logControl('LIFECYCLE', 'App backgrounded / paused');
        break;
      case AppLifecycleState.resumed:
        traceLog.logControl('LIFECYCLE', 'App resumed to foreground');
        if (session.isConnected && session.isAuthenticated) {
          traceLog.logControl('SYNC', 'Refreshing status and event subscriptions');
          session.getStatus().then((_) {}, onError: (_) {});
          session.subscribeEvents().then((_) {}, onError: (_) {});
        }
        break;
      case AppLifecycleState.inactive:
        traceLog.logControl('LIFECYCLE', 'App inactive');
        break;
      case AppLifecycleState.detached:
        traceLog.logControl('LIFECYCLE', 'App detached');
        break;
      case AppLifecycleState.hidden:
        traceLog.logControl('LIFECYCLE', 'App hidden');
        break;
    }
  }

  Future<void> _triggerEnrollment() async {
    final session = context.read<NodeSessionViewModel>();
    final nodeName = session.currentNode?.name ?? 'Node';

    final enrolled = await EnrollmentDialog.show(
      context,
      nodeName: nodeName,
      onEnroll: (pin) async {
        await session.enroll(pin);
      },
    );

    if (enrolled == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal.shade700,
          content: Text('Enrolled with $nodeName! Token saved in Android Keystore.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<NodeSessionViewModel>();
    final isConnected = session.isConnected;
    final isAuth = session.isAuthenticated;

    final showScanner = !isConnected || _forceShowScanner;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
              color: isConnected ? Colors.tealAccent : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isConnected
                  ? (session.currentNode?.name ?? 'Connected Node')
                  : 'ESP32 BLE Mesh Remote',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (isConnected) ...[
            if (_forceShowScanner)
              IconButton(
                icon: const Icon(Icons.dashboard_outlined),
                tooltip: 'Return to Node Dashboard',
                onPressed: () {
                  setState(() {
                    _forceShowScanner = false;
                  });
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.radar),
                tooltip: 'Show BLE Scanner',
                onPressed: () {
                  setState(() {
                    _forceShowScanner = true;
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.power_settings_new),
              tooltip: 'Disconnect',
              onPressed: () => session.disconnect(),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Enrollment Banner if connected but unauthenticated
          if (isConnected && !isAuth)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.orange.shade900,
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'PIN enrollment required before sending mesh commands.',
                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _triggerEnrollment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade900,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Enroll PIN'),
                  ),
                ],
              ),
            ),

          // Main View Content
          Expanded(
            child: showScanner
                ? ScannerView(
                    onNodeConnected: () {
                      setState(() {
                        _forceShowScanner = false;
                        _currentTabIndex = 0;
                      });
                    },
                  )
                : IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      DashboardView(
                        onNavigateToPeers: () => setState(() => _currentTabIndex = 1),
                        onNavigateToChat: () => setState(() => _currentTabIndex = 3),
                      ),
                      const PeerView(),
                      const GnssView(),
                      const ChatView(),
                      const LiveTraceView(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: (!showScanner && isConnected)
          ? NavigationBar(
              selectedIndex: _currentTabIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Peers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on),
                  label: 'GNSS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.terminal_outlined),
                  selectedIcon: Icon(Icons.terminal),
                  label: 'Trace',
                ),
              ],
            )
          : null,
    );
  }
}
