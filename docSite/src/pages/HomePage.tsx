import { Link } from 'react-router-dom';
import { ArrowRight, Fingerprint, KeyRound, ShieldCheck, Smartphone, Sparkles } from 'lucide-react';
import { Button } from '@/components/ui/button';
import CodeBlock from '@/components/CodeBlock';

const features = [
  {
    icon: ShieldCheck,
    title: 'Secure Storage',
    description:
      'Leverages platform-specific secure storage mechanisms (Keychain on iOS, Keystore on Android) to keep data safe.',
    accent: 'text-blue-500 bg-blue-500/10',
  },
  {
    icon: Fingerprint,
    title: 'Biometric Auth',
    description: 'Seamlessly integrate biometric authentication (Face ID, Touch ID, Fingerprint) for access control.',
    accent: 'text-violet-500 bg-violet-500/10',
  },
  {
    icon: Smartphone,
    title: 'Cross Platform',
    description: 'One unified Dart API for both iOS and Android, handling platform differences automatically.',
    accent: 'text-emerald-500 bg-emerald-500/10',
  },
  {
    icon: KeyRound,
    title: 'Passkeys Built-In',
    description: 'First-class support for FIDO2 passkeys alongside traditional password credentials.',
    accent: 'text-amber-500 bg-amber-500/10',
  },
];

const HomePage = () => {
  return (
    <div className="flex flex-col gap-16 pb-8">
      {/* Hero Section */}
      <section className="hero-glow relative -mx-4 flex flex-col items-start gap-5 overflow-hidden px-4 pt-8 md:pt-14 lg:pt-24">
        <div className="hero-grid pointer-events-none absolute inset-0 -z-10" />

        <div className="inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/10 px-3 py-1 text-sm font-medium text-primary">
          <Sparkles className="h-3.5 w-3.5" />
          v3.0.1 is now available
        </div>

        <h1 className="text-3xl font-extrabold leading-tight tracking-tighter md:text-5xl lg:leading-[1.1]">
          Secure Credential Management <br className="hidden sm:inline" />
          for <span className="gradient-text">Flutter Applications</span>
        </h1>

        <p className="max-w-[750px] text-lg text-muted-foreground sm:text-xl">
          A powerful, easy-to-use plugin for managing user credentials in Flutter.
          Securely store, retrieve, and manage passwords, passkeys, and Google sign-in.
        </p>

        <div className="flex w-full flex-col gap-3 sm:flex-row sm:items-center md:w-auto">
          <Link to="/installation" className="w-full sm:w-auto">
            <Button size="lg" className="w-full gap-2 shadow-glow sm:w-auto">
              Get Started <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
          <Link to="/examples" className="w-full sm:w-auto">
            <Button variant="outline" size="lg" className="w-full sm:w-auto">
              View Examples
            </Button>
          </Link>
        </div>

        <div className="mt-2 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <ShieldCheck className="h-4 w-4 text-primary" /> Android &amp; iOS
          </span>
          <span className="flex items-center gap-1.5">
            <KeyRound className="h-4 w-4 text-primary" /> Passkeys (FIDO2)
          </span>
          <span className="flex items-center gap-1.5">
            <Fingerprint className="h-4 w-4 text-primary" /> Biometric unlock
          </span>
        </div>
      </section>

      {/* Features Grid */}
      <section className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        {features.map(({ icon: Icon, title, description, accent }) => (
          <div
            key={title}
            className="card-hover relative overflow-hidden rounded-xl border border-border bg-card p-6"
          >
            <div className={`mb-4 flex h-11 w-11 items-center justify-center rounded-lg ${accent}`}>
              <Icon className="h-5 w-5" />
            </div>
            <h3 className="mb-2 text-lg font-bold">{title}</h3>
            <p className="text-sm text-muted-foreground">{description}</p>
          </div>
        ))}
      </section>

      {/* Code Preview Section */}
      <section className="rounded-xl border border-border bg-muted/30 p-6 md:p-8">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <h2 className="text-2xl font-bold">Simple &amp; Intuitive API</h2>
            <p className="mt-2 text-muted-foreground">
              Designed to be easy to integrate into your existing Flutter apps.
            </p>
          </div>
        </div>
        <div className="mt-6">
          <CodeBlock
            language="dart"
            code={`final credentialManager = CredentialManager();
await credentialManager.init(preferImmediatelyAvailableCredentials: true);

// Save a password credential
await credentialManager.savePasswordCredentials(
  PasswordCredential(username: 'user@example.com', password: 'hunter2'),
);

// Retrieve saved credentials
final credentials = await credentialManager.getCredentials();

// Sign out / clear state
await credentialManager.logout();`}
          />
        </div>
      </section>

      {/* CTA Section */}
      <section className="hero-glow relative -mx-4 flex flex-col items-center gap-4 overflow-hidden rounded-2xl border border-border px-4 py-12 text-center md:py-20">
        <h2 className="text-3xl font-extrabold tracking-tighter sm:text-4xl md:text-5xl">
          Ready to secure your app?
        </h2>
        <p className="max-w-[600px] text-muted-foreground md:text-xl">
          Join developers building secure Flutter applications with Credential Manager.
        </p>
        <Link to="/installation">
          <Button size="lg" className="mt-4 gap-2 shadow-glow">
            Start Integration <ArrowRight className="h-4 w-4" />
          </Button>
        </Link>
      </section>
    </div>
  );
};

export default HomePage;
