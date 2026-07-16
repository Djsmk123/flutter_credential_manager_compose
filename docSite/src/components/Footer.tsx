import { Github } from 'lucide-react';

const Footer = () => {
  return (
    <footer className="bg-muted/30 border-t border-border mt-auto">
      <div className="container max-w-screen-2xl py-12 md:py-16">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-foreground">Credential Manager</h3>
            <p className="text-sm text-muted-foreground leading-relaxed max-w-xs">
              A Flutter plugin for managing credentials, passkeys, and federated sign-in solutions.
            </p>
          </div>
          
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-foreground">Links</h3>
            <ul className="space-y-3 text-sm">
              <li>
                <a 
                  href="https://pub.dev/packages/credential_manager" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-muted-foreground hover:text-primary transition-colors"
                >
                  pub.dev Package
                </a>
              </li>
              <li>
                <a 
                  href="https://github.com/Djsmk123/flutter_credential_manager_compose" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-muted-foreground hover:text-primary transition-colors"
                >
                  GitHub Repository
                </a>
              </li>
              <li>
                <a 
                  href="https://github.com/Djsmk123/flutter_credential_manager_compose/issues" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-muted-foreground hover:text-primary transition-colors"
                >
                  Report Issue
                </a>
              </li>
            </ul>
          </div>
          
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-foreground">Support</h3>
            <p className="text-sm text-muted-foreground leading-relaxed">
              If you find this library useful, consider supporting the project.
            </p>
            <a 
              href="https://www.buymeacoffee.com/smkwinner" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="inline-flex items-center justify-center px-6 py-2.5 bg-yellow-500 hover:bg-yellow-600 text-white font-medium rounded-lg transition-all hover:scale-105 active:scale-95 shadow-sm"
            >
              Buy Me a Coffee
            </a>
          </div>
        </div>
        
        <div className="flex flex-col md:flex-row justify-between items-center mt-12 pt-8 border-t border-border gap-4">
          <p className="text-sm text-muted-foreground">
            © {new Date().getFullYear()} Credential Manager. All rights reserved.
          </p>
          <div className="flex space-x-6">
            <a 
              href="https://github.com/Djsmk123" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-muted-foreground hover:text-foreground transition-colors"
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
