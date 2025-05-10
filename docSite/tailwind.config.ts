
import type { Config } from "tailwindcss";

export default {
	darkMode: ["class"],
	content: [
		"./pages/**/*.{ts,tsx}",
		"./components/**/*.{ts,tsx}",
		"./app/**/*.{ts,tsx}",
		"./src/**/*.{ts,tsx}",
	],
	prefix: "",
	theme: {
		container: {
			center: true,
			padding: '2rem',
			screens: {
				'2xl': '1400px'
			}
		},
		extend: {
			colors: {
				border: 'hsl(var(--border))',
				input: 'hsl(var(--input))',
				ring: 'hsl(var(--ring))',
				background: 'hsl(var(--background))',
				foreground: 'hsl(var(--foreground))',
				primary: {
					DEFAULT: 'hsl(var(--primary))',
					foreground: 'hsl(var(--primary-foreground))'
				},
				secondary: {
					DEFAULT: 'hsl(var(--secondary))',
					foreground: 'hsl(var(--secondary-foreground))'
				},
				destructive: {
					DEFAULT: 'hsl(var(--destructive))',
					foreground: 'hsl(var(--destructive-foreground))'
				},
				muted: {
					DEFAULT: 'hsl(var(--muted))',
					foreground: 'hsl(var(--muted-foreground))'
				},
				accent: {
					DEFAULT: 'hsl(var(--accent))',
					foreground: 'hsl(var(--accent-foreground))'
				},
				popover: {
					DEFAULT: 'hsl(var(--popover))',
					foreground: 'hsl(var(--popover-foreground))'
				},
				card: {
					DEFAULT: 'hsl(var(--card))',
					foreground: 'hsl(var(--card-foreground))'
				},
				sidebar: {
					DEFAULT: 'hsl(var(--sidebar-background))',
					foreground: 'hsl(var(--sidebar-foreground))',
					primary: 'hsl(var(--sidebar-primary))',
					'primary-foreground': 'hsl(var(--sidebar-primary-foreground))',
					accent: 'hsl(var(--sidebar-accent))',
					'accent-foreground': 'hsl(var(--sidebar-accent-foreground))',
					border: 'hsl(var(--sidebar-border))',
					ring: 'hsl(var(--sidebar-ring))'
				},
                doc: {
                    bg: '#f8fafc',
                    sidebar: '#f1f5f9',
                    primary: '#3b82f6',
                    text: '#1e293b',
                    border: '#e2e8f0',
                    code: '#f1f5f9',
                    accent: '#60a5fa'
                }
			},
			borderRadius: {
				lg: 'var(--radius)',
				md: 'calc(var(--radius) - 2px)',
				sm: 'calc(var(--radius) - 4px)'
			},
			keyframes: {
				'accordion-down': {
					from: {
						height: '0'
					},
					to: {
						height: 'var(--radix-accordion-content-height)'
					}
				},
				'accordion-up': {
					from: {
						height: 'var(--radix-accordion-content-height)'
					},
					to: {
						height: '0'
					}
				},
				'fade-in': {
					'0%': {
						opacity: '0',
						transform: 'translateY(10px)'
					},
					'100%': {
						opacity: '1',
						transform: 'translateY(0)'
					}
				},
				'slide-in-right': {
					'0%': {
						transform: 'translateX(100%)',
						opacity: '0'
					},
					'100%': {
						transform: 'translateX(0)',
						opacity: '1'
					}
				},
				'slide-in-left': {
					'0%': {
						transform: 'translateX(-100%)',
						opacity: '0'
					},
					'100%': {
						transform: 'translateX(0)',
						opacity: '1'
					}
				},
				'scale-in': {
					'0%': {
						transform: 'scale(0.95)',
						opacity: '0'
					},
					'100%': {
						transform: 'scale(1)',
						opacity: '1'
					}
				}
			},
			animation: {
				'accordion-down': 'accordion-down 0.2s ease-out',
				'accordion-up': 'accordion-up 0.2s ease-out',
				'fade-in': 'fade-in 0.4s ease-out',
				'slide-in-right': 'slide-in-right 0.4s ease-out',
				'slide-in-left': 'slide-in-left 0.4s ease-out',
				'scale-in': 'scale-in 0.2s ease-out'
			},
            typography: {
                DEFAULT: {
                    css: {
                        maxWidth: '100%',
                        a: {
                            color: '#3b82f6',
                            '&:hover': {
                                color: '#2563eb',
                            },
                        },
                        pre: {
                            backgroundColor: '#f1f5f9',
                            color: '#1e293b',
                            overflow: 'auto',
                            padding: '1rem',
                            borderRadius: '0.375rem',
                            border: '1px solid #e2e8f0',
                        },
                        code: {
                            backgroundColor: '#f1f5f9',
                            color: '#1e293b',
                            padding: '0.25rem 0.5rem',
                            borderRadius: '0.25rem',
                            border: '1px solid #e2e8f0',
                        },
                        'code::before': {
                            content: '""',
                        },
                        'code::after': {
                            content: '""',
                        },
                        h1: {
                            color: '#1e293b',
                            fontWeight: '700',
                        },
                        h2: {
                            color: '#1e293b',
                            fontWeight: '600',
                        },
                        h3: {
                            color: '#1e293b',
                            fontWeight: '600',
                        },
                    },
                },
            },
		}
	},
	plugins: [
		require("tailwindcss-animate"),
		require('@tailwindcss/typography'),
		function({ addUtilities }) {
			const newUtilities = {
				'.scrollbar-thin': {
					'scrollbarWidth': 'thin',
					'&::-webkit-scrollbar': {
						width: '6px',
						height: '6px',
					},
					'&::-webkit-scrollbar-track': {
						background: 'transparent',
					},
					'&::-webkit-scrollbar-thumb': {
						background: '#d1d5db',
						borderRadius: '3px',
					},
					'&::-webkit-scrollbar-thumb:hover': {
						background: '#9ca3af',
					},
				},
			}
			addUtilities(newUtilities, ['responsive', 'hover'])
		},
	],
} satisfies Config;
