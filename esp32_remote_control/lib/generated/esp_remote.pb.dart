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

import 'esp_remote.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'esp_remote.pbenum.dart';

enum RemoteRequest_Payload {
  helloArgs,
  statusArgs,
  rosterArgs,
  gnssArgs,
  routesArgs,
  pingArgs,
  messageSendArgs,
  eventSubArgs,
  notSet
}

class RemoteRequest extends $pb.GeneratedMessage {
  factory RemoteRequest({
    $core.int? version,
    $core.int? requestId,
    RemoteOp? op,
    HelloArgs? helloArgs,
    NodeStatusArgs? statusArgs,
    PeerRosterArgs? rosterArgs,
    GnssGetArgs? gnssArgs,
    RoutesGetArgs? routesArgs,
    PingArgs? pingArgs,
    MessageSendArgs? messageSendArgs,
    EventSubArgs? eventSubArgs,
    $core.String? authToken,
  }) {
    final result = RemoteRequest._();
    if (version != null) result.version = version;
    if (requestId != null) result.requestId = requestId;
    if (op != null) result.op = op;
    if (helloArgs != null) result.helloArgs = helloArgs;
    if (statusArgs != null) result.statusArgs = statusArgs;
    if (rosterArgs != null) result.rosterArgs = rosterArgs;
    if (gnssArgs != null) result.gnssArgs = gnssArgs;
    if (routesArgs != null) result.routesArgs = routesArgs;
    if (pingArgs != null) result.pingArgs = pingArgs;
    if (messageSendArgs != null) result.messageSendArgs = messageSendArgs;
    if (eventSubArgs != null) result.eventSubArgs = eventSubArgs;
    if (authToken != null) result.authToken = authToken;
    return result;
  }

  RemoteRequest._();

