import React from 'react';

const ApiReferencePage = () => {
  return (
    <div className="max-w-4xl mx-auto px-4">
      <h1 className="text-4xl font-bold mb-6">API Reference</h1>
      
      <p className="my-4">
        For Android and iOS please refer to <a href="https://pub.dev/documentation/credential_manager/latest/credential_manager/credential_manager-library.html" target="_blank" rel="noopener noreferrer">credential_manager</a> library.
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">Android</h2>
      
      <p className="mb-6">
        <strong>Credential Manager</strong> is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (such as Sign-in with Google) in a single API, thus simplifying the integration for developers.
      </p>
      
      <p className="mb-6">
        Furthermore, for users, Credential Manager unifies the sign-in interface across authentication methods, making it clearer and easier for users to sign into apps, regardless of the method they choose.
      </p>
      
      <p className="mb-6">
        More about <a href="https://developer.android.com/identity/sign-in/credential-manager" target="_blank" rel="noopener noreferrer">Credential Manager</a>
      </p>
      
      <h2 className="text-2xl font-semibold mt-8 mb-4">iOS</h2>
      
      <p className="mb-6">
        Keychain is a secure storage system for sensitive information, such as passwords, certificates, and encryption keys. It provides a centralized place to store and manage this information, ensuring that it is protected from unauthorized access.
      </p>
      
      <p className="mb-6">
        More about <a href="https://developer.apple.com/documentation/security/keychain_services" target="_blank" rel="noopener noreferrer">Keychain</a>
      </p>
      
      <p className="mb-6">
        <strong>ASAuthorizationController</strong> and <strong>ASAuthorizationProvider</strong> are classes provided by Apple for handling authentication requests and responses and passkeys are supported in iOS 16 and above.
      </p>
      
      <p className="mb-6">
        More about <a href="https://developer.apple.com/documentation/authenticationservices/asauthorizationcontroller" target="_blank" rel="noopener noreferrer">ASAuthorizationController</a>
      </p>
      
      <p className="mb-6">
        More about <a href="https://developer.apple.com/documentation/authenticationservices/asauthorizationprovider" target="_blank" rel="noopener noreferrer">ASAuthorizationProvider</a>
      </p>

      <h2 className="text-2xl font-semibold mt-8 mb-4">Key Classes and Methods</h2>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">CredentialManager</h3>
      
      <p className="mb-4">The main class for interacting with platform credentials.</p>
      
      <table className="min-w-full border border-gray-300 mt-4 mb-8">
        <thead>
          <tr>
            <th className="border border-gray-300 px-4 py-2 text-left bg-gray-50 dark:bg-gray-800 text-sm">Method</th>
            <th className="border border-gray-300 px-4 py-2 text-left bg-gray-50 dark:bg-gray-800 text-sm">Description</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td className="border border-gray-300 px-4 py-2 font-mono text-sm">init()</td>
            <td className="border border-gray-300 px-4 py-2">Initializes the credential manager with optional parameters.</td>
          </tr>
          <tr>
            <td className="border border-gray-300 px-4 py-2 font-mono text-sm">savePasswordCredential()</td>
            <td className="border border-gray-300 px-4 py-2">Saves password-based credentials.</td>
          </tr>
          <tr>
            <td className="border border-gray-300 px-4 py-2 font-mono text-sm">saveGoogleCredential()</td>
            <td className="border border-gray-300 px-4 py-2">Saves Google sign-in credentials (Android only).</td>
          </tr>
          <tr>
            <td className="border border-gray-300 px-4 py-2 font-mono text-sm">savePasskeyCredentials()</td>
            <td className="border border-gray-300 px-4 py-2">Creates and saves passkey credentials.</td>
          </tr>
          <tr>
            <td className="border border-gray-300 px-4 py-2 font-mono text-sm">getCredentials()</td>
            <td className="border border-gray-300 px-4 py-2">Retrieves stored credentials based on provided options.</td>
          </tr>
          <tr>
            <td className="border border-gray-300 px-4 py-2 font-mono text-sm">logout()</td>
            <td className="border border-gray-300 px-4 py-2">Clears saved credentials from session (Android only).</td>
          </tr>
        </tbody>
      </table>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">PasswordCredential</h3>
      
      <p className="mb-4">Class representing username and password credentials.</p>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">PublicKeyCredential</h3>
      
      <p className="mb-4">Class representing passkey credentials.</p>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">GoogleIdTokenCredential</h3>
      
      <p className="mb-4">Class representing Google sign-in credentials.</p>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">CredentialCreationOptions</h3>
      
      <p className="mb-4">Class for configuring passkey creation options.</p>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">CredentialLoginOptions</h3>
      
      <p className="mb-4">Class for configuring passkey authentication options.</p>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">FetchOptionsAndroid</h3>
      
      <p className="mb-4">Class for configuring which types of credentials to retrieve on Android.</p>
      
      <h3 className="text-xl font-semibold mt-6 mb-2">CredentialException</h3>
      
      <p className="mb-4">Exception class for credential-related errors.</p>
      
      <p className="mt-8 mb-4">
        For full API documentation, visit the <a href="https://pub.dev/documentation/credential_manager/latest/" target="_blank" rel="noopener noreferrer">official pub.dev documentation</a>.
      </p>
    </div>
  );
};

export default ApiReferencePage;
