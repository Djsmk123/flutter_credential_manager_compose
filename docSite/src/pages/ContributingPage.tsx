import CodeBlock from "@/components/CodeBlock";
import React from 'react';

const ContributingPage = () => {
  return (
    <div>
      <h1>Contributing</h1>
      
      <p className="my-4">
        Thank you for considering contributing to Flutter Credential Manager! This document outlines how to contribute to the project and what we expect from contributors.
      </p>
      
      <h2 className="mt-8 mb-4">Ways to Contribute</h2>
      
      <p className="mb-4">There are many ways you can contribute to the project:</p>
      
      <ul className="list-disc pl-6 mb-6">
        <li className="mb-2">Reporting bugs and issues</li>
        <li className="mb-2">Suggesting new features or improvements</li>
        <li className="mb-2">Writing documentation</li>
        <li className="mb-2">Contributing code</li>
        <li className="mb-2">Reviewing pull requests</li>
      </ul>
      
      <h2 className="mt-8 mb-4">Getting Started</h2>
      
      <ol className="list-decimal pl-6 mb-6">
        <li className="mb-2">
          <p><strong>Fork the Repository</strong></p>
          <p>
            Start by <a href="https://github.com/Djsmk123/flutter_credential_manager_compose/fork" target="_blank" rel="noopener noreferrer">forking the repository</a> on GitHub.
          </p>
        </li>
        
        <li className="mb-2">
          <p><strong>Clone Your Fork</strong></p>
          <CodeBlock
            language="sh"
            code={`git clone https://github.com/YOUR_USERNAME/flutter_credential_manager_compose.git
cd flutter_credential_manager_compose`}
          />
        </li>
        
        <li className="mb-2">
          <p><strong>Set Up Remote</strong></p>
          <CodeBlock
            language="sh"
            code={`git remote add upstream https://github.com/Djsmk123/flutter_credential_manager_compose.git`}
          />
        </li>
        
        <li className="mb-2">
          <p><strong>Create a Branch</strong></p>
          <p>Create a new branch for your contributions:</p>
          <CodeBlock
            language="sh"
            code={`git checkout -b feature/your-feature-name`}
          />
        </li>
        
        <li className="mb-2">
          <p><strong>Make Your Changes</strong></p>
          <p>Now you can make your changes to the codebase.</p>
        </li>
        
        <li className="mb-2">
          <p><strong>Test Your Changes</strong></p>
          <p>Make sure your changes don't break existing functionality:</p>
          <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto my-4">
            <CodeBlock
              language="sh"
              code={`flutter test`}
            />
          </pre>
        </li>
        
        <li className="mb-2">
          <p><strong>Commit Your Changes</strong></p>
          <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto my-4">
            <CodeBlock
              language="sh"
              code={`git commit -am "Add feature: your feature description"`}
            />
          </pre>
          <p>Please use clear and descriptive commit messages.</p>
        </li>
        
        <li className="mb-2">
          <p><strong>Push to GitHub</strong></p>
          <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto my-4">
            <CodeBlock
              language="sh"
              code={`git push origin feature/your-feature-name`}
            />
          </pre>
        </li>
        
        <li className="mb-2">
          <p><strong>Create a Pull Request</strong></p>
          <p>Go to the <a href="https://github.com/Djsmk123/flutter_credential_manager_compose/pulls" target="_blank" rel="noopener noreferrer">repository's Pull Requests page</a> and click on "New Pull Request".</p>
        </li>
      </ol>
      
      <h2 className="mt-8 mb-4">Code Style Guidelines</h2>
      
      <ul className="list-disc pl-6 mb-6">
        <li className="mb-2">Follow the <a href="https://dart.dev/guides/language/effective-dart/style" target="_blank" rel="noopener noreferrer">Effective Dart: Style Guide</a></li>
        <li className="mb-2">Run <code>dart format .</code> before committing to ensure consistent formatting</li>
        <li className="mb-2">Use meaningful variable and function names</li>
        <li className="mb-2">Add comments for complex logic</li>
        <li className="mb-2">Write unit tests for new features</li>
      </ul>
      
      <h2 className="mt-8 mb-4">Pull Request Guidelines</h2>
      
      <ul className="list-disc pl-6 mb-6">
        <li className="mb-2">Ensure your PR addresses a specific issue or adds a specific feature</li>
        <li className="mb-2">Include a clear title and description</li>
        <li className="mb-2">Update documentation if needed</li>
        <li className="mb-2">Add tests for new functionality</li>
        <li className="mb-2">Make sure all tests pass</li>
        <li className="mb-2">Keep PRs focused on a single change</li>
      </ul>
      
      <h2 className="mt-8 mb-4">Issue Guidelines</h2>
      
      <p className="mb-4">When creating an issue, please provide:</p>
      
      <ul className="list-disc pl-6 mb-6">
        <li className="mb-2">A clear title and description</li>
        <li className="mb-2">Steps to reproduce (for bugs)</li>
        <li className="mb-2">Expected behavior and actual behavior</li>
        <li className="mb-2">Flutter and Dart version information</li>
        <li className="mb-2">Device/OS information</li>
      </ul>
      
      <h2 className="mt-8 mb-4">Code of Conduct</h2>
      
      <p className="mb-4">
        Please be respectful and inclusive when contributing to this project. We aim to foster an open and welcoming environment.
      </p>
      
      <h2 className="mt-8 mb-4">License</h2>
      
      <p className="mb-4">
        By contributing to this project, you agree that your contributions will be licensed under the project's <a href="https://github.com/Djsmk123/flutter_credential_manager_compose/blob/main/LICENSE" target="_blank" rel="noopener noreferrer">MIT License</a>.
      </p>
      
      <h2 className="mt-8 mb-4">Contact</h2>
      
      <p className="mb-4">
        If you have any questions, feel free to open an issue or contact the project maintainer at <a href="https://smkwinner.vercel.app/" target="_blank" rel="noopener noreferrer">smkwinner.vercel.app</a>.
      </p>
      
      <p className="mt-8 text-center font-medium">
        Thank you for your contributions!
      </p>
    </div>
  );
};

export default ContributingPage;
