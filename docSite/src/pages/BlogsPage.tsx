import React from 'react';

const BlogsPage = () => {
  return (
    <div className="bg-white dark:bg-gray-950 min-h-screen text-gray-800 dark:text-gray-100 px-4 py-6">
      <h1 className="text-3xl font-bold mb-6">Blogs</h1>

      <div className="mt-8 grid gap-6">
        <div className="bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
          <div className="p-6">
            <h2 className="text-xl font-bold mb-3">
              <a
                href="https://dev.to/djsmk123/unlocking-the-future-passwordless-authenticationpasskey-with-flutter-and-nodejs-1ojh"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
              >
                Unlocking the Future: Passwordless Authentication (Passkey) With Flutter and Node.js
              </a>
            </h2>
            <p className="text-gray-700 dark:text-gray-300 mb-4">
              A comprehensive guide on implementing passwordless authentication using passkeys with Flutter and Node.js.
            </p>
            <div className="flex items-center">
              <span className="text-sm text-gray-600 dark:text-gray-400">By </span>
              <a
                href="https://github.com/djsmk123"
                target="_blank"
                rel="noopener noreferrer"
                className="ml-1 text-sm text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
              >
                @djsmk123
              </a>
            </div>
            <a
              href="https://dev.to/djsmk123/unlocking-the-future-passwordless-authenticationpasskey-with-flutter-and-nodejs-1ojh"
              target="_blank"
              rel="noopener noreferrer"
              className="mt-4 inline-block px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 dark:hover:bg-blue-500 transition-colors text-sm"
            >
              Read Article
            </a>
          </div>
        </div>
      </div>

      <div className="bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6 mt-8">
        <h2 className="text-lg font-semibold mb-4">Write a Blog About This Package</h2>
        <p className="text-gray-700 dark:text-gray-300 mb-4">
          Did you write a blog about this package? Please let me know, and I'll add it to the list by opening a PR and contacting the project maintainer.
        </p>
        <div className="flex space-x-4">
          <a
            href="https://github.com/Djsmk123/flutter_credential_manager_compose/pulls"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-block px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 dark:hover:bg-blue-500 transition-colors text-sm"
          >
            Open a PR
          </a>
          <a
            href="https://github.com/Djsmk123/flutter_credential_manager_compose/issues"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-block px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 dark:hover:bg-gray-500 transition-colors text-sm"
          >
            Open an Issue
          </a>
        </div>
      </div>

      <div className="mt-8">
        <h2 className="text-xl font-bold mb-4">Related Resources</h2>
        <ul className="space-y-2">
          <li>
            <a
              href="https://developer.android.com/identity/sign-in/credential-manager"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
            >
              Android Credential Manager Documentation
            </a>
          </li>
          <li>
            <a
              href="https://developer.apple.com/documentation/security/keychain_services"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
            >
              iOS Keychain Services Documentation
            </a>
          </li>
          <li>
            <a
              href="https://pub.dev/packages/credential_manager"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
            >
              Credential Manager Package on pub.dev
            </a>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default BlogsPage;
