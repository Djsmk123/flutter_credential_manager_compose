
import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import DocLayout from "./components/DocLayout";
import HomePage from "./pages/HomePage";
import InstallationPage from "./pages/InstallationPage";
import ConfigurationPage from "./pages/ConfigurationPage";
import UsagePage from "./pages/UsagePage";
import ApiReferencePage from "./pages/ApiReferencePage";
import ExamplesPage from "./pages/ExamplesPage";
import FaqPage from "./pages/FaqPage";
import ContributingPage from "./pages/ContributingPage";
import ChangelogPage from "./pages/ChangelogPage";
import MigrationPage from "./pages/MigrationPage";
import BlogsPage from "./pages/BlogsPage";
import ReactNativePage from "./pages/ReactNativePage";
import NotFound from "./pages/NotFound";
import { ThemeProvider } from "./components/ThemeProvider";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <ThemeProvider defaultTheme="system">
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<DocLayout><HomePage /></DocLayout>} />
            <Route path="/installation" element={<DocLayout><InstallationPage /></DocLayout>} />
            <Route path="/configuration" element={<DocLayout><ConfigurationPage /></DocLayout>} />
            <Route path="/usage" element={<DocLayout><UsagePage /></DocLayout>} />
            <Route path="/api-reference" element={<DocLayout><ApiReferencePage /></DocLayout>} />
            <Route path="/examples" element={<DocLayout><ExamplesPage /></DocLayout>} />
            <Route path="/faq" element={<DocLayout><FaqPage /></DocLayout>} />
            <Route path="/contributing" element={<DocLayout><ContributingPage /></DocLayout>} />
            <Route path="/changelog" element={<DocLayout><ChangelogPage /></DocLayout>} />
            <Route path="/migration" element={<DocLayout><MigrationPage /></DocLayout>} />
            <Route path="/blogs" element={<DocLayout><BlogsPage /></DocLayout>} />
            <Route path="/react-native" element={<DocLayout><ReactNativePage /></DocLayout>} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
      </TooltipProvider>
    </ThemeProvider>
  </QueryClientProvider>
);

export default App;
