import { Box, Typography } from '@mui/material'
import { useTranslation } from 'react-i18next'
import { COLORS } from '../../styles/designTokens'

// Slim top bar for the logged-out (Login/Register) pages — same visual
// language as AppShell's bar, but logo + brand name only, no nav/session UI.
export default function AuthTopBar() {
  const { t } = useTranslation()

  return (
    <Box
      sx={{
        position: 'relative',
        zIndex: 1,
        flexShrink: 0,
        height: 64,
        width: '100%',
        bgcolor: '#FFFFFF',
        borderBottom: `1px solid ${COLORS.border}`,
        display: 'flex',
        alignItems: 'center',
        px: 3,
      }}
    >
      <Box
        sx={{
          width: 32,
          height: 32,
          flexShrink: 0,
          borderRadius: '9px',
          bgcolor: COLORS.purple,
          color: '#FFFFFF',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontWeight: 700,
          fontSize: 16,
        }}
      >
        П
      </Box>
      <Typography sx={{ ml: '10px', fontSize: 17, fontWeight: 700 }}>{t('common:appName')}</Typography>
    </Box>
  )
}
