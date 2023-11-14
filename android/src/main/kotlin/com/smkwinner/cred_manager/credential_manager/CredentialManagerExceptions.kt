package com.smkwinner.cred_manager.credential_manager

class CredentialManagerExceptions(val code:Int,val message:String, val details:String?)

/*  code  message
  101   initialization failure
  102   Plugin exception
  103   Not implemented

  201   Login cancelled
  202   No credentials found
  203   Mismatched credentials
  204   Login failed

  301   Save Credentials cancelled
  302   Create Credentials failed

  401  Create PublicKey Credential Dom Exception
*/