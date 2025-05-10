
import { useState, useEffect, useRef } from 'react';
import { CheckIcon, CopyIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface CodeBlockProps {
  code: string;
  language?: string;
}

const CodeBlock = ({ code, language = 'bash' }: CodeBlockProps) => {
  const [copied, setCopied] = useState(false);
  const preRef = useRef<HTMLPreElement>(null);
  
  useEffect(() => {
    // Dynamic import of Prism to avoid SSR issues
    const loadPrism = async () => {
      try {
        const Prism = await import('prismjs');
        await import('prismjs/themes/prism-tomorrow.css');
        
        // Load language components based on the language prop
        if (language === 'typescript' || language === 'ts') {
          await import('prismjs/components/prism-typescript');
        }
        if (language === 'bash' || language === 'sh') {
          await import('prismjs/components/prism-bash');
        }
        if (language === 'dart') {
          await import('prismjs/components/prism-dart');
        }
        if (language === 'json') {
          await import('prismjs/components/prism-json');
        }
        if (language === 'yaml') {
          await import('prismjs/components/prism-yaml');
        }
        
        // Highlight the code
        if (preRef.current) {
          Prism.default.highlightElement(preRef.current);
        }
      } catch (error) {
        console.error('Failed to load Prism:', error);
      }
    };
    
    loadPrism();
  }, [code, language]);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const formattedLanguage = language === 'sh' ? 'bash' : language;

  return (
    <div className="relative group rounded-md overflow-hidden transition-all duration-300 hover:shadow-lg dark:hover:shadow-blue-900/20">
      <div className="flex items-center justify-between bg-gray-800 dark:bg-gray-900 px-4 py-2">
        <span className="text-xs font-mono text-gray-400">{formattedLanguage}</span>
        <button
          onClick={handleCopy}
          className={cn(
            "p-1.5 rounded-md transition-colors",
            copied 
              ? "bg-green-500/20 text-green-400" 
              : "bg-gray-700/50 hover:bg-gray-700 text-gray-400 hover:text-white"
          )}
          aria-label="Copy code"
        >
          {copied ? <CheckIcon size={14} /> : <CopyIcon size={14} />}
        </button>
      </div>
      <pre 
        ref={preRef}
        className={`language-${formattedLanguage} !m-0 !rounded-t-none p-4 bg-gray-900 dark:bg-gray-950 overflow-x-auto`}
      >
        <code className={`language-${formattedLanguage}`}>
          {code}
        </code>
      </pre>
    </div>
  );
};

export default CodeBlock;
