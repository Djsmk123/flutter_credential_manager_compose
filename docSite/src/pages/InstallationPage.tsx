
import React from 'react';
import CodeBlock from '@/components/CodeBlock';

const InstallationPage = () => {
  return (
    <div className="animate-fade-in">
      <h1 className="text-3xl font-bold mb-6 text-gray-900 dark:text-white">Installation</h1>

      <div className="my-6 space-y-4">
        <p className="mb-4">Add the dependency to your <code className="px-2 py-1 bg-gray-100 dark:bg-gray-800 rounded text-pink-600 dark:text-pink-400">pubspec.yaml</code> file:</p>
        <CodeBlock 
          language="yaml" 
          code={`dependencies:
  credential_manager: <latest_version>`} 
        />
      </div>

      <div className="my-8 space-y-4">
        <p className="mb-4">Alternatively, you can run the following command:</p>
        <CodeBlock 
          language="bash" 
          code="flutter pub add credential_manager" 
        />
      </div>

      <div className="my-8 space-y-4">
        <p className="mb-4">Sync your project:</p>
        <CodeBlock 
          language="bash" 
          code="flutter pub get" 
        />
      </div>
      
      <div className="mt-12 p-4 border-l-4 border-blue-500 bg-blue-50 dark:bg-blue-900/20 dark:border-blue-700 rounded-r-md">
        <h3 className="font-medium text-blue-800 dark:text-blue-300 mb-2">Next Steps</h3>
        <p className="text-blue-700 dark:text-blue-200">After installing the package, check out the <a href="/configuration" className="font-medium underline hover:text-blue-500 transition-colors">Configuration</a> section to properly set up the credential manager.</p>
      </div>
    </div>
  );
};

export default InstallationPage;
