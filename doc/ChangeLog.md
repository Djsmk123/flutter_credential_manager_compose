# Changes Log

## 0.0.1

- initial release

## 0.0.2

- Add encryption
- No breaking changes
- Add documentation

## 0.0.3

- Implement remaining ActivityAware lifecycle methods,Thanks to [Granfalloner](https://github.com/Granfalloner)

## 0.0.4

- Migrate to latest version of jetpack library [https://developer.android.com/jetpack/androidx/releases/credentials#groovy](https://developer.android.com/jetpack/androidx/releases/credentials#groovy)
- Google Sign in with Credential Manager

## 0.0.5

- Update all dependencies to latest version Thanks to [@jlafazia-figure](https://github.com/jlafazia-figure)
- Bug fixes and improvements in example application
- Update README.md with latest information

## 1.0.0

- Added Passkey support.
- Autofill from website.
- Fix bugs and improve code.

## 1.0.1

- Fix Example application(package Id).
- Provided rpId for testing purpose.

## 1.0.2

- Add missing fields `Response` Object for `PublicKeyCredential`

## 1.0.3

- Add google button flow for google login,Thanks to @[wildsylvan](https://github.com/wildsylvan)

## 1.0.4

- Add logout functionality using clearCredential(), example application, documentation and dependencies update.

## 1.0.4+1

- Update documentation
- Update example application
- Update dependencies
- Update README.md
- Update CHANGELOG.md
- Update LICENSE
- Update pubspec.yaml
- Update errors.md

## 2.0.0

- Add Password Credentials and Passkey Credentials support for iOS
- Breaking changes in android
- Removed Encrypted Credentials password based from both platforms

## 2.0.1

- Fixed Example application (enableInlineAutofill) for iOS by Default.

## 2.0.2

- Update Documentation

## 2.0.3

- Migarte to example application to gradle-8.10.2
- Update dependencies
- Add Decoding for `attestationObject` to get `publicKey` and `authenticatorData` for passkey credential registration for iOS only.
- Improved Example application
