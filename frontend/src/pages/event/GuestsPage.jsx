import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import {
  Alert,
  Box,
  Button,
  Checkbox,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControlLabel,
  IconButton,
  MenuItem,
  Select,
  Stack,
  TextField,
  Tooltip,
  Typography,
} from '@mui/material'
import DeleteIcon from '@mui/icons-material/Delete'
import AddIcon from '@mui/icons-material/Add'
import GroupsOutlinedIcon from '@mui/icons-material/GroupsOutlined'
import { useTranslation } from 'react-i18next'
import { createGuest, deleteGuest, listGuests, updateGuest } from '../../api/guests'
import { listTables } from '../../api/tables'
import EmptyState from '../../components/common/EmptyState'
import StatusBadge from '../../components/common/StatusBadge'
import { COLORS, GUEST_RSVP_PALETTE, cardSx, pillButtonSx } from '../../styles/designTokens'

const STATUS_VALUES = ['pending', 'invited', 'confirmed', 'declined']

const EMPTY_FORM = { name: '', phone: '', email: '', plusOne: false, notes: '' }

export default function GuestsPage() {
  const { eventId } = useParams()
  const { t } = useTranslation()

  const [guests, setGuests] = useState([])
  const [tables, setTables] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingGuest, setEditingGuest] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [formError, setFormError] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [notice, setNotice] = useState('')

  useEffect(() => {
    setLoading(true)
    Promise.all([listGuests(eventId), listTables(eventId)])
      .then(([guestList, tableList]) => {
        setGuests(guestList)
        setTables(tableList)
      })
      .catch((err) => setError(err.response?.data?.error ?? 'unknown_error'))
      .finally(() => setLoading(false))
  }, [eventId])

  const tableLabel = (tableId) => tables.find((t) => t.id === tableId)?.label

  const openAddDialog = () => {
    setEditingGuest(null)
    setForm(EMPTY_FORM)
    setFormError('')
    setDialogOpen(true)
  }

  const openEditDialog = (guest) => {
    setEditingGuest(guest)
    setForm({
      name: guest.name,
      phone: guest.phone ?? '',
      email: guest.email ?? '',
      plusOne: guest.plusOne,
      notes: guest.notes ?? '',
    })
    setFormError('')
    setDialogOpen(true)
  }

  const closeDialog = () => setDialogOpen(false)

  const setField = (field) => (e) => setForm((prev) => ({ ...prev, [field]: e.target.value }))

  const handleSubmit = async (e) => {
    e.preventDefault()
    setFormError('')
    setSubmitting(true)
    try {
      const payload = {
        name: form.name,
        phone: form.phone || undefined,
        email: form.email || undefined,
        plusOne: form.plusOne,
        notes: form.notes || undefined,
      }

      if (editingGuest) {
        const updated = await updateGuest(eventId, editingGuest.id, {
          ...payload,
          rsvpStatus: editingGuest.rsvpStatus,
        })
        setGuests((prev) => prev.map((g) => (g.id === updated.id ? updated : g)))
        // The backend unseats a guest outright if turning plusOne on leaves no
        // free adjacent seat for the +1 — surface that side effect here since
        // nothing else about this page would otherwise reveal it happened.
        if (editingGuest.tableId != null && updated.tableId == null) {
          setNotice(t('guests:plusOneUnseatedNotice', { name: updated.name }))
        } else {
          setNotice('')
        }
      } else {
        const created = await createGuest(eventId, payload)
        setGuests((prev) => [...prev, created])
        setNotice('')
      }
      setDialogOpen(false)
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setFormError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    } finally {
      setSubmitting(false)
    }
  }

  const handleStatusChange = async (guest, rsvpStatus) => {
    try {
      const updated = await updateGuest(eventId, guest.id, {
        name: guest.name,
        phone: guest.phone ?? undefined,
        email: guest.email ?? undefined,
        plusOne: guest.plusOne,
        notes: guest.notes ?? undefined,
        rsvpStatus,
      })
      setGuests((prev) => prev.map((g) => (g.id === updated.id ? updated : g)))
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    }
  }

  const handleDelete = async (guest) => {
    if (!window.confirm(t('guests:confirmDelete', { name: guest.name }))) return
    try {
      await deleteGuest(eventId, guest.id)
      setGuests((prev) => prev.filter((g) => g.id !== guest.id))
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    }
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" py={4}>
        <CircularProgress />
      </Box>
    )
  }

  const countText = t('guests:summaryCount', { count: guests.length })

  return (
    <Box>
      <Stack
        direction="row"
        sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 2, mb: 3 }}
      >
        <Typography variant="body2" sx={{ color: COLORS.muted, fontSize: 13.5 }}>
          {countText}
        </Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={openAddDialog} sx={pillButtonSx}>
          {t('guests:addGuest')}
        </Button>
      </Stack>

      {error && (
        <Typography color="error" mb={2}>
          {error}
        </Typography>
      )}

      {notice && (
        <Alert severity="warning" sx={{ mb: 2 }} onClose={() => setNotice('')}>
          {notice}
        </Alert>
      )}

      {guests.length === 0 ? (
        <EmptyState
          icon={<GroupsOutlinedIcon fontSize="large" />}
          message={t('guests:emptyState')}
          actionLabel={t('guests:addGuest')}
          onAction={openAddDialog}
        />
      ) : (
        <Stack sx={{ gap: '10px', mt: 2 }}>
          {guests.map((guest) => {
            const label = tableLabel(guest.tableId)
            const seated = guest.tableId != null && label != null
            const subline = !seated
              ? t('guests:noSeat')
              : guest.seatNumber != null
                ? t('guests:seatSummaryWithSeat', { table: label, seat: guest.seatNumber })
                : t('guests:seatSummaryNoSeat', { table: label })

            return (
              <Box
                key={guest.id}
                onClick={() => openEditDialog(guest)}
                sx={{
                  ...cardSx,
                  borderRadius: '12px',
                  py: '14px',
                  px: '16px',
                  display: 'flex',
                  flexDirection: 'row',
                  alignItems: 'center',
                  gap: '14px',
                  cursor: 'pointer',
                  transition: 'transform 0.15s ease, box-shadow 0.15s ease',
                  '&:hover': {
                    transform: 'translateY(-1px)',
                    boxShadow: '0 4px 12px rgba(16,24,40,0.10), 0 2px 4px rgba(16,24,40,0.06)',
                  },
                }}
              >
                <Box
                  sx={{
                    width: 36,
                    height: 36,
                    flexShrink: 0,
                    borderRadius: '50%',
                    bgcolor: COLORS.purpleBg,
                    color: COLORS.purple,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 14,
                    fontWeight: 700,
                  }}
                >
                  {guest.name.charAt(0).toUpperCase()}
                </Box>

                <Box sx={{ flex: 1, minWidth: 0 }}>
                  <Stack direction="row" spacing={1} alignItems="center">
                    <Typography noWrap sx={{ fontSize: 14.5, fontWeight: 700 }}>
                      {guest.name}
                    </Typography>
                    {guest.plusOne && (
                      <StatusBadge label={t('guests:tablePlusOne')} bg={COLORS.plusOneBg} color={COLORS.plusOneText} />
                    )}
                  </Stack>
                  {guest.notes ? (
                    <Tooltip title={guest.notes}>
                      <Typography noWrap sx={{ fontSize: 12.5, color: seated ? COLORS.muted : COLORS.mutedLight, mt: '2px' }}>
                        {subline}
                      </Typography>
                    </Tooltip>
                  ) : (
                    <Typography noWrap sx={{ fontSize: 12.5, color: seated ? COLORS.muted : COLORS.mutedLight, mt: '2px' }}>
                      {subline}
                    </Typography>
                  )}
                </Box>

                <Box onClick={(e) => e.stopPropagation()} sx={{ flexShrink: 0 }}>
                  <Select
                    size="small"
                    variant="standard"
                    disableUnderline
                    value={guest.rsvpStatus}
                    onChange={(e) => handleStatusChange(guest, e.target.value)}
                    renderValue={(value) => (
                      <StatusBadge
                        label={t(`guests:rsvp.${value}`)}
                        bg={GUEST_RSVP_PALETTE[value].bg}
                        color={GUEST_RSVP_PALETTE[value].color}
                      />
                    )}
                    sx={{ '& .MuiSelect-select': { display: 'flex', alignItems: 'center', py: 0, pr: '20px !important' } }}
                  >
                    {STATUS_VALUES.map((s) => (
                      <MenuItem key={s} value={s}>
                        <StatusBadge label={t(`guests:rsvp.${s}`)} bg={GUEST_RSVP_PALETTE[s].bg} color={GUEST_RSVP_PALETTE[s].color} />
                      </MenuItem>
                    ))}
                  </Select>
                </Box>

                <IconButton
                  size="small"
                  onClick={(e) => {
                    e.stopPropagation()
                    handleDelete(guest)
                  }}
                  aria-label={t('guests:deleteAria')}
                >
                  <DeleteIcon fontSize="small" />
                </IconButton>
              </Box>
            )
          })}
        </Stack>
      )}

      <Dialog open={dialogOpen} onClose={closeDialog} fullWidth maxWidth="xs">
        <Box component="form" onSubmit={handleSubmit}>
          <DialogTitle>
            {editingGuest ? t('guests:editDialogTitle') : t('guests:addDialogTitle')}
          </DialogTitle>
          <DialogContent>
            <Stack spacing={2} mt={1}>
              <TextField
                label={t('guests:nameLabel')}
                value={form.name}
                onChange={setField('name')}
                required
                autoFocus
                fullWidth
              />
              <TextField label={t('guests:phoneLabel')} value={form.phone} onChange={setField('phone')} fullWidth />
              <TextField
                label={t('guests:emailLabel')}
                type="email"
                value={form.email}
                onChange={setField('email')}
                fullWidth
              />
              <FormControlLabel
                control={
                  <Checkbox
                    checked={form.plusOne}
                    onChange={(e) => setForm((prev) => ({ ...prev, plusOne: e.target.checked }))}
                  />
                }
                label={t('guests:plusOneLabel')}
              />
              <TextField
                label={t('guests:notesLabel')}
                value={form.notes}
                onChange={setField('notes')}
                multiline
                minRows={2}
                fullWidth
              />
              {formError && <Typography color="error">{formError}</Typography>}
            </Stack>
          </DialogContent>
          <DialogActions>
            <Button onClick={closeDialog}>{t('common:cancel')}</Button>
            <Button type="submit" variant="contained" disabled={submitting}>
              {editingGuest ? t('common:save') : t('common:add')}
            </Button>
          </DialogActions>
        </Box>
      </Dialog>
    </Box>
  )
}
