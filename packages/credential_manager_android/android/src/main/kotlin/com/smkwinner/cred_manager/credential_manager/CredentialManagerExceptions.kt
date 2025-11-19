package com.smkwinner.cred_manager.credential_manager

/**
 * Class representing exceptions thrown by the Credential Manager.
 * @property code The error code associated with the exception.
 * @property message A descriptive message explaining the exception.
 * @property details Additional details about the exception (optional).
 */
class CredentialManagerExceptions(val code: Int, val message: String, val details: String?)


/*  code  message
  101   initialization failure
  102   Plugin exception
  103   Not implemented

  201   Login cancelled
  202   No credentials found
  203   Mismatched credentials
  204   Login failed
  205   Temporarily blocked (due to too many canceled sign-in prompts)
  206   Credential fetch options not enabled
  207   No Google account present (launched account settings)
  208   RequestJson is required for passkey

  301   Save Credentials cancelled
  302   Create Credentials failed

  401  Create PublicKey Credential Dom Exception

*/