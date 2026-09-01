import { Box } from '@mui/material'

// Subtle brand-purple shapes behind the auth card. Positions are tuned for a
// ~1440x900 viewport, keeping the asymmetric top-left/bottom-right placement
// on smaller screens (shapes simply run past the edges, clipped by overflow:
// hidden on the page container) rather than a centered, in-your-face gradient.
export default function AuthDecorativeBackground() {
  return (
    <Box sx={{ position: 'absolute', inset: 0, zIndex: 0, pointerEvents: 'none' }}>
      <Box
        sx={{
          position: 'absolute',
          top: -180,
          left: -160,
          width: 560,
          height: 560,
          borderRadius: '50%',
          background:
            'radial-gradient(circle at 32% 32%, rgba(91,87,242,0.30), rgba(91,87,242,0) 68%)',
        }}
      />
      <Box
        sx={{
          position: 'absolute',
          bottom: -240,
          right: -200,
          width: 720,
          height: 720,
          borderRadius: '50%',
          background:
            'radial-gradient(circle at 62% 42%, rgba(124,111,224,0.26), rgba(124,111,224,0) 68%)',
        }}
      />
      <Box
        sx={{
          position: 'absolute',
          top: 200,
          right: 140,
          width: 210,
          height: 210,
          borderRadius: '42% 58% 65% 35% / 45% 40% 60% 55%',
          background: 'rgba(91,87,242,0.09)',
        }}
      />
      <Box
        sx={{
          position: 'absolute',
          bottom: 160,
          left: 120,
          width: 130,
          height: 130,
          borderRadius: '60% 40% 55% 45% / 40% 55% 45% 60%',
          background: 'rgba(124,111,224,0.10)',
        }}
      />
    </Box>
  )
}
