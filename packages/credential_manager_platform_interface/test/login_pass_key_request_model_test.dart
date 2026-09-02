import 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contains both '-' and '_', and a length that is not a multiple of four, so a
/// stray Base64URL to Base64 conversion of a credential id would be visible.
const String _credentialId = 'test-credential_id-002';

Map<String, dynamic> _requestOptions({Object? allowCredentials}) => {
      'challenge': 'Y2hhbGxlbmdlLXZhbHVl',
      'rpId': 'example.com',
      'userVerification': 'preferred',
      'timeout': 300000,
      if (allowCredentials != null) 'allowCredentials': allowCredentials,
    };

void main() {
  group('CredentialLoginOptions.allowCredentials', () {
    test('defaults to an empty list when the key is absent', () {
      final options = CredentialLoginOptions.fromJson(_requestOptions());

      expect(options.allowCredentials, isEmpty);
    });

    test('stays empty when the server sends an empty list', () {
      final options = CredentialLoginOptions.fromJson(
        _requestOptions(allowCredentials: const []),
      );

      expect(options.allowCredentials, isEmpty);
    });

    test('serialises without the key while empty, matching the previous output',
        () {
      final options = CredentialLoginOptions.fromJson(_requestOptions());

      expect(options.toJson(), {
        'challenge': 'Y2hhbGxlbmdlLXZhbHVl',
        'rpId': 'example.com',
        'userVerification': 'preferred',
        'timeout': 300000,
        'conditionalUI': false,
      });
    });

    test('parses a descriptor and keeps the id verbatim', () {
      final options = CredentialLoginOptions.fromJson(
        _requestOptions(allowCredentials: [
          {
            'id': _credentialId,
            'type': 'public-key',
            'transports': ['internal', 'hybrid'],
          },
        ]),
      );

      expect(options.allowCredentials, hasLength(1));
      expect(options.allowCredentials.first.id, _credentialId);
      expect(options.allowCredentials.first.type, 'public-key');
      expect(options.allowCredentials.first.transports, ['internal', 'hybrid']);
    });

    test('serialises descriptors in the shape the platforms expect', () {
      final options = CredentialLoginOptions.fromJson(
        _requestOptions(allowCredentials: [
          {'id': _credentialId, 'type': 'public-key'},
        ]),
      );

      expect(options.toJson()['allowCredentials'], [
        {'id': _credentialId, 'type': 'public-key'},
      ]);
    });

    test('defaults type to public-key and omits empty transports', () {
      final credential = AllowCredential.fromJson({'id': _credentialId});

      expect(credential.type, 'public-key');
      expect(credential.transports, isEmpty);
      expect(credential.toJson(), {'id': _credentialId, 'type': 'public-key'});
    });
  });
}
