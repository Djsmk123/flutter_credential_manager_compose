// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/material.dart';

// Create an instance of CredentialManager for managing credentials
CredentialManager credentialManager = CredentialManager();

//Google Client Id for google login

const String googleClientId = String.fromEnvironment("Google-web-client-id");
// Main entry point of the application
Future<void> main() async {
  // Ensure that the Flutter app is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize CredentialManager if the platform is supported
  if (credentialManager.isSupportedPlatform) {
    await credentialManager.init(
      preferImmediatelyAvailableCredentials: true,
      //optional parameter for integrate google signing
      googleClientId: googleClientId.isEmpty ? null : googleClientId,
    );
  }

  // Run the app
  runApp(const MyApp());
}

// The main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Credential Manager Example",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// Widget for the login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// State class for the login screen
class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? username;

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? password;

  final secretKey = '1234567812345678'; // Use a secure key here
  final ivKey = "xfpkDQJXIfb3mcnb";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credentials Manager"),
      ),
      body: Stack(
        children: [
          // Main body with user input
          AbsorbPointer(
            absorbing: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.5 : 1,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Username input field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            username = value;
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a username";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Password input field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            password = value;
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Register button
                    MaterialButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          onRegister();
                        }
                      },
                      color: Colors.red,
                      minWidth: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          onRegisterWithPassKey();
                        }
                      },
                      color: Colors.red,
                      minWidth: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Register with pass key",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    // Login button
                    MaterialButton(
                      onPressed: () async {
                        onLogin();
                      },
                      color: Colors.red,
                      minWidth: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Login in with saved credentials",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),

                    //Google Sign In
                    MaterialButton(
                      onPressed: () async {
                        try {
                          final credential =
                              await credentialManager.saveGoogleCredential();
                          String message =
                              credential?.toJson().toString() ?? "";

                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Successfully retrieved credential")));
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Login success"),
                              content: Text(message),
                            ),
                          );
                        } on CredentialException catch (e) {
                          log(e.message);
                        }
                      },
                      color: Colors.red,
                      minWidth: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Google Sign In",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading indicator
          Opacity(
            opacity: isLoading ? 1 : 0,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }

  // Method for handling login process
  onLogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Retrieve encrypted credentials and show a dialog on success
      Credentials credential = await credentialManager.getEncryptedCredentials(
          secretKey: secretKey,
          ivKey: ivKey,
          passKeyOption: CredentialLoginOptions(
            challenge: EncryptData.getEncodedChallenge(),
            rpId:
                "https://credentialmanger-a1hh5u861-djsmk123s-projects.vercel.app",
            userVerification: "required",
          ));
      bool isPasswordBasedCredentials = credential.passwordCredential != null;
      bool isPublicKeyBasedCredentials = credential.publicKeyCredential != null;
      var message =
          "Credential Type:${isPasswordBasedCredentials ? "Password" : isPublicKeyBasedCredentials ? "Passkey" : "Google base"}, ";
      if (isPasswordBasedCredentials) {
        message += credential.passwordCredential!.toJson().toString();
      } else if (isPublicKeyBasedCredentials) {
        message += credential.publicKeyCredential!.toJson().toString();
      } else {
        message += credential.googleIdTokenCredential!.toJson().toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully retrieved credential")));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login success"),
          content: Text(message),
        ),
      );
    } on CredentialException catch (e) {
      // Show a snack bar on exception
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } finally {
      // Update the loading state
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Method for handling registration process
  onRegister() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Save encrypted credentials and show a snackbar on success
      await credentialManager.saveEncryptedCredentials(
        credential: PasswordCredential(username: username, password: password),
        secretKey: secretKey,
        ivKey: ivKey,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully saved credential")),
      );
    } on CredentialException catch (e) {
      // Show a snack-bar on exception
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } finally {
      // Update the loading state
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  onRegisterWithPassKey() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Save encrypted credentials and show a snackbar on success
      await credentialManager.savePasskeyCredentials(
          request: CredentialCreationOptions.fromJson({
        "challenge": EncryptData.getEncodedChallenge(),
        "rp": {
          "name": "Credential test",
          "id":
              "https://credentialmanger-a1hh5u861-djsmk123s-projects.vercel.app"
        },
        "user": {
          "id": EncryptData.getEncodedUserId(),
          "name": username,
          "displayName": username,
        },
        "pubKeyCredParams": [
          {"type": "public-key", "alg": -7},
          {"type": "public-key", "alg": -257}
        ],
        "timeout": 1800000,
        "attestation": "none",
        "excludeCredentials": [
          {"id": "ghi789", "type": "public-key"},
          {"id": "jkl012", "type": "public-key"}
        ],
        "authenticatorSelection": {
          "authenticatorAttachment": "platform",
          "residentKey": "required"
        }
      }));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully saved credential")),
      );
    } on CredentialException catch (e) {
      // Show a snack-bar on exception
      log("Error: ${e.message} ${e.code} ${e.details}");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } finally {
      // Update the loading state
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
