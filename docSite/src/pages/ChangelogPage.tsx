
const changelog = [
  {
    version: "Unreleased",
    sections: [
      {
        title: "Example Experience",
        items: [
          <>Refined the login screen with Material 3 cards, loading overlays, and a prominent logout action on the result page so you can demo every credential flow without restarting the app. (<a href="https://github.com/Djsmk123/flutter_credential_manager_compose/commit/6449ccbd8777db80bca3790b30a4308addec62bf" target="_blank" rel="noopener noreferrer">6449ccb</a>)</>,
          <>Added a reusable <code>JsonViewer</code> widget that renders password, passkey, and Google ID token payloads with collapsible sections and copy-to-clipboard support. (<a href="https://github.com/Djsmk123/flutter_credential_manager_compose/commit/6449ccbd8777db80bca3790b30a4308addec62bf" target="_blank" rel="noopener noreferrer">6449ccb</a>)</>,
          <>Surfaced the new <code>credentialManager.isGmsAvailable</code> getter inside the sample app to block Google flows when Play Services are missing. (<a href="https://github.com/Djsmk123/flutter_credential_manager_compose/commit/6449ccbd8777db80bca3790b30a4308addec62bf" target="_blank" rel="noopener noreferrer">6449ccb</a>)</>,
        ],
      },
      {
        title: "Android Reliability",
        items: [
          <>Detect devices that have zero Google accounts and deep-link users into the system settings while returning error code <code>207</code> so the Flutter layer can react gracefully. (<a href="https://github.com/Djsmk123/flutter_credential_manager_compose/commit/3fdfef4d282ca26e34c8f544e1f1b152cd21711a" target="_blank" rel="noopener noreferrer">3fdfef4</a>)</>,
          <>Added explicit Google Play Services checks and a dedicated <code>209</code> error code that short-circuits Google Sign-In requests when Play Services are unavailable. (<a href="https://github.com/Djsmk123/flutter_credential_manager_compose/commit/3fdfef4d282ca26e34c8f544e1f1b152cd21711a" target="_blank" rel="noopener noreferrer">3fdfef4</a>)</>,
          <>Documented the expanded exception table in the platform interface so integrators see the new codes without digging into native sources. (<a href="https://github.com/Djsmk123/flutter_credential_manager_compose/commit/3fdfef4d282ca26e34c8f544e1f1b152cd21711a" target="_blank" rel="noopener noreferrer">3fdfef4</a>)</>,
        ],
      },
    ],
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
          "Refactored UIWindow retrieval logic in PasskeyAuthentication and PasskeyRegistration to address build issues on iOS.",
          "Fixed iOS build issues in the example project.",
        ],
      },
      {
        title: "Documentation & CI",
        items: [
          "Enhanced README and overall documentation.",
          "Updated static analysis and caching workflows in static.yml to improve CI efficiency.",
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
      "Fixed example application (enableInlineAutofill) for iOS by default.",
    ],
  },
  {
    version: "2.0.0",
    items: [
      "Added Password Credentials and Passkey Credentials support for iOS.",
      "Breaking changes in Android.",
      "Removed Encrypted Credentials (password-based) from both platforms.",
    ],
  },
  {
    version: "1.0.4+1",
    items: [
      "Updated documentation.",
      "Updated example application.",
      "Updated dependencies.",
      "Updated README.md.",
      "Updated CHANGELOG.md.",
      "Updated LICENSE.",
      "Updated pubspec.yaml.",
      "Updated errors.md.",
    ],
  },
  {
    version: "1.0.4",
    items: [
      "Added logout functionality using clearCredential(), updated example application, documentation, and dependencies.",
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
      "Bug fixes and improvements in example application.",
      "Updated README.md with latest information.",
    ],
  },
  {
    version: "0.0.4",
    items: [
      <>Migrated to latest version of Jetpack library (<a href="https://developer.android.com/jetpack/androidx/releases/credentials#groovy" target="_blank" rel="noopener noreferrer">release notes</a>).</>,
      "Added Google Sign-in with Credential Manager.",
    ],
  },
  {
    version: "0.0.3",
    items: [
      <>Implemented remaining ActivityAware lifecycle methods. Thanks to <a href="https://github.com/Granfalloner" target="_blank" rel="noopener noreferrer">Granfalloner</a>.</>,
    ],
  },
  {
    version: "0.0.2",
    items: [
      "Added encryption.",
      "No breaking changes.",
      "Added documentation.",
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
