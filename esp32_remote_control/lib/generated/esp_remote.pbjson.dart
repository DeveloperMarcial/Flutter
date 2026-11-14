// This is a generated file - do not edit.
//
// Generated from esp_remote.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use remoteOpDescriptor instead')
const RemoteOp$json = {
  '1': 'RemoteOp',
  '2': [
    {'1': 'OP_UNSPECIFIED', '2': 0},
    {'1': 'OP_HELLO', '2': 1},
    {'1': 'OP_NODE_STATUS', '2': 2},
    {'1': 'OP_PEER_ROSTER', '2': 3},
    {'1': 'OP_GNSS_GET', '2': 4},
    {'1': 'OP_ROUTES_GET', '2': 5},
    {'1': 'OP_PING', '2': 6},
    {'1': 'OP_MESSAGE_SEND', '2': 7},
    {'1': 'OP_EVENT_SUB', '2': 8},
  ],
};

/// Descriptor for `RemoteOp`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List remoteOpDescriptor = $convert.base64Decode(
    'CghSZW1vdGVPcBISCg5PUF9VTlNQRUNJRklFRBAAEgwKCE9QX0hFTExPEAESEgoOT1BfTk9ERV'
    '9TVEFUVVMQAhISCg5PUF9QRUVSX1JPU1RFUhADEg8KC09QX0dOU1NfR0VUEAQSEQoNT1BfUk9V'
    'VEVTX0dFVBAFEgsKB09QX1BJTkcQBhITCg9PUF9NRVNTQUdFX1NFTkQQBxIQCgxPUF9FVkVOVF'
    '9TVUIQCA==');

