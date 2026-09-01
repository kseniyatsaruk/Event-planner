import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import {
  Box,
  Button,
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
  Tooltip,
  Typography,
} from '@mui/material'
import DeleteIcon from '@mui/icons-material/Delete'
import AddIcon from '@mui/icons-material/Add'
import StorefrontOutlinedIcon from '@mui/icons-material/StorefrontOutlined'
import { useTranslation } from 'react-i18next'
import { createVendor, deleteVendor, listVendors, updateVendor } from '../../api/vendors'
import EmptyState from '../../components/common/EmptyState'
import StatusBadge from '../../components/common/StatusBadge'
import { CATEGORY_BADGE_PALETTE, COLORS, VENDOR_STATUS_PALETTE, cardSx, pillButtonSx } from '../../styles/designTokens'

const STATUS_VALUES = ['contacted', 'negotiating', 'confirmed', 'paid', 'cancelled']

const EMPTY_FORM = {
  name: '',
  category: '',
  contactName: '',
  phone: '',
  email: '',
  price: '',
  notes: '',
}

export default function VendorsPage() {
  const { eventId } = useParams()
  const { t } = useTranslation()

  const [vendors, setVendors] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingVendor, setEditingVendor] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [formError, setFormError] = useState('')
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    setLoading(true)
    listVendors(eventId)
      .then(setVendors)
      .catch((err) => setError(err.response?.data?.error ?? 'unknown_error'))
      .finally(() => setLoading(false))
  }, [eventId])

  const openAddDialog = () => {
    setEditingVendor(null)
    setForm(EMPTY_FORM)
    setFormError('')
    setDialogOpen(true)
  }

  const openEditDialog = (vendor) => {
    setEditingVendor(vendor)
    setForm({
      name: vendor.name,
      category: vendor.category ?? '',
      contactName: vendor.contactName ?? '',
      phone: vendor.phone ?? '',
      email: vendor.email ?? '',
      price: vendor.price ?? '',
      notes: vendor.notes ?? '',
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
        category: form.category || undefined,
        contactName: form.contactName || undefined,
        phone: form.phone || undefined,
        email: form.email || undefined,
        price: form.price === '' ? undefined : Number(form.price),
        notes: form.notes || undefined,
      }

      if (editingVendor) {
        const updated = await updateVendor(eventId, editingVendor.id, {
          ...payload,
          status: editingVendor.status,
        })
        setVendors((prev) => prev.map((v) => (v.id === updated.id ? updated : v)))
      } else {
        const created = await createVendor(eventId, payload)
        setVendors((prev) => [...prev, created])
      }
      setDialogOpen(false)
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setFormError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    } finally {
      setSubmitting(false)
    }
  }

  const handleStatusChange = async (vendor, status) => {
    try {
      const updated = await updateVendor(eventId, vendor.id, {
        name: vendor.name,
        category: vendor.category ?? undefined,
        contactName: vendor.contactName ?? undefined,
        phone: vendor.phone ?? undefined,
        email: vendor.email ?? undefined,
        price: vendor.price ?? undefined,
        notes: vendor.notes ?? undefined,
        status,
      })
      setVendors((prev) => prev.map((v) => (v.id === updated.id ? updated : v)))
    } catch (err) {
      const code = err.response?.data?.error ?? 'unknown_error'
      setError(t(`events:errors.${code}`, t('events:errors.unknown_error')))
    }
  }

  const handleDelete = async (vendor) => {
    if (!window.confirm(t('vendors:confirmDelete', { name: vendor.name }))) return
    try {
      await deleteVendor(eventId, vendor.id)
      setVendors((prev) => prev.filter((v) => v.id !== vendor.id))
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
        <Typography variant="body2" sx={{ color: COLORS.muted, fontSize: 13.5 }}>
          {t('vendors:countLabel', { count: vendors.length })}
        </Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={openAddDialog} sx={pillButtonSx}>
          {t('vendors:addVendor')}
        </Button>
      </Stack>

      {error && (
        <Typography color="error" mb={2}>
          {error}
        </Typography>
      )}

      {vendors.length === 0 ? (
        <EmptyState
          icon={<StorefrontOutlinedIcon fontSize="large" />}
          message={t('vendors:emptyState')}
          actionLabel={t('vendors:addVendor')}
          onAction={openAddDialog}
        />
      ) : (
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
            gap: '18px',
          }}
        >
          {vendors.map((vendor) => {
            return (
              <Box
                key={vendor.id}
                onClick={() => openEditDialog(vendor)}
                sx={{
                  ...cardSx,
                  p: '18px',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '11px',
                  cursor: 'pointer',
                  transition: 'transform 0.15s ease, box-shadow 0.15s ease',
                  '&:hover': {
                    transform: 'translateY(-2px)',
                    boxShadow: '0 4px 12px rgba(16,24,40,0.10), 0 2px 4px rgba(16,24,40,0.06)',
                  },
                }}
              >
                <Stack direction="row" justifyContent="space-between" alignItems="flex-start">
                  <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap" sx={{ rowGap: '6px' }}>
                    {vendor.category && (
                      <StatusBadge
                        label={vendor.category}
                        bg={CATEGORY_BADGE_PALETTE.bg}
                        color={CATEGORY_BADGE_PALETTE.color}
                      />
                    )}
                    <Box onClick={(e) => e.stopPropagation()}>
                      <Select
                        size="small"
                        variant="standard"
                        disableUnderline
                        value={vendor.status}
                        onChange={(e) => handleStatusChange(vendor, e.target.value)}
                        renderValue={(value) => (
                          <StatusBadge
                            label={t(`vendors:status.${value}`)}
                            bg={VENDOR_STATUS_PALETTE[value].bg}
                            color={VENDOR_STATUS_PALETTE[value].color}
                          />
                        )}
                        sx={{ '& .MuiSelect-select': { display: 'flex', alignItems: 'center', py: 0, pr: '20px !important' } }}
                      >
                        {STATUS_VALUES.map((s) => (
                          <MenuItem key={s} value={s}>
                            <StatusBadge
                              label={t(`vendors:status.${s}`)}
                              bg={VENDOR_STATUS_PALETTE[s].bg}
                              color={VENDOR_STATUS_PALETTE[s].color}
                            />
                          </MenuItem>
                        ))}
                      </Select>
                    </Box>
                  </Stack>
                  <IconButton
                    size="small"
                    onClick={(e) => {
                      e.stopPropagation()
                      handleDelete(vendor)
                    }}
                    aria-label={t('vendors:deleteAria')}
                    sx={{ mt: '-4px', mr: '-6px' }}
                  >
                    <DeleteIcon fontSize="small" />
                  </IconButton>
                </Stack>

                <Typography sx={{ fontSize: 15, fontWeight: 700 }}>{vendor.name}</Typography>

                {(vendor.contactName || vendor.phone || vendor.email) && (
                  <Typography noWrap sx={{ fontSize: 12.5, color: COLORS.muted }}>
                    {[vendor.contactName, vendor.phone, vendor.email].filter(Boolean).join(' · ')}
                  </Typography>
                )}

                {vendor.price != null && (
                  <Typography sx={{ fontSize: 13.5, fontWeight: 700 }}>${vendor.price}</Typography>
                )}

                {vendor.notes && (
                  <Tooltip title={vendor.notes}>
                    <Typography
                      sx={{
                        fontSize: 12.5,
                        color: COLORS.muted,
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        display: '-webkit-box',
                        WebkitLineClamp: 2,
                        WebkitBoxOrient: 'vertical',
                      }}
                    >
                      {vendor.notes}
                    </Typography>
                  </Tooltip>
                )}
              </Box>
            )
          })}
        </Box>
      )}

      <Dialog open={dialogOpen} onClose={closeDialog} fullWidth maxWidth="xs">
        <Box component="form" onSubmit={handleSubmit}>
          <DialogTitle>
            {editingVendor ? t('vendors:editDialogTitle') : t('vendors:addDialogTitle')}
          </DialogTitle>
          <DialogContent>
            <Stack spacing={2} mt={1}>
              <TextField
                label={t('vendors:nameLabel')}
                value={form.name}
                onChange={setField('name')}
                required
                autoFocus
                fullWidth
              />
              <TextField
                label={t('vendors:categoryLabel')}
                value={form.category}
                onChange={setField('category')}
                fullWidth
              />
              <TextField
                label={t('vendors:contactNameLabel')}
                value={form.contactName}
                onChange={setField('contactName')}
                fullWidth
              />
              <TextField label={t('vendors:phoneLabel')} value={form.phone} onChange={setField('phone')} fullWidth />
              <TextField
                label={t('vendors:emailLabel')}
                type="email"
                value={form.email}
                onChange={setField('email')}
                fullWidth
              />
              <TextField
                label={t('vendors:priceLabel')}
                type="number"
                value={form.price}
                onChange={setField('price')}
                fullWidth
              />
              <TextField
                label={t('vendors:notesLabel')}
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
              {editingVendor ? t('common:save') : t('common:add')}
            </Button>
          </DialogActions>
        </Box>
      </Dialog>
    </Box>
  )
}
