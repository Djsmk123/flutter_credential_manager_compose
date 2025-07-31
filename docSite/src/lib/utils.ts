import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Utility function to get the correct asset path for GitHub Pages
export function getAssetPath(path: string): string {
  const basePath = import.meta.env.BASE_URL || '/flutter_credential_manager_compose/'
  return `${basePath}${path.startsWith('/') ? path.slice(1) : path}`
}
