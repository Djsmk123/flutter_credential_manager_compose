import { Link } from 'react-router-dom';
import { ArrowRight, Shield, Lock, Smartphone, Zap } from 'lucide-react';
import { Button } from '@/components/ui/button';

const HomePage = () => {
  return (
    <div className="flex flex-col gap-16 pb-8">
      {/* Hero Section */}
      <section className="flex flex-col items-start gap-4 pt-8 md:pt-12 lg:pt-24">
        <div className="inline-flex items-center rounded-lg bg-muted px-3 py-1 text-sm font-medium">
          🎉 <span className="ml-1">v1.0.0 is now available</span>
        </div>
        <h1 className="text-3xl font-bold leading-tight tracking-tighter md:text-5xl lg:leading-[1.1]">
          Secure Credential Management <br className="hidden sm:inline" />
          for Flutter Applications
        </h1>
        <p className="max-w-[750px] text-lg text-muted-foreground sm:text-xl">
          A powerful, easy-to-use plugin for managing user credentials in Flutter. 
          Securely store, retrieve, and manage authentication tokens with biometric support.
        </p>
        <div className="flex w-full items-center gap-4 md:w-auto">
          <Link to="/installation">
            <Button size="lg" className="w-full md:w-auto gap-2">
              Get Started <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
          <Link to="/examples">
            <Button variant="outline" size="lg" className="w-full md:w-auto">
              View Examples
            </Button>
          </Link>
        </div>
      </section>

      {/* Features Grid */}
      <section className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
        <div className="relative overflow-hidden rounded-lg border bg-background p-6 hover:border-primary/50 transition-colors">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 mb-4">
            <Shield className="h-6 w-6 text-primary" />
          </div>
          <h3 className="font-bold text-xl mb-2">Secure Storage</h3>
          <p className="text-muted-foreground">
            Leverages platform-specific secure storage mechanisms (Keychain on iOS, Keystore on Android) to keep data safe.
          </p>
        </div>
        <div className="relative overflow-hidden rounded-lg border bg-background p-6 hover:border-primary/50 transition-colors">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 mb-4">
            <Lock className="h-6 w-6 text-primary" />
          </div>
          <h3 className="font-bold text-xl mb-2">Biometric Auth</h3>
          <p className="text-muted-foreground">
            Seamlessly integrate biometric authentication (Face ID, Touch ID, Fingerprint) for access control.
          </p>
        </div>
        <div className="relative overflow-hidden rounded-lg border bg-background p-6 hover:border-primary/50 transition-colors">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 mb-4">
            <Smartphone className="h-6 w-6 text-primary" />
          </div>
          <h3 className="font-bold text-xl mb-2">Cross Platform</h3>
          <p className="text-muted-foreground">
            Unified API for both iOS and Android, handling platform differences automatically.
          </p>
        </div>
      </section>

      {/* Code Preview Section */}
      <section className="rounded-xl border bg-muted/50 p-8">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <h2 className="text-2xl font-bold">Simple & Intuitive API</h2>
            <p className="text-muted-foreground mt-2">
              Designed to be easy to integrate into your existing Flutter apps.
            </p>
          </div>
        </div>
        <div className="mt-8 relative rounded-lg bg-slate-950 p-4 overflow-hidden">
          <pre className="text-sm text-slate-50 overflow-x-auto">
            <code>{`// Save credentials
await CredentialManager.save(
  key: 'user_token',
  value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);

// Retrieve credentials
final token = await CredentialManager.read(key: 'user_token');

// Delete credentials
await CredentialManager.delete(key: 'user_token');`}</code>
          </pre>
        </div>
      </section>

      {/* CTA Section */}
      <section className="flex flex-col items-center gap-4 py-8 md:py-12 lg:py-24 text-center">
        <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl">
          Ready to secure your app?
        </h2>
        <p className="max-w-[600px] text-muted-foreground md:text-xl">
          Join thousands of developers building secure Flutter applications with Credential Manager.
        </p>
        <Link to="/installation">
          <Button size="lg" className="mt-4">
            Start Integration
          </Button>
        </Link>
      </section>
    </div>
  );
};

export default HomePage;