@$core.Deprecated('Use remoteRequestDescriptor instead')
const RemoteRequest$json = {
  '1': 'RemoteRequest',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 13, '10': 'version'},
    {'1': 'request_id', '3': 2, '4': 1, '5': 13, '10': 'requestId'},
    {
      '1': 'op',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.esp_remote.RemoteOp',
      '10': 'op'
    },
    {'1': 'auth_token', '3': 12, '4': 1, '5': 9, '10': 'authToken'},
    {
      '1': 'hello_args',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.HelloArgs',
      '9': 0,
      '10': 'helloArgs'
    },
    {
      '1': 'status_args',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.NodeStatusArgs',
      '9': 0,
      '10': 'statusArgs'
    },
    {
      '1': 'roster_args',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.PeerRosterArgs',
      '9': 0,
      '10': 'rosterArgs'
    },
    {
      '1': 'gnss_args',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.GnssGetArgs',
      '9': 0,
      '10': 'gnssArgs'
    },
    {
      '1': 'routes_args',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.RoutesGetArgs',
      '9': 0,
      '10': 'routesArgs'
    },
    {
      '1': 'ping_args',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.PingArgs',
      '9': 0,
      '10': 'pingArgs'
    },
    {
      '1': 'message_send_args',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.MessageSendArgs',
      '9': 0,
      '10': 'messageSendArgs'
    },
    {
      '1': 'event_sub_args',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.EventSubArgs',
      '9': 0,
      '10': 'eventSubArgs'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `RemoteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List remoteRequestDescriptor = $convert.base64Decode(
    'Cg1SZW1vdGVSZXF1ZXN0EhgKB3ZlcnNpb24YASABKA1SB3ZlcnNpb24SHQoKcmVxdWVzdF9pZB'
    'gCIAEoDVIJcmVxdWVzdElkEiQKAm9wGAMgASgOMhQuZXNwX3JlbW90ZS5SZW1vdGVPcFICb3AS'
    'HQoKYXV0aF90b2tlbhgMIAEoCVIJYXV0aFRva2VuEjYKCmhlbGxvX2FyZ3MYBCABKAsyFS5lc3'
    'BfcmVtb3RlLkhlbGxvQXJnc0gAUgloZWxsb0FyZ3MSPQoLc3RhdHVzX2FyZ3MYBSABKAsyGi5l'
    'c3BfcmVtb3RlLk5vZGVTdGF0dXNBcmdzSABSCnN0YXR1c0FyZ3MSPQoLcm9zdGVyX2FyZ3MYBi'
    'ABKAsyGi5lc3BfcmVtb3RlLlBlZXJSb3N0ZXJBcmdzSABSCnJvc3RlckFyZ3MSNgoJZ25zc19h'
    'cmdzGAcgASgLMhcuZXNwX3JlbW90ZS5HbnNzR2V0QXJnc0gAUghnbnNzQXJncxI8Cgtyb3V0ZX'
    'NfYXJncxgIIAEoCzIZLmVzcF9yZW1vdGUuUm91dGVzR2V0QXJnc0gAUgpyb3V0ZXNBcmdzEjMK'
    'CXBpbmdfYXJncxgJIAEoCzIULmVzcF9yZW1vdGUuUGluZ0FyZ3NIAFIIcGluZ0FyZ3MSSQoRbW'
    'Vzc2FnZV9zZW5kX2FyZ3MYCiABKAsyGy5lc3BfcmVtb3RlLk1lc3NhZ2VTZW5kQXJnc0gAUg9t'
    'ZXNzYWdlU2VuZEFyZ3MSQAoOZXZlbnRfc3ViX2FyZ3MYCyABKAsyGC5lc3BfcmVtb3RlLkV2ZW'
    '50U3ViQXJnc0gAUgxldmVudFN1YkFyZ3NCCQoHcGF5bG9hZA==');

@$core.Deprecated('Use helloArgsDescriptor instead')
const HelloArgs$json = {
  '1': 'HelloArgs',
};

/// Descriptor for `HelloArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List helloArgsDescriptor =
    $convert.base64Decode('CglIZWxsb0FyZ3M=');

@$core.Deprecated('Use nodeStatusArgsDescriptor instead')
const NodeStatusArgs$json = {
  '1': 'NodeStatusArgs',
};

/// Descriptor for `NodeStatusArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeStatusArgsDescriptor =
    $convert.base64Decode('Cg5Ob2RlU3RhdHVzQXJncw==');

@$core.Deprecated('Use peerRosterArgsDescriptor instead')
const PeerRosterArgs$json = {
  '1': 'PeerRosterArgs',
};

/// Descriptor for `PeerRosterArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List peerRosterArgsDescriptor =
    $convert.base64Decode('Cg5QZWVyUm9zdGVyQXJncw==');

@$core.Deprecated('Use gnssGetArgsDescriptor instead')
const GnssGetArgs$json = {
  '1': 'GnssGetArgs',
};

/// Descriptor for `GnssGetArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gnssGetArgsDescriptor =
    $convert.base64Decode('CgtHbnNzR2V0QXJncw==');

@$core.Deprecated('Use routesGetArgsDescriptor instead')
const RoutesGetArgs$json = {
  '1': 'RoutesGetArgs',
};

/// Descriptor for `RoutesGetArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routesGetArgsDescriptor =
    $convert.base64Decode('Cg1Sb3V0ZXNHZXRBcmdz');

@$core.Deprecated('Use pingArgsDescriptor instead')
const PingArgs$json = {
  '1': 'PingArgs',
  '2': [
    {'1': 'target_address', '3': 1, '4': 1, '5': 13, '10': 'targetAddress'},
  ],
};

/// Descriptor for `PingArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingArgsDescriptor = $convert.base64Decode(
    'CghQaW5nQXJncxIlCg50YXJnZXRfYWRkcmVzcxgBIAEoDVINdGFyZ2V0QWRkcmVzcw==');

