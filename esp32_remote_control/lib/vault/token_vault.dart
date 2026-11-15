import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenVault {
  final FlutterSecureStorage _storage;

  TokenVault({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  static String _keyForNode(String nodeIdentifier) {
    final clean = nodeIdentifier.trim().toLowerCase();
    return 'token_$clean';
  }

  Future<void> saveToken(String nodeIdentifier, String token) async {
    await _storage.write(
      key: _keyForNode(nodeIdentifier),
      value: token.trim(),
    );
  }

  Future<String?> getToken(String nodeIdentifier) async {
    return await _storage.read(key: _keyForNode(nodeIdentifier));
  }

  Future<void> deleteToken(String nodeIdentifier) async {
    await _storage.delete(key: _keyForNode(nodeIdentifier));
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
