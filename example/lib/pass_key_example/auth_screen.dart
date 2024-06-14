// ignore_for_file: use_build_context_synchronously

import 'package:credential_manager/credential_manager.dart';
import 'package:credential_manager_example/pass_key_example/auth_service.dart';
import 'package:credential_manager_example/pass_key_example/home_screen.dart';

import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String? username;
  bool isRegistering = false;
  bool isLoggingIn = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwordless Auth',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Experience seamless passwordless authentication using passkeys.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) {
                  setState(() {
                    username = value;
                    errorMessage = null;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 16),
              if (errorMessage != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isRegistering ? null : register,
                icon: isRegistering
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.person_add),
                label: isRegistering
                    ? const SizedBox.shrink()
                    : const Text('Register'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isLoggingIn ? null : login,
                icon: isLoggingIn
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.login),
                label:
                    isLoggingIn ? const SizedBox.shrink() : const Text('Login'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<CredentialCreationOptions?> initRegister() async {
    if (username == null || username?.isEmpty == true) {
      setState(() {
        errorMessage = 'Please enter a username';
      });
      return null;
    }
    final res = await AuthService.passKeyRegisterInit(username: username!);
    return res;
  }

  Future<CredentialLoginOptions?> initLogin() async {
    final res = await AuthService.passKeyLoginInit();
    return res;
  }

  Future<void> login() async {
    setState(() {
      isLoggingIn = true;
      errorMessage = null;
    });
    try {
      final options = await initLogin();
      if (options == null) {
        setState(() {
          isLoggingIn = false;
          errorMessage = 'No credentials found';
        });
        return;
      }
      final credResponse =
          await AuthService.credentialManager.getPasswordCredentials(
        passKeyOption: CredentialLoginOptions(
          challenge: options.challenge,
          rpId: options.rpId,
          userVerification: options.userVerification,
        ),
      );

      if (credResponse.publicKeyCredential == null) {
        setState(() {
          isLoggingIn = false;
          errorMessage = 'No credentials found';
        });
        return;
      }

      final res = await AuthService.passKeyLoginFinish(
        challenge: options.challenge,
        request: credResponse.publicKeyCredential!,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: res,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoggingIn = false;
      });
    }
  }

  Future<void> register() async {
    setState(() {
      isRegistering = true;
      errorMessage = null;
    });
    try {
      final options = await initRegister();
      if (options == null) {
        setState(() {
          isRegistering = false;
        });
        return;
      }
      final credResponse = await AuthService.credentialManager
          .savePasskeyCredentials(request: options);

      final res = await AuthService.passKeyRegisterFinish(
        username: username!,
        challenge: options.challenge,
        request: credResponse,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: res,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isRegistering = false;
      });
    }
  }
}