@$core.Deprecated('Use messageSendArgsDescriptor instead')
const MessageSendArgs$json = {
  '1': 'MessageSendArgs',
  '2': [
    {'1': 'dest_address', '3': 1, '4': 1, '5': 13, '10': 'destAddress'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `MessageSendArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSendArgsDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlU2VuZEFyZ3MSIQoMZGVzdF9hZGRyZXNzGAEgASgNUgtkZXN0QWRkcmVzcxISCg'
    'R0ZXh0GAIgASgJUgR0ZXh0');

@$core.Deprecated('Use eventSubArgsDescriptor instead')
const EventSubArgs$json = {
  '1': 'EventSubArgs',
  '2': [
    {
      '1': 'subscribe_messages',
      '3': 1,
      '4': 1,
      '5': 8,
      '10': 'subscribeMessages'
    },
    {
      '1': 'subscribe_telemetry',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'subscribeTelemetry'
    },
    {'1': 'subscribe_status', '3': 3, '4': 1, '5': 8, '10': 'subscribeStatus'},
  ],
};

/// Descriptor for `EventSubArgs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventSubArgsDescriptor = $convert.base64Decode(
    'CgxFdmVudFN1YkFyZ3MSLQoSc3Vic2NyaWJlX21lc3NhZ2VzGAEgASgIUhFzdWJzY3JpYmVNZX'
    'NzYWdlcxIvChNzdWJzY3JpYmVfdGVsZW1ldHJ5GAIgASgIUhJzdWJzY3JpYmVUZWxlbWV0cnkS'
    'KQoQc3Vic2NyaWJlX3N0YXR1cxgDIAEoCFIPc3Vic2NyaWJlU3RhdHVz');

@$core.Deprecated('Use remoteResponseDescriptor instead')
const RemoteResponse$json = {
  '1': 'RemoteResponse',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 13, '10': 'version'},
    {'1': 'request_id', '3': 2, '4': 1, '5': 13, '10': 'requestId'},
    {'1': 'ok', '3': 3, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'error_code', '3': 4, '4': 1, '5': 9, '10': 'errorCode'},
    {
      '1': 'hello_result',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.HelloResult',
      '9': 0,
      '10': 'helloResult'
    },
    {
      '1': 'status_result',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.NodeStatusResult',
      '9': 0,
      '10': 'statusResult'
    },
    {
      '1': 'roster_result',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.PeerRosterResult',
      '9': 0,
      '10': 'rosterResult'
    },
    {
      '1': 'gnss_result',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.GnssGetResult',
      '9': 0,
      '10': 'gnssResult'
    },
    {
      '1': 'routes_result',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.RoutesGetResult',
      '9': 0,
      '10': 'routesResult'
    },
    {
      '1': 'ping_result',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.PingResult',
      '9': 0,
      '10': 'pingResult'
    },
    {
      '1': 'message_send_result',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.MessageSendResult',
      '9': 0,
      '10': 'messageSendResult'
    },
    {
      '1': 'event_notification',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.esp_remote.EventNotification',
      '9': 0,
      '10': 'eventNotification'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `RemoteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List remoteResponseDescriptor = $convert.base64Decode(
    'Cg5SZW1vdGVSZXNwb25zZRIYCgd2ZXJzaW9uGAEgASgNUgd2ZXJzaW9uEh0KCnJlcXVlc3RfaW'
    'QYAiABKA1SCXJlcXVlc3RJZBIOCgJvaxgDIAEoCFICb2sSHQoKZXJyb3JfY29kZRgEIAEoCVIJ'
    'ZXJyb3JDb2RlEjwKDGhlbGxvX3Jlc3VsdBgFIAEoCzIXLmVzcF9yZW1vdGUuSGVsbG9SZXN1bH'
    'RIAFILaGVsbG9SZXN1bHQSQwoNc3RhdHVzX3Jlc3VsdBgGIAEoCzIcLmVzcF9yZW1vdGUuTm9k'
    'ZVN0YXR1c1Jlc3VsdEgAUgxzdGF0dXNSZXN1bHQSQwoNcm9zdGVyX3Jlc3VsdBgHIAEoCzIcLm'
    'VzcF9yZW1vdGUuUGVlclJvc3RlclJlc3VsdEgAUgxyb3N0ZXJSZXN1bHQSPAoLZ25zc19yZXN1'
    'bHQYCCABKAsyGS5lc3BfcmVtb3RlLkduc3NHZXRSZXN1bHRIAFIKZ25zc1Jlc3VsdBJCCg1yb3'
    'V0ZXNfcmVzdWx0GAkgASgLMhsuZXNwX3JlbW90ZS5Sb3V0ZXNHZXRSZXN1bHRIAFIMcm91dGVz'
    'UmVzdWx0EjkKC3BpbmdfcmVzdWx0GAogASgLMhYuZXNwX3JlbW90ZS5QaW5nUmVzdWx0SABSCn'
    'BpbmdSZXN1bHQSTwoTbWVzc2FnZV9zZW5kX3Jlc3VsdBgLIAEoCzIdLmVzcF9yZW1vdGUuTWVz'
    'c2FnZVNlbmRSZXN1bHRIAFIRbWVzc2FnZVNlbmRSZXN1bHQSTgoSZXZlbnRfbm90aWZpY2F0aW'
    '9uGAwgASgLMh0uZXNwX3JlbW90ZS5FdmVudE5vdGlmaWNhdGlvbkgAUhFldmVudE5vdGlmaWNh'
    'dGlvbkIICgZyZXN1bHQ=');

@$core.Deprecated('Use helloResultDescriptor instead')
const HelloResult$json = {
  '1': 'HelloResult',
  '2': [
    {'1': 'node_address', '3': 1, '4': 1, '5': 13, '10': 'nodeAddress'},
    {'1': 'node_name', '3': 2, '4': 1, '5': 9, '10': 'nodeName'},
    {'1': 'hw_profile', '3': 3, '4': 1, '5': 13, '10': 'hwProfile'},
    {'1': 'firmware_stamp', '3': 4, '4': 1, '5': 9, '10': 'firmwareStamp'},
    {'1': 'protocol_version', '3': 5, '4': 1, '5': 13, '10': 'protocolVersion'},
    {'1': 'auth_token', '3': 6, '4': 1, '5': 9, '10': 'authToken'},
  ],
};

/// Descriptor for `HelloResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List helloResultDescriptor = $convert.base64Decode(
    'CgtIZWxsb1Jlc3VsdBIhCgxub2RlX2FkZHJlc3MYASABKA1SC25vZGVBZGRyZXNzEhsKCW5vZG'
    'VfbmFtZRgCIAEoCVIIbm9kZU5hbWUSHQoKaHdfcHJvZmlsZRgDIAEoDVIJaHdQcm9maWxlEiUK'
    'DmZpcm13YXJlX3N0YW1wGAQgASgJUg1maXJtd2FyZVN0YW1wEikKEHByb3RvY29sX3ZlcnNpb2'
    '4YBSABKA1SD3Byb3RvY29sVmVyc2lvbhIdCgphdXRoX3Rva2VuGAYgASgJUglhdXRoVG9rZW4=');

@$core.Deprecated('Use nodeStatusResultDescriptor instead')
const NodeStatusResult$json = {
  '1': 'NodeStatusResult',
  '2': [
    {'1': 'uptime_seconds', '3': 1, '4': 1, '5': 13, '10': 'uptimeSeconds'},
    {'1': 'free_heap', '3': 2, '4': 1, '5': 13, '10': 'freeHeap'},
    {'1': 'min_free_heap', '3': 3, '4': 1, '5': 13, '10': 'minFreeHeap'},
    {'1': 'running_slot', '3': 4, '4': 1, '5': 9, '10': 'runningSlot'},
    {'1': 'ota_state', '3': 5, '4': 1, '5': 9, '10': 'otaState'},
    {'1': 'owner_master_id', '3': 6, '4': 1, '5': 13, '10': 'ownerMasterId'},
    {'1': 'mesh_online', '3': 7, '4': 1, '5': 8, '10': 'meshOnline'},
  ],
};

/// Descriptor for `NodeStatusResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeStatusResultDescriptor = $convert.base64Decode(
    'ChBOb2RlU3RhdHVzUmVzdWx0EiUKDnVwdGltZV9zZWNvbmRzGAEgASgNUg11cHRpbWVTZWNvbm'
    'RzEhsKCWZyZWVfaGVhcBgCIAEoDVIIZnJlZUhlYXASIgoNbWluX2ZyZWVfaGVhcBgDIAEoDVIL'
    'bWluRnJlZUhlYXASIQoMcnVubmluZ19zbG90GAQgASgJUgtydW5uaW5nU2xvdBIbCglvdGFfc3'
    'RhdGUYBSABKAlSCG90YVN0YXRlEiYKD293bmVyX21hc3Rlcl9pZBgGIAEoDVINb3duZXJNYXN0'
    'ZXJJZBIfCgttZXNoX29ubGluZRgHIAEoCFIKbWVzaE9ubGluZQ==');

@$core.Deprecated('Use peerInfoDescriptor instead')
const PeerInfo$json = {
  '1': 'PeerInfo',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 13, '10': 'address'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'last_heard_sec', '3': 3, '4': 1, '5': 13, '10': 'lastHeardSec'},
  ],
};

/// Descriptor for `PeerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List peerInfoDescriptor = $convert.base64Decode(
    'CghQZWVySW5mbxIYCgdhZGRyZXNzGAEgASgNUgdhZGRyZXNzEhIKBG5hbWUYAiABKAlSBG5hbW'
    'USJAoObGFzdF9oZWFyZF9zZWMYAyABKA1SDGxhc3RIZWFyZFNlYw==');

