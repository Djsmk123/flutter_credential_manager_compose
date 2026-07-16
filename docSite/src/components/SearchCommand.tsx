import { useEffect, useMemo, useState } from "react";
import { CommandDialog, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList, CommandSeparator } from "@/components/ui/command";
import { useNavigate } from "react-router-dom";
import { docNavGroups } from "@/lib/docs-utils";
import { searchDocs } from "@/lib/search-index";
import { Laptop, Moon, SearchX, Sun } from "lucide-react";
import { useTheme } from "@/components/ThemeProvider";

interface SearchCommandProps {
  open: boolean;
  setOpen: (open: boolean) => void;
}

export function SearchCommand({ open, setOpen }: SearchCommandProps) {
  const navigate = useNavigate();
  const { setTheme } = useTheme();
  const [query, setQuery] = useState("");

  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen(!open);
      }
    };

    document.addEventListener("keydown", down);
    return () => document.removeEventListener("keydown", down);
  }, [open, setOpen]);

  // Reset the query each time the palette is closed, so it opens fresh next time.
  useEffect(() => {
    if (!open) setQuery("");
  }, [open]);

  const runCommand = (command: () => void) => {
    setOpen(false);
    command();
  };

  const results = useMemo(() => searchDocs(query), [query]);
  const isSearching = query.trim().length > 0;

  return (
    <CommandDialog open={open} onOpenChange={setOpen}>
      <CommandInput
        placeholder="Search pages, guides, API names..."
        value={query}
        onValueChange={setQuery}
      />
      <CommandList>
        {isSearching ? (
          results.length === 0 ? (
            <CommandEmpty>
              <div className="flex flex-col items-center gap-2 py-2 text-muted-foreground">
                <SearchX className="h-5 w-5" />
                <span>No results for &quot;{query}&quot;</span>
              </div>
            </CommandEmpty>
          ) : (
            <CommandGroup heading="Results">
              {results.map((result, idx) => {
                const Icon = result.page.icon;
                return (
                  <CommandItem
                    key={`${result.page.path}-${idx}`}
                    value={`${result.page.path}-${idx}`}
                    onSelect={() => runCommand(() => navigate(result.page.path))}
                    className="flex items-start gap-2.5"
                  >
                    <Icon className="mt-0.5 h-4 w-4 shrink-0 text-muted-foreground" />
                    <div className="flex flex-col">
                      <span className="font-medium">{result.page.title}</span>
                      <span className="text-xs text-muted-foreground">
                        {result.match === 'section' ? result.sectionText : result.page.description}
                      </span>
                    </div>
                  </CommandItem>
                );
              })}
            </CommandGroup>
          )
        ) : (
          docNavGroups.map((group) => (
            <CommandGroup key={group.label} heading={group.label}>
              {group.items.map((navItem) => {
                const Icon = navItem.icon;
                return (
                  <CommandItem
                    key={navItem.path}
                    value={navItem.path}
                    onSelect={() => runCommand(() => navigate(navItem.path))}
                    className="flex items-center gap-2.5"
                  >
                    <Icon className="h-4 w-4 text-muted-foreground" />
                    <span>{navItem.title}</span>
                  </CommandItem>
                );
              })}
            </CommandGroup>
          ))
        )}
        <CommandSeparator />
        <CommandGroup heading="Theme">
          <CommandItem onSelect={() => runCommand(() => setTheme("light"))}>
            <Sun className="mr-2 h-4 w-4" />
            <span>Light</span>
          </CommandItem>
          <CommandItem onSelect={() => runCommand(() => setTheme("dark"))}>
            <Moon className="mr-2 h-4 w-4" />
            <span>Dark</span>
          </CommandItem>
          <CommandItem onSelect={() => runCommand(() => setTheme("system"))}>
            <Laptop className="mr-2 h-4 w-4" />
            <span>System</span>
          </CommandItem>
        </CommandGroup>
      </CommandList>
    </CommandDialog>
  );
}
