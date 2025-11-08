import 'dart:async';
import 'package:credential_manager/credential_manager.dart';
import 'package:credential_manager_example/home_screen.dart';
import 'package:flutter/material.dart';

const String googleClientId = "";
const String rpId = "blogs-deeplink-example.vercel.app";
final CredentialManager credentialManager = CredentialManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  bool isLoading = false;
  bool createPassKey = false;
  String? username;
  String? password;
  late CredentialLoginOptions passKeyLoginOption;
  bool isGoogleEnabled = false;

  @override
  void initState() {
    super.initState();
    passKeyLoginOption = CredentialLoginOptions(
      challenge: "HjBbH__fbLuzy95AGR31yEARA0EMtKlY0NrV5oy3NQw",
      rpId: rpId,
      userVerification: "required",
      //only for ios, true only when we want to show the passkey popup on keyboard otherwise false
      conditionalUI: false,
    );
    isGoogleEnabled = googleClientId.isNotEmpty;
  }

  Widget _buildAutofillGroup(Widget child) {
    if (enableInlineAutofill) {
      return AutofillGroup(
        child: child,
      );
    }
    return child;
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
              child: _buildAutofillGroup(
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInputField("Username", (value) => username = value),
                      if (createPassKey)
                        _buildInputField(
                            "Password", (value) => password = value,
                            isPassword: true),
                      _buildButton("Register", onRegister),
                      _buildButton(
                          "Register with pass key", onRegisterWithPassKey),
                      if (Platform.isAndroid)
                        _buildButton(
                            "Register with Google Sign In", onGoogleSignIn),
                      if (Platform.isAndroid)
                        _buildButton(
                            "Login (Password, Passkey, Google)", onLogin)
                      else
                        _buildButton("Login Passkey", onLogin)
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator.adaptive()),
        ],
      ),
    );
  }

  bool enableInlineAutofill = Platform.isIOS;

  Widget _buildInputField(String hint, Function(String) onChanged,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        onChanged: onChanged,
        obscureText: isPassword,
        autofillHints: enableInlineAutofill
            ? (isPassword
                ? const [AutofillHints.password]
                : const [AutofillHints.username])
            : [],
        keyboardType: isPassword ? TextInputType.visiblePassword : null,
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
        if (enableInlineAutofill) {
          _navigateToHomeScreen(Credential.password,
              passwordCredential: PasswordCredential(
                username: username,
                password: password,
              ));
          return;
        }

        await _performAction(() async {
          await credentialManager.savePasswordCredentials(
            PasswordCredential(username: username, password: password),
          );

          _showSnackBar("Successfully saved credential");
          _navigateToHomeScreen(Credential.password,
              passwordCredential: PasswordCredential(
                username: username,
                password: password,
              ));
        });
      }
    }
  }

  Future<void> onRegisterWithPassKey() async {
    if (_formKey.currentState!.validate()) {
      await _performAction(() async {
        final credentialCreationOptions = {
          "challenge": "HjBbH__fbLuzy95AGR31yEARA0EMtKlY0NrV5oy3NQw",
          "rp": {"name": "CredMan App Test", "id": rpId},
          "user": {
            "id": EncryptData.getEncodedUserId(),
            "name": username,
            "displayName": username,
          },
          "excludeCredentials": [
            {"id": "ghi789", "type": "public-key"},
            {"id": "jkl012", "type": "public-key"}
          ],
        };

        if (Platform.isAndroid) {
          credentialCreationOptions.addAll({
            "pubKeyCredParams": [
              {"type": "public-key", "alg": -7},
              {"type": "public-key", "alg": -257}
            ],
            "timeout": 1800000,
            "attestation": "none",
            "authenticatorSelection": {
              "authenticatorAttachment": "platform",
              "residentKey": "required",
              "userVerification": "required"
            }
          });
        }

        final res = await credentialManager.savePasskeyCredentials(
          request:
              CredentialCreationOptions.fromJson(credentialCreationOptions),
        );
        _showSnackBar("Successfully saved credential");
        _navigateToHomeScreen(Credential.passkey, publicKeyCredential: res);
      });
    }
  }

  Future<void> onGoogleSignIn() async {
    await _performAction(() async {
      final credential = await credentialManager.saveGoogleCredential();
      _showSnackBar("Successfully retrieved credential");
      _navigateToHomeScreen(Credential.google,
          googleIdTokenCredential: credential);
    });
  }

  Future<void> onLogin() async {
    await _performAction(() async {
      Credentials credential = await credentialManager.getCredentials(
        passKeyOption: passKeyLoginOption,
        //only for android
        fetchOptions: FetchOptionsAndroid(
          passKey: true,
          passwordCredential: true,
          googleCredential: isGoogleEnabled,
        ),
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

  void _showLoginSuccessDialog(Credentials credential) {
    bool isPasswordBasedCredentials = credential.passwordCredential != null;
    bool isPublicKeyBasedCredentials = credential.publicKeyCredential != null;
    _showSnackBar("Successfully retrieved credential");

    _navigateToHomeScreen(
      isPasswordBasedCredentials
          ? Credential.password
          : isPublicKeyBasedCredentials
              ? Credential.passkey
              : Credential.google,
      googleIdTokenCredential: credential.googleIdTokenCredential,
      passwordCredential: credential.passwordCredential,
      publicKeyCredential: credential.publicKeyCredential,
    );
  }

  void _navigateToHomeScreen(Credential credentialType,
      {GoogleIdTokenCredential? googleIdTokenCredential,
      PasswordCredential? passwordCredential,
      PublicKeyCredential? publicKeyCredential}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          credentialType: credentialType,
          passwordCredential: passwordCredential,
          publicKeyCredential: publicKeyCredential,
          googleIdTokenCredential: googleIdTokenCredential,
        ),
      ),
    );
  }
}
