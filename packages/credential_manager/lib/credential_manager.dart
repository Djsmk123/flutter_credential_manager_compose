export 'dart:io' show Platform;

// Export platform interface from package
export 'package:credential_manager_platform_interface/credential_manager_platform_interface.dart';

// Export models
export 'src/Models/password_credentials.dart';
export 'src/Models/google_user_model.dart';
export 'src/Models/credentials.dart';
export 'src/Models/passkey/create_pass_key_request_model.dart';
export 'src/Models/passkey/login_pass_key_request_model.dart';
export 'src/Models/passkey/pass_key_response_model_sucess.dart';
export 'src/Models/fetch_options.dart';

// Export core and utilities
export 'src/credential_manager_core.dart';
export 'src/exceptions/exceptions.dart';
export 'src/utils/encryption.dart';
export 'src/utils/credential_type.dart';
export 'src/utils/platform_exception_handler.dart';
export 'src/utils/credential_response_parser.dart';
