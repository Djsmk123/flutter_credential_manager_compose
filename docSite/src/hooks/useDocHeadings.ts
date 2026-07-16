import { useEffect, useRef, useState } from 'react';
import { useLocation } from 'react-router-dom';

export interface TocItem {
  id: string;
  text: string;
  level: number;
}

const ANCHOR_SVG =
  '<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" ' +
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
  '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>' +
  '<path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>';

// The app uses HashRouter (required for GitHub Pages, which has no server-side rewrite rules),
// so the URL fragment after the FIRST '#' is the router's whole world — it's parsed as
// pathname+search. A bare `#heading-id` therefore gets misread as a route path ("/heading-id")
// and 404s. Deep-linkable headings instead go in a `?heading=` query param inside that fragment,
// e.g. `#/usage?heading=google-sign-in`, which the router parses correctly as pathname "/usage".
export function buildHeadingUrl(routePath: string, routeSearch: string, id: string) {
  const params = new URLSearchParams(routeSearch);
  params.set('heading', id);
  return `${routePath}?${params.toString()}`;
}

// Updates the address bar to a deep-linkable heading URL without disturbing router state
// (replaceState doesn't fire hashchange, so React Router's own location stays put — fine here
// since scrolling is handled manually and the URL only needs to be correct for sharing/refresh).
export function setHeadingHash(routePath: string, routeSearch: string, id: string) {
  const hash = buildHeadingUrl(routePath, routeSearch, id);
  window.history.replaceState(null, '', `${window.location.pathname}#${hash}`);
}

// Scrapes h2/h3 headings inside the doc article for the TOC, assigns stable ids, and
// progressively enhances each heading with a hover-to-copy anchor link (docs sites like
// this render headings as plain JSX per-page, so there's no markdown pipeline to hook into).
export function useDocHeadings() {
  const [headings, setHeadings] = useState<TocItem[]>([]);
  const [activeId, setActiveId] = useState<string>('');
  const location = useLocation();
  const hasScrolledToDeepLink = useRef(false);

  useEffect(() => {
    hasScrolledToDeepLink.current = false;
  }, [location.pathname]);

  useEffect(() => {
    const timer = setTimeout(() => {
      const elements = Array.from(document.querySelectorAll<HTMLElement>('article h2, article h3'));

      const items = elements.map((element) => {
        const text = element.textContent?.trim() || '';

        if (!element.id) {
          const slug = text
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/(^-|-$)+/g, '');
          element.id = slug || `heading-${Math.random().toString(36).slice(2, 11)}`;
        }

        if (!element.dataset.anchorEnhanced) {
          element.dataset.anchorEnhanced = 'true';
          element.classList.add('group/heading', 'relative');

          const anchor = document.createElement('a');
          anchor.setAttribute('aria-label', `Link to ${text || 'section'}`);
          anchor.className =
            'heading-anchor absolute -left-5 top-1/2 hidden -translate-y-1/2 text-muted-foreground ' +
            'hover:text-primary transition-colors no-underline md:group-hover/heading:inline-flex';
          anchor.innerHTML = ANCHOR_SVG;
          anchor.addEventListener('click', (event) => {
            event.preventDefault();
            const shareUrl = `${window.location.origin}${window.location.pathname}#${buildHeadingUrl(
              location.pathname,
              location.search,
              element.id
            )}`;
            navigator.clipboard?.writeText(shareUrl).catch(() => undefined);
            setHeadingHash(location.pathname, location.search, element.id);
            element.scrollIntoView({ behavior: 'smooth', block: 'start' });
          });
          anchor.href = `#${buildHeadingUrl(location.pathname, location.search, element.id)}`;
          element.prepend(anchor);
        }

        return {
          id: element.id,
          text,
          level: Number(element.tagName.substring(1)),
        };
      });

      setHeadings(items);

      // Deep link support: `#/usage?heading=id` scrolls to that heading once on load.
      if (!hasScrolledToDeepLink.current) {
        const targetId = new URLSearchParams(location.search).get('heading');
        const target = targetId ? document.getElementById(targetId) : null;
        if (target) {
          target.scrollIntoView({ block: 'start' });
          setActiveId(target.id);
        }
        hasScrolledToDeepLink.current = true;
      }

      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              setActiveId(entry.target.id);
            }
          });
        },
        { rootMargin: '0px 0px -80% 0px' }
      );

      elements.forEach((element) => observer.observe(element));

      return () => observer.disconnect();
    }, 100);

    return () => clearTimeout(timer);
  }, [location.pathname, location.search]);

  return { headings, activeId, setActiveId };
}
