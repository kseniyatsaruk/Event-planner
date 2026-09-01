import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Button,
  Card,
  CardActionArea,
  CardContent,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Stack,
  TextField,
  Typography,
} from '@mui/material'
import EventNoteOutlinedIcon from '@mui/icons-material/EventNoteOutlined'
import CalendarTodayOutlinedIcon from '@mui/icons-material/CalendarTodayOutlined'
import LocationOnOutlinedIcon from '@mui/icons-material/LocationOnOutlined'
import { useTranslation } from 'react-i18next'
import { createEvent, listEvents } from '../api/events'
import { formatDate } from '../i18n/formatDate'
import EmptyState from '../components/common/EmptyState'

export default function EventsListPage() {
  const navigate = useNavigate()
  const { t, i18n } = useTranslation()

  const [events, setEvents] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const [dialogOpen, setDialogOpen] = useState(false)
  const [name, setName] = useState('')
  const [date, setDate] = useState('')
  const [formError, setFormError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    listEvents()
      .then(setEvents)
      .catch((err) => {
        const code = err.response?.data?.error ?? 'unknown_error'
        setError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
      })
      .finally(() => setLoading(false))
  }, [t])

  const openDialog = () => {
    setName('')
    setDate('')
    setFormError('')
    setDialogOpen(true)
  }

  const closeDialog = () => setDialogOpen(false)

  const handleCreate = async (e) => {
    e.preventDefault()
    setFormError('')
    setSubmitting(true)
    try {
      const event = await createEvent({ name, eventDate: date || undefined })
      navigate(`/events/${event.id}`)
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setFormError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <Box sx={{ p: 3 }}>
      <Stack
        direction="row"
        sx={{ justifyContent: 'space-between', alignItems: 'center', mb: 3 }}
      >
        <Typography variant="h4" component="h1">
          {t('events:title')}
        </Typography>
        <Button variant="contained" onClick={openDialog}>
          {t('events:createEvent')}
        </Button>
      </Stack>

      {loading && (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
          <CircularProgress />
        </Box>
      )}

      {!loading && error && (
        <Typography color="error">{error}</Typography>
      )}

      {!loading && !error && events.length === 0 && (
        <EmptyState
          icon={<EventNoteOutlinedIcon fontSize="large" />}
          message={t('events:emptyState')}
          actionLabel={t('events:createEvent')}
          onAction={openDialog}
        />
      )}

      {!loading && !error && events.length > 0 && (
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
            gap: 2.5,
          }}
        >
          {events.map((event) => (
            <Card
              key={event.id}
              sx={{
                transition: 'transform 0.15s ease, box-shadow 0.15s ease',
                '&:hover': {
                  transform: 'translateY(-3px)',
                  boxShadow: '0 4px 12px rgba(16,24,40,0.10), 0 2px 4px rgba(16,24,40,0.06)',
                },
              }}
            >
              <CardActionArea onClick={() => navigate(`/events/${event.id}`)} sx={{ height: '100%' }}>
                <CardContent sx={{ p: 2.5 }}>
                  <Typography variant="h6" gutterBottom noWrap>
                    {event.name}
                  </Typography>
                  <Stack
                    direction="row"
                    spacing={0.75}
                    sx={{ alignItems: 'center', color: 'text.secondary' }}
                  >
                    <CalendarTodayOutlinedIcon sx={{ fontSize: 16 }} />
                    <Typography variant="body2" color="text.secondary">
                      {event.eventDate ? formatDate(event.eventDate, i18n.language) : t('events:noDateSet')}
                    </Typography>
                  </Stack>
                  {event.locationAddress && (
                    <Stack
                      direction="row"
                      spacing={0.75}
                      sx={{ alignItems: 'center', color: 'text.secondary', mt: 0.5 }}
                    >
                      <LocationOnOutlinedIcon sx={{ fontSize: 16 }} />
                      <Typography variant="body2" color="text.secondary" noWrap>
                        {event.locationAddress}
                      </Typography>
                    </Stack>
                  )}
                </CardContent>
              </CardActionArea>
            </Card>
          ))}
        </Box>
      )}

      <Dialog open={dialogOpen} onClose={closeDialog} fullWidth maxWidth="xs">
        <Box component="form" onSubmit={handleCreate}>
          <DialogTitle>{t('events:dialogTitle')}</DialogTitle>
          <DialogContent>
            <Stack spacing={2} sx={{ mt: 1 }}>
              <TextField
                label={t('events:nameLabel')}
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                autoFocus
                fullWidth
              />
              <TextField
                label={t('events:dateLabel')}
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                slotProps={{ inputLabel: { shrink: true } }}
                fullWidth
              />
              {formError && <Typography color="error">{formError}</Typography>}
            </Stack>
          </DialogContent>
          <DialogActions>
            <Button onClick={closeDialog}>{t('common:cancel')}</Button>
            <Button type="submit" variant="contained" disabled={submitting}>
              {t('events:createButton')}
            </Button>
          </DialogActions>
        </Box>
      </Dialog>
    </Box>
  )
}
