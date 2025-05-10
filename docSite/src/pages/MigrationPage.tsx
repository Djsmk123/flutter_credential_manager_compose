import CodeBlock from '@/components/CodeBlock';
import { AlertTriangle,Info } from 'lucide-react';

const MigrationPage = () => {
  return (
    <div>
      <h1>Migration Guide V1 to V2</h1>
      
      <div className="space-y-6 mt-6">
        <div className="bg-yellow-50 dark:bg-yellow-900/50 border-l-4 border-yellow-400 p-4 mb-8">
          <div>
            <div>
              <AlertTriangle className="h-5 w-5 text-yellow-400" />
            </div>
            <div>
              <p className="text-sm text-yellow-700 dark:text-yellow-200">
                This guide helps you migrate your code from V1 to V2 of the Credential Manager library.
              </p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 gap-8">
          <div>
            <h2 className="text-xl font-bold mb-4">Password Credentials</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h3 className="font-medium text-sm mb-2 text-red-600">V1 Code</h3>
                <CodeBlock 
                  language="dart"
                  code={`// Save password credentials
await credentialManager.savePasswordCredential(
  PasswordCredential(
    username: 'user@example.com',
    password: 'password123',
  ),
);

// Get password credentials
final credential = await credentialManager.getPasswordCredentials();
print('Username: \${credential.username}');
print('Password: \${credential.password}');`}
                />
              </div>
              
              <div>
                <h3 className="font-medium text-sm mb-2 text-green-600">V2 Code</h3>
                <CodeBlock
                  language="dart" 
                  code={`// Save password credentials (unchanged)
await credentialManager.savePasswordCredential(
  PasswordCredential(
    username: 'user@example.com',
    password: 'password123',
  ),
);

// Get password credentials (changed)
final credential = await credentialManager.getCredentials(
  fetchOptions: FetchOptionsAndroid(
    passwordCredential: true
  ),
);

// Access the credential object
if (credential.passwordCredential != null) {
  print('Username: \${credential.passwordCredential!.username}');
  print('Password: \${credential.passwordCredential!.password}');
}`}
                />
              </div>
            </div>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">Passkey Credentials</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h3 className="font-medium text-sm mb-2 text-red-600">V1 Code</h3>
                <CodeBlock
                  language="dart"
                  code={`// Save passkey credentials
final credential = await credentialManager.savePasskeyCredentials(
  request: credentialCreationOptions,
);

// Get passkey credentials
// No direct method in V1`}
                />
              </div>
              
              <div>
                <h3 className="font-medium text-sm mb-2 text-green-600">V2 Code</h3>
                <CodeBlock
                  language="dart"
                  code={`// Save passkey credentials (unchanged)
final credential = await credentialManager.savePasskeyCredentials(
  request: credentialCreationOptions,
);

// Get passkey credentials (new)
final credentials = await credentialManager.getCredentials(
  passKeyOption: CredentialLoginOptions(
    challenge: "challenge_string",
    rpId: "yourdomain.com",
    userVerification: "required"
  ),
  fetchOptions: FetchOptionsAndroid(
    passKey: true
  ),
);

if (credentials.publicKeyCredential != null) {
  print('Passkey ID: \${credentials.publicKeyCredential!.id}');
  print('Raw ID: \${credentials.publicKeyCredential!.rawId}');
}`}
                />
              </div>
            </div>
          </div>

          <div>
            <h2 className="text-xl font-bold mb-4">Google Sign-In Credentials</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h3 className="font-medium text-sm mb-2 text-red-600">V1 Code</h3>
                <CodeBlock
                  language="dart"
                  code={`// Save Google credentials
final credential = await credentialManager.saveGoogleCredential();

// Get Google credentials
// No direct method in V1`}
                />
              </div>
              
              <div>
                <h3 className="font-medium text-sm mb-2 text-green-600">V2 Code</h3>
                <CodeBlock
                  language="dart"
                  code={`// Save Google credentials (parameters added)
final credential = await credentialManager.saveGoogleCredential(
  useButtonFlow: false // or true
);

// Get Google credentials (new)
final credentials = await credentialManager.getCredentials(
  fetchOptions: FetchOptionsAndroid(
    googleCredential: true
  ),
);

if (credentials.googleIdTokenCredential != null) {
  print('Email: \${credentials.googleIdTokenCredential!.email}');
  print('ID: \${credentials.googleIdTokenCredential!.id}');
}`}
                />
              </div>
            </div>
          </div>
        </div>

        <div className="bg-blue-50 dark:bg-blue-900/50 border-l-4 border-blue-400 p-4 mt-8">
          <div>
            <div>
              <Info className="h-5 w-5 text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-blue-700 dark:text-blue-200">
                If you encounter any issues during the migration process, please open an issue on the <a href="https://github.com/Djsmk123/flutter_credential_manager_compose/issues" target="_blank" rel="noopener noreferrer" className="font-medium underline">GitHub repository</a>.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

};


export default MigrationPage;
