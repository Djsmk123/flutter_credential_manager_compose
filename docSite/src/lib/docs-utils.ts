
import { useLocation } from 'react-router-dom';
import type { LucideIcon } from 'lucide-react';
import {
  Home,
  Download,
  Settings,
  BookOpen,
  Code2,
  Sparkles,
  HelpCircle,
  Users,
  History,
  ArrowUpRightFromCircle,
  Newspaper,
} from 'lucide-react';

export interface DocNavItem {
  title: string;
  path: string;
  icon: LucideIcon;
  description: string;
  /** Path relative to docSite/src/pages, used to build "Edit this page" links. */
  file: string;
}

export interface DocNavGroup {
  label: string;
  items: DocNavItem[];
}

// Grouped navigation structure, used by the sidebar, search index, and prev/next pagination.
export const docNavGroups: DocNavGroup[] = [
  {
    label: 'Getting Started',
    items: [
      { title: 'Home', path: '/', icon: Home, description: 'Overview of the plugin and its features.', file: 'HomePage.tsx' },
      { title: 'Installation', path: '/installation', icon: Download, description: 'Add the package to your Flutter project.', file: 'InstallationPage.tsx' },
      { title: 'Configuration', path: '/configuration', icon: Settings, description: 'Android and iOS native setup.', file: 'ConfigurationPage.tsx' },
    ],
  },
  {
    label: 'Guides',
    items: [
      { title: 'Usage', path: '/usage', icon: BookOpen, description: 'Core APIs for saving and retrieving credentials.', file: 'UsagePage.tsx' },
      { title: 'Examples', path: '/examples', icon: Sparkles, description: 'Copy-paste recipes for common flows.', file: 'ExamplesPage.tsx' },
      { title: 'Migration', path: '/migration', icon: ArrowUpRightFromCircle, description: 'Upgrading between major versions.', file: 'MigrationPage.tsx' },
    ],
  },
  {
    label: 'Reference',
    items: [
      { title: 'API Reference', path: '/api-reference', icon: Code2, description: 'Full class and method reference.', file: 'ApiReferencePage.tsx' },
      { title: 'FAQ', path: '/faq', icon: HelpCircle, description: 'Answers to common questions.', file: 'FaqPage.tsx' },
      { title: 'React Native', path: '/react-native', icon: Newspaper, description: 'Status of React Native support.', file: 'ReactNativePage.tsx' },
    ],
  },
  {
    label: 'Community',
    items: [
      { title: 'Contributing', path: '/contributing', icon: Users, description: 'How to contribute to the project.', file: 'ContributingPage.tsx' },
      { title: 'Changelog', path: '/changelog', icon: History, description: 'Release history and version notes.', file: 'ChangelogPage.tsx' },
      { title: 'Blogs', path: '/blogs', icon: Newspaper, description: 'Articles and write-ups.', file: 'BlogsPage.tsx' },
    ],
  },
];

// Flattened navigation list, kept for callers that only need path/title (prev/next, search).
export const docNavigation: DocNavItem[] = docNavGroups.flatMap((group) => group.items);

// Hook to get current path and highlight active nav item
export function useActiveNavItem() {
  const location = useLocation();

  const isActive = (path: string) => {
    if (path === '/') {
      return location.pathname === '/';
    }
    return location.pathname.startsWith(path);
  };

  return { isActive };
}

// Format the section titles correctly
export function formatTitle(title: string): string {
  switch (title) {
    case 'api-reference':
      return 'API Reference';
    case 'react-native':
      return 'React Native';
    case 'faq':
      return 'FAQ';
    default:
      return title.charAt(0).toUpperCase() + title.slice(1);
  }
}
