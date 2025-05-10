
import React from 'react';
import { Github } from 'lucide-react';

const Footer = () => {
  return (
    <footer className="bg-white dark:bg-gray-900 shadow-md border-t border-gray-200 dark:border-gray-800 mt-auto">
      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Credential Manager</h3>
            <p className="text-sm text-gray-600 dark:text-gray-300">
              A Flutter plugin for managing credentials, passkeys, and federated sign-in solutions.
            </p>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Links</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <a 
                  href="https://pub.dev/packages/credential_manager" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-blue-600 dark:text-blue-400 hover:underline"
                >
                  pub.dev Package
                </a>
              </li>
              <li>
                <a 
                  href="https://github.com/Djsmk123/flutter_credential_manager_compose" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-blue-600 dark:text-blue-400 hover:underline"
                >
                  GitHub Repository
                </a>
              </li>
              <li>
                <a 
                  href="https://github.com/Djsmk123/flutter_credential_manager_compose/issues" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-blue-600 dark:text-blue-400 hover:underline"
                >
                  Report Issue
                </a>
              </li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Support</h3>
            <p className="text-sm text-gray-600 dark:text-gray-300 mb-4">
              If you find this library useful, consider supporting the project.
            </p>
            <a 
              href="https://www.buymeacoffee.com/smkwinner" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="inline-flex items-center px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-md text-sm font-medium transition-colors"
            >
              Buy Me a Coffee
            </a>
          </div>
        </div>
        
        <div className="flex justify-between items-center mt-8 pt-8 border-t border-gray-200 dark:border-gray-800">
          <p className="text-xs text-gray-500 dark:text-gray-400">
            © {new Date().getFullYear()} Credential Manager. All rights reserved.
          </p>
          <div className="flex space-x-4">
            <a 
              href="https://github.com/Djsmk123" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
              aria-label="GitHub"
            >
              <Github size={20} />
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
