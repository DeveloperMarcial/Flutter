enum SendStatus {
  success,
  failed,
  uncertain,
}

class DisconnectedDuringSendException implements Exception {
  final String message;
  final SendStatus status = SendStatus.uncertain;

  const DisconnectedDuringSendException([this.message = 'Link dropped during send acknowledgment — manual retry required']);

  @override
  String toString() => 'DisconnectedDuringSendException: $message (status: $status)';
}

class RemoteTransportException implements Exception {
  final String message;
  const RemoteTransportException(this.message);

  @override
  String toString() => 'RemoteTransportException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Device rejected request: unauthorized or invalid token']);

  @override
  String toString() => 'UnauthorizedException: $message';
}
