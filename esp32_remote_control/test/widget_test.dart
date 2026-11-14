import 'package:flutter_test/flutter_test.dart';
import 'package:esp32_remote_control/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Esp32RemoteApp());
    expect(find.text('ESP32-S3 Mesh Remote Control Initialized'), findsOneWidget);
  });
}
