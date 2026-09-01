import { useState } from 'react'
import { Link as RouterLink, useNavigate } from 'react-router-dom'
import { Box, Button, Card, CardContent, Link, Stack, TextField, Typography } from '@mui/material'
import { useTranslation } from 'react-i18next'
import { useAuth } from '../context/AuthContext'
import AuthDecorativeBackground from '../components/auth/AuthDecorativeBackground'
import AuthTopBar from '../components/auth/AuthTopBar'

export default function RegisterPage() {
  const { register } = useAuth()
  const navigate = useNavigate()
  const { t } = useTranslation()

  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setSubmitting(true)
    try {
      await register(email, password, name)
      navigate('/events')
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setError(t(`auth:errors.${code}`, t('auth:errors.unknown_error')))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100vh',
        bgcolor: 'background.default',
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <AuthDecorativeBackground />
      <AuthTopBar />

      <Box
        sx={{
          flex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          position: 'relative',
          zIndex: 1,
          px: 2,
        }}
      >
        <Card sx={{ width: '100%', maxWidth: 440 }}>
          <CardContent sx={{ p: 4 }}>
            <Typography variant="h5" component="h1" gutterBottom>
              {t('auth:registerTitle')}
            </Typography>
            <Stack component="form" onSubmit={handleSubmit} spacing={2} sx={{ mt: 1 }}>
              <TextField
                label={t('auth:nameLabel')}
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                autoFocus
              />
              <TextField
                label={t('auth:emailLabel')}
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <TextField
                label={t('auth:passwordLabel')}
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              {error && (
                <Typography color="error" variant="body2">
                  {error}
                </Typography>
              )}
              <Button type="submit" variant="contained" size="large" disabled={submitting}>
                {t('auth:registerButton')}
              </Button>
              <Link component={RouterLink} to="/login" variant="body2" sx={{ textAlign: 'center' }}>
                {t('auth:haveAccountPrompt')}
              </Link>
            </Stack>
          </CardContent>
        </Card>
      </Box>
    </Box>
  )
}
