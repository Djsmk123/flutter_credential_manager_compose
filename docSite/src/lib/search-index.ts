import { docNavGroups, type DocNavItem } from './docs-utils';

export interface SearchSection {
  /** Heading or topic text shown/matched as a sub-result under its parent page. */
  text: string;
  /** Optional anchor id to deep-link to, when it matches the slug the page will generate. */
  anchor?: string;
}

// Hand-maintained per-page topic index (headings, FAQ questions, key API names) so search can
// match more than just the page title. Pages render headings as plain JSX rather than markdown,
// so there's no build-time content pipeline to source this from automatically.
const sectionsByPath: Record<string, SearchSection[]> = {
  '/': [
    { text: 'Secure Storage' },
    { text: 'Biometric Auth' },
    { text: 'Cross Platform' },
  ],
  '/installation': [
    { text: 'pubspec.yaml' },
    { text: 'Next Steps' },
  ],
  '/configuration': [
    { text: 'Android Configuration' },
    { text: 'Proguard Rules' },
    { text: 'Gradle Configuration' },
    { text: 'Digital Asset Links Setup' },
    { text: 'Google Sign-In Setup' },
    { text: 'iOS Configuration' },
    { text: 'Swift Package Manager (SPM) Support' },
    { text: 'Enabling Password AutoFill' },
    { text: 'Keychain Group' },
    { text: 'Apple App Site Association File Example' },
  ],
  '/usage': [
    { text: 'Initialize Credential Manager' },
    { text: 'Password Based Credentials' },
    { text: 'Google Sign-In (Only For Android)' },
    { text: 'Setup Google Cloud Console' },
    { text: 'Sign-In with Google' },
    { text: 'Passkey' },
    { text: 'Passkey Setup for Android' },
    { text: 'Create Passkey Credentials' },
    { text: 'Get Passkey Credentials' },
    { text: 'Logout' },
    { text: 'Error Handling' },
    { text: 'Platform Support' },
  ],
  '/api-reference': [
    { text: 'CredentialManager' },
    { text: 'PasswordCredential' },
    { text: 'PublicKeyCredential' },
    { text: 'GoogleIdTokenCredential' },
    { text: 'CredentialCreationOptions' },
    { text: 'CredentialLoginOptions' },
    { text: 'FetchOptionsAndroid' },
    { text: 'CredentialException' },
    { text: 'savePasswordCredentials' },
    { text: 'savePasskeyCredentials' },
    { text: 'getCredentials' },
    { text: 'saveGoogleCredential' },
  ],
  '/examples': [
    { text: "What's New in the Example App" },
    { text: 'Gate Google Sign-In When Play Services Are Missing' },
    { text: 'Inspect Credential Payloads with JsonViewer' },
    { text: 'Password Credential Example' },
    { text: 'Passkey Example' },
    { text: 'Google Sign-In Example' },
  ],
  '/migration': [
    { text: 'Password Credentials' },
    { text: 'Passkey Credentials' },
    { text: 'Google Sign-In Credentials' },
    { text: 'V1 Code' },
    { text: 'V2 Code' },
  ],
  '/faq': [
    { text: 'What is Credential Manager?' },
    { text: 'What is Keychain?' },
    { text: 'What is ASAuthorizationController?' },
    { text: 'How do I clone the repository?' },
    { text: 'How do I initialize Credential Manager?' },
    { text: 'How do I save password-based credentials on Android?' },
    { text: 'How do handle errors?' },
    { text: 'How do I logout?' },
  ],
  '/contributing': [
    { text: 'Ways to Contribute' },
    { text: 'Getting Started' },
    { text: 'Code Style Guidelines' },
    { text: 'Pull Request Guidelines' },
    { text: 'Issue Guidelines' },
    { text: 'Code of Conduct' },
  ],
  '/changelog': [
    { text: 'Release notes' },
    { text: 'Version history' },
    { text: 'Breaking changes' },
  ],
  '/blogs': [
    { text: 'Write a Blog About This Package' },
    { text: 'Related Resources' },
  ],
  '/react-native': [
    { text: 'React Native Alternatives' },
    { text: 'Android Alternatives' },
    { text: 'iOS Alternatives' },
    { text: 'Passkey Support in React Native' },
  ],
};

export interface SearchResult {
  page: DocNavItem;
  groupLabel: string;
  match: 'title' | 'description' | 'section';
  sectionText?: string;
}

const allPages = docNavGroups.flatMap((group) =>
  group.items.map((item) => ({ item, groupLabel: group.label }))
);

export function searchDocs(query: string): SearchResult[] {
  const q = query.trim().toLowerCase();
  if (!q) return [];

  const results: SearchResult[] = [];

  for (const { item, groupLabel } of allPages) {
    if (item.title.toLowerCase().includes(q)) {
      results.push({ page: item, groupLabel, match: 'title' });
      continue;
    }

    if (item.description.toLowerCase().includes(q)) {
      results.push({ page: item, groupLabel, match: 'description' });
      continue;
    }

    const sections = sectionsByPath[item.path] ?? [];
    const matchedSection = sections.find((s) => s.text.toLowerCase().includes(q));
    if (matchedSection) {
      results.push({ page: item, groupLabel, match: 'section', sectionText: matchedSection.text });
    }
  }

  return results;
}
