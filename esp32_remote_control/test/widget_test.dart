import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:esp32_remote_control/main.dart';
import 'package:esp32_remote_control/services/trace_log_service.dart';
import 'package:esp32_remote_control/transport/bluetooth_state_notifier.dart';
import 'package:esp32_remote_control/transport/ble_scanner_service.dart';
import 'package:esp32_remote_control/transport/ble_remote_transport.dart';
import 'package:esp32_remote_control/vault/token_vault.dart';
import 'package:esp32_remote_control/viewmodels/node_session_viewmodel.dart';
import 'token_vault_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final vault = TokenVault(storage: FakeSecureStorage());
    final traceLog = TraceLogService();
    final transport = BleRemoteTransport(traceLog: traceLog);

    await tester.pumpWidget(
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

    expect(find.text('ESP32 BLE Mesh Remote'), findsOneWidget);
  });
}
