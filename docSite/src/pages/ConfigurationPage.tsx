import CodeBlock from '@/components/CodeBlock';
import ImageViewer from '@/components/ImageViewer';
import { getAssetPath } from '@/lib/utils';

const ConfigurationPage = () => {
  return (
    <div>
      <h1>Configuration</h1>

      <p className="my-4">
        It is recommended to use the latest version of Android Studio and Xcode to ensure compatibility with the latest Android and iOS SDKs.
      </p>

      <p className="my-4">
        Both Android and iOS have some configuration to ensure that the library works properly.
      </p>

      <h2 className="mt-8 mb-4">Android Configuration</h2>

      <h3 className="mt-6 mb-2">Proguard Rules</h3>

      <p className="mb-2">Create or update <code>android/app/proguard-rules.pro</code>:</p>
      <CodeBlock
        code={`-if class androidx.credentials.CredentialManager
-keep class androidx.credentials.playservices.** {
  *;
}`}
        language="plaintext"
      />

      <h3 className="mt-6 mb-2">Gradle Configuration</h3>
      <p className="mb-2">Update <code>android/app/build.gradle</code>:</p>
      <CodeBlock
        language="kotlin"
        code={`android {
  buildTypes {
    release {
      minifyEnabled true
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
  }
}`}
      />

      <h3 className="mt-6 mb-2">Digital Asset Links Setup</h3>

      <ol className="list-decimal pl-6 mb-6">
        <li className="mb-2">
          <p>Create a Digital Asset Links JSON file (<code>assetlinks.json</code>):</p>
          <CodeBlock
            code={`[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls",
      "delegate_permission/common.get_login_creds"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "your.package.name",
      "sha256_cert_fingerprints": [
        "YOUR_APP_SIGNATURE_SHA256_HASH"
      ]
    }
  }
]`}
            language="json"
          />
        </li>

        <li className="mb-2">
          <p>Host this file on your sign-in domain at:</p>
          <CodeBlock code={`https://yourdomain.com/.well-known/assetlinks.json`} language="plaintext" />
        </li>

        <li className="mb-2">
          <p>Configure <code>robots.txt</code> to allow Google to access your asset links file:</p>

          <CodeBlock
            code={`User-agent: *
Allow: /.well-known/`}
            language="plaintext"
          />
        </li>
      </ol>

      <h3 className="mt-6 mb-2">Google Sign-In Setup</h3>

      <ol className="list-decimal pl-6 mb-6">
        <li className="mb-2">Go to the <a href="https://console.cloud.google.com/" target="_blank" rel="noopener noreferrer">Google Cloud Console</a></li>
        <li className="mb-2">Create or select a project</li>
        <li className="mb-2">Configure the OAuth consent screen</li>
        <li className="mb-2">Create OAuth client ID credentials for Android and Web</li>
        <li className="mb-2">
          <p>For Android, obtain SHA-1 certificate fingerprint:</p>
          <CodeBlock code={`cd android && ./gradlew signingReport`} language="bash" />
          <p className="my-2">or</p>
          <CodeBlock
            code={`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`}
            language="bash"
          />
        </li>
      </ol>

      <h2 className="mt-8 mb-4">iOS Configuration</h2>

      <p className="mb-4">
        For iOS, it uses <a href="https://developer.apple.com/documentation/security/keychain_services" target="_blank">Keychain</a> for storing passkeys and <a href="https://developer.apple.com/documentation/uikit/text_input/adding_password_autofill_support_to_your_app" target="_blank">Autofill</a> for managing credentials.
      </p>

      <p className="mb-4">
        Password autofill was introduced with iOS 11 and got major updates with iOS 12, including security code autofill, password suggestions, and support for third-party managers.
      </p>

      <h3 className="mt-6 mb-2">Enabling Password AutoFill</h3>

      <ol className="list-decimal pl-6 mb-6">
        <li className="mb-2">Open your project in XcoIn the Associated Domains section, add the domain that you want to associate with your app using the format applinks:yourdomain.com and webcredentials:yourdomain.com.
        de.</li>
        <li className="mb-2">Go to your app target &gt; Signing & Capabilities tab.</li>
        <li className="mb-2">Click "+" and select <strong>Associated Domains</strong>.</li>
        <li className="mb-2">Add domains like <code>applinks:yourdomain.com</code> and <code>webcredentials:yourdomain.com</code>.</li>
        <li className="mb-2">
          <ImageViewer imageUrls={[getAssetPath("assets/associated_domain.png")]} height="300" />
          Ensure your website hosts an <code>apple-app-site-association</code> file at the root with:
          <CodeBlock
            code={`{   
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["<team_id>.com.yourappname"]
    }]
  },
  "webcredentials": {
    "apps": [
      "<team_id>.com.yourappname"   
    ]
  }
}`}
            language="json"
          />
        </li>
        <li className="mb-2">
          Validate your file:
          <CodeBlock code={`curl -X GET https://yourdomain.com/.well-known/apple-app-site-association`} language="bash" />
          Or use the <a href="https://branch.io/resources/aasa-validator/" target="_blank">Branch AASA Validator</a>.
        </li>
      </ol>

      <h3 className="mt-6 mb-2">Keychain Group</h3>

      <ul className="list-disc pl-6 mb-6">
        <li className="mb-2">Add the <strong>Keychain Sharing</strong> capability.</li>
        <li className="mb-2">Enter the keychain group name shared across apps in the same team.</li>
      </ul>

      {/* Update ImageViewer reference */}
      <ImageViewer imageUrls={[getAssetPath("assets/keychain.png")]} height="300" />

      <h3 className="mt-6 mb-2">Apple App Site Association File Example</h3>

      <CodeBlock
        code={`{
  "webcredentials": {
    "apps": [ "TEAM_ID.your.bundle.identifier" ]
  },
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.your.bundle.identifier",
        "paths": [ "*" ]
      }
    ]
  }
}`}
        language="json"
      />

      <p className="my-4">
        After completing these configurations, your application will be ready to use all features of the Credential Manager plugin.
      </p>
    </div>
  );
};

export default ConfigurationPage;
