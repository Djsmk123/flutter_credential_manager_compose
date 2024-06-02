// Dart class representing a Google Id Token Credential
class GoogleIdTokenCredential {
  // Properties of the GoogleIdTokenCredential
  final String id;
  final String idToken;
  final String? displayName;
  final String? familyName;
  final String? givenName;
  final String? phoneNumber;
  final Uri? profilePictureUri;

  // Constructor for creating an instance of GoogleIdTokenCredential
  GoogleIdTokenCredential({
    required this.id,
    required this.idToken,
    this.displayName,
    this.familyName,
    this.givenName,
    this.phoneNumber,
    this.profilePictureUri,
  });

  // Method to convert the GoogleIdTokenCredential object to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idToken': idToken,
      'displayName': displayName,
      'familyName': familyName,
      'givenName': givenName,
      'phoneNumber': phoneNumber,
      'profilePictureUri': profilePictureUri?.toString(),
    };
  }

  // Factory method to create a GoogleIdTokenCredential object from a JSON-serializable map
  factory GoogleIdTokenCredential.fromJson(Map<String, dynamic> json) {
    return GoogleIdTokenCredential(
      id: json['id'],
      idToken: json['idToken'],
      displayName: json['displayName'],
      familyName: json['familyName'],
      givenName: json['givenName'],
      phoneNumber: json['phoneNumber'],
      profilePictureUri: json['profilePictureUri'] != null
          ? Uri.parse(json['profilePictureUri'])
          : null,
    );
  }
}
