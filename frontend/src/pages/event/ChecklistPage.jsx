import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import {
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  MenuItem,
  Select,
  Stack,
  TextField,
  Typography,
} from '@mui/material'
import DeleteIcon from '@mui/icons-material/Delete'
import ChecklistIcon from '@mui/icons-material/Checklist'
import CalendarTodayOutlinedIcon from '@mui/icons-material/CalendarTodayOutlined'
import { useTranslation } from 'react-i18next'
import {
  createChecklistItem,
  deleteChecklistItem,
  listChecklist,
  updateChecklistItem,
} from '../../api/checklist'
import { listVendors } from '../../api/vendors'
import { formatDate } from '../../i18n/formatDate'
import EmptyState from '../../components/common/EmptyState'
import StatusBadge from '../../components/common/StatusBadge'
import { CATEGORY_BADGE_PALETTE } from '../../styles/designTokens'

const STATUS_VALUES = ['todo', 'in_progress', 'done']

const STATUS_COLORS = {
  todo: 'default',
  in_progress: 'warning',
  done: 'success',
}

const EMPTY_FORM = { title: '', description: '', category: '', dueDate: '', vendorId: '' }

export default function ChecklistPage() {
  const { eventId } = useParams()
  const { t, i18n } = useTranslation()

  const [items, setItems] = useState([])
  const [vendors, setVendors] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingItem, setEditingItem] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [formError, setFormError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    setLoading(true)
    Promise.all([listChecklist(eventId), listVendors(eventId)])
      .then(([checklistItems, vendorList]) => {
        setItems(checklistItems)
        setVendors(vendorList)
      })
      .catch((err) => setError(err.response?.data?.error ?? 'unknown_error'))
      .finally(() => setLoading(false))
  }, [eventId])

  const vendorName = (vendorId) => vendors.find((v) => v.id === vendorId)?.name

  const doneCount = items.filter((item) => item.status === 'done').length

  const openAddDialog = () => {
    setEditingItem(null)
    setForm(EMPTY_FORM)
    setFormError('')
    setDialogOpen(true)
  }

  const openEditDialog = (item) => {
    setEditingItem(item)
    setForm({
      title: item.title,
      description: item.description ?? '',
      category: item.category ?? '',
      dueDate: item.dueDate ? item.dueDate.slice(0, 10) : '',
      vendorId: item.vendorId ?? '',
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
      const vendorId = form.vendorId === '' ? undefined : Number(form.vendorId)

      if (editingItem) {
        const updated = await updateChecklistItem(eventId, editingItem.id, {
          title: form.title,
          description: form.description || undefined,
          category: form.category || undefined,
          dueDate: form.dueDate || undefined,
          status: editingItem.status,
          vendorId,
        })
        setItems((prev) => prev.map((i) => (i.id === updated.id ? updated : i)))
      } else {
        const item = await createChecklistItem(eventId, {
          title: form.title,
          description: form.description || undefined,
          category: form.category || undefined,
          dueDate: form.dueDate || undefined,
        })
        setItems((prev) => [...prev, item])
      }
      setDialogOpen(false)
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setFormError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    } finally {
      setSubmitting(false)
    }
  }

  const handleStatusChange = async (item, status) => {
    try {
      const updated = await updateChecklistItem(eventId, item.id, {
        title: item.title,
        description: item.description ?? undefined,
        category: item.category ?? undefined,
        dueDate: item.dueDate ?? undefined,
        status,
        vendorId: item.vendorId ?? undefined,
      })
      setItems((prev) => prev.map((i) => (i.id === updated.id ? updated : i)))
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    }
  }

  const handleDelete = async (item) => {
    if (!window.confirm(t('checklist:confirmDelete', { title: item.title }))) return
    try {
      await deleteChecklistItem(eventId, item.id)
      setItems((prev) => prev.filter((i) => i.id !== item.id))
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

  return (
    <Box>
      <Stack
        direction="row"
        sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 2, mb: 3 }}
      >
        <Typography variant="body2" sx={{ color: 'text.secondary', fontSize: 13.5 }}>
          {t('checklist:summary', { count: items.length, done: doneCount })}
        </Typography>
        <Button variant="contained" onClick={openAddDialog}>
          {t('checklist:addItem')}
        </Button>
      </Stack>

      {error && (
        <Typography color="error" mb={2}>
          {error}
        </Typography>
      )}

      {items.length === 0 ? (
        <EmptyState
          icon={<ChecklistIcon fontSize="large" />}
          message={t('checklist:emptyState')}
          actionLabel={t('checklist:addItem')}
          onAction={openAddDialog}
        />
      ) : (
        <Stack spacing={4}>
          {STATUS_VALUES.map((status) => {
            const statusItems = items.filter((item) => item.status === status)
            return (
              <Box key={status}>
                <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                  {t(`checklist:status.${status}`)}
                </Typography>
                {statusItems.length === 0 ? (
                  <Typography variant="body2" color="text.secondary">
                    {t('checklist:noItems')}
                  </Typography>
                ) : (
                  <Box
                    sx={{
                      display: 'grid',
                      gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
                      gap: '18px',
                    }}
                  >
                    {statusItems.map((item) => (
                      <Card
                        key={item.id}
                        onClick={() => openEditDialog(item)}
                        sx={{
                          cursor: 'pointer',
                          transition: 'transform 0.15s ease, box-shadow 0.15s ease',
                          '&:hover': {
                            transform: 'translateY(-2px)',
                            boxShadow: '0 4px 12px rgba(16,24,40,0.10), 0 2px 4px rgba(16,24,40,0.06)',
                          },
                        }}
                      >
                        <CardContent sx={{ p: 2.5 }}>
                          <Stack direction="row" justifyContent="space-between" alignItems="center">
                            <Stack
                              direction="row"
                              spacing={1}
                              alignItems="center"
                              flexWrap="wrap"
                              onClick={(e) => e.stopPropagation()}
                            >
                              {item.category && (
                                <StatusBadge
                                  label={item.category}
                                  bg={CATEGORY_BADGE_PALETTE.bg}
                                  color={CATEGORY_BADGE_PALETTE.color}
                                />
                              )}
                              <Select
                                size="small"
                                variant="standard"
                                disableUnderline
                                value={item.status}
                                onChange={(e) => handleStatusChange(item, e.target.value)}
                                sx={{
                                  '& .MuiSelect-select': {
                                    display: 'flex',
                                    alignItems: 'center',
                                    py: 0,
                                    pr: '20px !important',
                                  },
                                }}
                              >
                                {STATUS_VALUES.map((s) => (
                                  <MenuItem key={s} value={s}>
                                    <Chip label={t(`checklist:status.${s}`)} color={STATUS_COLORS[s]} size="small" />
                                  </MenuItem>
                                ))}
                              </Select>
                            </Stack>
                            <IconButton
                              size="small"
                              onClick={(e) => {
                                e.stopPropagation()
                                handleDelete(item)
                              }}
                              aria-label={t('checklist:deleteAria')}
                            >
                              <DeleteIcon fontSize="small" />
                            </IconButton>
                          </Stack>

                          <Typography variant="subtitle1" mt={1}>
                            {item.title}
                          </Typography>

                          {item.dueDate && (
                            <Stack direction="row" spacing={0.5} alignItems="center" mt={1} sx={{ color: 'text.secondary' }}>
                              <CalendarTodayOutlinedIcon sx={{ fontSize: 14 }} />
                              <Typography variant="body2" color="text.secondary">
                                {t('checklist:dueLabel', { date: formatDate(item.dueDate, i18n.language) })}
                              </Typography>
                            </Stack>
                          )}

                          {item.vendorId && vendorName(item.vendorId) && (
                            <Chip
                              label={t('checklist:vendorChip', { name: vendorName(item.vendorId) })}
                              size="small"
                              color="secondary"
                              variant="outlined"
                              sx={{ mt: 1 }}
                            />
                          )}
                        </CardContent>
                      </Card>
                    ))}
                  </Box>
                )}
              </Box>
            )
          })}
        </Stack>
      )}

      <Dialog open={dialogOpen} onClose={closeDialog} fullWidth maxWidth="xs">
        <Box component="form" onSubmit={handleSubmit}>
          <DialogTitle>
            {editingItem ? t('checklist:editDialogTitle') : t('checklist:addDialogTitle')}
          </DialogTitle>
          <DialogContent>
            <Stack spacing={2} mt={1}>
              <TextField
                label={t('checklist:titleLabel')}
                value={form.title}
                onChange={setField('title')}
                required
                autoFocus
                fullWidth
              />
              <TextField
                label={t('checklist:descriptionLabel')}
                value={form.description}
                onChange={setField('description')}
                multiline
                minRows={2}
                fullWidth
              />
              <TextField
                label={t('checklist:categoryLabel')}
                value={form.category}
                onChange={setField('category')}
                fullWidth
              />
              <TextField
                label={t('checklist:dueDateLabel')}
                type="date"
                value={form.dueDate}
                onChange={setField('dueDate')}
                slotProps={{ inputLabel: { shrink: true } }}
                fullWidth
              />
              <Select
                value={form.vendorId}
                onChange={setField('vendorId')}
                displayEmpty
                fullWidth
                inputProps={{ 'aria-label': t('checklist:vendorLabel') }}
              >
                <MenuItem value="">{t('checklist:noneOption')}</MenuItem>
                {vendors.map((v) => (
                  <MenuItem key={v.id} value={v.id}>
                    {v.name}
                  </MenuItem>
                ))}
              </Select>
              {formError && <Typography color="error">{formError}</Typography>}
            </Stack>
          </DialogContent>
          <DialogActions>
            <Button onClick={closeDialog}>{t('common:cancel')}</Button>
            <Button type="submit" variant="contained" disabled={submitting}>
              {editingItem ? t('common:save') : t('common:add')}
            </Button>
          </DialogActions>
        </Box>
      </Dialog>
    </Box>
  )
}
