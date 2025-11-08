# credential_manager_platform_interface

A common platform interface for the `credential_manager` plugin.

This package allows platform-specific implementations of `credential_manager` to share the same interface. Platform-specific implementations should extend `CredentialManagerPlatform` and implement the required methods.

## Usage

This package is typically used by platform-specific implementations of `credential_manager`. End users should use the main `credential_manager` package instead.

## Platform Implementations

- `credential_manager_android` - Android implementation
- `credential_manager_ios` - iOS implementation
- `credential_manager_web` - Web implementation (future)

## License

See the [LICENSE](../LICENSE) file for details.

