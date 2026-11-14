// This is a generated file - do not edit.
//
// Generated from esp_remote.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class RemoteOp extends $pb.ProtobufEnum {
  static const RemoteOp OP_UNSPECIFIED =
      RemoteOp._(0, _omitEnumNames ? '' : 'OP_UNSPECIFIED');
  static const RemoteOp OP_HELLO =
      RemoteOp._(1, _omitEnumNames ? '' : 'OP_HELLO');
  static const RemoteOp OP_NODE_STATUS =
      RemoteOp._(2, _omitEnumNames ? '' : 'OP_NODE_STATUS');
  static const RemoteOp OP_PEER_ROSTER =
      RemoteOp._(3, _omitEnumNames ? '' : 'OP_PEER_ROSTER');
  static const RemoteOp OP_GNSS_GET =
      RemoteOp._(4, _omitEnumNames ? '' : 'OP_GNSS_GET');
  static const RemoteOp OP_ROUTES_GET =
      RemoteOp._(5, _omitEnumNames ? '' : 'OP_ROUTES_GET');
  static const RemoteOp OP_PING =
      RemoteOp._(6, _omitEnumNames ? '' : 'OP_PING');
  static const RemoteOp OP_MESSAGE_SEND =
      RemoteOp._(7, _omitEnumNames ? '' : 'OP_MESSAGE_SEND');
  static const RemoteOp OP_EVENT_SUB =
      RemoteOp._(8, _omitEnumNames ? '' : 'OP_EVENT_SUB');

  static const $core.List<RemoteOp> values = <RemoteOp>[
    OP_UNSPECIFIED,
    OP_HELLO,
    OP_NODE_STATUS,
    OP_PEER_ROSTER,
    OP_GNSS_GET,
    OP_ROUTES_GET,
    OP_PING,
    OP_MESSAGE_SEND,
    OP_EVENT_SUB,
  ];

  static final $core.List<RemoteOp?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static RemoteOp? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RemoteOp._(super.value, super.name);
}

class EventNotification_EventType extends $pb.ProtobufEnum {
  static const EventNotification_EventType EVT_UNSPECIFIED =
      EventNotification_EventType._(0, _omitEnumNames ? '' : 'EVT_UNSPECIFIED');
  static const EventNotification_EventType EVT_MESSAGE_RX =
      EventNotification_EventType._(1, _omitEnumNames ? '' : 'EVT_MESSAGE_RX');
  static const EventNotification_EventType EVT_TELEMETRY =
      EventNotification_EventType._(2, _omitEnumNames ? '' : 'EVT_TELEMETRY');
  static const EventNotification_EventType EVT_STATUS =
      EventNotification_EventType._(3, _omitEnumNames ? '' : 'EVT_STATUS');

  static const $core.List<EventNotification_EventType> values =
      <EventNotification_EventType>[
    EVT_UNSPECIFIED,
    EVT_MESSAGE_RX,
    EVT_TELEMETRY,
    EVT_STATUS,
  ];

  static final $core.List<EventNotification_EventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static EventNotification_EventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EventNotification_EventType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
