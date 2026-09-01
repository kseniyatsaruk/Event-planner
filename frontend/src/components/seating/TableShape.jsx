import { useDraggable, useDroppable } from '@dnd-kit/core'
import { Box, IconButton, Typography } from '@mui/material'
import { alpha } from '@mui/material/styles'
import CloseIcon from '@mui/icons-material/Close'
import { useTranslation } from 'react-i18next'
import { nextSeatNumber } from './seatAdjacency'

const ROUND_DIAMETER = 100
const RECT_HEIGHT = 70
const RECT_MIN_WIDTH = 160
const SEAT_WIDTH = 72
const SEAT_HEIGHT = 26
const SEAT_GAP = 10
const SOFT_SHADOW = '0 1px 3px rgba(16,24,40,0.08), 0 1px 2px rgba(16,24,40,0.05)'

// Minimum distance from a round table's center to a seat's center that keeps
// the seat pill's bounding box clear of the table disc at any angle: by the
// triangle inequality, every point of a box lies within half its diagonal of
// the box's own center, so this bound holds regardless of rotation.
function roundSeatRadius(capacity) {
  const halfDiagonal = Math.sqrt((SEAT_WIDTH / 2) ** 2 + (SEAT_HEIGHT / 2) ** 2)
  const minClearance = ROUND_DIAMETER / 2 + halfDiagonal + 8
  if (capacity <= 1) return minClearance
  const arcRadius = (SEAT_WIDTH + SEAT_GAP) / (2 * Math.sin(Math.PI / capacity))
  return Math.max(minClearance, arcRadius)
}

function roundSeatCenter(capacity, seatNumber) {
  const radius = roundSeatRadius(capacity)
  const angle = -Math.PI / 2 + (2 * Math.PI * (seatNumber - 1)) / capacity
  return {
    x: ROUND_DIAMETER / 2 + radius * Math.cos(angle),
    y: ROUND_DIAMETER / 2 + radius * Math.sin(angle),
  }
}

// Builds one entry per seat number (1..capacity): who sits there directly,
// and — for a plus-one guest — which adjacent seat (per nextSeatNumber, the
// same row-aware rule the backend enforces) is reserved for their companion.
function buildSeats(table, assignedGuests) {
  const capacity = table.capacity
  const seats = Array.from({ length: capacity }, (_, idx) => ({
    seatNumber: idx + 1,
    guest: null,
    plusOneOf: null,
  }))

  for (const guest of assignedGuests) {
    const seatNumber = guest.seatNumber
    if (!seatNumber || seatNumber < 1 || seatNumber > capacity) continue
    seats[seatNumber - 1].guest = guest

    if (guest.plusOne) {
      const companionNumber = nextSeatNumber(table.shape, capacity, seatNumber)
      const companion = companionNumber != null ? seats[companionNumber - 1] : null
      if (companion && !companion.guest) {
        companion.plusOneOf = guest
      }
    }
  }

  return seats
}

