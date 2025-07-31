import CodeBlock from "@/components/CodeBlock";
import ImageViewer from "@/components/ImageViewer";
import { getAssetPath } from "@/lib/utils";

const UsagePage = () => {
  return (
    <div className="max-w-4xl mx-auto px-4">
      <h1 className="text-4xl font-bold mb-6">Usage</h1>

      <p className="mb-6">
        Let's see how to use Credential Manager in your app and how to integrate it with other services including Google Sign-In, Passkey and Password based authentication.
      </p>

      <h2 className="text-2xl font-semibold mb-4">Initialize Credential Manager</h2>

      <p className="mb-4">
        Create an instance of <strong>CredentialManager</strong> object:
      </p>

      <CodeBlock
        language="dart"
        code={`final CredentialManager credentialManager = CredentialManager();`}
      />

      <p className="mt-4 mb-4">
        Check if the platform is supported by calling <code>isSupportedPlatform</code> property:
      </p>

      <CodeBlock
        language="dart"
        code={`if (credentialManager.isSupportedPlatform) {
  // Platform is supported, initialize the manager
}`}
      />

      <p className="mt-4 mb-4">
        Initialize the manager with the required parameters:
      </p>

      <CodeBlock
        language="dart"
        code={`await credentialManager.init(
  preferImmediatelyAvailableCredentials: true,
);`}
      />

      <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg my-4">
        <p className="text-blue-700 dark:text-blue-400">
          <strong>Note:</strong> The <code>preferImmediatelyAvailableCredentials</code> parameter is optional. When set to <code>true</code>, it tells the authorization controller to prefer credentials that are immediately available on the local device. If not provided, it defaults to <code>false</code>, and it will try to fetch the credentials from the platform's native APIs.
        </p>
      </div>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Password Based Credentials</h2>

      <p className="mb-4">
        Mechanism of storing and retrieving password based credentials in Android uses native APIs of <a href="https://developer.android.com/jetpack/androidx/releases/credentials" className="text-blue-600 hover:underline">Credential Manager</a> and for iOS it uses autofill service which use keychain to store the credentials.
      </p>

      <h3 className="text-xl font-semibold mt-6 mb-3">Android</h3>

      <p className="mb-3">Saving Credentials:</p>
      <CodeBlock
        language="dart"
        code={`try {
  await credentialManager.savePasswordCredential(
    PasswordCredential(
      username: '1234567890',
      password: 'password',
    ),
  );
} on CredentialException catch (e) {
  // Handle the error
  print('Error saving password credential: \${e.message}');
}`}
      />

      <p className="mt-4 mb-3">Retrieving Credentials:</p>
      <CodeBlock
        language="dart"
        code={`try {
  Credentials credential = await credentialManager.getCredentials(
    fetchOptions: FetchOptionsAndroid(
      passwordCredential: true
    ),
  );
} on CredentialException catch (e) {
  // Handle the error
}`}
      />

      <p className="mt-4 mb-3">Handling Response:</p>
      <p className="mb-2">
        Credentials object will have one of the following properties based on the type of credential that is available:
      </p>
      <CodeBlock
        language="dart"
        code={`if (credential.passwordCredential != null) {
  // Handle password credential
  print('Username: \${credential.passwordCredential!.username}');
  print('Password: \${credential.passwordCredential!.password}');
} else if (credential.publicKeyCredential != null) {
  // Handle passkey credential
  print('Passkey ID: \${credential.publicKeyCredential!.id}');
  print('Passkey Raw ID: \${credential.publicKeyCredential!.rawId}');
} else if (credential.googleIdTokenCredential != null) {
  // Handle Google ID token credential
  print('Google ID Token: \${credential.googleIdTokenCredential!.email}');
} else {
  // Handle case where no credentials are available
  print('No credentials available');
}`}
      />

      <h3 className="text-xl font-semibold mt-6 mb-3">iOS</h3>

      <p className="mb-3">Saving Credentials:</p>
      <p className="mb-2">
        Wrap the textfield with of <strong>username</strong> and <strong>password</strong> with <code>AutofillGroup</code> widget:
      </p>
      <CodeBlock
        language="dart"
        code={`AutofillGroup(
  child: Column(
    children: [
    TextFormField(
      autofillHints: const [AutofillHints.username],
      decoration: const InputDecoration(
        labelText: 'Username',
      ),
    ),
    TextFormField(
      autofillHints: const [AutofillHints.password],
      decoration: const InputDecoration(
        labelText: 'Password',
      ),
      obscureText: true,
    ),
    ],
  ),
);`}
      />

      <p className="mt-4 mb-2">
        Now validate the credentials and after action, Native APIs will handle the rest of the things.
      </p>
      
      <div className="my-4">
        <p className="mb-2 font-medium">iOS Password Autofill:</p>
        <div className="border border-gray-300 rounded-lg p-2 inline-block">
          <ImageViewer imageUrls={[getAssetPath("assets/save_password_ios.jpg")]} height="300" />
        </div>
      </div>

      <p className="mt-4 mb-2">
        Retrieving Credentials:
      </p>
      <p className="mb-2">
        It will popup keychain access prompt on <strong>keyboard</strong> when user starts typing in the textfield with autofill hint as <strong>password</strong> and <strong>username</strong>.
      </p>

      <div className="my-4">
        <p className="mb-2 font-medium">iOS Password Autofill on Retrieval:</p>
        <div className="border border-gray-300 rounded-lg p-2 inline-block">
          <ImageViewer imageUrls={[getAssetPath("assets/get_password_ios.jpg")]} height="300" />
        </div>
      </div>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Google Sign-In (Only For Android)</h2>

      <p className="mb-2">
        Follow these steps to set up Google Sign-In for your application:
      </p>

      <h3 className="text-xl font-semibold mt-6 mb-3">Setup Google Cloud Console</h3>
      <ol className="list-decimal pl-6 mb-6 space-y-3">
        <li>
          <strong>Access Google Cloud Console</strong>
          <p>Visit the <a href="https://console.cloud.google.com/" className="text-blue-600 hover:underline">Google Cloud Console</a></p>
        </li>
        <li>
          <strong>Create or Select a Project</strong>
          <p>Create a new project or select an existing one</p>
        </li>
        <li>
          <strong>Configure OAuth Consent Screen</strong>
          <p>In the left sidebar, navigate to "APIs & Services" and then "OAuth consent screen"</p>
          <p>Choose the user type (External or Internal)</p>
          <p>Fill in the required information and save</p>
        </li>
        <li>
          <strong>Create Credentials</strong>
          <p>In the left sidebar, go to "APIs & Services" and then "Credentials"</p>
          <p>Click the "Create Credentials" button and select "OAuth client ID"</p>
        </li>
        <li>
          <strong>Set Application Type</strong>
          <p>For Android apps, choose "Android" as the Application Type</p>
        </li>
        <li>
          <strong>Configure Android App</strong>
          <p>Enter your app's package name</p>
          <p>Obtain the SHA-1 certificate fingerprint:</p>
          <CodeBlock
            language="sh"
            code={`cd android && ./gradlew signingReport`}
          />
          <p>or use <code>keytool</code> command:</p>
          <CodeBlock
            language="sh"
            code={`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`}
          />
          <p>Add the SHA-1 fingerprint to the Google Cloud Console</p>
        </li>
        <li>
          <strong>Create Web Application Credentials</strong>
          <p>Go back to the Credentials page</p>
          <p>Click "Create Credentials" and then "OAuth client ID" again</p>
          <p>Select "Web application" as the Application Type</p>
          <p>You can leave "Authorized JavaScript Origins" and "Authorized redirect URIs" blank for now</p>
          <p>Click "Create"</p>
        </li>
      </ol>

      <div className="my-4">
        <p className="mb-2 font-medium">Google Cloud Console:</p>
        <div className="border border-gray-300 rounded-lg p-2 inline-block">
          <ImageViewer imageUrls={[getAssetPath("assets/0AuthConsent.jpg")]} height="300" />
        </div>
      </div>

      <ol className="list-decimal pl-6 mb-6 space-y-3" start={8}>
        <li>
          <strong>Obtain Client ID</strong>
          <p>After creation, copy the "Client ID" for the web application.</p>
        </li>
        <li>
          <strong>Set Client ID in Credential Manager</strong>
          <CodeBlock
            language="dart"
            code={`await credentialManager.init(
  googleClientId: '<your-web-client-id>',
);`}
          />
        </li>
      </ol>

      <h3 className="text-xl font-semibold mt-6 mb-3">Sign-In with Google</h3>
      <p className="mb-2">
        Sign up using Google account and then you will be able to see the saved credentials in the app:
      </p>
      <CodeBlock
        language="dart"
        code={`try {
  final GoogleIdTokenCredential credential = await credentialManager.saveGoogleCredential(
    useButtonFlow: false
  );

} on CredentialException catch (e) {
  // Handle the error
  print('Error saving Google credential: \${e.message}');
}`}
      />

      <p className="mt-4 mb-2">
        <a href="https://pub.dev/documentation/credential_manager/latest/credential_manager/GoogleIdTokenCredential-class.html" className="text-blue-600 hover:underline">GoogleIdTokenCredential</a> object will have the following properties:
      </p>
      <CodeBlock
        language="dart"
        code={`print('Google ID Token: \${credential.email}');`}
      />

      <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg my-4">
        <p className="text-blue-700 dark:text-blue-400">
          <strong>Note:</strong> <code>useButtonFlow</code> is <code>true</code> for traditional Google sign in alert dialog flow and <code>false</code> for new Google one tap sign in flow with Credential Manager UI.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 my-6">
        <div>
          <p className="font-medium mb-2">With using <code>useButtonFlow</code>:</p>
          <div className="border border-gray-300 rounded-lg p-2">
            <ImageViewer imageUrls={["https://developer.android.com/static/identity/sign-in/images/add-siwg-animated-2.gif"]} height="300" />
            
          </div>
        </div>
        <div>
          <p className="font-medium mb-2">Without using <code>useButtonFlow</code>:</p>
          <div className="border border-gray-300 rounded-lg p-2">
            <ImageViewer imageUrls={["https://i.ibb.co/KNkgtdV/IMG-20240128-164347.jpg"]} height="300" />
            
          </div>
        </div>
      </div>

      <h3 className="text-xl font-semibold mt-6 mb-3">Getting Google Sign-In Account</h3>
      <CodeBlock
        language="dart"
        code={`try {
  Credentials credential = await credentialManager.getCredentials(
    fetchOptions: FetchOptionsAndroid(
      googleCredential: true
    ),
  );
  //check if credential is not null
  if (credential.googleIdTokenCredential != null) {
    print('Google Email: \${credential.googleIdTokenCredential!.email}');
  }
} on CredentialException catch (e) {
  // Handle the error
  print('Error getting Google credential: \${e.message}');
}`}
      />

      <h2 className="text-2xl font-semibold mt-8 mb-4">Passkey</h2>

      <p className="mb-4">
        For iOS, we have nothing extra to do apart from hosting Apple Site Association File on your server, which is also required for this plugin to work in <strong>iOS</strong>.
      </p>

      <p className="mb-4">
        PassKey support is for <strong>Android 14+</strong> and <strong>iOS 16+</strong> and above. Other platforms are not supported yet and the SDK will throw an error if you try to use it on those platforms.
      </p>

      <h3 className="text-xl font-semibold mt-6 mb-3">Passkey Setup for Android</h3>
      <ol className="list-decimal pl-6 mb-6 space-y-3">
        <li>
          <strong>Create a Digital Asset Links JSON file (assetlinks.json):</strong>
          <p>Open a text editor and create a new file named <code>assetlinks.json</code>.</p>
          <p>Paste the following content into the file, replacing the placeholders with your specific information:</p>
          <CodeBlock
            language="json"
            code={`[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls",
      "delegate_permission/common.get_login_creds"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.android",
      "sha256_cert_fingerprints": [
        "SHA_HEX_VALUE"
      ]
    }
  }
]`}
          />
        </li>
        <li>
          <strong>Host the Digital Asset Links JSON file:</strong>
          <p>Place the file at the following location on your sign-in domain:</p>
          <p><code>https://domain[:optional_port]/.well-known/assetlinks.json</code></p>
        </li>
        <li>
          <strong>Configure your host:</strong>
          <p>Ensure that your host permits Google to retrieve your Digital Asset Link file.</p>
          <p>If you have a <code>robots.txt</code> file, it must allow the Googlebot agent to retrieve <code>/.well-known/assetlinks.json</code>.</p>
          <p>Most sites can use the following configuration:</p>
          <CodeBlock
            language="text"
            code={`User-agent: *
Allow: /.well-known/`}
          />
        </li>
      </ol>

      <h3 className="text-xl font-semibold mt-6 mb-3">Create Passkey Credentials</h3>
      <p className="mb-2">
        <a href="https://pub.dev/documentation/credential_manager/latest/credential_manager/CredentialCreationOptions-class.html" className="text-blue-600 hover:underline">CredentialCreationOptions</a> is a class that is used to create passkey credentials. It has many optional parameters to customize the passkey creation process depending on your requirement and platform support.
      </p>
      <p className="mb-2">
        Here is an example of how to create passkey credentials with default options:
      </p>

      <CodeBlock
        language="dart"
        code={`final credentialCreationOptions = {
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
//add platform specific options

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
      //required for android
      "userVerification": "required"
    }
  });
}`}
      />

      <p className="mt-4 mb-2">
        Call <code>savePasskeyCredentials</code> method of <strong>CredentialManager</strong> object with <code>credentialCreationOptions</code> as parameter:
      </p>
      <CodeBlock
        language="dart"
        code={`final PublicKeyCredential credential = await credentialManager.savePasskeyCredentials(
  request: CredentialCreationOptions.fromJson(credentialCreationOptions),
);`}
      />

      <p className="mt-4 mb-2">
        <a href="https://pub.dev/documentation/credential_manager/latest/credential_manager/PublicKeyCredential-class.html" className="text-blue-600 hover:underline">PublicKeyCredential</a> object will have the following properties:
      </p>
      <CodeBlock
        language="dart"
        code={`print('Passkey ID: \${credential.id}');
print('Passkey Raw ID: \${credential.rawId}');`}
      />

      <div className="my-4">
        <div className="border border-gray-300 rounded-lg p-2 inline-block">
          <ImageViewer imageUrls={["https://i.ibb.co/XCLvkB3/Whats-App-Image-2024-06-02-at-21-46-17.jpg"]} height="300" />
          
        </div>
      </div>

      <h3 className="text-xl font-semibold mt-6 mb-3">Get Passkey Credentials</h3>
      <p className="mb-2">
        Call <code>getCredentials</code> method of <strong>CredentialManager</strong> object with <code>fetchOptions</code> parameter set to <code>FetchOptionsAndroid(passKey: true)</code> for Android. For iOS it will automatically fetch the passkey credentials without <code>fetchOptions</code> parameter. It also requires payload data for getting passkey credentials using <code>CredentialLoginOptions</code> which is passed as the <code>passKeyOption</code> parameter.
      </p>

      <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg my-4">
        <p className="text-blue-700 dark:text-blue-400">
          <strong>Note:</strong> <code>CredentialLoginOptions</code> is an optional parameter for Android if you don't want to fetch passkey credentials. But if you want to fetch passkey credentials, then you have to provide <code>CredentialLoginOptions</code> as a parameter otherwise it will throw an error on both platforms.
        </p>
      </div>

      <p className="mb-2">
        Here is an example of how to get passkey credentials:
      </p>

      <CodeBlock
        language="dart"
        code={`var passKeyLoginOption = CredentialLoginOptions(
  challenge: "HjBbH__fbLuzy95AGR31yEARA0EMtKlY0NrV5oy3NQw",
  rpId: rpId,
  userVerification: "required",
  //only for ios, true only when we want to show the passkey popup on keyboard otherwise false
  conditionalUI: false,
);`}
      />

      <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg my-4">
        <p className="text-blue-700 dark:text-blue-400">
          <strong>Note:</strong> <code>rpId</code> is the relying party ID which is your domain name. <code>challenge</code> is a challenge string that the authenticator must complete and it should be base64url encoded string. <code>userVerification</code> is an optional parameter in <strong>iOS</strong> and <strong>Android</strong> (defaults to <code>required</code> if not provided). <code>conditionalUI</code> is only for <strong>iOS</strong> and defaults to <code>false</code> if not provided, which gives a hint passkey popup on keyboard.
        </p>
      </div>

      <p className="mb-2">
        Read more about <a href="https://pub.dev/documentation/credential_manager/latest/credential_manager/CredentialLoginOptions-class.html" className="text-blue-600 hover:underline">CredentialLoginOptions</a> for more details.
      </p>

      <p className="mt-4 mb-2">
        Now call <code>getCredentials</code> method with <code>passKeyLoginOption</code> as parameter:
      </p>

      <CodeBlock
        language="dart"
        code={`try {
  Credentials credential = await credentialManager.getCredentials(
    passKeyOption: passKeyLoginOption,
    fetchOptions: FetchOptionsAndroid(
      passKey: true
    ),
  );
  //handle response
  if(credential.publicKeyCredential != null){
    print('Passkey ID: \${credential.publicKeyCredential!.id}');
    print('Passkey Raw ID: \${credential.publicKeyCredential!.rawId}');
  }  
} on CredentialException catch (e) {
  // Handle the error
  print('Error getting passkey credential: \${e.message}');
}`}
      />

      <h2 className="text-2xl font-semibold mt-8 mb-4">Logout</h2>
      <p className="mb-2">
        It works only on Android and it will clear all the saved credentials from session:
      </p>
      <CodeBlock
        language="dart"
        code={`await credentialManager.logout();`}
      />
      <p className="mb-2">
        More about <a href="https://pub.dev/documentation/credential_manager/latest/credential_manager/CredentialManager/logout.html" className="text-blue-600 hover:underline">logout</a> method.
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Error Handling</h2>
      <p className="mb-4">
        Handle common errors when working with the Credential Manager:
      </p>

      <CodeBlock
        language="dart"
        code={`try {
  final result = await credentialManager.getCredentials(
    fetchOptions: FetchOptionsAndroid(
      passwordCredential: true,
      googleCredential: true,
      passKey: true,
    ),
  );
  // Process result
} catch (CredentialCancelledException e) {
  print('User cancelled the operation');
} catch (CredentialRequestException e) {
  print('Credential request failed: \${e.message}');
} catch (e) {
  print('Unexpected error: \${e}');
}`}
      />

      <h2 className="text-2xl font-semibold mt-8 mb-4">Platform Support</h2>
      <ul className="list-disc pl-6 mb-6 space-y-2">
        <li><strong>Android</strong>: Full support for password credentials, Google Sign-In, and passkeys (Android 14+)</li>
        <li><strong>iOS</strong>: Support for password credentials and passkeys (iOS 16+)</li>
      </ul>

      <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg mb-8">
        <h3 className="text-lg font-medium text-blue-800 dark:text-blue-300 mb-2">Note</h3>
        <p className="text-blue-700 dark:text-blue-400">
          Feature availability varies by platform. Implement appropriate fallbacks for unsupported features.
        </p>
      </div>
    </div>
  );
};

export default UsagePage;