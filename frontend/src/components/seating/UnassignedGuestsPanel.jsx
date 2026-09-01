import { useDroppable } from '@dnd-kit/core'
import { Box, Paper, Stack, Typography } from '@mui/material'
import TaskAltOutlinedIcon from '@mui/icons-material/TaskAltOutlined'
import GroupsOutlinedIcon from '@mui/icons-material/GroupsOutlined'
import { useTranslation } from 'react-i18next'
import GuestChip from './GuestChip'

export default function UnassignedGuestsPanel({ guests, hasAnyGuests }) {
  const { setNodeRef, isOver } = useDroppable({ id: 'unassigned-panel' })
  const { t } = useTranslation()

  return (
    <Paper
      ref={setNodeRef}
      sx={{
        width: 220,
        minHeight: 400,
        p: 2,
        flexShrink: 0,
        display: 'flex',
        flexDirection: 'column',
        bgcolor: isOver ? 'action.hover' : 'background.paper',
        border: '1.5px solid',
        borderColor: isOver ? 'primary.main' : 'divider',
        transition: 'background-color 0.15s ease, border-color 0.15s ease',
      }}
    >
      <Typography variant="subtitle2" fontWeight={600} gutterBottom>
        {t('seating:unassignedTitle', { count: guests.length })}
      </Typography>
      {guests.length > 0 ? (
        <Stack direction="row" flexWrap="wrap" gap={1}>
          {guests.map((guest) => (
            <GuestChip key={guest.id} guest={guest} />
          ))}
        </Stack>
      ) : (
        <Box
          sx={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            textAlign: 'center',
            color: 'text.secondary',
          }}
        >
          {hasAnyGuests ? (
            <>
              <TaskAltOutlinedIcon sx={{ fontSize: 32, mb: 1, color: 'success.main' }} />
              <Typography variant="body2" color="text.secondary">
                {t('seating:everyoneSeated')}
              </Typography>
            </>
          ) : (
            <>
              <GroupsOutlinedIcon sx={{ fontSize: 32, mb: 1, opacity: 0.5 }} />
              <Typography variant="body2" color="text.secondary">
                {t('seating:noGuestsYet')}
              </Typography>
            </>
          )}
        </Box>
      )}
    </Paper>
  )
}
