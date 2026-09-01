import { Box, Drawer, List, ListItemButton, ListItemIcon, ListItemText, Stack, Typography } from '@mui/material'
import { alpha } from '@mui/material/styles'
import { Link as RouterLink, useLocation, useParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import ArrowBackOutlinedIcon from '@mui/icons-material/ArrowBackOutlined'
import GridViewOutlinedIcon from '@mui/icons-material/GridViewOutlined'
import ChecklistOutlinedIcon from '@mui/icons-material/ChecklistOutlined'
import BusinessCenterOutlinedIcon from '@mui/icons-material/BusinessCenterOutlined'
import PeopleAltOutlinedIcon from '@mui/icons-material/PeopleAltOutlined'
import TableRestaurantOutlinedIcon from '@mui/icons-material/TableRestaurantOutlined'
import CalendarTodayOutlinedIcon from '@mui/icons-material/CalendarTodayOutlined'
import { formatDate } from '../../i18n/formatDate'

const DRAWER_WIDTH = 220

const ITEMS = [
  { path: 'overview', labelKey: 'events:navLabel', Icon: GridViewOutlinedIcon },
  { path: 'checklist', labelKey: 'checklist:navLabel', Icon: ChecklistOutlinedIcon },
  { path: 'vendors', labelKey: 'vendors:navLabel', Icon: BusinessCenterOutlinedIcon },
  { path: 'guests', labelKey: 'guests:navLabel', Icon: PeopleAltOutlinedIcon },
  { path: 'seating', labelKey: 'seating:navLabel', Icon: TableRestaurantOutlinedIcon },
]

export default function EventSidebar({ event }) {
  const { eventId } = useParams()
  const location = useLocation()
  const { t, i18n } = useTranslation()

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: DRAWER_WIDTH,
        flexShrink: 0,
        height: '100%',
        '& .MuiDrawer-paper': {
          width: DRAWER_WIDTH,
          boxSizing: 'border-box',
          position: 'relative',
          height: '100%',
        },
      }}
    >
      <List sx={{ px: 1, pt: 1, pb: 0 }}>
        <ListItemButton
          component={RouterLink}
          to="/events"
          sx={{
            borderRadius: 1,
            '& .MuiListItemIcon-root': { minWidth: 36, color: 'text.secondary' },
            '& .MuiListItemText-primary': { color: 'text.secondary', fontSize: 14 },
            '&:hover': {
              bgcolor: 'action.hover',
            },
          }}
        >
          <ListItemIcon>
            <ArrowBackOutlinedIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText primary={t('events:backToEvents')} />
        </ListItemButton>
      </List>

      {event && (
        <Box sx={{ px: 2.5, py: 2, borderBottom: '1px solid', borderColor: 'divider' }}>
          <Typography noWrap sx={{ fontSize: 15, fontWeight: 700 }}>
            {event.name}
          </Typography>
          <Stack direction="row" spacing={0.5} alignItems="center" sx={{ mt: 0.5, color: 'text.secondary' }}>
            <CalendarTodayOutlinedIcon sx={{ fontSize: 13 }} />
            <Typography variant="caption" sx={{ fontSize: 12 }}>
              {event.eventDate ? formatDate(event.eventDate, i18n.language) : t('events:noDateSet')}
            </Typography>
          </Stack>
        </Box>
      )}

      <List sx={{ px: 1, py: 1.5 }}>
        {ITEMS.map((item) => {
          const to = `/events/${eventId}/${item.path}`
          return (
            <ListItemButton
              key={item.path}
              component={RouterLink}
              to={to}
              selected={location.pathname === to}
              sx={{
                borderRadius: 1,
                mb: 0.5,
                '& .MuiListItemIcon-root': { minWidth: 36, color: 'text.secondary' },
                '& .MuiListItemText-primary': { color: 'text.secondary', fontSize: 14 },
                '&.Mui-selected': {
                  bgcolor: (theme) => alpha(theme.palette.primary.main, 0.12),
                  '&:hover': {
                    bgcolor: (theme) => alpha(theme.palette.primary.main, 0.18),
                  },
                  '& .MuiListItemIcon-root': {
                    color: 'primary.main',
                  },
                  '& .MuiListItemText-primary': {
                    color: 'primary.main',
                    fontWeight: 600,
                  },
                },
                '&:hover': {
                  bgcolor: 'action.hover',
                },
              }}
            >
              <ListItemIcon>
                <item.Icon fontSize="small" />
              </ListItemIcon>
              <ListItemText primary={t(item.labelKey)} />
            </ListItemButton>
          )
        })}
      </List>
    </Drawer>
  )
}
