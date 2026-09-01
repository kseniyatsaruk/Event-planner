import { Box, Button, ToggleButton, ToggleButtonGroup, Typography } from '@mui/material'
import { Outlet } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { useAuth } from '../../context/AuthContext'
import { COLORS } from '../../styles/designTokens'

export default function AppShell() {
  const { user, logout } = useAuth()
  const { t, i18n } = useTranslation()

  const handleLanguageChange = (_event, lang) => {
    if (lang) {
      i18n.changeLanguage(lang)
    }
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100vh' }}>
      <Box
        sx={{
          flexShrink: 0,
          height: 64,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          px: '28px',
          bgcolor: '#FFFFFF',
          borderBottom: `1px solid ${COLORS.border}`,
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center' }}>
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
              fontSize: 15,
            }}
          >
            П
          </Box>
          <Typography
            sx={{ ml: '10px', fontSize: 17, fontWeight: 700, letterSpacing: '-0.01em', color: COLORS.heading }}
          >
            {t('common:appName')}
          </Typography>
        </Box>

        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <ToggleButtonGroup
            value={i18n.language}
            exclusive
            size="small"
            onChange={handleLanguageChange}
            aria-label={t('common:language')}
          >
            <ToggleButton value="en">EN</ToggleButton>
            <ToggleButton value="ru">RU</ToggleButton>
          </ToggleButtonGroup>
          <Typography variant="body2" sx={{ color: COLORS.muted }}>
            {user?.email}
          </Typography>
          <Button color="primary" onClick={logout}>
            {t('common:logout')}
          </Button>
        </Box>
      </Box>
      <Box sx={{ flex: 1, minHeight: 0 }}>
        <Outlet />
      </Box>
    </Box>
  )
}
