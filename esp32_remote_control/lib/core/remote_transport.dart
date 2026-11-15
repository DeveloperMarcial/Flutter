import 'package:protobuf/protobuf.dart';
import '../generated/esp_remote.pb.dart';

abstract class RemoteTransport {
  bool get isConnected;
  int get negotiatedMtu;
  Stream<EventNotification> get eventStream;
  Stream<bool> get connectionStream;

  Future<void> connect(String deviceId);
  Future<void> disconnect();

  Future<RemoteResponse> executeRequest({
    required RemoteOp op,
    GeneratedMessage? args,
    String? authToken,
    Duration timeout = const Duration(seconds: 10),
  });

  Future<String> readMetadata();
}
