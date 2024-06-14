import 'package:credential_manager_example/pass_key_example/auth_screen.dart';
import 'package:credential_manager_example/pass_key_example/auth_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AuthService.credentialManager.isSupportedPlatform) {
    await AuthService.credentialManager.init(
      preferImmediatelyAvailableCredentials: true,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(
        key: Key('auth_screen'),
      ),
    );
  }
}
