import { Box, Paper, Stack, Typography } from '@mui/material'
import EventSeatOutlinedIcon from '@mui/icons-material/EventSeatOutlined'
import { useTranslation } from 'react-i18next'

// Purely derived from the same `tables` + `guestsByTable` state SeatingCanvas
// renders from — no fetch of its own — so it re-renders in lockstep whenever
// a guest is seated, moved, or unassigned.
export default function SeatedGuestsPanel({ tables, guestsByTable }) {
  const { t } = useTranslation()

  const groups = tables
    .map((table) => ({
      table,
      guests: [...(guestsByTable.get(table.id) ?? [])].sort((a, b) => {
        if (a.seatNumber == null) return 1
        if (b.seatNumber == null) return -1
        return a.seatNumber - b.seatNumber
      }),
    }))
    .filter((group) => group.guests.length > 0)

  const totalSeated = groups.reduce((sum, group) => sum + group.guests.length, 0)

  return (
    <Paper
      sx={{
        width: 220,
        flexShrink: 0,
        p: 2,
        display: 'flex',
        flexDirection: 'column',
        border: '1.5px solid',
        borderColor: 'divider',
      }}
    >
      <Typography variant="subtitle2" fontWeight={600} gutterBottom>
        {t('seating:seatedTitle', { count: totalSeated })}
      </Typography>

      {groups.length === 0 ? (
        <Box
          sx={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            textAlign: 'center',
            color: 'text.secondary',
            py: 2,
          }}
        >
          <EventSeatOutlinedIcon sx={{ fontSize: 32, mb: 1, opacity: 0.5 }} />
          <Typography variant="body2" color="text.secondary">
            {t('seating:seatedEmpty')}
          </Typography>
        </Box>
      ) : (
        <Stack spacing={1.5}>
          {groups.map(({ table, guests }) => (
            <Box key={table.id}>
              <Typography
                variant="caption"
                fontWeight={700}
                color="text.secondary"
                sx={{ textTransform: 'uppercase', letterSpacing: 0.4 }}
              >
                {table.label}
              </Typography>
              <Stack spacing={0.25} mt={0.5}>
                {guests.map((guest) => (
                  <Typography key={guest.id} variant="body2" noWrap title={guest.name}>
                    {guest.seatNumber != null
                      ? t('seating:seatLine', {
                          seat: guest.seatNumber,
                          name: guest.plusOne ? t('seating:guestPlusOne', { name: guest.name }) : guest.name,
                        })
                      : t('seating:seatUnspecifiedLine', { name: guest.name })}
                  </Typography>
                ))}
              </Stack>
            </Box>
          ))}
        </Stack>
      )}
    </Paper>
  )
}
