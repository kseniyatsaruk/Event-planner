import client from './client'

export async function listEvents() {
  const { data } = await client.get('/events')
  return data
}

export async function createEvent(data) {
  const { data: event } = await client.post('/events', data)
  return event
}

export async function getEvent(id) {
  const { data } = await client.get(`/events/${id}`)
  return data
}

export async function updateEvent(id, data) {
  const { data: event } = await client.put(`/events/${id}`, data)
  return event
}

export async function deleteEvent(id) {
  await client.delete(`/events/${id}`)
}
