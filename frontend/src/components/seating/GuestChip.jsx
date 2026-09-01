import { useDraggable } from '@dnd-kit/core'
import { Chip } from '@mui/material'
import { useTranslation } from 'react-i18next'

export default function GuestChip({ guest }) {
  const { t } = useTranslation()
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: `guest-${guest.id}`,
    data: { guest },
  })

  const style = {
    transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined,
    opacity: isDragging ? 0.4 : 1,
    zIndex: isDragging ? 20 : undefined,
    position: isDragging ? 'relative' : undefined,
    touchAction: 'none',
  }

  return (
    <Chip
      ref={setNodeRef}
      style={style}
      {...listeners}
      {...attributes}
      label={guest.plusOne ? t('seating:guestPlusOne', { name: guest.name }) : guest.name}
      size="small"
      sx={{ cursor: 'grab' }}
    />
  )
}