// A single seat pill: free (droppable), occupied by a guest (draggable, so
// they can be moved to another seat or back to "unassigned"), or reserved as
// a plus-one's companion seat (static — not an independent drop target).
function SeatContent({ table, seat }) {
  const { t } = useTranslation()
  const isFree = !seat.guest && !seat.plusOneOf

  const { setNodeRef: setDropRef, isOver } = useDroppable({
    id: `table-${table.id}-seat-${seat.seatNumber}`,
    data: { table, seatNumber: seat.seatNumber },
    disabled: !isFree,
  })

  const {
    attributes,
    listeners,
    setNodeRef: setDragRef,
    transform,
    isDragging,
  } = useDraggable({
    id: seat.guest ? `guest-${seat.guest.id}` : `seat-${table.id}-${seat.seatNumber}-empty`,
    data: seat.guest ? { guest: seat.guest } : undefined,
    disabled: !seat.guest,
  })

  const setRefs = (node) => {
    setDropRef(node)
    setDragRef(node)
  }

  let label
  if (seat.guest) {
    label = seat.guest.plusOne ? t('seating:guestPlusOne', { name: seat.guest.name }) : seat.guest.name
  } else if (seat.plusOneOf) {
    label = t('seating:plusOneSeatLabel', { name: seat.plusOneOf.name })
  } else {
    label = t('seating:seatFree')
  }

  return (
    <Box
      ref={setRefs}
      {...(seat.guest ? listeners : {})}
      {...(seat.guest ? attributes : {})}
      title={label}
      style={{
        transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined,
      }}
      sx={{
        width: SEAT_WIDTH,
        height: SEAT_HEIGHT,
        flexShrink: 0,
        boxSizing: 'border-box',
        px: 0.75,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: '999px',
        whiteSpace: 'nowrap',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        border: seat.guest ? '1.5px solid' : '1px dashed',
        borderColor: (theme) => {
          if (isOver) return theme.palette.primary.main
          if (seat.guest) return alpha(theme.palette.primary.main, 0.4)
          return theme.palette.divider
        },
        bgcolor: (theme) => {
          if (isOver) return alpha(theme.palette.primary.main, 0.14)
          if (seat.guest) return alpha(theme.palette.primary.main, 0.1)
          if (seat.plusOneOf) return alpha(theme.palette.primary.main, 0.05)
          return 'transparent'
        },
        color: seat.guest ? 'text.primary' : seat.plusOneOf ? 'text.secondary' : 'text.disabled',
        cursor: seat.guest ? 'grab' : 'default',
        userSelect: 'none',
        touchAction: 'none',
        zIndex: isDragging ? 20 : undefined,
        opacity: isDragging ? 0.4 : 1,
        transition: 'background-color 0.15s ease, border-color 0.15s ease',
      }}
    >
      <Typography component="span" variant="caption" fontWeight={600} sx={{ mr: 0.4, flexShrink: 0 }}>
        {seat.seatNumber}
      </Typography>
      <Typography component="span" variant="caption" noWrap>
        {label}
      </Typography>
    </Box>
  )
}

function RoundSeat({ table, seat }) {
  const center = roundSeatCenter(table.capacity, seat.seatNumber)
  return (
    <Box sx={{ position: 'absolute', left: center.x - SEAT_WIDTH / 2, top: center.y - SEAT_HEIGHT / 2 }}>
      <SeatContent table={table} seat={seat} />
    </Box>
  )
}

// The table's own drag handle + label/count + delete button, sized to
// whatever width/height the caller (round or rectangle layout) computes.
// dropRef is attached here (not on the outer wrapper) so the table-level
// drop target's hit region is exactly this box — it must never geometrically
// overlap the seat pills, or a drop that lands on an occupied seat (whose own
// droppable is disabled) would resolve to this one instead and silently wipe
// the guest's seat number.
function TableCore({
  table,
  isRound,
  width,
  height,
  occupiedSeats,
  overCapacity,
  hasGuests,
  isOver,
  dropRef,
  listeners,
  attributes,
  onDelete,
}) {
  const { t } = useTranslation()
  return (
    <Box
      ref={dropRef}
      sx={{
        position: 'relative',
        width,
        height,
        flexShrink: 0,
        borderRadius: isRound ? '50%' : '12px',
        bgcolor: (theme) => {
          if (isOver) return alpha(theme.palette.primary.main, 0.14)
          if (overCapacity) return alpha(theme.palette.error.main, 0.08)
          if (hasGuests) return alpha(theme.palette.primary.main, 0.07)
          return theme.palette.background.paper
        },
        border: '1.5px solid',
        borderColor: (theme) => {
          if (isOver) return theme.palette.primary.main
          if (overCapacity) return theme.palette.error.main
          if (hasGuests) return alpha(theme.palette.primary.main, 0.35)
          return theme.palette.divider
        },
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        boxShadow: SOFT_SHADOW,
        userSelect: 'none',
        transition: 'background-color 0.15s ease, border-color 0.15s ease',
      }}
    >
      <Box
        {...listeners}
        {...attributes}
        sx={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'grab',
          touchAction: 'none',
        }}
      >
        <Typography variant="body2" fontWeight={600} noWrap>
          {table.label}
        </Typography>
        <Typography
          variant="caption"
          color={overCapacity ? 'error' : 'text.secondary'}
          fontWeight={overCapacity ? 700 : 400}
        >
          {occupiedSeats}/{table.capacity}
        </Typography>
      </Box>

      <IconButton
        className="table-delete-btn"
        size="small"
        onPointerDown={(e) => e.stopPropagation()}
        onClick={() => onDelete?.(table)}
        aria-label={t('seating:deleteTableAria')}
        sx={{
          position: 'absolute',
          top: -14,
          right: -14,
          opacity: 0,
          bgcolor: 'background.paper',
          border: '1px solid',
          borderColor: 'divider',
          boxShadow: SOFT_SHADOW,
          transition: 'opacity 0.15s',
          zIndex: 1,
          '&:hover': { bgcolor: 'error.light' },
        }}
      >
        <CloseIcon fontSize="small" />
      </IconButton>
    </Box>
  )
}

