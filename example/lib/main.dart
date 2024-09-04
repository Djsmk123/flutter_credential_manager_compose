import 'dart:async';
import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/material.dart';

const String googleClientId = "";
const String secretKey = '1234567812345678'; // Use a secure key here
const String ivKey = "xfpkDQJXIfb3mcnb";
const String rpId = "blogs-deeplink-example.vercel.app";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final credentialManager = CredentialManager();

  if (credentialManager.isSupportedPlatform) {
    await credentialManager.init(
      preferImmediatelyAvailableCredentials: true,
      googleClientId: googleClientId.isNotEmpty ? googleClientId : null,
    );
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
      theme: ThemeData(useMaterial3: true),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final credentialManager = CredentialManager();
  bool isLoading = false;
  bool createPassKey = false;
  String? username;
  String? password;
  late CredentialLoginOptions passKeyLoginOption;

  @override
  void initState() {
    super.initState();
    passKeyLoginOption = CredentialLoginOptions(
      challenge: "HjBbH__fbLuzy95AGR31yEARA0EMtKlY0NrV5oy3NQw",
      rpId: rpId,
      userVerification: "required",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Credentials Manager")),
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
                    _buildInputField("Username", (value) => username = value),
                    if (createPassKey)
                      _buildInputField("Password", (value) => password = value,
                          isPassword: true),
                    _buildButton("Register", onRegister),
                    _buildButton(
                        "Register with pass key", onRegisterWithPassKey),
                    _buildButton(
                        "Register with Google Sign In", onGoogleSignIn),
                    _buildButton("Login (Password, Passkey, Google)", onLogin),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, Function(String) onChanged,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        onChanged: onChanged,
        obscureText: isPassword,
        validator: (value) => value!.isEmpty ? "Please enter a $hint" : null,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.red,
      minWidth: MediaQuery.of(context).size.width / 2,
      height: 40,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Future<void> onRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!createPassKey) {
        setState(() => createPassKey = true);
      } else {
        await _performAction(() async {
          await credentialManager.saveEncryptedCredentials(
            credential:
                PasswordCredential(username: username, password: password),
            secretKey: secretKey,
            ivKey: ivKey,
          );
          _showSnackBar("Successfully saved credential");
        });
      }
    }
  }

  Future<void> onRegisterWithPassKey() async {
    if (_formKey.currentState!.validate()) {
      await _performAction(() async {
        final res = await credentialManager.savePasskeyCredentials(
          request: CredentialCreationOptions.fromJson({
            "challenge": "HjBbH__fbLuzy95AGR31yEARA0EMtKlY0NrV5oy3NQw",
            "rp": {"name": "CredMan App Test", "id": rpId},
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
          }),
        );
        _showSnackBar("Successfully saved credential");
        _showDialog(
            "Pass key created successfully", "Response: ${res.toJson()}");
      });
    }
  }

  Future<void> onGoogleSignIn() async {
    await _performAction(() async {
      final credential = await credentialManager.saveGoogleCredential();
      String message = credential?.toJson().toString() ?? "";
      _showSnackBar("Successfully retrieved credential");
      _showDialog("Login success", message);
    });
  }

  Future<void> onLogin() async {
    await _performAction(() async {
      Credentials credential = await credentialManager.getEncryptedCredentials(
        secretKey: secretKey,
        ivKey: ivKey,
        passKeyOption: passKeyLoginOption,
      );
      _showLoginSuccessDialog(credential);
    });
  }

  Future<void> _performAction(Future<void> Function() action) async {
    setState(() => isLoading = true);
    try {
      await action();
    } on CredentialException catch (e) {
      _showSnackBar(e.message.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(content)),
    );
  }

  void _showLoginSuccessDialog(Credentials credential) {
    bool isPasswordBasedCredentials = credential.passwordCredential != null;
    bool isPublicKeyBasedCredentials = credential.publicKeyCredential != null;
    var message =
        "Credential Type: ${isPasswordBasedCredentials ? "Password" : isPublicKeyBasedCredentials ? "Passkey" : "Google"}, ";
    message += isPasswordBasedCredentials
        ? credential.passwordCredential!.toJson().toString()
        : isPublicKeyBasedCredentials
            ? credential.publicKeyCredential!.toJson().toString()
            : credential.googleIdTokenCredential!.toJson().toString();
    _showSnackBar("Successfully retrieved credential");
    _showDialog("Login success", message);
  }
}
