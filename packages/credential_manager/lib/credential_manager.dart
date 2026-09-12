/// A unified Flutter API for platform credential storage: one-tap sign-in and
/// passkeys via Android's Jetpack Credential Manager, and Keychain/Autofill on
/// iOS, behind a single [CredentialManager] entry point.
library;

// Export platform interface and models from platform_interface
export 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';

// Re-export exceptions and utilities from platform_interface
export 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart'
    show CredentialException, CredentialType, PlatformExceptionHandler, CredentialResponseParser;

// Export core and utilities (only encryption, others moved to platform_interface)
export 'src/credential_manager_core.dart';
export 'src/utils/encryption.dart';
export 'src/utils/platform.dart';