export default function TableShape({ table, assignedGuests = [], onDelete }) {
  const {
    attributes,
    listeners,
    setNodeRef: setDragRef,
    transform,
    isDragging,
  } = useDraggable({
    id: `table-${table.id}`,
    data: { table },
  })

  const { setNodeRef: setDropRef, isOver } = useDroppable({
    id: `table-${table.id}`,
    data: { table },
  })

  const isRound = table.shape === 'round'
  const occupiedSeats = assignedGuests.reduce((sum, g) => sum + (g.plusOne ? 2 : 1), 0)
  const hasGuests = assignedGuests.length > 0
  const overCapacity = occupiedSeats > table.capacity
  const seats = buildSeats(table, assignedGuests)
  const translate = transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined

  const coreProps = {
    table,
    occupiedSeats,
    overCapacity,
    hasGuests,
    isOver,
    dropRef: setDropRef,
    listeners,
    attributes,
    onDelete,
  }

  if (isRound) {
    return (
      <Box
        ref={setDragRef}
        style={{
          position: 'absolute',
          left: table.posX,
          top: table.posY,
          transform: translate,
          zIndex: isDragging ? 10 : 1,
          width: ROUND_DIAMETER,
          height: ROUND_DIAMETER,
        }}
        sx={{ '&:hover .table-delete-btn': { opacity: 1 } }}
      >
        <TableCore {...coreProps} isRound width={ROUND_DIAMETER} height={ROUND_DIAMETER} />
        {seats.map((seat) => (
          <RoundSeat key={seat.seatNumber} table={table} seat={seat} />
        ))}
      </Box>
    )
  }

  // Rectangle: the table widens automatically to fit however many seats sit
  // in its longest row (capacity split evenly top/bottom), and each row is a
  // flex row with a real gap so pills can never overlap.
  const topCount = Math.ceil(table.capacity / 2)
  const bottomCount = table.capacity - topCount
  const rowWidth = (count) => (count > 0 ? count * SEAT_WIDTH + (count - 1) * SEAT_GAP : 0)
  const tableWidth = Math.max(RECT_MIN_WIDTH, rowWidth(topCount), rowWidth(bottomCount))
  const topSeats = seats.slice(0, topCount)
  const bottomSeats = seats.slice(topCount)

  return (
    <Box
      ref={setDragRef}
      style={{
        position: 'absolute',
        left: table.posX,
        top: table.posY,
        transform: translate,
        zIndex: isDragging ? 10 : 1,
      }}
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: `${SEAT_GAP}px`,
        '&:hover .table-delete-btn': { opacity: 1 },
      }}
    >
      <Box sx={{ display: 'flex', justifyContent: 'center', gap: `${SEAT_GAP}px`, width: tableWidth }}>
        {topSeats.map((seat) => (
          <SeatContent key={seat.seatNumber} table={table} seat={seat} />
        ))}
      </Box>

      <TableCore {...coreProps} isRound={false} width={tableWidth} height={RECT_HEIGHT} />

      <Box sx={{ display: 'flex', justifyContent: 'center', gap: `${SEAT_GAP}px`, width: tableWidth }}>
        {bottomSeats.map((seat) => (
          <SeatContent key={seat.seatNumber} table={table} seat={seat} />
        ))}
      </Box>
    </Box>
  )
}
