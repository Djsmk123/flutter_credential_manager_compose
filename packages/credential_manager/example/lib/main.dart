import 'dart:async';
import 'package:credential_manager/credential_manager.dart';
import 'package:credential_manager_example/home_screen.dart';
import 'package:flutter/material.dart';

const String googleClientId = "<your-web-client-id>";
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
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
      conditionalUI: false,
    );
    isGoogleEnabled = googleClientId.isNotEmpty;
  }

  Widget _buildAutofillGroup(Widget child) {
    if (enableInlineAutofill) {
      return AutofillGroup(child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final isGmsAvailable = credentialManager.isGmsAvailable;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credential Manager"),
        centerTitle: true,
      ),
      body: !isGmsAvailable
          ? const Center(child: Text("Google Play Services is not available"))
          : Stack(
              children: [
                AbsorbPointer(
                  absorbing: isLoading,
                  child: Opacity(
                    opacity: isLoading ? 0.5 : 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildAutofillGroup(
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 32),
                              _buildInputField(
                                "Username",
                                (value) => username = value,
                                icon: Icons.person_outline,
                              ),
                              if (createPassKey) ...[
                                const SizedBox(height: 16),
                                _buildInputField(
                                  "Password",
                                  (value) => password = value,
                                  isPassword: true,
                                  icon: Icons.lock_outline,
                                ),
                              ],
                              const SizedBox(height: 24),
                              _buildSectionTitle("Registration"),
                              const SizedBox(height: 12),
                              _buildActionButton(
                                "Register with Password",
                                onRegister,
                                icon: Icons.password,
                                isPrimary: true,
                              ),
                              const SizedBox(height: 12),
                              _buildActionButton(
                                "Register with Passkey",
                                onRegisterWithPassKey,
                                icon: Icons.key,
                              ),
                              if (Platform.isAndroid) ...[
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  "Register with Google",
                                  onGoogleSignIn,
                                  icon: Icons.g_mobiledata,
                                ),
                              ],
                              const SizedBox(height: 24),
                              _buildSectionTitle("Login"),
                              const SizedBox(height: 12),
                              _buildActionButton(
                                Platform.isAndroid ? "Login (All Methods)" : "Login with Passkey",
                                onLogin,
                                icon: Icons.login,
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  bool enableInlineAutofill = Platform.isIOS;

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.security,
            size: 48,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Secure Authentication',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in with password, passkey, or Google',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String hint,
    Function(String) onChanged, {
    bool isPassword = false,
    IconData? icon,
  }) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: isPassword,
      autofillHints:
          enableInlineAutofill ? (isPassword ? const [AutofillHints.password] : const [AutofillHints.username]) : [],
      keyboardType: isPassword ? TextInputType.visiblePassword : null,
      validator: (value) => value!.isEmpty ? "Please enter a $hint" : null,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onPressed, {
    IconData? icon,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label),
      ),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
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
          request: CredentialCreationOptions.fromJson(credentialCreationOptions),
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
      _navigateToHomeScreen(Credential.google, googleIdTokenCredential: credential);
    });
  }

  Future<void> onLogin() async {
    await _performAction(() async {
      Credentials credential = await credentialManager.getCredentials(
        passKeyOption: passKeyLoginOption,
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
