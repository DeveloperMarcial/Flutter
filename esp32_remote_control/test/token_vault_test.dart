import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:esp32_remote_control/vault/token_vault.dart';

class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('TokenVault Android Keystore Encrypted Vault Tests', () {
    late FakeSecureStorage fakeStorage;
    late TokenVault vault;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      vault = TokenVault(storage: fakeStorage);
    });

    test('Save, retrieve and delete token for eNode-48', () async {
      expect(await vault.getToken('eNode-48'), isNull);

      await vault.saveToken('eNode-48', 'aabbccddeeff00112233445566778899');
      expect(await vault.getToken('eNode-48'), equals('aabbccddeeff00112233445566778899'));

      // Case-insensitive lookup
      expect(await vault.getToken('ENODE-48'), equals('aabbccddeeff00112233445566778899'));

      await vault.deleteToken('eNode-48');
      expect(await vault.getToken('eNode-48'), isNull);
    });

    test('Multiple nodes store isolated tokens', () async {
      await vault.saveToken('eNode-48', 'token_48');
      await vault.saveToken('eNode-49', 'token_49');

      expect(await vault.getToken('eNode-48'), equals('token_48'));
      expect(await vault.getToken('eNode-49'), equals('token_49'));

      await vault.clearAll();
      expect(await vault.getToken('eNode-48'), isNull);
      expect(await vault.getToken('eNode-49'), isNull);
    });
  });
}
