// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/material.dart';

CredentialManager credentialManager = CredentialManager();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (credentialManager.isSupportedPlatform) {
    await credentialManager.init(preferImmediatelyAvailableCredentials: true);
  }

  runApp(const MyApp());
}

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? username;

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
          AbsorbPointer(
            absorbing: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.5 : 1,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                                    color: Colors.blueAccent))),
                      ),
                    ),
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
                                    color: Colors.blueAccent))),
                      ),
                    ),
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
                          borderRadius: BorderRadius.circular(16)),
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        onLogin();
                      },
                      color: Colors.red,
                      minWidth: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: const Text(
                        "Login in with saved credentials",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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

  onLogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      PasswordCredential credential = await credentialManager
          .getEncryptedCredentials(secretKey: secretKey, ivKey: ivKey);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully retrived credential")));
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Login success"),
                content: Text(
                    "Username:${credential.username}\nPassword:${credential.password}"),
              ));
    } on CredentialException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  onRegister() async {
    setState(() {
      isLoading = true;
    });
    try {
      await credentialManager.saveEncryptedCredentials(
          credential:
              PasswordCredential(username: username, password: password),
          secretKey: secretKey,
          ivKey: ivKey);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully saved credential")));
    } on CredentialException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
