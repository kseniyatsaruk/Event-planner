import { DndContext } from '@dnd-kit/core'
import { Box } from '@mui/material'
import TableShape from './TableShape'
import UnassignedGuestsPanel from './UnassignedGuestsPanel'
import SeatedGuestsPanel from './SeatedGuestsPanel'

const CANVAS_MIN_WIDTH = 1400
const CANVAS_MIN_HEIGHT = 900
const CANVAS_MARGIN = 300

export default function SeatingCanvas({
  tables,
  guestsByTable,
  unassignedGuests,
  hasAnyGuests,
  onTableMove,
  onTableDelete,
  onGuestAssign,
}) {
  const handleDragEnd = (event) => {
    const { active, over, delta } = event
    const activeData = active.data.current

    if (activeData?.table) {
      if (!delta.x && !delta.y) return
      // Clamp to non-negative: the canvas surface is laid out from (0,0), so
      // a table dragged past its top-left origin would land outside the
      // scrollable region (browsers don't extend scroll toward negative
      // offsets) and become permanently unreachable.
      onTableMove(activeData.table, {
        posX: Math.max(0, activeData.table.posX + delta.x),
        posY: Math.max(0, activeData.table.posY + delta.y),
      })
      return
    }

    if (activeData?.guest) {
      if (!over) return
      const guest = activeData.guest
      if (over.id === 'unassigned-panel') {
        onGuestAssign(guest, null, null)
      } else if (over.data.current?.table && over.data.current?.seatNumber != null) {
        // Only a specific seat's droppable carries a seatNumber. Dropping on
        // the table body itself (no seat resolved — e.g. an occupied seat's
        // own droppable was disabled) is a no-op: it must never silently
        // clear an already-seated guest's seat number.
        onGuestAssign(guest, over.data.current.table.id, over.data.current.seatNumber)
      }
    }
  }

  // The pannable surface always has room beyond the farthest-placed table,
  // so dragging a table toward an edge never runs out of space to keep going.
  const canvasWidth = tables.reduce((max, t) => Math.max(max, t.posX + CANVAS_MARGIN), CANVAS_MIN_WIDTH)
  const canvasHeight = tables.reduce((max, t) => Math.max(max, t.posY + CANVAS_MARGIN), CANVAS_MIN_HEIGHT)

  return (
    <DndContext onDragEnd={handleDragEnd}>
      <Box sx={{ display: 'flex', flexDirection: 'row', gap: 2, alignItems: 'stretch', height: '100%', minHeight: 0 }}>
        <Box
          sx={{
            flex: 1,
            minWidth: 0,
            minHeight: 0,
            border: '1px solid',
            borderColor: 'divider',
            borderRadius: '12px',
            overflow: 'auto',
            position: 'relative',
          }}
        >
          <Box
            sx={{
              position: 'relative',
              width: canvasWidth,
              height: canvasHeight,
              minWidth: '100%',
              minHeight: '100%',
              backgroundImage:
                'linear-gradient(to right, rgba(0,0,0,0.06) 1px, transparent 1px), ' +
                'linear-gradient(to bottom, rgba(0,0,0,0.06) 1px, transparent 1px)',
              backgroundSize: '20px 20px',
            }}
          >
            {tables.map((table) => (
              <TableShape
                key={table.id}
                table={table}
                assignedGuests={guestsByTable.get(table.id) ?? []}
                onDelete={onTableDelete}
              />
            ))}
          </Box>
        </Box>

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, width: 220, flexShrink: 0, overflowY: 'auto' }}>
          <UnassignedGuestsPanel guests={unassignedGuests} hasAnyGuests={hasAnyGuests} />
          <SeatedGuestsPanel tables={tables} guestsByTable={guestsByTable} />
        </Box>
      </Box>
    </DndContext>
  )
}
