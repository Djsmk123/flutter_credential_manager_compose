import 'dart:convert';

import 'package:credential_manager_ios/credential_manager_ios.dart';
import 'package:credential_manager_ios/src/messages.g.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHostApi extends CredentialManagerHostApi {
  _FakeHostApi();

  Object? error;
  String? lastRequestJson;
  bool? lastPreferImmediate;
  String passkeyResponse = '{"id":"id","rawId":"id","response":{"clientDataJSON":"cdj","signature":"sig"}}';
  bool loggedOut = false;

  void _maybeThrow() {
    if (error != null) throw error!;
  }

  @override
  Future<String> getPlatformVersion() async => 'iOS 17.0';

  @override
  Future<void> initialize(bool preferImmediatelyAvailableCredentials, String? googleClientId) async {
    _maybeThrow();
    lastPreferImmediate = preferImmediatelyAvailableCredentials;
  }

  @override
  Future<String> getPasskeyCredential(String passkeyRequestJson) async {
    _maybeThrow();
    lastRequestJson = passkeyRequestJson;
    return passkeyResponse;
  }

  @override
  Future<String> savePasskeyCredential(String requestJson) async {
    _maybeThrow();
    lastRequestJson = requestJson;
    return passkeyResponse;
  }

  @override
  Future<void> logout() async {
    _maybeThrow();
    loggedOut = true;
  }
}

void main() {
  late _FakeHostApi host;
  late CredentialManagerIos ios;

  setUp(() {
    host = _FakeHostApi();
    ios = CredentialManagerIos(hostApi: host);
  });

  test('getPlatformVersion delegates to host api', () async {
    expect(await ios.getPlatformVersion(), 'iOS 17.0');
  });

  test('init forwards flag and maps native failures to code 101', () async {
    await ios.init(true, null);
    expect(host.lastPreferImmediate, isTrue);

    host.error = PlatformException(code: 'invalid-arguments', message: 'boom');
    expect(() => ios.init(true, null), throwsA(isA<CredentialException>().having((e) => e.code, 'code', 101)));
  });

  test('getCredentials without passkey option is unsupported', () async {
    expect(() => ios.getCredentials(), throwsA(isA<CredentialException>().having((e) => e.code, 'code', 103)));
  });

  test('getCredentials maps native failures through PlatformExceptionHandler', () async {
    host.error = PlatformException(code: 'cancelled', message: 'user cancelled');
    final option = CredentialLoginOptions(challenge: 'c', rpId: 'example.com', userVerification: 'required');
    expect(() => ios.getCredentials(passKeyOption: option), throwsA(isA<CredentialException>()));
  });

  test('getCredentials decodes the passkey JSON into a public key credential', () async {
    final option = CredentialLoginOptions(challenge: 'c', rpId: 'example.com', userVerification: 'required');
    final res = await ios.getCredentials(passKeyOption: option);
    expect(res.publicKeyCredential?.id, 'id');
    expect(jsonDecode(host.lastRequestJson!)['rpId'], 'example.com');
  });

  test('logout delegates to host api and maps failures to code 504', () async {
    await ios.logout();
    expect(host.loggedOut, isTrue);

    host.error = PlatformException(code: 'x');
    expect(() => ios.logout(), throwsA(isA<CredentialException>().having((e) => e.code, 'code', 504)));
  });

  test('unsupported password and google methods fail explicitly', () async {
    expect(
      () => ios.savePasswordCredentials(PasswordCredential(username: 'u', password: 'p')),
      throwsA(isA<CredentialException>().having((e) => e.code, 'code', 103)),
    );
    expect(
      () => ios.saveGoogleCredential(false),
      throwsA(isA<CredentialException>().having((e) => e.code, 'code', 103)),
    );
  });
}
