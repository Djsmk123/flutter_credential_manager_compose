
import React from 'react';

const ChangelogPage = () => {
  return (
    <div>
      <h1>Changes Log</h1>
      
      <div className="space-y-8">
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">2.0.3</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Migarte to example application to gradle-8.10.2</li>
            <li>Update dependencies</li>
            <li>Add Decoding for <code>attestationObject</code> to get <code>publicKey</code> and <code>authenticatorData</code> for passkey credential registration for iOS only.</li>
            <li>Improved Example application</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">2.0.2</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Update Documentation</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">2.0.1</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Fixed Example application (enableInlineAutofill) for iOS by Default.</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">2.0.0</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Add Password Credentials and Passkey Credentials support for iOS</li>
            <li>Breaking changes in android</li>
            <li>Removed Encrypted Credentials password based from both platforms</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">1.0.4+1</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Update documentation</li>
            <li>Update example application</li>
            <li>Update dependencies</li>
            <li>Update README.md</li>
            <li>Update CHANGELOG.md</li>
            <li>Update LICENSE</li>
            <li>Update pubspec.yaml</li>
            <li>Update errors.md</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">1.0.4</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Add logout functionality using clearCredential(), example application, documentation and dependencies update.</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">1.0.3</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Add google button flow for google login,Thanks to @<a href="https://github.com/wildsylvan" target="_blank" rel="noopener noreferrer">wildsylvan</a></li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">1.0.2</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Add missing fields <code>Response</code> Object for <code>PublicKeyCredential</code></li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">1.0.1</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Fix Example application(package Id).</li>
            <li>Provided rpId for testing purpose.</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">1.0.0</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Added Passkey support.</li>
            <li>Autofill from website.</li>
            <li>Fix bugs and improve code.</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">0.0.5</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Update all dependencies to latest version Thanks to <a href="https://github.com/jlafazia-figure" target="_blank" rel="noopener noreferrer">@jlafazia-figure</a></li>
            <li>Bug fixes and improvements in example application</li>
            <li>Update README.md with latest information</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">0.0.4</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Migrate to latest version of jetpack library <a href="https://developer.android.com/jetpack/androidx/releases/credentials#groovy" target="_blank" rel="noopener noreferrer">https://developer.android.com/jetpack/androidx/releases/credentials#groovy</a></li>
            <li>Google Sign in with Credential Manager</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">0.0.3</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Implement remaining ActivityAware lifecycle methods,Thanks to <a href="https://github.com/Granfalloner" target="_blank" rel="noopener noreferrer">Granfalloner</a></li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">0.0.2</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>Add encryption</li>
            <li>No breaking changes</li>
            <li>Add documentation</li>
          </ul>
        </div>
        
        <div className="border-l-4 border-blue-500 pl-4 mb-8">
          <h2 className="text-xl font-bold mb-2">0.0.1</h2>
          <ul className="list-disc pl-5 space-y-1">
            <li>initial release</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default ChangelogPage;
