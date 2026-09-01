import { Box } from '@mui/material'

export default function StatusBadge({ label, bg, color, sx }) {
  return (
    <Box
      component="span"
      sx={{
        display: 'inline-flex',
        alignItems: 'center',
        px: '10px',
        py: '3px',
        borderRadius: '999px',
        fontSize: 12,
        fontWeight: 600,
        lineHeight: 1.6,
        whiteSpace: 'nowrap',
        bgcolor: bg,
        color,
        ...sx,
      }}
    >
      {label}
    </Box>
  )
}