@$core.Deprecated('Use peerRosterResultDescriptor instead')
const PeerRosterResult$json = {
  '1': 'PeerRosterResult',
  '2': [
    {
      '1': 'peers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.esp_remote.PeerInfo',
      '10': 'peers'
    },
  ],
};

/// Descriptor for `PeerRosterResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List peerRosterResultDescriptor = $convert.base64Decode(
    'ChBQZWVyUm9zdGVyUmVzdWx0EioKBXBlZXJzGAEgAygLMhQuZXNwX3JlbW90ZS5QZWVySW5mb1'
    'IFcGVlcnM=');

@$core.Deprecated('Use gnssGetResultDescriptor instead')
const GnssGetResult$json = {
  '1': 'GnssGetResult',
  '2': [
    {'1': 'fix_valid', '3': 1, '4': 1, '5': 8, '10': 'fixValid'},
    {'1': 'fix_age_ms', '3': 2, '4': 1, '5': 13, '10': 'fixAgeMs'},
    {'1': 'latitude_scaled', '3': 3, '4': 1, '5': 5, '10': 'latitudeScaled'},
    {'1': 'longitude_scaled', '3': 4, '4': 1, '5': 5, '10': 'longitudeScaled'},
    {'1': 'satellites_used', '3': 5, '4': 1, '5': 13, '10': 'satellitesUsed'},
    {'1': 'hdop_scaled', '3': 6, '4': 1, '5': 13, '10': 'hdopScaled'},
    {'1': 'altitude_meters', '3': 7, '4': 1, '5': 5, '10': 'altitudeMeters'},
  ],
};