  factory RemoteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoteRequest()..mergeFromBuffer(data, registry);
  factory RemoteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoteRequest()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RemoteRequest_Payload>
      _RemoteRequest_PayloadByTag = {
    4: RemoteRequest_Payload.helloArgs,
    5: RemoteRequest_Payload.statusArgs,
    6: RemoteRequest_Payload.rosterArgs,
    7: RemoteRequest_Payload.gnssArgs,
    8: RemoteRequest_Payload.routesArgs,
    9: RemoteRequest_Payload.pingArgs,
    10: RemoteRequest_Payload.messageSendArgs,
    11: RemoteRequest_Payload.eventSubArgs,
    0: RemoteRequest_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: RemoteRequest.$_createMessage)
    ..oo(0, [4, 5, 6, 7, 8, 9, 10, 11])
    ..aI(1, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'requestId', fieldType: $pb.PbFieldType.OU3)
    ..aE<RemoteOp>(3, _omitFieldNames ? '' : 'op', enumValues: RemoteOp.values)
    ..aOM<HelloArgs>(4, _omitFieldNames ? '' : 'helloArgs',
        subBuilder: HelloArgs.$_createMessage)
    ..aOM<NodeStatusArgs>(5, _omitFieldNames ? '' : 'statusArgs',
        subBuilder: NodeStatusArgs.$_createMessage)
    ..aOM<PeerRosterArgs>(6, _omitFieldNames ? '' : 'rosterArgs',
        subBuilder: PeerRosterArgs.$_createMessage)
    ..aOM<GnssGetArgs>(7, _omitFieldNames ? '' : 'gnssArgs',
        subBuilder: GnssGetArgs.$_createMessage)
    ..aOM<RoutesGetArgs>(8, _omitFieldNames ? '' : 'routesArgs',
        subBuilder: RoutesGetArgs.$_createMessage)
    ..aOM<PingArgs>(9, _omitFieldNames ? '' : 'pingArgs',
        subBuilder: PingArgs.$_createMessage)
    ..aOM<MessageSendArgs>(10, _omitFieldNames ? '' : 'messageSendArgs',
        subBuilder: MessageSendArgs.$_createMessage)
    ..aOM<EventSubArgs>(11, _omitFieldNames ? '' : 'eventSubArgs',
        subBuilder: EventSubArgs.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'authToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoteRequest copyWith(void Function(RemoteRequest) updates) =>
      super.copyWith((message) => updates(message as RemoteRequest))
          as RemoteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RemoteRequest() / RemoteRequest.new instead')
  static RemoteRequest create() => RemoteRequest._();
  static $pb.GeneratedMessage $_createMessage() => RemoteRequest._();
  @$core.override
  RemoteRequest createEmptyInstance() => RemoteRequest._();
  @$core.pragma('dart2js:noInline')
  static RemoteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoteRequest>(
          RemoteRequest.$_createMessage);
  static RemoteRequest? _defaultInstance;

  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  RemoteRequest_Payload whichPayload() =>
      _RemoteRequest_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get requestId => $_getIZ(1);
  @$pb.TagNumber(2)
  set requestId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  RemoteOp get op => $_getN(2);
  @$pb.TagNumber(3)
  set op(RemoteOp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOp() => $_has(2);
  @$pb.TagNumber(3)
  void clearOp() => $_clearField(3);

  @$pb.TagNumber(4)
  HelloArgs get helloArgs => $_getN(3);
  @$pb.TagNumber(4)
  set helloArgs(HelloArgs value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasHelloArgs() => $_has(3);
  @$pb.TagNumber(4)
  void clearHelloArgs() => $_clearField(4);
  @$pb.TagNumber(4)
  HelloArgs ensureHelloArgs() => $_ensure(3);

  @$pb.TagNumber(5)
  NodeStatusArgs get statusArgs => $_getN(4);
  @$pb.TagNumber(5)
  set statusArgs(NodeStatusArgs value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatusArgs() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatusArgs() => $_clearField(5);
  @$pb.TagNumber(5)
  NodeStatusArgs ensureStatusArgs() => $_ensure(4);

  @$pb.TagNumber(6)
  PeerRosterArgs get rosterArgs => $_getN(5);
  @$pb.TagNumber(6)
  set rosterArgs(PeerRosterArgs value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRosterArgs() => $_has(5);
  @$pb.TagNumber(6)
  void clearRosterArgs() => $_clearField(6);
  @$pb.TagNumber(6)
  PeerRosterArgs ensureRosterArgs() => $_ensure(5);

  @$pb.TagNumber(7)
  GnssGetArgs get gnssArgs => $_getN(6);
  @$pb.TagNumber(7)
  set gnssArgs(GnssGetArgs value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasGnssArgs() => $_has(6);
  @$pb.TagNumber(7)
  void clearGnssArgs() => $_clearField(7);
  @$pb.TagNumber(7)
  GnssGetArgs ensureGnssArgs() => $_ensure(6);

  @$pb.TagNumber(8)
  RoutesGetArgs get routesArgs => $_getN(7);
  @$pb.TagNumber(8)
  set routesArgs(RoutesGetArgs value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasRoutesArgs() => $_has(7);
  @$pb.TagNumber(8)
  void clearRoutesArgs() => $_clearField(8);
  @$pb.TagNumber(8)
  RoutesGetArgs ensureRoutesArgs() => $_ensure(7);

  @$pb.TagNumber(9)
  PingArgs get pingArgs => $_getN(8);
  @$pb.TagNumber(9)
  set pingArgs(PingArgs value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPingArgs() => $_has(8);
  @$pb.TagNumber(9)
  void clearPingArgs() => $_clearField(9);
  @$pb.TagNumber(9)
  PingArgs ensurePingArgs() => $_ensure(8);

  @$pb.TagNumber(10)
  MessageSendArgs get messageSendArgs => $_getN(9);
  @$pb.TagNumber(10)
  set messageSendArgs(MessageSendArgs value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasMessageSendArgs() => $_has(9);
  @$pb.TagNumber(10)
  void clearMessageSendArgs() => $_clearField(10);
  @$pb.TagNumber(10)
  MessageSendArgs ensureMessageSendArgs() => $_ensure(9);

  @$pb.TagNumber(11)
  EventSubArgs get eventSubArgs => $_getN(10);
  @$pb.TagNumber(11)
  set eventSubArgs(EventSubArgs value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasEventSubArgs() => $_has(10);
  @$pb.TagNumber(11)
  void clearEventSubArgs() => $_clearField(11);
  @$pb.TagNumber(11)
  EventSubArgs ensureEventSubArgs() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.String get authToken => $_getSZ(11);
  @$pb.TagNumber(12)
  set authToken($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasAuthToken() => $_has(11);
  @$pb.TagNumber(12)
  void clearAuthToken() => $_clearField(12);
}

class HelloArgs extends $pb.GeneratedMessage {
  factory HelloArgs() => HelloArgs._();

  HelloArgs._();

  factory HelloArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HelloArgs()..mergeFromBuffer(data, registry);
  factory HelloArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HelloArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HelloArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: HelloArgs.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloArgs copyWith(void Function(HelloArgs) updates) =>
      super.copyWith((message) => updates(message as HelloArgs)) as HelloArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HelloArgs() / HelloArgs.new instead')
  static HelloArgs create() => HelloArgs._();
  static $pb.GeneratedMessage $_createMessage() => HelloArgs._();
  @$core.override
  HelloArgs createEmptyInstance() => HelloArgs._();
  @$core.pragma('dart2js:noInline')
  static HelloArgs getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HelloArgs>(HelloArgs.$_createMessage);
  static HelloArgs? _defaultInstance;
}

class NodeStatusArgs extends $pb.GeneratedMessage {
  factory NodeStatusArgs() => NodeStatusArgs._();

  NodeStatusArgs._();

  factory NodeStatusArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeStatusArgs()..mergeFromBuffer(data, registry);
  factory NodeStatusArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeStatusArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeStatusArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: NodeStatusArgs.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusArgs copyWith(void Function(NodeStatusArgs) updates) =>
      super.copyWith((message) => updates(message as NodeStatusArgs))
          as NodeStatusArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NodeStatusArgs() / NodeStatusArgs.new instead')
  static NodeStatusArgs create() => NodeStatusArgs._();
  static $pb.GeneratedMessage $_createMessage() => NodeStatusArgs._();
  @$core.override
  NodeStatusArgs createEmptyInstance() => NodeStatusArgs._();
  @$core.pragma('dart2js:noInline')
  static NodeStatusArgs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeStatusArgs>(
          NodeStatusArgs.$_createMessage);
  static NodeStatusArgs? _defaultInstance;
}

class PeerRosterArgs extends $pb.GeneratedMessage {
  factory PeerRosterArgs() => PeerRosterArgs._();

  PeerRosterArgs._();

  factory PeerRosterArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PeerRosterArgs()..mergeFromBuffer(data, registry);
  factory PeerRosterArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PeerRosterArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PeerRosterArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: PeerRosterArgs.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PeerRosterArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PeerRosterArgs copyWith(void Function(PeerRosterArgs) updates) =>
      super.copyWith((message) => updates(message as PeerRosterArgs))
          as PeerRosterArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PeerRosterArgs() / PeerRosterArgs.new instead')
  static PeerRosterArgs create() => PeerRosterArgs._();
  static $pb.GeneratedMessage $_createMessage() => PeerRosterArgs._();
  @$core.override
  PeerRosterArgs createEmptyInstance() => PeerRosterArgs._();
  @$core.pragma('dart2js:noInline')
  static PeerRosterArgs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PeerRosterArgs>(
          PeerRosterArgs.$_createMessage);
  static PeerRosterArgs? _defaultInstance;
}

class GnssGetArgs extends $pb.GeneratedMessage {
  factory GnssGetArgs() => GnssGetArgs._();

  GnssGetArgs._();

  factory GnssGetArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GnssGetArgs()..mergeFromBuffer(data, registry);
  factory GnssGetArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GnssGetArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GnssGetArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: GnssGetArgs.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GnssGetArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GnssGetArgs copyWith(void Function(GnssGetArgs) updates) =>
      super.copyWith((message) => updates(message as GnssGetArgs))
          as GnssGetArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GnssGetArgs() / GnssGetArgs.new instead')
  static GnssGetArgs create() => GnssGetArgs._();
  static $pb.GeneratedMessage $_createMessage() => GnssGetArgs._();
  @$core.override
  GnssGetArgs createEmptyInstance() => GnssGetArgs._();
  @$core.pragma('dart2js:noInline')
  static GnssGetArgs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GnssGetArgs>(
          GnssGetArgs.$_createMessage);
  static GnssGetArgs? _defaultInstance;
}

class RoutesGetArgs extends $pb.GeneratedMessage {
  factory RoutesGetArgs() => RoutesGetArgs._();

  RoutesGetArgs._();

  factory RoutesGetArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoutesGetArgs()..mergeFromBuffer(data, registry);
  factory RoutesGetArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoutesGetArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoutesGetArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: RoutesGetArgs.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutesGetArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutesGetArgs copyWith(void Function(RoutesGetArgs) updates) =>
      super.copyWith((message) => updates(message as RoutesGetArgs))
          as RoutesGetArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoutesGetArgs() / RoutesGetArgs.new instead')
  static RoutesGetArgs create() => RoutesGetArgs._();
  static $pb.GeneratedMessage $_createMessage() => RoutesGetArgs._();
  @$core.override
  RoutesGetArgs createEmptyInstance() => RoutesGetArgs._();
  @$core.pragma('dart2js:noInline')
  static RoutesGetArgs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoutesGetArgs>(
          RoutesGetArgs.$_createMessage);
  static RoutesGetArgs? _defaultInstance;
}

class PingArgs extends $pb.GeneratedMessage {
  factory PingArgs({
    $core.int? targetAddress,
  }) {
    final result = PingArgs._();
    if (targetAddress != null) result.targetAddress = targetAddress;
    return result;
  }

  PingArgs._();

  factory PingArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingArgs()..mergeFromBuffer(data, registry);
  factory PingArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: PingArgs.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'targetAddress',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingArgs copyWith(void Function(PingArgs) updates) =>
      super.copyWith((message) => updates(message as PingArgs)) as PingArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PingArgs() / PingArgs.new instead')
  static PingArgs create() => PingArgs._();
  static $pb.GeneratedMessage $_createMessage() => PingArgs._();
  @$core.override
  PingArgs createEmptyInstance() => PingArgs._();
  @$core.pragma('dart2js:noInline')
  static PingArgs getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PingArgs>(PingArgs.$_createMessage);
  static PingArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get targetAddress => $_getIZ(0);
  @$pb.TagNumber(1)
  set targetAddress($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetAddress() => $_clearField(1);
}

class MessageSendArgs extends $pb.GeneratedMessage {
  factory MessageSendArgs({
    $core.int? destAddress,
    $core.String? text,
  }) {
    final result = MessageSendArgs._();
    if (destAddress != null) result.destAddress = destAddress;
    if (text != null) result.text = text;
    return result;
  }

  MessageSendArgs._();

  factory MessageSendArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageSendArgs()..mergeFromBuffer(data, registry);
  factory MessageSendArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageSendArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageSendArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: MessageSendArgs.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'destAddress',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSendArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSendArgs copyWith(void Function(MessageSendArgs) updates) =>
      super.copyWith((message) => updates(message as MessageSendArgs))
          as MessageSendArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MessageSendArgs() / MessageSendArgs.new instead')
  static MessageSendArgs create() => MessageSendArgs._();
  static $pb.GeneratedMessage $_createMessage() => MessageSendArgs._();
  @$core.override
  MessageSendArgs createEmptyInstance() => MessageSendArgs._();
  @$core.pragma('dart2js:noInline')
  static MessageSendArgs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageSendArgs>(
          MessageSendArgs.$_createMessage);
  static MessageSendArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get destAddress => $_getIZ(0);
  @$pb.TagNumber(1)
  set destAddress($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDestAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearDestAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);
}

class EventSubArgs extends $pb.GeneratedMessage {
  factory EventSubArgs({
    $core.bool? subscribeMessages,
    $core.bool? subscribeTelemetry,
    $core.bool? subscribeStatus,
  }) {
    final result = EventSubArgs._();
    if (subscribeMessages != null) result.subscribeMessages = subscribeMessages;
    if (subscribeTelemetry != null)
      result.subscribeTelemetry = subscribeTelemetry;
    if (subscribeStatus != null) result.subscribeStatus = subscribeStatus;
    return result;
  }

  EventSubArgs._();

  factory EventSubArgs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EventSubArgs()..mergeFromBuffer(data, registry);
  factory EventSubArgs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EventSubArgs()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EventSubArgs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: EventSubArgs.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'subscribeMessages')
    ..aOB(2, _omitFieldNames ? '' : 'subscribeTelemetry')
    ..aOB(3, _omitFieldNames ? '' : 'subscribeStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventSubArgs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventSubArgs copyWith(void Function(EventSubArgs) updates) =>
      super.copyWith((message) => updates(message as EventSubArgs))
          as EventSubArgs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EventSubArgs() / EventSubArgs.new instead')
  static EventSubArgs create() => EventSubArgs._();
  static $pb.GeneratedMessage $_createMessage() => EventSubArgs._();
  @$core.override
  EventSubArgs createEmptyInstance() => EventSubArgs._();
  @$core.pragma('dart2js:noInline')
  static EventSubArgs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EventSubArgs>(
          EventSubArgs.$_createMessage);
  static EventSubArgs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get subscribeMessages => $_getBF(0);
  @$pb.TagNumber(1)
  set subscribeMessages($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSubscribeMessages() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscribeMessages() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get subscribeTelemetry => $_getBF(1);
  @$pb.TagNumber(2)
  set subscribeTelemetry($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSubscribeTelemetry() => $_has(1);
  @$pb.TagNumber(2)
  void clearSubscribeTelemetry() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get subscribeStatus => $_getBF(2);
  @$pb.TagNumber(3)
  set subscribeStatus($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSubscribeStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubscribeStatus() => $_clearField(3);
}

enum RemoteResponse_Result {
  helloResult,
  statusResult,
  rosterResult,
  gnssResult,
  routesResult,
  pingResult,
  messageSendResult,
  eventNotification,
  notSet
}

class RemoteResponse extends $pb.GeneratedMessage {
  factory RemoteResponse({
    $core.int? version,
    $core.int? requestId,
    $core.bool? ok,
    $core.String? errorCode,
    HelloResult? helloResult,
    NodeStatusResult? statusResult,
    PeerRosterResult? rosterResult,
    GnssGetResult? gnssResult,
    RoutesGetResult? routesResult,
    PingResult? pingResult,
    MessageSendResult? messageSendResult,
    EventNotification? eventNotification,
  }) {
    final result = RemoteResponse._();
    if (version != null) result.version = version;
    if (requestId != null) result.requestId = requestId;
    if (ok != null) result.ok = ok;
    if (errorCode != null) result.errorCode = errorCode;
    if (helloResult != null) result.helloResult = helloResult;
    if (statusResult != null) result.statusResult = statusResult;
    if (rosterResult != null) result.rosterResult = rosterResult;
    if (gnssResult != null) result.gnssResult = gnssResult;
    if (routesResult != null) result.routesResult = routesResult;
    if (pingResult != null) result.pingResult = pingResult;
    if (messageSendResult != null) result.messageSendResult = messageSendResult;
    if (eventNotification != null) result.eventNotification = eventNotification;
    return result;
  }

  RemoteResponse._();

  factory RemoteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoteResponse()..mergeFromBuffer(data, registry);
  factory RemoteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoteResponse()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RemoteResponse_Result>
      _RemoteResponse_ResultByTag = {
    5: RemoteResponse_Result.helloResult,
    6: RemoteResponse_Result.statusResult,
    7: RemoteResponse_Result.rosterResult,
    8: RemoteResponse_Result.gnssResult,
    9: RemoteResponse_Result.routesResult,
    10: RemoteResponse_Result.pingResult,
    11: RemoteResponse_Result.messageSendResult,
    12: RemoteResponse_Result.eventNotification,
    0: RemoteResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: RemoteResponse.$_createMessage)
    ..oo(0, [5, 6, 7, 8, 9, 10, 11, 12])
    ..aI(1, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'requestId', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'ok')
    ..aOS(4, _omitFieldNames ? '' : 'errorCode')
    ..aOM<HelloResult>(5, _omitFieldNames ? '' : 'helloResult',
        subBuilder: HelloResult.$_createMessage)
    ..aOM<NodeStatusResult>(6, _omitFieldNames ? '' : 'statusResult',
        subBuilder: NodeStatusResult.$_createMessage)
    ..aOM<PeerRosterResult>(7, _omitFieldNames ? '' : 'rosterResult',
        subBuilder: PeerRosterResult.$_createMessage)
    ..aOM<GnssGetResult>(8, _omitFieldNames ? '' : 'gnssResult',
        subBuilder: GnssGetResult.$_createMessage)
    ..aOM<RoutesGetResult>(9, _omitFieldNames ? '' : 'routesResult',
        subBuilder: RoutesGetResult.$_createMessage)
    ..aOM<PingResult>(10, _omitFieldNames ? '' : 'pingResult',
        subBuilder: PingResult.$_createMessage)
    ..aOM<MessageSendResult>(11, _omitFieldNames ? '' : 'messageSendResult',
        subBuilder: MessageSendResult.$_createMessage)
    ..aOM<EventNotification>(12, _omitFieldNames ? '' : 'eventNotification',
        subBuilder: EventNotification.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoteResponse copyWith(void Function(RemoteResponse) updates) =>
      super.copyWith((message) => updates(message as RemoteResponse))
          as RemoteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RemoteResponse() / RemoteResponse.new instead')
  static RemoteResponse create() => RemoteResponse._();
  static $pb.GeneratedMessage $_createMessage() => RemoteResponse._();
  @$core.override
  RemoteResponse createEmptyInstance() => RemoteResponse._();
  @$core.pragma('dart2js:noInline')
  static RemoteResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoteResponse>(
          RemoteResponse.$_createMessage);
  static RemoteResponse? _defaultInstance;

  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  RemoteResponse_Result whichResult() =>
      _RemoteResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get requestId => $_getIZ(1);
  @$pb.TagNumber(2)
  set requestId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get ok => $_getBF(2);
  @$pb.TagNumber(3)
  set ok($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOk() => $_has(2);
  @$pb.TagNumber(3)
  void clearOk() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get errorCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set errorCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasErrorCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearErrorCode() => $_clearField(4);

  @$pb.TagNumber(5)
  HelloResult get helloResult => $_getN(4);
  @$pb.TagNumber(5)
  set helloResult(HelloResult value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasHelloResult() => $_has(4);
  @$pb.TagNumber(5)
  void clearHelloResult() => $_clearField(5);
  @$pb.TagNumber(5)
  HelloResult ensureHelloResult() => $_ensure(4);

  @$pb.TagNumber(6)
  NodeStatusResult get statusResult => $_getN(5);
  @$pb.TagNumber(6)
  set statusResult(NodeStatusResult value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatusResult() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatusResult() => $_clearField(6);
  @$pb.TagNumber(6)
  NodeStatusResult ensureStatusResult() => $_ensure(5);

  @$pb.TagNumber(7)
  PeerRosterResult get rosterResult => $_getN(6);
  @$pb.TagNumber(7)
  set rosterResult(PeerRosterResult value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRosterResult() => $_has(6);
  @$pb.TagNumber(7)
  void clearRosterResult() => $_clearField(7);
  @$pb.TagNumber(7)
  PeerRosterResult ensureRosterResult() => $_ensure(6);

  @$pb.TagNumber(8)
  GnssGetResult get gnssResult => $_getN(7);
  @$pb.TagNumber(8)
  set gnssResult(GnssGetResult value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGnssResult() => $_has(7);
  @$pb.TagNumber(8)
  void clearGnssResult() => $_clearField(8);
  @$pb.TagNumber(8)
  GnssGetResult ensureGnssResult() => $_ensure(7);

  @$pb.TagNumber(9)
  RoutesGetResult get routesResult => $_getN(8);
  @$pb.TagNumber(9)
  set routesResult(RoutesGetResult value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasRoutesResult() => $_has(8);
  @$pb.TagNumber(9)
  void clearRoutesResult() => $_clearField(9);
  @$pb.TagNumber(9)
  RoutesGetResult ensureRoutesResult() => $_ensure(8);

  @$pb.TagNumber(10)
  PingResult get pingResult => $_getN(9);
  @$pb.TagNumber(10)
  set pingResult(PingResult value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPingResult() => $_has(9);
  @$pb.TagNumber(10)
  void clearPingResult() => $_clearField(10);
  @$pb.TagNumber(10)
  PingResult ensurePingResult() => $_ensure(9);

  @$pb.TagNumber(11)
  MessageSendResult get messageSendResult => $_getN(10);
  @$pb.TagNumber(11)
  set messageSendResult(MessageSendResult value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasMessageSendResult() => $_has(10);
  @$pb.TagNumber(11)
  void clearMessageSendResult() => $_clearField(11);
  @$pb.TagNumber(11)
  MessageSendResult ensureMessageSendResult() => $_ensure(10);

  @$pb.TagNumber(12)
  EventNotification get eventNotification => $_getN(11);
  @$pb.TagNumber(12)
  set eventNotification(EventNotification value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasEventNotification() => $_has(11);
  @$pb.TagNumber(12)
  void clearEventNotification() => $_clearField(12);
  @$pb.TagNumber(12)
  EventNotification ensureEventNotification() => $_ensure(11);
}

class HelloResult extends $pb.GeneratedMessage {
  factory HelloResult({
    $core.int? nodeAddress,
    $core.String? nodeName,
    $core.int? hwProfile,
    $core.String? firmwareStamp,
    $core.int? protocolVersion,
    $core.String? authToken,
  }) {
    final result = HelloResult._();
    if (nodeAddress != null) result.nodeAddress = nodeAddress;
    if (nodeName != null) result.nodeName = nodeName;
    if (hwProfile != null) result.hwProfile = hwProfile;
    if (firmwareStamp != null) result.firmwareStamp = firmwareStamp;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (authToken != null) result.authToken = authToken;
    return result;
  }

  HelloResult._();

  factory HelloResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HelloResult()..mergeFromBuffer(data, registry);
  factory HelloResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HelloResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HelloResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: HelloResult.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'nodeAddress',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'nodeName')
    ..aI(3, _omitFieldNames ? '' : 'hwProfile', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'firmwareStamp')
    ..aI(5, _omitFieldNames ? '' : 'protocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'authToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloResult copyWith(void Function(HelloResult) updates) =>
      super.copyWith((message) => updates(message as HelloResult))
          as HelloResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HelloResult() / HelloResult.new instead')
  static HelloResult create() => HelloResult._();
  static $pb.GeneratedMessage $_createMessage() => HelloResult._();
  @$core.override
  HelloResult createEmptyInstance() => HelloResult._();
  @$core.pragma('dart2js:noInline')
  static HelloResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HelloResult>(
          HelloResult.$_createMessage);
  static HelloResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nodeAddress => $_getIZ(0);
  @$pb.TagNumber(1)
  set nodeAddress($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeName => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeName() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get hwProfile => $_getIZ(2);
  @$pb.TagNumber(3)
  set hwProfile($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHwProfile() => $_has(2);
  @$pb.TagNumber(3)
  void clearHwProfile() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get firmwareStamp => $_getSZ(3);
  @$pb.TagNumber(4)
  set firmwareStamp($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFirmwareStamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearFirmwareStamp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get protocolVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set protocolVersion($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProtocolVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearProtocolVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get authToken => $_getSZ(5);
  @$pb.TagNumber(6)
  set authToken($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAuthToken() => $_has(5);
  @$pb.TagNumber(6)
  void clearAuthToken() => $_clearField(6);
}

class NodeStatusResult extends $pb.GeneratedMessage {
  factory NodeStatusResult({
    $core.int? uptimeSeconds,
    $core.int? freeHeap,
    $core.int? minFreeHeap,
    $core.String? runningSlot,
    $core.String? otaState,
    $core.int? ownerMasterId,
    $core.bool? meshOnline,
  }) {
    final result = NodeStatusResult._();
    if (uptimeSeconds != null) result.uptimeSeconds = uptimeSeconds;
    if (freeHeap != null) result.freeHeap = freeHeap;
    if (minFreeHeap != null) result.minFreeHeap = minFreeHeap;
    if (runningSlot != null) result.runningSlot = runningSlot;
    if (otaState != null) result.otaState = otaState;
    if (ownerMasterId != null) result.ownerMasterId = ownerMasterId;
    if (meshOnline != null) result.meshOnline = meshOnline;
    return result;
  }

  NodeStatusResult._();

  factory NodeStatusResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeStatusResult()..mergeFromBuffer(data, registry);
  factory NodeStatusResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeStatusResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeStatusResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: NodeStatusResult.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'uptimeSeconds',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'freeHeap', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'minFreeHeap',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'runningSlot')
    ..aOS(5, _omitFieldNames ? '' : 'otaState')
    ..aI(6, _omitFieldNames ? '' : 'ownerMasterId',
        fieldType: $pb.PbFieldType.OU3)
    ..aOB(7, _omitFieldNames ? '' : 'meshOnline')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusResult copyWith(void Function(NodeStatusResult) updates) =>
      super.copyWith((message) => updates(message as NodeStatusResult))
          as NodeStatusResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NodeStatusResult() / NodeStatusResult.new instead')
  static NodeStatusResult create() => NodeStatusResult._();
  static $pb.GeneratedMessage $_createMessage() => NodeStatusResult._();
  @$core.override
  NodeStatusResult createEmptyInstance() => NodeStatusResult._();
  @$core.pragma('dart2js:noInline')
  static NodeStatusResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeStatusResult>(
          NodeStatusResult.$_createMessage);
  static NodeStatusResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get uptimeSeconds => $_getIZ(0);
  @$pb.TagNumber(1)
  set uptimeSeconds($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUptimeSeconds() => $_has(0);
  @$pb.TagNumber(1)
  void clearUptimeSeconds() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get freeHeap => $_getIZ(1);
  @$pb.TagNumber(2)
  set freeHeap($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFreeHeap() => $_has(1);
  @$pb.TagNumber(2)
  void clearFreeHeap() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get minFreeHeap => $_getIZ(2);
  @$pb.TagNumber(3)
  set minFreeHeap($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMinFreeHeap() => $_has(2);
  @$pb.TagNumber(3)
  void clearMinFreeHeap() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get runningSlot => $_getSZ(3);
  @$pb.TagNumber(4)
  set runningSlot($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRunningSlot() => $_has(3);
  @$pb.TagNumber(4)
  void clearRunningSlot() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get otaState => $_getSZ(4);
  @$pb.TagNumber(5)
  set otaState($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOtaState() => $_has(4);
  @$pb.TagNumber(5)
  void clearOtaState() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get ownerMasterId => $_getIZ(5);
  @$pb.TagNumber(6)
  set ownerMasterId($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOwnerMasterId() => $_has(5);
  @$pb.TagNumber(6)
  void clearOwnerMasterId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get meshOnline => $_getBF(6);
  @$pb.TagNumber(7)
  set meshOnline($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMeshOnline() => $_has(6);
  @$pb.TagNumber(7)
  void clearMeshOnline() => $_clearField(7);
}

class PeerInfo extends $pb.GeneratedMessage {
  factory PeerInfo({
    $core.int? address,
    $core.String? name,
    $core.int? lastHeardSec,
  }) {
    final result = PeerInfo._();
    if (address != null) result.address = address;
    if (name != null) result.name = name;
    if (lastHeardSec != null) result.lastHeardSec = lastHeardSec;
    return result;
  }

  PeerInfo._();

  factory PeerInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PeerInfo()..mergeFromBuffer(data, registry);
  factory PeerInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PeerInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PeerInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: PeerInfo.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'address', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'lastHeardSec',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PeerInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PeerInfo copyWith(void Function(PeerInfo) updates) =>
      super.copyWith((message) => updates(message as PeerInfo)) as PeerInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PeerInfo() / PeerInfo.new instead')
  static PeerInfo create() => PeerInfo._();
  static $pb.GeneratedMessage $_createMessage() => PeerInfo._();
  @$core.override
  PeerInfo createEmptyInstance() => PeerInfo._();
  @$core.pragma('dart2js:noInline')
  static PeerInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PeerInfo>(PeerInfo.$_createMessage);
  static PeerInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get address => $_getIZ(0);
  @$pb.TagNumber(1)
  set address($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get lastHeardSec => $_getIZ(2);
  @$pb.TagNumber(3)
  set lastHeardSec($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastHeardSec() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastHeardSec() => $_clearField(3);
}

class PeerRosterResult extends $pb.GeneratedMessage {
  factory PeerRosterResult({
    $core.Iterable<PeerInfo>? peers,
  }) {
    final result = PeerRosterResult._();
    if (peers != null) result.peers.addAll(peers);
    return result;
  }

  PeerRosterResult._();

  factory PeerRosterResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PeerRosterResult()..mergeFromBuffer(data, registry);
  factory PeerRosterResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PeerRosterResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PeerRosterResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: PeerRosterResult.$_createMessage)
    ..pPM<PeerInfo>(1, _omitFieldNames ? '' : 'peers',
        subBuilder: PeerInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PeerRosterResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PeerRosterResult copyWith(void Function(PeerRosterResult) updates) =>
      super.copyWith((message) => updates(message as PeerRosterResult))
          as PeerRosterResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PeerRosterResult() / PeerRosterResult.new instead')
  static PeerRosterResult create() => PeerRosterResult._();
  static $pb.GeneratedMessage $_createMessage() => PeerRosterResult._();
  @$core.override
  PeerRosterResult createEmptyInstance() => PeerRosterResult._();
  @$core.pragma('dart2js:noInline')
  static PeerRosterResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PeerRosterResult>(
          PeerRosterResult.$_createMessage);
  static PeerRosterResult? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PeerInfo> get peers => $_getList(0);
}

class GnssGetResult extends $pb.GeneratedMessage {
  factory GnssGetResult({
    $core.bool? fixValid,
    $core.int? fixAgeMs,
    $core.int? latitudeScaled,
    $core.int? longitudeScaled,
    $core.int? satellitesUsed,
    $core.int? hdopScaled,
    $core.int? altitudeMeters,
  }) {
    final result = GnssGetResult._();
    if (fixValid != null) result.fixValid = fixValid;
    if (fixAgeMs != null) result.fixAgeMs = fixAgeMs;
    if (latitudeScaled != null) result.latitudeScaled = latitudeScaled;
    if (longitudeScaled != null) result.longitudeScaled = longitudeScaled;
    if (satellitesUsed != null) result.satellitesUsed = satellitesUsed;
    if (hdopScaled != null) result.hdopScaled = hdopScaled;
    if (altitudeMeters != null) result.altitudeMeters = altitudeMeters;
    return result;
  }

  GnssGetResult._();

  factory GnssGetResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GnssGetResult()..mergeFromBuffer(data, registry);
  factory GnssGetResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GnssGetResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GnssGetResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: GnssGetResult.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'fixValid')
    ..aI(2, _omitFieldNames ? '' : 'fixAgeMs', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'latitudeScaled')
    ..aI(4, _omitFieldNames ? '' : 'longitudeScaled')
    ..aI(5, _omitFieldNames ? '' : 'satellitesUsed',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'hdopScaled', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'altitudeMeters')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GnssGetResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GnssGetResult copyWith(void Function(GnssGetResult) updates) =>
      super.copyWith((message) => updates(message as GnssGetResult))
          as GnssGetResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GnssGetResult() / GnssGetResult.new instead')
  static GnssGetResult create() => GnssGetResult._();
  static $pb.GeneratedMessage $_createMessage() => GnssGetResult._();
  @$core.override
  GnssGetResult createEmptyInstance() => GnssGetResult._();
  @$core.pragma('dart2js:noInline')
  static GnssGetResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GnssGetResult>(
          GnssGetResult.$_createMessage);
  static GnssGetResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get fixValid => $_getBF(0);
  @$pb.TagNumber(1)
  set fixValid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFixValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearFixValid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get fixAgeMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set fixAgeMs($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFixAgeMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearFixAgeMs() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get latitudeScaled => $_getIZ(2);
  @$pb.TagNumber(3)
  set latitudeScaled($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatitudeScaled() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatitudeScaled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get longitudeScaled => $_getIZ(3);
  @$pb.TagNumber(4)
  set longitudeScaled($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLongitudeScaled() => $_has(3);
  @$pb.TagNumber(4)
  void clearLongitudeScaled() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get satellitesUsed => $_getIZ(4);
  @$pb.TagNumber(5)
  set satellitesUsed($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSatellitesUsed() => $_has(4);
  @$pb.TagNumber(5)
  void clearSatellitesUsed() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get hdopScaled => $_getIZ(5);
  @$pb.TagNumber(6)
  set hdopScaled($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHdopScaled() => $_has(5);
  @$pb.TagNumber(6)
  void clearHdopScaled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get altitudeMeters => $_getIZ(6);
  @$pb.TagNumber(7)
  set altitudeMeters($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAltitudeMeters() => $_has(6);
  @$pb.TagNumber(7)
  void clearAltitudeMeters() => $_clearField(7);
}

class RouteInfo extends $pb.GeneratedMessage {
  factory RouteInfo({
    $core.int? destAddress,
    $core.int? nextHop,
    $core.int? state,
  }) {
    final result = RouteInfo._();
    if (destAddress != null) result.destAddress = destAddress;
    if (nextHop != null) result.nextHop = nextHop;
    if (state != null) result.state = state;
    return result;
  }

  RouteInfo._();

  factory RouteInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RouteInfo()..mergeFromBuffer(data, registry);
  factory RouteInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RouteInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RouteInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: RouteInfo.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'destAddress',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'nextHop', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'state', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouteInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouteInfo copyWith(void Function(RouteInfo) updates) =>
      super.copyWith((message) => updates(message as RouteInfo)) as RouteInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RouteInfo() / RouteInfo.new instead')
  static RouteInfo create() => RouteInfo._();
  static $pb.GeneratedMessage $_createMessage() => RouteInfo._();
  @$core.override
  RouteInfo createEmptyInstance() => RouteInfo._();
  @$core.pragma('dart2js:noInline')
  static RouteInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RouteInfo>(RouteInfo.$_createMessage);
  static RouteInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get destAddress => $_getIZ(0);
  @$pb.TagNumber(1)
  set destAddress($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDestAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearDestAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get nextHop => $_getIZ(1);
  @$pb.TagNumber(2)
  set nextHop($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextHop() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextHop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get state => $_getIZ(2);
  @$pb.TagNumber(3)
  set state($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => $_clearField(3);
}

class RoutesGetResult extends $pb.GeneratedMessage {
  factory RoutesGetResult({
    $core.Iterable<RouteInfo>? routes,
  }) {
    final result = RoutesGetResult._();
    if (routes != null) result.routes.addAll(routes);
    return result;
  }

  RoutesGetResult._();

  factory RoutesGetResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoutesGetResult()..mergeFromBuffer(data, registry);
  factory RoutesGetResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RoutesGetResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RoutesGetResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: RoutesGetResult.$_createMessage)
    ..pPM<RouteInfo>(1, _omitFieldNames ? '' : 'routes',
        subBuilder: RouteInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutesGetResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutesGetResult copyWith(void Function(RoutesGetResult) updates) =>
      super.copyWith((message) => updates(message as RoutesGetResult))
          as RoutesGetResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RoutesGetResult() / RoutesGetResult.new instead')
  static RoutesGetResult create() => RoutesGetResult._();
  static $pb.GeneratedMessage $_createMessage() => RoutesGetResult._();
  @$core.override
  RoutesGetResult createEmptyInstance() => RoutesGetResult._();
  @$core.pragma('dart2js:noInline')
  static RoutesGetResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoutesGetResult>(
          RoutesGetResult.$_createMessage);
  static RoutesGetResult? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RouteInfo> get routes => $_getList(0);
}

class PingResult extends $pb.GeneratedMessage {
  factory PingResult({
    $core.int? targetAddress,
    $core.int? rttMs,
    $core.bool? success,
  }) {
    final result = PingResult._();
    if (targetAddress != null) result.targetAddress = targetAddress;
    if (rttMs != null) result.rttMs = rttMs;
    if (success != null) result.success = success;
    return result;
  }

  PingResult._();

  factory PingResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingResult()..mergeFromBuffer(data, registry);
  factory PingResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: PingResult.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'targetAddress',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'rttMs', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingResult copyWith(void Function(PingResult) updates) =>
      super.copyWith((message) => updates(message as PingResult)) as PingResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PingResult() / PingResult.new instead')
  static PingResult create() => PingResult._();
  static $pb.GeneratedMessage $_createMessage() => PingResult._();
  @$core.override
  PingResult createEmptyInstance() => PingResult._();
  @$core.pragma('dart2js:noInline')
  static PingResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PingResult>(PingResult.$_createMessage);
  static PingResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get targetAddress => $_getIZ(0);
  @$pb.TagNumber(1)
  set targetAddress($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get rttMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set rttMs($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRttMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearRttMs() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get success => $_getBF(2);
  @$pb.TagNumber(3)
  set success($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSuccess() => $_has(2);
  @$pb.TagNumber(3)
  void clearSuccess() => $_clearField(3);
}

class MessageSendResult extends $pb.GeneratedMessage {
  factory MessageSendResult({
    $core.int? destAddress,
    $core.int? messageId,
    $core.bool? enqueued,
  }) {
    final result = MessageSendResult._();
    if (destAddress != null) result.destAddress = destAddress;
    if (messageId != null) result.messageId = messageId;
    if (enqueued != null) result.enqueued = enqueued;
    return result;
  }

  MessageSendResult._();

  factory MessageSendResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageSendResult()..mergeFromBuffer(data, registry);
  factory MessageSendResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageSendResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageSendResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: MessageSendResult.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'destAddress',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'messageId', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'enqueued')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSendResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageSendResult copyWith(void Function(MessageSendResult) updates) =>
      super.copyWith((message) => updates(message as MessageSendResult))
          as MessageSendResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MessageSendResult() / MessageSendResult.new instead')
  static MessageSendResult create() => MessageSendResult._();
  static $pb.GeneratedMessage $_createMessage() => MessageSendResult._();
  @$core.override
  MessageSendResult createEmptyInstance() => MessageSendResult._();
  @$core.pragma('dart2js:noInline')
  static MessageSendResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageSendResult>(
          MessageSendResult.$_createMessage);
  static MessageSendResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get destAddress => $_getIZ(0);
  @$pb.TagNumber(1)
  set destAddress($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDestAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearDestAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get messageId => $_getIZ(1);
  @$pb.TagNumber(2)
  set messageId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enqueued => $_getBF(2);
  @$pb.TagNumber(3)
  set enqueued($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnqueued() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnqueued() => $_clearField(3);
}

class EventNotification extends $pb.GeneratedMessage {
  factory EventNotification({
    EventNotification_EventType? eventType,
    $core.int? fromAddress,
    $core.String? payloadText,
  }) {
    final result = EventNotification._();
    if (eventType != null) result.eventType = eventType;
    if (fromAddress != null) result.fromAddress = fromAddress;
    if (payloadText != null) result.payloadText = payloadText;
    return result;
  }

  EventNotification._();

  factory EventNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EventNotification()..mergeFromBuffer(data, registry);
  factory EventNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EventNotification()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EventNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'esp_remote'),
      createEmptyInstance: EventNotification.$_createMessage)
    ..aE<EventNotification_EventType>(1, _omitFieldNames ? '' : 'eventType',
        enumValues: EventNotification_EventType.values)
    ..aI(2, _omitFieldNames ? '' : 'fromAddress',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'payloadText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventNotification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventNotification copyWith(void Function(EventNotification) updates) =>
      super.copyWith((message) => updates(message as EventNotification))
          as EventNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EventNotification() / EventNotification.new instead')
  static EventNotification create() => EventNotification._();
  static $pb.GeneratedMessage $_createMessage() => EventNotification._();
  @$core.override
  EventNotification createEmptyInstance() => EventNotification._();
  @$core.pragma('dart2js:noInline')
  static EventNotification getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EventNotification>(
          EventNotification.$_createMessage);
  static EventNotification? _defaultInstance;

  @$pb.TagNumber(1)
  EventNotification_EventType get eventType => $_getN(0);
  @$pb.TagNumber(1)
  set eventType(EventNotification_EventType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEventType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get fromAddress => $_getIZ(1);
  @$pb.TagNumber(2)
  set fromAddress($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get payloadText => $_getSZ(2);
  @$pb.TagNumber(3)
  set payloadText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayloadText() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayloadText() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
