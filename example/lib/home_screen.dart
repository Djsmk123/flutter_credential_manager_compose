// ignore_for_file: use_build_context_synchronously

import 'package:credential_manager/credential_manager.dart';
import 'package:credential_manager_example/main.dart';
import 'package:flutter/material.dart';

enum Credential { password, passkey, google }

class HomeScreen extends StatelessWidget {
  final Credential credentialType;
  final GoogleIdTokenCredential? googleIdTokenCredential;
  final PasswordCredential? passwordCredential;
  final PublicKeyCredential? publicKeyCredential;

  const HomeScreen({
    super.key,
    required this.credentialType,
    this.googleIdTokenCredential,
    this.passwordCredential,
    this.publicKeyCredential,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logged in as/using ${_getCredentialName()}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCredentialInfo(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _handleLogout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  String _getCredentialName() {
    return passwordCredential?.username ??
        googleIdTokenCredential?.displayName ??
        "passkey";
  }

  Widget _buildCredentialInfo() {
    switch (credentialType) {
      case Credential.password:
        return _buildInfoText(
            'Password Credential: ${passwordCredential?.username}');
      case Credential.passkey:
        return _buildInfoText('Passkey Credential: ${publicKeyCredential?.id}');
      case Credential.google:
        return Column(
          children: [
            _buildInfoText(
                'Google Credential: ${googleIdTokenCredential?.displayName}'),
            const SizedBox(height: 10),
            if (googleIdTokenCredential?.profilePictureUri != null)
              Image.network(
                googleIdTokenCredential!.profilePictureUri.toString(),
                width: 100,
                height: 100,
              ),
          ],
        );
    }
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text(
          'Are you sure you want to logout?.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await credentialManager.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.of(context).pop();
    }
  }
}
