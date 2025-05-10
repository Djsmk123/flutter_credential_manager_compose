
import React from 'react';
import CodeBlock from './CodeBlock';

interface MarkdownRendererProps {
  markdown: string;
}

const MarkdownRenderer = ({ markdown }: MarkdownRendererProps) => {
  // Simple convertor for demo purposes - in a real app would use a proper markdown library
  
  // Convert headers
  let html = markdown
    .replace(/^# (.*$)/gm, '<h1>$1</h1>')
    .replace(/^## (.*$)/gm, '<h2>$1</h2>')
    .replace(/^### (.*$)/gm, '<h3>$1</h3>')
    .replace(/^#### (.*$)/gm, '<h4>$1</h4>')
    .replace(/^##### (.*$)/gm, '<h5>$1</h5>')
    .replace(/^###### (.*$)/gm, '<h6>$1</h6>');
    
  // Convert links
  html = html.replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2">$1</a>');
  
  // Convert bold text
  html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
  
  // Convert italic text
  html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
  
  // Convert code blocks
  const codeBlocks: string[] = [];
  html = html.replace(/```([a-z]*)\n([\s\S]*?)```/g, (match, language, code) => {
    const id = `code-${codeBlocks.length}`;
    codeBlocks.push(`<div id="${id}" data-language="${language}" data-code="${encodeURIComponent(code.trim())}"></div>`);
    return codeBlocks[codeBlocks.length - 1];
  });
  
  // Convert inline code
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
  
  // Convert lists
  html = html.replace(/^\s*\d+\.\s+(.*$)/gm, '<li>$1</li>');
  html = html.replace(/<li>(.*)<\/li>/g, function(match) {
    if (html.indexOf('<ol>') === -1) html = html.replace(match, '<ol>' + match + '</ol>');
    return match;
  });
  
  html = html.replace(/^\s*[\*\-]\s+(.*$)/gm, '<li>$1</li>');
  html = html.replace(/<li>(.*)<\/li>/g, function(match) {
    if (html.indexOf('<ul>') === -1) html = html.replace(match, '<ul>' + match + '</ul>');
    return match;
  });
  
  // Convert paragraphs
  html = html.replace(/^\s*(\n)?(.+)/gm, function(match) {
    const trimmed = match.trim();
    if (/^<\/?(\w+).*>/.test(trimmed)) {
      return match;
    }
    return '<p>' + trimmed + '</p>';
  });

  // Create a div to render the HTML
  const divRef = React.useRef<HTMLDivElement>(null);
  
  // Use effect to handle code blocks after render
  React.useEffect(() => {
    if (!divRef.current) return;
    
    // Find all code block placeholders
    const codeBlockElements = divRef.current.querySelectorAll('div[id^="code-"]');
    codeBlockElements.forEach((element) => {
      const language = element.getAttribute('data-language') || '';
      const code = decodeURIComponent(element.getAttribute('data-code') || '');
      
      // Create React element for code block
      const codeBlockElement = React.createElement(CodeBlock, {
        code,
        language
      });
      
      // Render the code block component
      const container = document.createElement('div');
      element.parentNode?.replaceChild(container, element);
      
      // Use ReactDOM to render the component
      const ReactDOM = require('react-dom');
      ReactDOM.render(codeBlockElement, container);
    });
  }, [html]);
  
  return <div ref={divRef} dangerouslySetInnerHTML={{ __html: html }} className="markdown-content" />;
};

export default MarkdownRenderer;
