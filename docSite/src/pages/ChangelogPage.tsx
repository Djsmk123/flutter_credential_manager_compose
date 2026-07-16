
/**
 * Changelog entries are sourced directly from packages/credential_manager/CHANGELOG.md.
 * To update: Copy the desired versions directly, convert markdown (links/code blocks) as needed.
 */

const changelog = [
  {
    version: "3.0.1",
    items: [
      <>Bumped <code>credential_manager_ios</code> to <code>^3.0.1</code> and <code>credential_manager_android</code> to <code>^3.0.1</code>, both of which add native static analysis (SwiftLint, Detekt) with no functional or API changes.</>,
      "No breaking changes to the Dart API.",
    ],
  },
  {
    version: "3.0.0",
    items: [
      <>Bumped <code>credential_manager_ios</code> to <code>^3.0.0</code>, which adds Swift Package Manager (SPM) support alongside the existing CocoaPods integration.</>,
      "No breaking changes to the Dart API; apps still on CocoaPods continue to work unchanged.",
    ],
  },
  {
    version: "2.0.8",
    items: [
      <>Added <code>isGmsAvailable</code> to platform interface.</>,
      <>Handle <code>exception code 209</code> for Google Play Services not available.</>,
      <>On Android, if Google account is not logged in, the plugin will launch Google Sign-In flow.</>,
      "Updated documentation.",
    ],
  },
  {
    version: "2.0.7",
    items: [
      "Fixed plugin score issues."
    ],
  },
  {
    version: "2.0.6",
    sections: [
      {
        title: "🚀 Major Refactoring: Modular Architecture",
        items: [
          <><strong>⚠️ Breaking Change:</strong> The plugin has been completely refactored into a modular architecture for better scalability and maintenance.</>,
          <>Introduced new packages:</>,
          <ul className="list-disc pl-6">
            <li><code>credential_manager</code> – Main package containing shared logic, models, and utilities.</li>
            <li><code>credential_manager_platform_interface</code> – Platform-agnostic interface for consistent API definitions.</li>
            <li><code>credential_manager_android</code> – Android-specific implementation.</li>
            <li><code>credential_manager_ios</code> – iOS-specific implementation.</li>
          </ul>,
          "All packages are now organized under the packages/ directory.",
          "Greatly improved maintainability, clarity, and extensibility for future updates."
        ]
      },
      {
        title: "🧠 Code Optimization",
        items: [
          "Removed 300+ lines of duplicate code between Android and iOS implementations.",
          <>Introduced shared utilities:</>,
          <ul className="list-disc pl-6">
            <li><code>CredentialType</code> – Centralized credential type definitions.</li>
            <li><code>PlatformExceptionHandler</code> – Unified platform error handling.</li>
            <li><code>CredentialResponseParser</code> – Shared response parsing logic for all platforms.</li>
          </ul>,
          <>File size reduction highlights:</>,
          <ul className="list-disc pl-6">
            <li>Android implementation: <strong>~326 → 177 lines</strong></li>
            <li>iOS implementation: <strong>~410 → 250 lines</strong></li>
          </ul>,
        ]
      },
      {
        title: "🐞 Bug Fixes",
        items: [
          "Fixed AssertionError for uninitialized CredentialManagerPlatform.instance.",
          "Added automatic platform registration within the CredentialManager constructor.",
          "Fixed platform implementations not being registered automatically."
        ]
      },
      {
        title: "⚙️ Platform Registration Improvements",
        items: [
          "Platform implementations now auto-register when CredentialManager is instantiated.",
          "Improved error messages for uninitialized platform instances.",
        ]
      },
      {
        title: "✅ Testing & Migration",
        items: [
          <>Migration verified and tested on both platforms:</>,
          <ul className="list-disc pl-6">
            <li>✅ iOS</li>
            <li>✅ Android</li>
          </ul>,
          "All platform implementations are stable and functional."
        ]
      },
      {
        title: "🧩 Developer Experience",
        items: [
          "Added analysis_error.sh script for static analysis and code health checks.",
          "Enforced better separation of concerns across all packages.",
          "All packages pass static analysis with zero errors.",
        ]
      },
      {
        title: "📚 Documentation",
        items: [
          "Updated README and package documentation to reflect the modular structure.",
          "Added in-code documentation for maintainers and contributors.",
          "Improved migration guide and changelog clarity.",
        ]
      }
    ]
  },
  {
    version: "2.0.4",
    sections: [
      {
        title: "Dependencies",
        items: [
          <>Updated Android and Flutter dependencies for improved stability and compatibility. (<a href="https://github.com/your-repo/commit/3a870fa" target="_blank" rel="noopener noreferrer">3a870fa</a>)</>,
          "Updated Android Gradle plugin version to 8.4.2.",
          "Upgraded package versions and fixed iOS-related errors.",
        ],
      },
      {
        title: "iOS Fixes",
        items: [
          "Refactored UIWindow retrieval logic in PasskeyAuthentication and PasskeyRegistration.",
          "Fixed iOS build issues in the example project.",
        ],
      },
      {
        title: "Documentation & CI",
        items: [
          "Enhanced README and overall documentation.",
          "Updated static analysis and caching workflows in static.yml for improved CI performance.",
        ],
      },
    ],
  },
  {
    version: "2.0.3",
    items: [
      "Migrated example application to Gradle 8.10.2.",
      "Updated dependencies.",
      <>Added decoding of <code>attestationObject</code> to extract <code>publicKey</code> and <code>authenticatorData</code> for passkey credential registration (iOS only).</>,
      "Improved example application.",
    ],
  },
  {
    version: "2.0.2",
    items: [
      "Updated documentation.",
    ],
  },
  {
    version: "2.0.1",
    items: [
      <>Fixed example application (<code>enableInlineAutofill</code>) for iOS by default.</>,
    ],
  },
  {
    version: "2.0.0",
    items: [
      "Added Password Credentials and Passkey Credentials support for iOS.",
      <><strong>Breaking Changes</strong> on Android.</>,
      "Removed Encrypted Credentials (password-based) from both platforms.",
    ],
  },
  {
    version: "1.0.4+1",
    items: [
      "Updated documentation and example application.",
      "Updated dependencies, README, CHANGELOG, LICENSE, and pubspec.yaml.",
      "Updated errors.md.",
    ],
  },
  {
    version: "1.0.4",
    items: [
      <>Added logout functionality using <code>clearCredential()</code>. Updated example application, documentation, and dependencies.</>,
    ],
  },
  {
    version: "1.0.3",
    items: [
      <>Added Google button flow for Google login. Thanks to <a href="https://github.com/wildsylvan" target="_blank" rel="noopener noreferrer">@wildsylvan</a>.</>,
    ],
  },
  {
    version: "1.0.2",
    items: [
      <>Added missing fields to <code>Response</code> object for <code>PublicKeyCredential</code>.</>,
    ],
  },
  {
    version: "1.0.1",
    items: [
      "Fixed example application (package ID).",
      "Provided rpId for testing purposes.",
    ],
  },
  {
    version: "1.0.0",
    items: [
      "Added Passkey support.",
      "Autofill from website.",
      "Fixed bugs and improved code.",
    ],
  },
  {
    version: "0.0.5",
    items: [
      <>Updated all dependencies to latest versions. Thanks to <a href="https://github.com/jlafazia-figure" target="_blank" rel="noopener noreferrer">@jlafazia-figure</a>.</>,
      "Bug fixes and improvements in example app.",
      "Updated README.md with latest info.",
    ],
  },
  {
    version: "0.0.4",
    items: [
      <>Migrated to latest Jetpack library version (<a href="https://developer.android.com/jetpack/androidx/releases/credentials#groovy" target="_blank" rel="noopener noreferrer">release notes</a>).</>,
      "Added Google Sign-in with Credential Manager.",
    ],
  },
  {
    version: "0.0.3",
    items: [
      <>Implemented remaining <code>ActivityAware</code> lifecycle methods. Thanks to <a href="https://github.com/Granfalloner" target="_blank" rel="noopener noreferrer">Granfalloner</a>.</>
    ],
  },
  {
    version: "0.0.2",
    items: [
      "Added encryption.",
      "Added documentation.",
      "No breaking changes.",
    ],
  },
  {
    version: "0.0.1",
    items: [
      "Initial release.",
    ],
  },
];

const ChangelogPage = () => {
  return (
    <div>
      <h1>Changelog</h1>
      <div className="space-y-8">
        {changelog.map((entry, idx) => (
          <div key={entry.version} className="border-l-4 border-blue-500 pl-4 mb-8">
            <h2 className="text-xl font-bold mb-2">{entry.version}</h2>
            {entry.sections ? (
              entry.sections.map((section, sidx) => (
                <div key={section.title} className="mb-4">
                  <h3 className="font-semibold">{section.title}</h3>
                  <ul className="list-disc pl-5 space-y-1">
                    {section.items.map((item, iidx) => (
                      <li key={iidx}>{item}</li>
                    ))}
                  </ul>
                </div>
              ))
            ) : (
              <ul className="list-disc pl-5 space-y-1">
                {entry.items.map((item, iidx) => (
                  <li key={iidx}>{item}</li>
                ))}
              </ul>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default ChangelogPage;
