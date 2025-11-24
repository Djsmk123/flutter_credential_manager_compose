# Credential Manager
![Android](https://img.shields.io/badge/Platforms-Android-green)
![iOS](https://img.shields.io/badge/Platforms-iOS-blue)

[Credential Manager](https://developer.android.com/jetpack/androidx/releases/credentials) is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (like Sign-in with Google) in a single API, simplifying integration for developers on Android. For iOS, it uses Keychain for storing credentials.

For users, Credential Manager unifies the sign-in interface across authentication methods, making it clearer and easier to sign into apps, regardless of the chosen method.

For iOS, it uses [Keychain](https://developer.apple.com/documentation/security/keychain_services) and [Autofill](https://developer.apple.com/documentation/uikit/text_input/adding_password_autofill_support_to_your_app).

For more information, please refer to the [official documentation](https://developer.android.com/jetpack/androidx/releases/credentials).

## Getting Started

Add the dependency to your pubspec.yaml file:

```yaml
credential_manager: <latest_version>
```

Or run:

```bash
flutter pub add credential_manager
```

## Documentation

For comprehensive guides and detailed documentation, please visit our [Documentation Page](https://djsmk123.github.io/flutter_credential_manager_compose/#/). Here you will find everything you need to get started, including API references, usage examples, and best practices for integrating Credential Manager into your application.

## Credential Flow Previews

<table>
  <tr>
    <th>Android Credential Manager</th>
    <th>iOS Passkey Sheet</th>
  </tr>
  <tr>
    <td align="center">
      <img
        src="https://developer.android.com/static/images/design/ui/mobile/passkeys/02c-a14-two-step-flow.png"
        alt="Credential Manager UI"
        width="350"
      />
    </td>
    <td align="center">
      <img
        src="https://devimages-cdn.apple.com/wwdc-services/images/D35E0E85-CCB6-41A1-B227-7995ECD83ED5/8332/8332_wide_900x506_2x.jpg"
        alt="Apple Passkey UI"
        width="350"
      />
    </td>
  </tr>
</table>

> **Heads-up:** The screenshots above come directly from the official Android and Apple design resources. The bundled example application recreates similar flows but may look slightly different depending on your theme, device, or customizations.

## Development Workflow

We rely on [pre-commit](https://pre-commit.com/) to guarantee formatting and analyzer checks run before every commit.

```bash
pip3 install --user pre-commit   # first time only
python3 -m pre_commit install    # installs the git hook
# (optional) run on the entire repo once
python3 -m pre_commit run --all-files
```

The configured hooks will:

- Format every staged Dart file using `dart format`.
- Format `docSite` sources with Prettier.
- Run `flutter analyze` across all packages (including the example app); commits are blocked if any analyzer error occurs.

## Support the Project

If you find this library useful and would like to support its development, consider buying me a coffee:

[☕ Buy Me a Coffee](https://www.buymeacoffee.com/smkwinner)

## Looking for Maintainers

We are looking for maintainers to help us keep this library up-to-date and implement new features. If you are interested in contributing, please reach out via [GitHub](https://github.com/Djsmk123/flutter_credential_manager_compose) or open an issue. Your help would be greatly appreciated!

## Contributors

Thanks to all the contributors who have helped make this library better!

[![Contributors](https://contrib.rocks/image?repo=Djsmk123/flutter_credential_manager_compose)](https://github.com/Djsmk123/flutter_credential_manager_compose/graphs/contributors)
