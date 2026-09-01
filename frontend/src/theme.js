import { darken, lighten } from '@mui/material/styles'

// Indigo/violet accents, shifted a touch darker than the raw Tailwind
// indigo-500 (#6366F1) / violet-500 (#8B5CF6) — those sit right at the
// ~4.2-4.5:1 contrast line against white text, too close to rely on for
// WCAG AA (4.5:1). These shades (indigo-600 / violet-600) clear it with
// room to spare (~6.3:1 and ~5.7:1 respectively).
const PRIMARY_MAIN = '#4F46E5'
const SECONDARY_MAIN = '#7C3AED'

const softShadow = '0 1px 3px rgba(16,24,40,0.06), 0 1px 2px rgba(16,24,40,0.04)'

export const baseThemeOptions = {
  palette: {
    mode: 'light',
    primary: {
      main: PRIMARY_MAIN,
      light: lighten(PRIMARY_MAIN, 0.18),
      dark: darken(PRIMARY_MAIN, 0.18),
      contrastText: '#FFFFFF',
    },
    secondary: {
      main: SECONDARY_MAIN,
      light: lighten(SECONDARY_MAIN, 0.18),
      dark: darken(SECONDARY_MAIN, 0.18),
      contrastText: '#FFFFFF',
    },
    background: {
      default: '#F7F7FB',
      paper: '#FFFFFF',
    },
  },
  typography: {
    fontFamily: "'Inter', system-ui, sans-serif",
    h1: { fontWeight: 700, letterSpacing: '-0.02em' },
    h2: { fontWeight: 700, letterSpacing: '-0.02em' },
    h3: { fontWeight: 700, letterSpacing: '-0.015em' },
    h4: { fontWeight: 600, letterSpacing: '-0.01em' },
    h5: { fontWeight: 600, letterSpacing: '-0.01em' },
    h6: { fontWeight: 600, letterSpacing: '-0.005em' },
  },
  shape: {
    borderRadius: 12,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          // borderRadius already follows theme.shape.borderRadius natively
          textTransform: 'none',
          fontWeight: 600,
          boxShadow: 'none',
        },
        contained: {
          boxShadow: '0 1px 2px rgba(16,24,40,0.06), 0 2px 4px rgba(16,24,40,0.08)',
          '&:hover': {
            boxShadow: '0 1px 3px rgba(16,24,40,0.08), 0 4px 8px rgba(16,24,40,0.10)',
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          // borderRadius already follows theme.shape.borderRadius natively
          boxShadow: softShadow,
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          // borderRadius already follows theme.shape.borderRadius natively
          boxShadow: softShadow,
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: ({ theme }) => ({
          boxShadow: 'none',
          borderBottom: `1px solid ${theme.palette.divider}`,
        }),
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          fontWeight: 500,
        },
      },
    },
  },
}