/// Descriptor for `GnssGetResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gnssGetResultDescriptor = $convert.base64Decode(
    'Cg1HbnNzR2V0UmVzdWx0EhsKCWZpeF92YWxpZBgBIAEoCFIIZml4VmFsaWQSHAoKZml4X2FnZV'
    '9tcxgCIAEoDVIIZml4QWdlTXMSJwoPbGF0aXR1ZGVfc2NhbGVkGAMgASgFUg5sYXRpdHVkZVNj'
    'YWxlZBIpChBsb25naXR1ZGVfc2NhbGVkGAQgASgFUg9sb25naXR1ZGVTY2FsZWQSJwoPc2F0ZW'
    'xsaXRlc191c2VkGAUgASgNUg5zYXRlbGxpdGVzVXNlZBIfCgtoZG9wX3NjYWxlZBgGIAEoDVIK'
    'aGRvcFNjYWxlZBInCg9hbHRpdHVkZV9tZXRlcnMYByABKAVSDmFsdGl0dWRlTWV0ZXJz');

@$core.Deprecated('Use routeInfoDescriptor instead')
const RouteInfo$json = {
  '1': 'RouteInfo',
  '2': [
    {'1': 'dest_address', '3': 1, '4': 1, '5': 13, '10': 'destAddress'},
    {'1': 'next_hop', '3': 2, '4': 1, '5': 13, '10': 'nextHop'},
    {'1': 'state', '3': 3, '4': 1, '5': 13, '10': 'state'},
  ],
};

/// Descriptor for `RouteInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routeInfoDescriptor = $convert.base64Decode(
    'CglSb3V0ZUluZm8SIQoMZGVzdF9hZGRyZXNzGAEgASgNUgtkZXN0QWRkcmVzcxIZCghuZXh0X2'
    'hvcBgCIAEoDVIHbmV4dEhvcBIUCgVzdGF0ZRgDIAEoDVIFc3RhdGU=');

