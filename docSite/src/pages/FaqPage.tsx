import CodeBlock from "@/components/CodeBlock";
const FaqPage = () => {
 


  return (
    <div>
      <h1>Frequently Asked Questions</h1>
      
      <div className="space-y-8 mt-6">
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              What is Credential Manager?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              Credential Manager is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (such as Sign-in with Google) in a single API, thus simplifying the integration for developers. It unifies the sign-in interface across authentication methods, making it clearer and easier for users to sign into apps, regardless of the method they choose.
            </p>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              What is Keychain?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              Keychain is a secure storage system for sensitive information, such as passwords, certificates, and encryption keys. It provides a centralized place to store and manage this information, ensuring that it is protected from unauthorized access.
            </p>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              What is ASAuthorizationController?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              ASAuthorizationController is a class provided by Apple for handling authentication requests and responses. It supports passkeys in iOS 16 and above.
            </p>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              How do I clone the repository?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              You can clone the repository using the following command:
            </p>
            <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto mt-4">
              <CodeBlock
                language="sh"
                code={`git clone https://github.com/Djsmk123/flutter_credential_manager_compose`}
              />
            </pre>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              How do I initialize Credential Manager?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              To initialize Credential Manager, create an instance of the <code>CredentialManager</code> object and check if the platform is supported by calling the <code>isSupportedPlatform</code> property. Then, initialize the manager with the required parameters.
            </p>
            <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto mt-4">
              <CodeBlock
                language="dart"
                code={`final credentialManager = CredentialManager();
if (credentialManager.isSupportedPlatform) {
  await credentialManager.init(
    preferImmediatelyAvailableCredentials: true,
  );
}`}
              />
            </pre>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              How do I save password-based credentials on Android?
            </h3>
          </div>
          <div className="border-t border-gray-200 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500">
              To save password-based credentials on Android, use the <code>savePasswordCredential</code> method of the <code>CredentialManager</code> object. Wrap the call in a try-catch block to handle any potential errors.
            </p>
            <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto mt-4">
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
  print('Error saving password credential: \${e.message}');
}`}
              />
            </pre>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              How do handle errors?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              You can handle errors by catching the <code>CredentialException</code> in a try-catch block.
            </p>
            <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto mt-4">
              <CodeBlock
                language="dart"
                code={`try {
  // Your credential manager code here
} on CredentialException catch (e) {
  print('Error: \${e.message}');
  // Handle specific error cases if needed
}`}
              />
            </pre>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              How do I logout?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              To logout, call the <code>logout</code> method of the <code>CredentialManager</code> object. This will clear the saved credentials from the session.
            </p>
            <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto mt-4">
              <CodeBlock
                language="dart"
                code={`await credentialManager.logout();`}
              />
            </pre>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              How to contribute?
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              We welcome contributions to improve the functionality and documentation of this package. Please see our <a href="/contributing" className="text-blue-600 hover:text-blue-800">contributing guide</a> for guidelines on how to submit improvements and bug fixes.
            </p>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              License
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              This project is licensed under the MIT License. See the <a href="https://github.com/Djsmk123/flutter_credential_manager_compose/blob/main/LICENSE" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800">LICENSE</a> file for details.
            </p>
          </div>
        </div>
        
        <div className="bg-white shadow overflow-hidden rounded-lg border dark:bg-gray-800  ">
          <div className="px-4 py-5 sm:px-6 bg-gray-50 dark:bg-gray-900">
            <h3 className="text-lg leading-6 font-medium text-gray-900 dark:text-white">
              Contact
            </h3>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
            <p className="text-sm text-gray-500 dark:text-gray-400 font-mono">
              For questions or feedback, please contact the project maintainer:
            </p>
            <ul className="list-disc pl-5 mt-2 text-sm text-gray-500 dark:text-gray-400 font-mono">
              <li>Website: <a href="https://smkwinner.vercel.app" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800">https://smkwinner.vercel.app</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FaqPage;
