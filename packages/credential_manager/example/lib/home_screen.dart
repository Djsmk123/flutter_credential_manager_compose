// ignore_for_file: use_build_context_synchronously

import 'package:credential_manager/credential_manager.dart';
import 'package:credential_manager_example/main.dart';
import 'package:credential_manager_example/widgets/json_viewer.dart';
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
          _getAppBarTitle(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCredentialHeader(context),
            const SizedBox(height: 16),
            _buildCredentialJsonView(),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (credentialType) {
      case Credential.password:
        return 'Password Credential';
      case Credential.passkey:
        return 'Passkey Credential';
      case Credential.google:
        return 'Google Credential';
    }
  }

  Widget _buildCredentialHeader(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildCredentialIcon(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCredentialTypeLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCredentialName(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (credentialType == Credential.google &&
                googleIdTokenCredential?.profilePictureUri != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  googleIdTokenCredential!.profilePictureUri.toString(),
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (credentialType) {
      case Credential.password:
        icon = Icons.password;
        color = Colors.blue;
        break;
      case Credential.passkey:
        icon = Icons.key;
        color = Colors.purple;
        break;
      case Credential.google:
        icon = Icons.g_mobiledata;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  String _getCredentialTypeLabel() {
    switch (credentialType) {
      case Credential.password:
        return 'PASSWORD';
      case Credential.passkey:
        return 'PASSKEY';
      case Credential.google:
        return 'GOOGLE ID TOKEN';
    }
  }

  String _getCredentialName() {
    return passwordCredential?.username ??
        googleIdTokenCredential?.displayName ??
        googleIdTokenCredential?.email ??
        publicKeyCredential?.id ??
        'Unknown';
  }

  Widget _buildCredentialJsonView() {
    return JsonViewer(
      data: _getCredentialJson(),
      title: 'Credential Data',
      initiallyExpanded: true,
    );
  }

  Map<String, dynamic> _getCredentialJson() {
    switch (credentialType) {
      case Credential.password:
        return _passwordCredentialToJson();
      case Credential.passkey:
        return _passkeyCredentialToJson();
      case Credential.google:
        return _googleCredentialToJson();
    }
  }

  Map<String, dynamic> _passwordCredentialToJson() {
    if (passwordCredential == null) return {'error': 'No credential data'};

    return {
      'type': 'PasswordCredential',
      'username': passwordCredential!.username,
      'password': passwordCredential!.password != null
          ? '••••••••' // Mask password for security
          : null,
    };
  }

  Map<String, dynamic> _passkeyCredentialToJson() {
    if (publicKeyCredential == null) return {'error': 'No credential data'};

    // Use the built-in toJson method and filter out null values
    final rawJson = publicKeyCredential!.toJson();
    final json = <String, dynamic>{};

    rawJson.forEach((key, value) {
      if (value != null) {
        if (value is Map) {
          // Filter nested maps (like response)
          final filtered = <String, dynamic>{};
          value.forEach((k, v) {
            if (v != null) filtered[k as String] = v;
          });
          if (filtered.isNotEmpty) json[key] = filtered;
        } else {
          json[key] = value;
        }
      }
    });

    return json;
  }

  Map<String, dynamic> _googleCredentialToJson() {
    if (googleIdTokenCredential == null) return {'error': 'No credential data'};

    final json = <String, dynamic>{
      'type': 'GoogleIdTokenCredential',
    };

    json['idToken'] = googleIdTokenCredential?.idToken.substring(0, 50);
  
    json['displayName'] = googleIdTokenCredential?.displayName;

    json['givenName'] = googleIdTokenCredential?.givenName;

    json['familyName'] = googleIdTokenCredential?.familyName;

    json['email'] = googleIdTokenCredential?.email;
  
    json['phoneNumber'] = googleIdTokenCredential?.phoneNumber;

    json['profilePictureUri'] =
        googleIdTokenCredential?.profilePictureUri?.toString();

    return json;
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (Platform.isAndroid) {
      final bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.of(context).pop();
    }
  }
}
