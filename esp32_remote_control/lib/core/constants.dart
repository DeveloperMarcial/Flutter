class BleConstants {
  static const String serviceUuid = '4d657368-0001-4147-5930-000000000001';
  static const String charReqUuid = '4d657368-0002-4147-5930-000000000001';
  static const String charRespUuid = '4d657368-0003-4147-5930-000000000001';
  static const String charMetaUuid = '4d657368-0004-4147-5930-000000000001';

  static const int fragHeaderLen = 3;
  static const Duration reassemblyTimeout = Duration(seconds: 5);
  static const Duration defaultRequestTimeout = Duration(seconds: 10);
  static const int requestedMtu = 256;
  static const int defaultAttMtu = 23;
}
