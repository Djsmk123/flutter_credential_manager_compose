import React from 'react';

const ReactNativePage = () => {
  return (
    <div className="bg-white dark:bg-gray-900 min-h-screen px-4 py-6">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">React Native</h1>

      {/* Warning Box */}
      <div className="bg-yellow-50 dark:bg-yellow-900 border-l-4 border-yellow-400 dark:border-yellow-600 p-4 my-6">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-yellow-400 dark:text-yellow-300" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-yellow-700 dark:text-yellow-100">
              This library is currently only available for Flutter. React Native support is not yet available.
            </p>
          </div>
        </div>
      </div>

      <h2 className="text-xl font-bold mt-8 mb-4 text-gray-900 dark:text-white">React Native Alternatives</h2>

      <p className="mb-6 text-gray-700 dark:text-gray-300">
        While this specific library doesn't support React Native, there are similar libraries available for React Native that provide credential management functionality:
      </p>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Android Alternatives */}
        <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden shadow-sm p-6">
          <h3 className="font-bold text-lg mb-2 text-gray-900 dark:text-white">Android Alternatives</h3>
          <ul className="list-disc pl-5 space-y-2">
            <li>
              <a
                href="https://github.com/react-native-google-signin/google-signin"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium"
              >
                @react-native-google-signin/google-signin
              </a>
              <p className="text-gray-600 dark:text-gray-400 mt-1 text-sm">
                Google Sign-in for React Native
              </p>
            </li>
            <li>
              <a
                href="https://github.com/FormidableLabs/react-native-app-auth"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium"
              >
                react-native-app-auth
              </a>
              <p className="text-gray-600 dark:text-gray-400 mt-1 text-sm">
                OAuth2 library for React Native
              </p>
            </li>
            <li>
              <a
                href="https://github.com/oblador/react-native-keychain"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium"
              >
                react-native-keychain
              </a>
              <p className="text-gray-600 dark:text-gray-400 mt-1 text-sm">
                Keychain/Keystore access for React Native
              </p>
            </li>
          </ul>
        </div>

        {/* iOS Alternatives */}
        <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden shadow-sm p-6">
          <h3 className="font-bold text-lg mb-2 text-gray-900 dark:text-white">iOS Alternatives</h3>
          <ul className="list-disc pl-5 space-y-2">
            <li>
              <a
                href="https://github.com/oblador/react-native-keychain"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium"
              >
                react-native-keychain
              </a>
              <p className="text-gray-600 dark:text-gray-400 mt-1 text-sm">
                Keychain access for React Native
              </p>
            </li>
            <li>
              <a
                href="https://github.com/invertase/react-native-apple-authentication"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium"
              >
                @invertase/react-native-apple-authentication
              </a>
              <p className="text-gray-600 dark:text-gray-400 mt-1 text-sm">
                Apple authentication for React Native
              </p>
            </li>
          </ul>
        </div>
      </div>

      <h2 className="text-xl font-bold mt-8 mb-4 text-gray-900 dark:text-white">Passkey Support in React Native</h2>

      <p className="mb-4 text-gray-700 dark:text-gray-300">
        As of now, comprehensive passkey support in React Native is still evolving. Here are some resources to explore:
      </p>

      <ul className="list-disc pl-6 mb-6 space-y-2 text-gray-700 dark:text-gray-300">
        <li>
          <a
            href="https://github.com/justinsafrit/react-native-passkey"
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium"
          >
            react-native-passkey
          </a>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            An experimental library for passkey support in React Native
          </p>
        </li>
        <li>
          <a
            href="https://w3c.github.io/webauthn/"
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium"
          >
            Web Authentication API (WebAuthn)
          </a>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            The underlying standard for passkeys that some React Native libraries implement
          </p>
        </li>
      </ul>

      {/* Info Box */}
      <div className="bg-blue-50 dark:bg-blue-900 border-l-4 border-blue-400 dark:border-blue-600 p-4 mt-8">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-blue-400 dark:text-blue-300" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2h-1V9a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-blue-700 dark:text-blue-100">
              Interested in a React Native version of the Credential Manager package? Open a feature request on our{' '}
              <a
                href="https://github.com/Djsmk123/flutter_credential_manager_compose/issues"
                target="_blank"
                rel="noopener noreferrer"
                className="font-medium underline"
              >
                GitHub repository
              </a>.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ReactNativePage;
