'use client';

import { useGitHubRepoStats } from '@/lib/useGithHubRepoState';
import ImageViewer from '@/components/ImageViewer';
import { motion } from 'framer-motion';

const fadeIn = {
  hidden: { opacity: 0, y: 20 },
  visible: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.15 },
  }),
};

const HomePage = () => {
  const stats = useGitHubRepoStats();

  return (
    <motion.div
      className="p-4 sm:p-6 md:p-8 max-w-4xl mx-auto"
      initial="hidden"
      animate="visible"
      variants={{
        hidden: {},
        visible: {},
      }}
    >
      <motion.h1
        className="text-2xl sm:text-3xl font-bold mb-6 sm:mb-8 text-gray-900 dark:text-white"
        variants={fadeIn}
        custom={0}
      >
        Credential Manager
      </motion.h1>

      {stats && (
        <motion.div
          className="mb-6 sm:mb-8 text-gray-800 dark:text-gray-300 flex flex-col sm:flex-row gap-2 sm:gap-4 text-xs sm:text-sm"
          variants={fadeIn}
          custom={1}
        >
          <span>⭐ Stars: {stats.stars}</span>
          <span>🍴 Forks: {stats.forks}</span>
          <span>🕒 Last Commit: {new Date(stats.lastCommitDate).toLocaleDateString()}</span>
          <span>📌 Total Commits: {stats.totalCommits}</span>
        </motion.div>
      )}

      <motion.div className="flex gap-2 mb-6 sm:mb-8" variants={fadeIn} custom={2}>
        <span className="inline-flex items-center px-2 py-0.5 rounded-md text-xs sm:text-sm font-medium bg-green-100 text-green-800 dark:bg-green-800 dark:text-green-100">
          Android
        </span>
        <span className="inline-flex items-center px-2 py-0.5 rounded-md text-xs sm:text-sm font-medium bg-blue-100 text-blue-800 dark:bg-blue-800 dark:text-blue-100">
          iOS
        </span>
      </motion.div>

      {[
        'Credential Manager is a Jetpack API that supports multiple sign-in methods, such as username and password, passkeys, and federated sign-in solutions (like Sign-in with Google) in a single API, simplifying integration for developers.',
        'For users, Credential Manager unifies the sign-in interface across authentication methods, making it clearer and easier to sign into apps, regardless of the chosen method.',
        'For iOS, it uses Keychain for storing passkeys and Autofill for managing credentials.',
        'For more information, please refer to the official documentation.',
      ].map((text, idx) => (
        <motion.p
          key={idx}
          className="mb-4 sm:mb-6 text-base sm:text-lg text-gray-800 dark:text-gray-300"
          variants={fadeIn}
          custom={3 + idx}
        >
          {text.includes('Keychain') ? (
            <>
              For iOS, it uses{' '}
              <a
                href="https://developer.apple.com/documentation/security/keychain_services"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 underline"
              >
                Keychain
              </a>{' '}
              and{' '}
              <a
                href="https://developer.apple.com/documentation/uikit/text_input/adding_password_autofill_support_to_your_app"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 underline"
              >
                Autofill
              </a>
              .
            </>
          ) : text.includes('official documentation') ? (
            <>
              For more information, please refer to the{' '}
              <a
                href="https://developer.android.com/jetpack/androidx/releases/credentials"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 underline"
              >
                official documentation
              </a>
              .
            </>
          ) : (
            text
          )}
        </motion.p>
      ))}

      {/* Support section */}
      <motion.div
        className="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4 sm:p-6 mb-6 sm:mb-8"
        variants={fadeIn}
        custom={7}
      >
        <h2 className="text-lg sm:text-xl font-semibold mb-3 sm:mb-4 text-gray-900 dark:text-white">
          Support the Project
        </h2>
        <p className="mb-3 sm:mb-4 text-sm sm:text-base text-gray-700 dark:text-gray-300">
          If you find this library useful and would like to support its development, consider buying me a coffee:
        </p>
        <a
          href="https://www.buymeacoffee.com/smkwinner"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-block bg-yellow-500 hover:bg-yellow-600 text-white font-semibold py-2 px-4 rounded transition-colors text-sm sm:text-base"
        >
          ☕ Buy Me a Coffee
        </a>
      </motion.div>

      {/* Maintainers section */}
      <motion.div
        className="bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4 sm:p-6 mb-6 sm:mb-8"
        variants={fadeIn}
        custom={8}
      >
        <h2 className="text-lg sm:text-xl font-semibold mb-3 sm:mb-4 text-gray-900 dark:text-white">
          Looking for Maintainers
        </h2>
        <p className="text-sm sm:text-base text-gray-700 dark:text-gray-300">
          We are looking for maintainers to help us keep this library up-to-date and implement new features. If you are interested in contributing, please reach out via{' '}
          <a
            href="https://github.com/Djsmk123/flutter_credential_manager_compose"
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 underline"
          >
            GitHub
          </a>{' '}
          or open an issue. Your help would be greatly appreciated!
        </p>
      </motion.div>

      {/* Contributors */}
      <motion.div className="mt-6 sm:mt-8" variants={fadeIn} custom={9}>
        <h2 className="text-lg sm:text-xl font-semibold mb-3 sm:mb-4 text-gray-900 dark:text-white">Contributors</h2>
        <p className="mb-3 sm:mb-4 text-sm sm:text-base text-gray-800 dark:text-gray-300">
          Thanks to all the contributors who have helped make this library better!
        </p>
        <a
          href="https://github.com/Djsmk123/flutter_credential_manager_compose/graphs/contributors"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-block"
        >
          <ImageViewer 
            imageUrls={["https://contrib.rocks/image?repo=Djsmk123/flutter_credential_manager_compose"]} 
            height="200" 
          />
        </a>
      </motion.div>
    </motion.div>
  );
};

export default HomePage;
