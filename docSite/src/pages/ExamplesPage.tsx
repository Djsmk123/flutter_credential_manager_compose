
import React from 'react';
import CodeBlock from '@/components/CodeBlock';

const ExamplesPage = () => {
  return (
    <div className="animate-fade-in">
      <h1 className="text-3xl font-bold mb-6">Example</h1>

      <ol className="list-decimal pl-6 mb-6 space-y-6">
        <li className="mb-4">
          <p>Clone the repo</p>
          <CodeBlock
            language="bash"
            code="git clone https://github.com/Djsmk123/flutter_credential_manager_compose"
          />
        </li>

        <li className="mb-4">
          <p>Open <code className="px-2 py-1 bg-gray-100 dark:bg-gray-800 rounded text-pink-600 dark:text-pink-400">example/</code> folder in your favorite IDE(Android Studio, VSCode, IntelliJ etc.), Mine is TurboC++ 😂,just kidding.</p>
        </li>

        <li className="mb-4">
          <p>Get the dependencies</p>
          <CodeBlock
            language="bash"
            code="flutter pub get"
          />
        </li>
      </ol>

      <blockquote className="border-l-4 border-blue-500 pl-4 italic text-gray-600 dark:text-gray-300 my-8 bg-blue-50 dark:bg-blue-900/20 p-4 rounded-r-md">
        <p>
          <strong>Note:</strong> For passkey authentication you need to setup a web server and configure it with your domain and you might use mine for testing purpose for android only but for iOS you need to setup your own(Apple Policy Sucks so much).
        </p>
      </blockquote>

      <h2 className="text-2xl font-semibold mt-10 mb-4">What's New in the Example App</h2>
      <p className="mb-4">
        The latest commits refresh <code>login_screen.dart</code> and <code>home_screen.dart</code> with Material 3 styling, loading overlays, and a quick logout shortcut so you can repeatedly test each credential flow. Two highlights:
      </p>
      <ul className="list-disc pl-6 space-y-2 mb-6">
        <li>A guard around Google actions that checks the new <code>credentialManager.isGmsAvailable</code> flag so emulators without Play Services show a friendly message instead of throwing.</li>
        <li>A dedicated <code>JsonViewer</code> widget (<code>example/lib/widgets/json_viewer.dart</code>) that renders any credential payload with collapsible sections and copy-to-clipboard support.</li>
      </ul>

      <h3 className="text-xl font-medium mt-6 mb-2">Gate Google Sign-In When Play Services Are Missing</h3>
      <p className="mb-2">The login screen now short-circuits Google flows using the platform-reported GMS status:</p>
      <CodeBlock
        language="dart"
        code={`final isGmsAvailable = credentialManager.isGmsAvailable;
return !isGmsAvailable
    ? const Center(child: Text('Google Play Services is not available'))
    : LoginScaffold(...);`}
      />

      <h3 className="text-xl font-medium mt-6 mb-2">Inspect Credential Payloads with JsonViewer</h3>
      <p className="mb-2">
        Every successful login pushes you to <code>HomeScreen</code>, which now shows the structured payload for the credential you just received:
      </p>
      <CodeBlock
        language="dart"
        code={`JsonViewer(
  data: _getCredentialJson(),
  title: 'Credential Data',
  initiallyExpanded: true,
);`}
      />
      <p className="mb-6 text-sm text-gray-600 dark:text-gray-300">
        The viewer collapses nested sections, highlights keys/values, and offers a one-tap “Copy JSON” action—handy when debugging responses from Google ID tokens, passkeys, or masked password credentials.
      </p>

      <h2 className="text-2xl font-semibold mt-10 mb-4">Example Code Snippets</h2>

      <h3 className="text-xl font-medium mt-6 mb-2">Initializing Credential Manager</h3>

      <CodeBlock
        language="dart"
        code={`// Create an instance
final credentialManager = CredentialManager();

// Check if platform is supported
if (!credentialManager.isSupportedPlatform) {
  print('Platform not supported');
  return;
}

// Initialize
await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
  // Add Google Client ID for Google Sign-In
  googleClientId: 'YOUR_GOOGLE_CLIENT_ID',
);`}
      />

      <h3 className="text-xl font-medium mt-6 mb-2">Password Credential Example</h3>

      <CodeBlock
        language="dart"
        code={`// Save Password Credential
try {
  await credentialManager.savePasswordCredentials(
    PasswordCredential(
      username: emailController.text,
      password: passwordController.text,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Credential saved successfully')),
  );
} on CredentialException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: \${e.message}')),
  );
}

// Get Password Credential
try {
  final credentials = await credentialManager.getCredentials(
    fetchOptions: FetchOptionsAndroid(passwordCredential: true),
  );

  if (credentials.passwordCredential != null) {
    emailController.text = credentials.passwordCredential!.username;
    passwordController.text = credentials.passwordCredential!.password;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credential retrieved successfully')),
    );
  }
} on CredentialException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: \${e.message}')),
  );
}`}
      />

      <h3 className="text-xl font-medium mt-6 mb-2">Passkey Example</h3>

      <CodeBlock
        language="dart"
        code={`// Save Passkey
final Map<String, dynamic> credentialCreationOptions = {
  "challenge": base64UrlEncode(generateRandomBytes(32)),
  "rp": {"name": "Example App", "id": "yourdomain.com"},
  "user": {
    "id": base64UrlEncode(utf8.encode(userId)),
    "name": username,
    "displayName": username,
  },
  "pubKeyCredParams": [
    {"type": "public-key", "alg": -7}, // ES256
    {"type": "public-key", "alg": -257} // RS256
  ],
  "timeout": 60000,
  "authenticatorSelection": {
    "authenticatorAttachment": "platform",
    "residentKey": "required",
    "userVerification": "required"
  },
  "attestation": "none"
};

try {
  final credential = await credentialManager.savePasskeyCredentials(
    request: CredentialCreationOptions.fromJson(credentialCreationOptions),
  );

  // Send registration response to your server
  final registrationResponse = {
    "id": credential.id,
    "rawId": credential.rawId,
    "type": credential.type,
    "clientDataJSON": credential.response?.clientDataJSON,
    "attestationObject": credential.response?.attestationObject,
    "authenticatorData": credential.response?.authenticatorData,
    "publicKey": credential.publicKey,
    "publicKeyAlgorithm": credential.publicKeyAlgorithm,
    "transports": credential.transports,
  };

  // TODO: Send registrationResponse to your server
} catch (e) {
  print('Error creating passkey: $e');
}`}
      />

      <h3 className="text-xl font-medium mt-6 mb-2">Google Sign-In Example</h3>

      <CodeBlock
        language="dart"
        code={`try {
  final GoogleIdTokenCredential credential =
      await credentialManager.saveGoogleCredential(
    useButtonFlow: true, // Set to false for One Tap UI
  );

  // Use the Google credential
  print('Google Email: \${credential.email}');
  print('Google ID: \${credential.id}');
  print('Google Display Name: \${credential.displayName}');
  print('Google ID Token: \${credential.idToken}');

  // TODO: Authenticate with your backend using the ID token
} on CredentialException catch (e) {
  print('Error signing in with Google: \${e.message}');
}`}
      />

      <div className="mt-10 flex justify-center">
        <a
          href="https://github.com/Djsmk123/flutter_credential_manager_compose/tree/main/example"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center justify-center px-6 py-3 bg-blue-500 dark:bg-blue-600 text-white dark:text-gray-100 rounded-md transition-all duration-200 hover:bg-blue-600 dark:hover:bg-blue-700 hover:shadow-lg hover:shadow-blue-500/20 dark:hover:shadow-blue-600/20"
        >
          View Full Example on GitHub
        </a>
      </div>
    </div>
  );
};

export default ExamplesPage;
