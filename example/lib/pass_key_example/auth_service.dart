import 'dart:convert';
import 'dart:developer';

import 'package:credential_manager/credential_manager.dart';
import 'package:credential_manager_example/pass_key_example/model/user_model.dart';

import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:3000';
  static Future<CredentialCreationOptions> passKeyRegisterInit(
      {required String username}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register/start'),
      body: jsonEncode({'username': username}),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final decode = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return CredentialCreationOptions.fromJson(
        decode,
      );
    } else {
      throw Exception(
        'Failed to load credential creation options ${decode['message']} ${decode['error']}',
      );
    }
  }

  static Future<UserModel> passKeyRegisterFinish(
      {required String username,
      required String challenge,
      required PublicKeyCredential request}) async {
    Map<String, dynamic> body = {
      'username': username,
      'challenge': challenge,
    };

    body.addAll(request.toJson());
    log(body.toString());
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register/complete'),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final decode = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to finish passkey registration: ${decode['message']} ${decode['error']}',
        );
      }

      log("Response from passkey registration: ${decode.toString()}");
      return UserModel.fromJson(decode['data']);
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to finish passkey registration $e');
    }
  }

  static Future<CredentialLoginOptions> passKeyLoginInit() async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/login/start',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final decode = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load credential login options ${decode['message']} ${decode['error']}');
    }

    log("Response from passkey login init: ${decode.toString()}");
    return CredentialLoginOptions.fromJson(decode);
  }

  static Future<UserModel> passKeyLoginFinish(
      {required String challenge, required PublicKeyCredential request}) async {
    final Map<String, dynamic> body = {
      'challenge': challenge,
    };
    body.addAll(request.toJson());

    final response = await http.post(
      Uri.parse('$_baseUrl/login/complete'),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final decode = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to finish passkey login: ${decode['message']}, ${decode['error']}',
      );
    }

    return UserModel.fromJson(decode['data']);
  }

  static Future<void> getUser({required String token}) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final decode = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to get user: ${decode['message']} ${decode['error']}',
      );
    }
    log("Response from get user: ${decode.toString()}");
  }

  static CredentialManager credentialManager = CredentialManager();
}