@$core.Deprecated('Use routesGetResultDescriptor instead')
const RoutesGetResult$json = {
  '1': 'RoutesGetResult',
  '2': [
    {
      '1': 'routes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.esp_remote.RouteInfo',
      '10': 'routes'
    },
  ],
};

/// Descriptor for `RoutesGetResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routesGetResultDescriptor = $convert.base64Decode(
    'Cg9Sb3V0ZXNHZXRSZXN1bHQSLQoGcm91dGVzGAEgAygLMhUuZXNwX3JlbW90ZS5Sb3V0ZUluZm'
    '9SBnJvdXRlcw==');

@$core.Deprecated('Use pingResultDescriptor instead')
const PingResult$json = {
  '1': 'PingResult',
  '2': [
    {'1': 'target_address', '3': 1, '4': 1, '5': 13, '10': 'targetAddress'},
    {'1': 'rtt_ms', '3': 2, '4': 1, '5': 13, '10': 'rttMs'},
    {'1': 'success', '3': 3, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `PingResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResultDescriptor = $convert.base64Decode(
    'CgpQaW5nUmVzdWx0EiUKDnRhcmdldF9hZGRyZXNzGAEgASgNUg10YXJnZXRBZGRyZXNzEhUKBn'
    'J0dF9tcxgCIAEoDVIFcnR0TXMSGAoHc3VjY2VzcxgDIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use messageSendResultDescriptor instead')
const MessageSendResult$json = {
  '1': 'MessageSendResult',
  '2': [
    {'1': 'dest_address', '3': 1, '4': 1, '5': 13, '10': 'destAddress'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 13, '10': 'messageId'},
    {'1': 'enqueued', '3': 3, '4': 1, '5': 8, '10': 'enqueued'},
  ],
};

/// Descriptor for `MessageSendResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSendResultDescriptor = $convert.base64Decode(
    'ChFNZXNzYWdlU2VuZFJlc3VsdBIhCgxkZXN0X2FkZHJlc3MYASABKA1SC2Rlc3RBZGRyZXNzEh'
    '0KCm1lc3NhZ2VfaWQYAiABKA1SCW1lc3NhZ2VJZBIaCghlbnF1ZXVlZBgDIAEoCFIIZW5xdWV1'
    'ZWQ=');

@$core.Deprecated('Use eventNotificationDescriptor instead')
const EventNotification$json = {
  '1': 'EventNotification',
  '2': [
    {
      '1': 'event_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.esp_remote.EventNotification.EventType',
      '10': 'eventType'
    },
    {'1': 'from_address', '3': 2, '4': 1, '5': 13, '10': 'fromAddress'},
    {'1': 'payload_text', '3': 3, '4': 1, '5': 9, '10': 'payloadText'},
  ],
  '4': [EventNotification_EventType$json],
};

@$core.Deprecated('Use eventNotificationDescriptor instead')
const EventNotification_EventType$json = {
  '1': 'EventType',
  '2': [
    {'1': 'EVT_UNSPECIFIED', '2': 0},
    {'1': 'EVT_MESSAGE_RX', '2': 1},
    {'1': 'EVT_TELEMETRY', '2': 2},
    {'1': 'EVT_STATUS', '2': 3},
  ],
};

/// Descriptor for `EventNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventNotificationDescriptor = $convert.base64Decode(
    'ChFFdmVudE5vdGlmaWNhdGlvbhJGCgpldmVudF90eXBlGAEgASgOMicuZXNwX3JlbW90ZS5Fdm'
    'VudE5vdGlmaWNhdGlvbi5FdmVudFR5cGVSCWV2ZW50VHlwZRIhCgxmcm9tX2FkZHJlc3MYAiAB'
    'KA1SC2Zyb21BZGRyZXNzEiEKDHBheWxvYWRfdGV4dBgDIAEoCVILcGF5bG9hZFRleHQiVwoJRX'
    'ZlbnRUeXBlEhMKD0VWVF9VTlNQRUNJRklFRBAAEhIKDkVWVF9NRVNTQUdFX1JYEAESEQoNRVZU'
    'X1RFTEVNRVRSWRACEg4KCkVWVF9TVEFUVVMQAw==');
