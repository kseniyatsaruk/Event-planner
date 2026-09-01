import { useCallback, useEffect, useState } from 'react'
import { Box } from '@mui/material'
import { Outlet, useParams } from 'react-router-dom'
import EventSidebar from '../../components/layout/EventSidebar'
import { getEvent } from '../../api/events'

export default function EventDetailLayout() {
  const { eventId } = useParams()
  const [event, setEvent] = useState(null)
  const [error, setError] = useState('')

  const reloadEvent = useCallback(() => {
    return getEvent(eventId)
      .then((data) => {
        setEvent(data)
        setError('')
        return data
      })
      .catch((err) => {
        setError(err.response?.data?.error ?? 'unknown_error')
        throw err
      })
  }, [eventId])

  useEffect(() => {
    setEvent(null)
    reloadEvent().catch(() => {})
  }, [reloadEvent])

  return (
    <Box sx={{ display: 'flex', height: '100%' }}>
      <EventSidebar event={event} />
      <Box component="main" sx={{ flexGrow: 1, height: '100%', overflowY: 'auto', p: 3 }}>
        <Outlet context={{ event, setEvent, reloadEvent, eventLoadError: error }} />
      </Box>
    </Box>
  )
}
