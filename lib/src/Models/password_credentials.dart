// ignore_for_file: unnecessary_getters_setters

/// A class representing a password credential with optional username and password.
class PasswordCredential {
  String? _username;
  String? _password;

  /// Creates a [PasswordCredential] instance with optional username and password.
  PasswordCredential({String? username, String? password}) {
    if (username != null) {
      _username = username;
    }
    if (password != null) {
      _password = password;
    }
  }

  /// Gets the username associated with this credential.
  String? get username => _username;

  /// Sets the username for this credential.
  set username(String? username) => _username = username;

  /// Gets the password associated with this credential.
  String? get password => _password;

  /// Sets the password for this credential.
  set password(String? password) => _password = password;

  /// Creates a [PasswordCredential] instance from a JSON representation.
  PasswordCredential.fromJson(Map<String, dynamic> json) {
    _username = json['username'];
    _password = json['password'];
  }

  /// Converts this [PasswordCredential] instance to a JSON representation.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = _username;
    data['password'] = _password;
    return data;
  }
}
