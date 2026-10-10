import 'package:credential_manager_android/credential_manager_android.dart';
import 'package:credential_manager_android/src/messages.g.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [CredentialManagerHostApi] test double. Pigeon generates a concrete
/// (non-abstract) client class for `@HostApi()`, so overriding its methods
/// directly is simpler and more robust than mocking the underlying
/// `BinaryMessenger` channel traffic.
class _FakeHostApi extends CredentialManagerHostApi {
  _FakeHostApi();

  final calls = <String>[];
  FetchOptionsMessage? lastFetchOptions;
  String? lastPasskeyRequestJson;

  bool preparedResult = false;
  CredentialResultMessage? credentialsResult;
  Object? errorToThrow;

  @override
  Future<bool> prepareCredentials(String? passkeyRequestJson, FetchOptionsMessage fetchOptions) async {
    calls.add('prepareCredentials');
    lastPasskeyRequestJson = passkeyRequestJson;
    lastFetchOptions = fetchOptions;
    return preparedResult;
  }

  @override
  Future<CredentialResultMessage> getCredentials(String? passkeyRequestJson, FetchOptionsMessage fetchOptions) async {
    calls.add('getCredentials');
    lastPasskeyRequestJson = passkeyRequestJson;
    lastFetchOptions = fetchOptions;
    final error = errorToThrow;
    if (error != null) throw error;
    return credentialsResult!;
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
  }
}

void main() {
  test('prepareCredentials forwards the same options used by getCredentials', () async {
    final fakeApi = _FakeHostApi()
      ..preparedResult = true
      ..credentialsResult = CredentialResultMessage(
        type: CredentialResultType.passwordCredential,
        passwordCredential: PasswordCredentialMessage(username: 'alex@example.com', password: 'secret-password'),
      );

    final manager = CredentialManagerAndroid(hostApi: fakeApi);
    final options = FetchOptionsAndroid(passwordCredential: true);

    expect(await manager.prepareCredentials(fetchOptions: options), isTrue);
    final credentials = await manager.getCredentials(fetchOptions: options);

    expect(credentials.passwordCredential?.username, 'alex@example.com');
    expect(fakeApi.calls, ['prepareCredentials', 'getCredentials']);
    expect(fakeApi.lastFetchOptions?.passKey, false);
    expect(fakeApi.lastFetchOptions?.googleCredential, false);
    expect(fakeApi.lastFetchOptions?.passwordCredential, true);
  });

  test('prepareCredentials reports when native preparation is unsupported', () async {
    final fakeApi = _FakeHostApi()..preparedResult = false;
    final manager = CredentialManagerAndroid(hostApi: fakeApi);

    expect(await manager.prepareCredentials(fetchOptions: FetchOptionsAndroid(passwordCredential: true)), isFalse);
  });

  test('getCredentials returns empty Credentials when native reports no credentials found (code 202)', () async {
    final fakeApi = _FakeHostApi()..errorToThrow = PlatformException(code: '202', message: 'No credentials found');
    final manager = CredentialManagerAndroid(hostApi: fakeApi);

    final credentials = await manager.getCredentials(fetchOptions: FetchOptionsAndroid(passwordCredential: true));

    expect(credentials.passwordCredential, isNull);
    expect(credentials.googleIdTokenCredential, isNull);
    expect(credentials.publicKeyCredential, isNull);
  });

  test('getCredentials rethrows other platform errors as CredentialException', () async {
    final fakeApi = _FakeHostApi()..errorToThrow = PlatformException(code: '204', message: 'Login failed');
    final manager = CredentialManagerAndroid(hostApi: fakeApi);

    expect(
      () => manager.getCredentials(fetchOptions: FetchOptionsAndroid(passwordCredential: true)),
      throwsA(isA<CredentialException>().having((e) => e.code, 'code', 204)),
    );
  });

  test('savePasswordCredentials throws when username or password is missing', () async {
    final manager = CredentialManagerAndroid(hostApi: _FakeHostApi());

    expect(
      () => manager.savePasswordCredentials(PasswordCredential(username: 'alex@example.com')),
      throwsA(isA<CredentialException>().having((e) => e.code, 'code', 302)),
    );
  });

  test('logout delegates to the host API', () async {
    final fakeApi = _FakeHostApi();
    final manager = CredentialManagerAndroid(hostApi: fakeApi);

    await manager.logout();

    expect(fakeApi.calls, ['logout']);
  });
}
