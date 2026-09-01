// Shared design tokens for the card/badge look used across Vendors, Guests
// and the event Overview page — white cards, a thin neutral border, a
// consistent purple brand accent, and color-coded status pills.

export const COLORS = {
  border: '#ECECF3',
  purple: '#5B57F2',
  purpleBg: '#F1F0F9',
  plusOneText: '#7C3AED',
  plusOneBg: '#F5F3FF',
  muted: '#8A8CA3',
  mutedLight: '#B7B9C9',
  heading: '#1A1730',
}

export const cardSx = {
  bgcolor: '#FFFFFF',
  border: `1px solid ${COLORS.border}`,
  borderRadius: '14px',
  boxShadow: '0 1px 3px rgba(16,24,40,0.05)',
}

export const pillButtonSx = {
  borderRadius: '999px',
  bgcolor: COLORS.purple,
  '&:hover': { bgcolor: '#4B47E0' },
}

const BADGE_PALETTES = {
  gray: { bg: '#F1F1F6', color: '#6B7280' },
  amber: { bg: '#FEF3E2', color: '#B45309' },
  blue: { bg: '#EAF2FF', color: '#2563EB' },
  green: { bg: '#E7F8F0', color: '#0E9F6E' },
  red: { bg: '#FDECEC', color: '#DC2626' },
}

export const VENDOR_STATUS_PALETTE = {
  contacted: BADGE_PALETTES.gray,
  negotiating: BADGE_PALETTES.amber,
  confirmed: BADGE_PALETTES.blue,
  paid: BADGE_PALETTES.green,
  cancelled: BADGE_PALETTES.red,
}

export const GUEST_RSVP_PALETTE = {
  pending: BADGE_PALETTES.gray,
  invited: BADGE_PALETTES.blue,
  confirmed: BADGE_PALETTES.green,
  declined: BADGE_PALETTES.red,
}

export const CATEGORY_BADGE_PALETTE = { bg: COLORS.purpleBg, color: COLORS.purple }
