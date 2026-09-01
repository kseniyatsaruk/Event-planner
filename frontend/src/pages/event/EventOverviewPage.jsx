import { useEffect, useState } from 'react'
import { useOutletContext, useParams } from 'react-router-dom'
import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Snackbar,
  TextField,
  Typography,
} from '@mui/material'
import { useTranslation } from 'react-i18next'
import { updateEvent } from '../../api/events'
import LocationPicker from '../../components/map/LocationPicker'
import { COLORS, cardSx, pillButtonSx } from '../../styles/designTokens'

function toDateInputValue(iso) {
  return iso ? iso.slice(0, 10) : ''
}

export default function EventOverviewPage() {
  const { eventId } = useParams()
  const { t } = useTranslation()
  const { event, setEvent, eventLoadError } = useOutletContext()

  const [name, setName] = useState('')
  const [date, setDate] = useState('')
  const [description, setDescription] = useState('')
  const [address, setAddress] = useState('')
  const [lat, setLat] = useState(null)
  const [lng, setLng] = useState(null)

  const [saving, setSaving] = useState(false)
  const [saveError, setSaveError] = useState('')
  const [saveSuccess, setSaveSuccess] = useState(false)

  useEffect(() => {
    if (!event) return
    setName(event.name)
    setDate(toDateInputValue(event.eventDate))
    setDescription(event.description ?? '')
    setAddress(event.locationAddress ?? '')
    setLat(event.locationLat)
    setLng(event.locationLng)
  }, [event?.id])

  const handlePick = ({ lat: newLat, lng: newLng }) => {
    setLat(newLat)
    setLng(newLng)
  }

  const handleSave = async (e) => {
    e.preventDefault()
    setSaving(true)
    setSaveError('')
    try {
      const updated = await updateEvent(eventId, {
        name,
        eventDate: date || undefined,
        description: description || undefined,
        locationAddress: address || undefined,
        locationLat: lat,
        locationLng: lng,
      })
      setEvent(updated)
      setSaveSuccess(true)
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setSaveError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    } finally {
      setSaving(false)
    }
  }

  if (eventLoadError) {
    return (
      <Typography color="error">
        {t(`events:errors.${eventLoadError}`, t('events:errors.unknown_error'))}
      </Typography>
    )
  }

  if (!event) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box sx={{ maxWidth: 640, mx: 'auto' }}>
      <Box sx={{ ...cardSx, p: '24px' }}>
        <Box
          component="form"
          onSubmit={handleSave}
          sx={{ display: 'flex', flexDirection: 'column', gap: '18px' }}
        >
          <TextField label={t('events:nameLabel')} value={name} onChange={(e) => setName(e.target.value)} required />
          <TextField
            label={t('events:dateLabel')}
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            slotProps={{ inputLabel: { shrink: true } }}
          />
          <TextField
            label={t('events:descriptionLabel')}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            multiline
            minRows={3}
          />
          <TextField label={t('events:addressLabel')} value={address} onChange={(e) => setAddress(e.target.value)} />

          <Typography sx={{ fontSize: 14, fontWeight: 700, color: COLORS.purple }}>
            {t('events:locationLabel')}
          </Typography>
          <LocationPicker lat={lat} lng={lng} onChange={handlePick} />
          {lat != null && lng != null && (
            <Typography variant="body2" sx={{ color: COLORS.muted }}>
              {lat.toFixed(5)}, {lng.toFixed(5)}
            </Typography>
          )}

          {saveError && <Typography color="error">{saveError}</Typography>}

          <Button type="submit" variant="contained" disabled={saving} sx={{ ...pillButtonSx, alignSelf: 'flex-start', px: 3 }}>
            {t('common:save')}
          </Button>
        </Box>
      </Box>

      <Snackbar open={saveSuccess} autoHideDuration={3000} onClose={() => setSaveSuccess(false)}>
        <Alert onClose={() => setSaveSuccess(false)} severity="success" sx={{ width: '100%' }}>
          {t('events:savedMessage')}
        </Alert>
      </Snackbar>
    </Box>
  )
}
