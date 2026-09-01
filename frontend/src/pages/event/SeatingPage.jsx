import { useEffect, useMemo, useState } from 'react'
import { useParams } from 'react-router-dom'
import {
  Box,
  Button,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  MenuItem,
  Select,
  Stack,
  TextField,
  Typography,
} from '@mui/material'
import { useTranslation } from 'react-i18next'
import TableRestaurantOutlinedIcon from '@mui/icons-material/TableRestaurantOutlined'
import SeatingCanvas from '../../components/seating/SeatingCanvas'
import { createTable, deleteTable, listTables, updateTable } from '../../api/tables'
import { assignGuestTable, listGuests } from '../../api/guests'
import EmptyState from '../../components/common/EmptyState'

const EMPTY_FORM = { label: '', capacity: 8, shape: 'round' }

export default function SeatingPage() {
  const { eventId } = useParams()
  const { t } = useTranslation()

  const [tables, setTables] = useState([])
  const [guests, setGuests] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const [dialogOpen, setDialogOpen] = useState(false)
  const [form, setForm] = useState(EMPTY_FORM)
  const [formError, setFormError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    setLoading(true)
    Promise.all([listTables(eventId), listGuests(eventId)])
      .then(([tableList, guestList]) => {
        setTables(tableList)
        setGuests(guestList)
      })
      .catch((err) => setError(err.response?.data?.error ?? 'unknown_error'))
      .finally(() => setLoading(false))
  }, [eventId])

  const guestsByTable = useMemo(() => {
    const map = new Map()
    for (const guest of guests) {
      if (guest.tableId == null) continue
      if (!map.has(guest.tableId)) map.set(guest.tableId, [])
      map.get(guest.tableId).push(guest)
    }
    return map
  }, [guests])

  const unassignedGuests = useMemo(() => guests.filter((g) => g.tableId == null), [guests])

  const assignedCount = guests.length - unassignedGuests.length

  const openAddDialog = () => {
    setForm(EMPTY_FORM)
    setFormError('')
    setDialogOpen(true)
  }

  const closeDialog = () => setDialogOpen(false)

  const handleCreate = async (e) => {
    e.preventDefault()
    setFormError('')
    setSubmitting(true)
    try {
      const table = await createTable(eventId, {
        label: form.label,
        capacity: Number(form.capacity),
        shape: form.shape,
      })
      setTables((prev) => [...prev, table])
      setDialogOpen(false)
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setFormError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    } finally {
      setSubmitting(false)
    }
  }

  const handleTableMove = async (table, { posX, posY }) => {
    const previous = { posX: table.posX, posY: table.posY }
    setTables((prev) => prev.map((t) => (t.id === table.id ? { ...t, posX, posY } : t)))
    try {
      await updateTable(eventId, table.id, {
        label: table.label,
        capacity: table.capacity,
        shape: table.shape,
        posX,
        posY,
        rotation: table.rotation,
      })
    } catch (err) {
      setTables((prev) => prev.map((t) => (t.id === table.id ? { ...t, ...previous } : t)))
      const code = err.response?.data?.error ?? 'unknown_error'
      setError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    }
  }

  const handleDeleteTable = async (table) => {
    if (!window.confirm(t('seating:confirmDelete', { label: table.label }))) {
      return
    }
    try {
      await deleteTable(eventId, table.id)
      setTables((prev) => prev.filter((t) => t.id !== table.id))
      setGuests((prev) => prev.map((g) => (g.tableId === table.id ? { ...g, tableId: null } : g)))
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    }
  }

  const handleGuestAssign = async (guest, tableId, seatNumber = null) => {
    if (guest.tableId === tableId && guest.seatNumber === seatNumber) return
    const previous = { tableId: guest.tableId, seatNumber: guest.seatNumber }
    setGuests((prev) => prev.map((g) => (g.id === guest.id ? { ...g, tableId, seatNumber } : g)))
    try {
      await assignGuestTable(eventId, guest.id, tableId, seatNumber)
    } catch (err) {
      setGuests((prev) => prev.map((g) => (g.id === guest.id ? { ...g, ...previous } : g)))
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

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%', minHeight: 0 }}>
      <Stack
        direction="row"
        sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 2, mb: 3 }}
      >
        <Typography variant="body2" sx={{ color: 'text.secondary', fontSize: 13.5 }}>
          {t('seating:summary', { count: tables.length, assigned: assignedCount, total: guests.length })}
        </Typography>
        <Button variant="contained" onClick={openAddDialog}>
          {t('seating:addTable')}
        </Button>
      </Stack>

      {error && (
        <Typography color="error" mb={2}>
          {error}
        </Typography>
      )}

      {tables.length === 0 ? (
        <EmptyState
          icon={<TableRestaurantOutlinedIcon fontSize="large" />}
          message={t('seating:emptyTables')}
          actionLabel={t('seating:addTable')}
          onAction={openAddDialog}
        />
      ) : (
        <Box sx={{ flex: 1, minHeight: 0 }}>
          <SeatingCanvas
            tables={tables}
            guestsByTable={guestsByTable}
            unassignedGuests={unassignedGuests}
            hasAnyGuests={guests.length > 0}
            onTableMove={handleTableMove}
            onTableDelete={handleDeleteTable}
            onGuestAssign={handleGuestAssign}
          />
        </Box>
      )}

      <Dialog open={dialogOpen} onClose={closeDialog} fullWidth maxWidth="xs">
        <Box component="form" onSubmit={handleCreate}>
          <DialogTitle>{t('seating:dialogTitle')}</DialogTitle>
          <DialogContent>
            <Stack spacing={2} mt={1}>
              <TextField
                label={t('seating:labelLabel')}
                value={form.label}
                onChange={(e) => setForm((prev) => ({ ...prev, label: e.target.value }))}
                required
                autoFocus
                fullWidth
              />
              <TextField
                label={t('seating:capacityLabel')}
                type="number"
                value={form.capacity}
                onChange={(e) => setForm((prev) => ({ ...prev, capacity: e.target.value }))}
                fullWidth
              />
              <Select
                value={form.shape}
                onChange={(e) => setForm((prev) => ({ ...prev, shape: e.target.value }))}
                fullWidth
              >
                <MenuItem value="round">{t('seating:shapeRound')}</MenuItem>
                <MenuItem value="rectangle">{t('seating:shapeRectangle')}</MenuItem>
              </Select>
              {formError && <Typography color="error">{formError}</Typography>}
            </Stack>
          </DialogContent>
          <DialogActions>
            <Button onClick={closeDialog}>{t('common:cancel')}</Button>
            <Button type="submit" variant="contained" disabled={submitting}>
              {t('common:add')}
            </Button>
          </DialogActions>
        </Box>
      </Dialog>
    </Box>
  )
}
