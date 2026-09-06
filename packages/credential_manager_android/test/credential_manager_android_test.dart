import 'dart:convert';

import 'package:credential_manager_android/credential_manager_android.dart';
import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('credential_manager_test');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('prepareCredentials forwards the same options used by getCredentials', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'prepare_credentials') return true;
      if (call.method == 'get_password_credentials') {
        return <String, Object?>{
          'type': 'PasswordCredentials',
          'data': <String, Object?>{'username': 'alex@example.com', 'password': 'secret-password'},
        };
      }
      return null;
    });

    final manager = CredentialManagerAndroid(channel: channel);
    final options = FetchOptionsAndroid(passwordCredential: true);

    expect(await manager.prepareCredentials(fetchOptions: options), isTrue);
    final credentials = await manager.getCredentials(fetchOptions: options);

    expect(credentials.passwordCredential?.username, 'alex@example.com');
    expect(calls.map((call) => call.method), ['prepare_credentials', 'get_password_credentials']);
    expect(calls[0].arguments, calls[1].arguments);
    expect(jsonDecode((calls[0].arguments as Map<Object?, Object?>)['fetchOptions']! as String), {
      'passKey': false,
      'googleCredential': false,
      'passwordCredential': true,
    });
  });

  test('prepareCredentials reports when native preparation is unsupported', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => false,
    );

    final manager = CredentialManagerAndroid(channel: channel);

    expect(await manager.prepareCredentials(fetchOptions: FetchOptionsAndroid(passwordCredential: true)), isFalse);
  });
}
