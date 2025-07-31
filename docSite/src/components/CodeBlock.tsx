
import { useState, useEffect, useRef } from 'react';
import { CheckIcon, CopyIcon } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useToast } from '@/hooks/use-toast';

interface CodeBlockProps {
  code: string;
  language?: string;
}

const CodeBlock = ({ code, language = 'bash' }: CodeBlockProps) => {
  const [copied, setCopied] = useState(false);
  const preRef = useRef<HTMLPreElement>(null);
  const { toast } = useToast();
  
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
    try {
      // Check if clipboard API is available
      if (!navigator.clipboard) {
        throw new Error('Clipboard API not available');
      }

      // Try to copy using modern clipboard API
      await navigator.clipboard.writeText(code);
      setCopied(true);
      
      // Show success toast
      toast({
        title: "Code copied!",
        description: `Successfully copied ${formattedLanguage} code to clipboard`,
        duration: 2000,
      });
      
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      // Fallback for iOS and other browsers that don't support clipboard API
      try {
        // Create a temporary textarea element
        const textArea = document.createElement('textarea');
        textArea.value = code;
        textArea.style.position = 'fixed';
        textArea.style.left = '-999999px';
        textArea.style.top = '-999999px';
        document.body.appendChild(textArea);
        
        // Select and copy
        textArea.focus();
        textArea.select();
        const successful = document.execCommand('copy');
        
        // Clean up
        document.body.removeChild(textArea);
        
        if (successful) {
          setCopied(true);
          toast({
            title: "Code copied!",
            description: `Successfully copied ${formattedLanguage} code to clipboard`,
            duration: 2000,
          });
          setTimeout(() => setCopied(false), 2000);
        } else {
          throw new Error('execCommand copy failed');
        }
      } catch (fallbackError) {
        // If both methods fail, show manual copy instructions
        toast({
          title: "Copy failed",
          description: "Please select and copy the code manually (Cmd+C on Mac, Ctrl+C on Windows)",
          variant: "destructive",
          duration: 4000,
        });
        
        // Highlight the code block to help user select it
        if (preRef.current) {
          preRef.current.style.outline = '2px solid #ef4444';
          preRef.current.style.outlineOffset = '2px';
          setTimeout(() => {
            if (preRef.current) {
              preRef.current.style.outline = '';
              preRef.current.style.outlineOffset = '';
            }
          }, 3000);
        }
      }
    }
  };

  const formattedLanguage = language === 'sh' ? 'bash' : language;

  return (
    <div className="relative group rounded-md overflow-hidden transition-all duration-300 hover:shadow-lg dark:hover:shadow-blue-900/20">
      <div className="flex items-center justify-between bg-gray-800 dark:bg-gray-900 px-3 sm:px-4 py-2">
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
        className={`language-${formattedLanguage} !m-0 !rounded-t-none p-3 sm:p-4 bg-gray-900 dark:bg-gray-950 overflow-x-auto text-sm sm:text-base`}
      >
        <code className={`language-${formattedLanguage}`}>
          {code}
        </code>
      </pre>
    </div>
  );
};

export default CodeBlock;
