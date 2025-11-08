export 'dart:io' show Platform;

// Export platform interface and models from platform_interface
export 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';

// Re-export exceptions and utilities from platform_interface
export 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart'
    show
        CredentialException,
        CredentialType,
        PlatformExceptionHandler,
        CredentialResponseParser;

// Export core and utilities (only encryption, others moved to platform_interface)
export 'src/credential_manager_core.dart';
export 'src/utils/encryption.dart';
