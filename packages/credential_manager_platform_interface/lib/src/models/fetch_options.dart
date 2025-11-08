/// Fetch options for Android to retrieve specific types of credentials.
///
/// [passKey] - Whether to fetch passkey credentials.
/// [googleCredential] - Whether to fetch Google credentials.
/// [passwordCredential] - Whether to fetch password credentials.
class FetchOptionsAndroid {
  /// Whether to fetch passkey credentials.
  final bool passKey;

  /// Whether to fetch Google credentials.
  final bool googleCredential;

  /// Whether to fetch password credentials.
  final bool passwordCredential;

  /// Creates an instance of [FetchOptionsAndroid].
  ///
  /// By default, all options are set to false.
  ///
  /// [passKey] - Whether to fetch passkey credentials.
  /// [googleCredential] - Whether to fetch Google credentials.
  /// [passwordCredential] - Whether to fetch password credentials.
  FetchOptionsAndroid({
    this.passKey = false,
    this.googleCredential = false,
    this.passwordCredential = false,
  });

  /// Creates an instance of [FetchOptionsAndroid] from a JSON object.
  ///
  /// [json] - The JSON object containing the fetch options.
  factory FetchOptionsAndroid.fromJson(Map<String, dynamic> json) {
    return FetchOptionsAndroid(
      passKey: json['passKey'] ?? true,
      googleCredential: json['googleCredential'] ?? true,
      passwordCredential: json['passwordCredential'] ?? true,
    );
  }

  /// Creates an instance of [FetchOptionsAndroid] with all options set to true.
  factory FetchOptionsAndroid.all() {
    return FetchOptionsAndroid(
      passKey: true,
      googleCredential: true,
      passwordCredential: true,
    );
  }

  /// Converts the [FetchOptionsAndroid] instance to a JSON object.
  ///
  /// Returns a JSON object representing the fetch options.
  Map<String, dynamic> toJson() {
    return {
      'passKey': passKey,
      'googleCredential': googleCredential,
      'passwordCredential': passwordCredential,
    };
  }
}
